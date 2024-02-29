const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d12 = @import("win32/d3d12.zig");
const d3d12d = @import("win32/d3d12sdklayers.zig");
const dxgi = @import("win32/dxgi.zig");

const d3d12_debug = @import("build_options").d3d12_debug or @import("build_options").d3d12_debug_gpu;
const d3d12_debug_gpu = @import("build_options").d3d12_debug_gpu;
const d3d12_vsync = @import("build_options").d3d12_vsync;

const log = std.log.scoped(.gpu_context);

const GpuContext = @This();

pub const IDevice = d3d12.IDevice11;
pub const IGraphicsCommandList = d3d12.IGraphicsCommandList9;

pub const max_buffered_frames = 2;

pub const display_target_num_samples = if (msaa_target_num_samples > 1) msaa_target_num_samples else 1;
pub const display_target_format = if (msaa_target_num_samples > 1)
    msaa_target_format
else
    swap_chain_target_view_format;

const max_rtv_descriptors = 1024;
const max_shader_descriptors = 32 * 1024;

const swap_chain_target_format: dxgi.FORMAT = .R8G8B8A8_UNORM;
const swap_chain_target_view_format: dxgi.FORMAT = .R8G8B8A8_UNORM_SRGB;

const msaa_target_format: dxgi.FORMAT = .R8G8B8A8_UNORM_SRGB;
const msaa_target_num_samples = @import("build_options").d3d12_msaa;

window: w32.HWND,
window_width: u32,
window_height: u32,

dxgi_factory: *dxgi.IFactory6,
adapter: *dxgi.IAdapter3,
device: *IDevice,

command_queue: *d3d12.ICommandQueue,
command_allocators: [max_buffered_frames]*d3d12.ICommandAllocator,
command_list: *IGraphicsCommandList,

swap_chain: *dxgi.ISwapChain3,
swap_chain_targets: [max_buffered_frames]*d3d12.IResource,
swap_chain_flags: dxgi.SWAP_CHAIN_FLAG,
swap_chain_present_interval: w32.UINT = if (d3d12_vsync) 1 else 0,

rtv_dheap: *d3d12.IDescriptorHeap,
rtv_dheap_start: d3d12.CPU_DESCRIPTOR_HANDLE,
rtv_dheap_descriptor_size: u32,

shader_dheap: *d3d12.IDescriptorHeap,
shader_dheap_start_cpu: d3d12.CPU_DESCRIPTOR_HANDLE,
shader_dheap_start_gpu: d3d12.GPU_DESCRIPTOR_HANDLE,
shader_dheap_descriptor_size: u32,

frame_fence: *d3d12.IFence,
frame_fence_event: w32.HANDLE,
frame_fence_counter: u64 = 0,
frame_index: u32,

msaa_target: if (msaa_target_num_samples > 1) *d3d12.IResource else void,

debug: if (d3d12_debug) *d3d12d.IDebug5 else void,
debug_device: if (d3d12_debug) *d3d12.IDebugDevice else void,
debug_info_queue: if (d3d12_debug) *d3d12d.IInfoQueue else void,
debug_command_queue: if (d3d12_debug) *d3d12d.IDebugCommandQueue1 else void,
debug_command_list: if (d3d12_debug) *d3d12d.IDebugCommandList3 else void,

pub fn display_target_descriptor(gc: GpuContext) d3d12.CPU_DESCRIPTOR_HANDLE {
    const d = if (msaa_target_num_samples > 1)
        .{ .ptr = gc.rtv_dheap_start.ptr + max_buffered_frames * gc.rtv_dheap_descriptor_size }
    else
        .{ .ptr = gc.rtv_dheap_start.ptr + gc.frame_index * gc.rtv_dheap_descriptor_size };
    return d;
}

pub fn begin_command_list(gc: *GpuContext) void {
    const command_allocator = gc.command_allocators[gc.frame_index];

    vhr(command_allocator.Reset());
    vhr(gc.command_list.Reset(command_allocator, null));

    gc.command_list.SetDescriptorHeaps(1, &[_]*d3d12.IDescriptorHeap{gc.shader_dheap});

    gc.command_list.RSSetViewports(1, &[_]d3d12.VIEWPORT{.{
        .TopLeftX = 0.0,
        .TopLeftY = 0.0,
        .Width = @floatFromInt(gc.window_width),
        .Height = @floatFromInt(gc.window_height),
        .MinDepth = 0.0,
        .MaxDepth = 1.0,
    }});
    gc.command_list.RSSetScissorRects(1, &[_]d3d12.RECT{.{
        .left = 0,
        .top = 0,
        .right = @intCast(gc.window_width),
        .bottom = @intCast(gc.window_height),
    }});

    if (msaa_target_num_samples <= 1) {
        gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
            .Type = .TEXTURE,
            .NumBarriers = 1,
            .u = .{
                .pTextureBarriers = &[_]d3d12.TEXTURE_BARRIER{
                    .{
                        .SyncBefore = .{},
                        .SyncAfter = .{ .RENDER_TARGET = true },
                        .AccessBefore = .{ .NO_ACCESS = true },
                        .AccessAfter = .{ .RENDER_TARGET = true },
                        .LayoutBefore = .PRESENT,
                        .LayoutAfter = .RENDER_TARGET,
                        .pResource = gc.swap_chain_targets[gc.frame_index],
                    },
                },
            },
        }});
    }
}

pub fn end_command_list(gc: *GpuContext) void {
    if (msaa_target_num_samples > 1) {
        gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
            .Type = .TEXTURE,
            .NumBarriers = 2,
            .u = .{
                .pTextureBarriers = &[_]d3d12.TEXTURE_BARRIER{
                    .{
                        .SyncBefore = .{ .RENDER_TARGET = true },
                        .SyncAfter = .{ .RESOLVE = true },
                        .AccessBefore = .{ .RENDER_TARGET = true },
                        .AccessAfter = .{ .RESOLVE_SOURCE = true },
                        .LayoutBefore = .RENDER_TARGET,
                        .LayoutAfter = .RESOLVE_SOURCE,
                        .pResource = gc.msaa_target,
                    },
                    .{
                        .SyncBefore = .{},
                        .SyncAfter = .{ .RESOLVE = true },
                        .AccessBefore = .{ .NO_ACCESS = true },
                        .AccessAfter = .{ .RESOLVE_DEST = true },
                        .LayoutBefore = .PRESENT,
                        .LayoutAfter = .RESOLVE_DEST,
                        .pResource = gc.swap_chain_targets[gc.frame_index],
                    },
                },
            },
        }});
        gc.command_list.ResolveSubresource(
            gc.swap_chain_targets[gc.frame_index],
            0,
            gc.msaa_target,
            0,
            swap_chain_target_format,
        );
        gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
            .Type = .TEXTURE,
            .NumBarriers = 2,
            .u = .{
                .pTextureBarriers = &[_]d3d12.TEXTURE_BARRIER{
                    .{
                        .SyncBefore = .{ .RESOLVE = true },
                        .SyncAfter = .{},
                        .AccessBefore = .{ .RESOLVE_SOURCE = true },
                        .AccessAfter = .{ .NO_ACCESS = true },
                        .LayoutBefore = .RESOLVE_SOURCE,
                        .LayoutAfter = .RENDER_TARGET,
                        .pResource = gc.msaa_target,
                    },
                    .{
                        .SyncBefore = .{ .RESOLVE = true },
                        .SyncAfter = .{},
                        .AccessBefore = .{ .RESOLVE_DEST = true },
                        .AccessAfter = .{ .NO_ACCESS = true },
                        .LayoutBefore = .RESOLVE_DEST,
                        .LayoutAfter = .PRESENT,
                        .pResource = gc.swap_chain_targets[gc.frame_index],
                    },
                },
            },
        }});
    } else {
        gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
            .Type = .TEXTURE,
            .NumBarriers = 1,
            .u = .{
                .pTextureBarriers = &[_]d3d12.TEXTURE_BARRIER{
                    .{
                        .SyncBefore = .{ .RENDER_TARGET = true },
                        .SyncAfter = .{},
                        .AccessBefore = .{ .RENDER_TARGET = true },
                        .AccessAfter = .{ .NO_ACCESS = true },
                        .LayoutBefore = .RENDER_TARGET,
                        .LayoutAfter = .PRESENT,
                        .pResource = gc.swap_chain_targets[gc.frame_index],
                    },
                },
            },
        }});
    }
    vhr(gc.command_list.Close());
}

pub fn present_frame(gc: *GpuContext) void {
    gc.frame_fence_counter += 1;

    const present_flags: dxgi.PRESENT_FLAG =
        if (gc.swap_chain_present_interval == 0 and gc.swap_chain_flags.ALLOW_TEARING)
        .{ .ALLOW_TEARING = true }
    else
        .{};

    vhr(gc.swap_chain.Present(gc.swap_chain_present_interval, present_flags));
    vhr(gc.command_queue.Signal(gc.frame_fence, gc.frame_fence_counter));

    const gpu_frame_counter = gc.frame_fence.GetCompletedValue();
    if ((gc.frame_fence_counter - gpu_frame_counter) >= max_buffered_frames) {
        vhr(gc.frame_fence.SetEventOnCompletion(gpu_frame_counter + 1, gc.frame_fence_event));
        _ = w32.WaitForSingleObject(gc.frame_fence_event, w32.INFINITE);
    }

    gc.frame_index = gc.swap_chain.GetCurrentBackBufferIndex();
}

pub fn finish_gpu_commands(gc: *GpuContext) void {
    gc.frame_fence_counter += 1;

    vhr(gc.command_queue.Signal(gc.frame_fence, gc.frame_fence_counter));
    vhr(gc.frame_fence.SetEventOnCompletion(gc.frame_fence_counter, gc.frame_fence_event));

    _ = w32.WaitForSingleObject(gc.frame_fence_event, w32.INFINITE);
}

pub fn handle_window_resize(gc: *GpuContext) enum {
    minimized,
    resized,
    unchanged,
} {
    const current_width: u32, const current_height: u32 = blk: {
        var rect: w32.RECT = undefined;
        _ = w32.GetClientRect(gc.window, &rect);
        break :blk .{ @intCast(rect.right - rect.left), @intCast(rect.bottom - rect.top) };
    };

    if (current_width == 0 and current_height == 0) {
        if (gc.window_width > 0 and gc.window_height > 0) {
            gc.window_width = 0;
            gc.window_height = 0;
            log.info("Window has been minimized.", .{});
        }
        return .minimized;
    }

    if (current_width != gc.window_width or current_height != gc.window_height) {
        log.info("Window resized to {d}x{d}", .{ current_width, current_height });

        gc.finish_gpu_commands();

        for (gc.swap_chain_targets) |texture| _ = texture.Release();

        vhr(gc.swap_chain.ResizeBuffers(0, 0, 0, .UNKNOWN, gc.swap_chain_flags));

        for (&gc.swap_chain_targets, 0..) |*texture, i| {
            vhr(gc.swap_chain.GetBuffer(@intCast(i), &d3d12.IResource.IID, @ptrCast(&texture.*)));
        }
        for (gc.swap_chain_targets, 0..) |texture, i| {
            gc.device.CreateRenderTargetView(
                texture,
                &.{
                    .Format = display_target_format,
                    .ViewDimension = .TEXTURE2D,
                    .u = .{ .Texture2D = .{ .MipSlice = 0, .PlaneSlice = 0 } },
                },
                .{ .ptr = gc.rtv_dheap_start.ptr + i * gc.rtv_dheap_descriptor_size },
            );
        }

        gc.window_width = current_width;
        gc.window_height = current_height;
        gc.frame_index = gc.swap_chain.GetCurrentBackBufferIndex();

        if (msaa_target_num_samples > 1) {
            _ = gc.msaa_target.Release();
            gc.msaa_target = create_msaa_srgb_target(gc.device, gc.window_width, gc.window_height);
            gc.device.CreateRenderTargetView(
                gc.msaa_target,
                null,
                .{ .ptr = gc.rtv_dheap_start.ptr + max_buffered_frames * gc.rtv_dheap_descriptor_size },
            );
        }

        return .resized;
    }
    return .unchanged;
}

pub fn init(window: w32.HWND) GpuContext {
    //
    // Factory, adapater, device
    //
    var dxgi_factory: *dxgi.IFactory6 = undefined;
    vhr(dxgi.CreateFactory2(
        if (d3d12_debug) dxgi.CREATE_FACTORY_DEBUG else 0,
        &dxgi.IFactory6.IID,
        @ptrCast(&dxgi_factory),
    ));
    log.info("DXGI factory created.", .{});

    var adapter: *dxgi.IAdapter3 = undefined;
    vhr(dxgi_factory.EnumAdapterByGpuPreference(0, .HIGH_PERFORMANCE, &dxgi.IAdapter3.IID, @ptrCast(&adapter)));
    {
        var adapter_desc: dxgi.ADAPTER_DESC2 = undefined;
        vhr(adapter.GetDesc2(&adapter_desc));
        var adapter_name_utf8: [256]u8 = undefined;
        const index = std.unicode.utf16leToUtf8(adapter_name_utf8[0..], adapter_desc.Description[0..]) catch 0;
        log.info("Adapter: {s}.", .{adapter_name_utf8[0..index]});
    }

    const debug = if (d3d12_debug) blk: {
        var debug: *d3d12d.IDebug5 = undefined;
        vhr(d3d12.GetDebugInterface(&d3d12d.IDebug5.IID, @ptrCast(&debug)));
        debug.EnableDebugLayer();
        log.info("D3D12 debug layer enabled.", .{});
        if (d3d12_debug_gpu) {
            debug.SetEnableGPUBasedValidation(w32.TRUE);
            log.info("D3D12 GPU-based validation enabled.", .{});
        }
        break :blk debug;
    } else {};

    var device: *IDevice = undefined;
    if (d3d12.CreateDevice(@ptrCast(adapter), .@"11_1", &IDevice.IID, @ptrCast(&device)) != w32.S_OK) {
        _ = w32.MessageBoxA(
            window,
            "Failed to create Direct3D 12 Device. This applications requires graphics card " ++
                "with Feature Level 11.1 support. Please update your graphics driver and try again.",
            "DirectX 12 initialization error",
            w32.MB_OK | w32.MB_ICONERROR,
        );
        w32.ExitProcess(0);
    }

    const debug_device = if (d3d12_debug) blk: {
        var debug_device: *d3d12.IDebugDevice = undefined;
        vhr(device.QueryInterface(&d3d12.IDebugDevice.IID, @ptrCast(&debug_device)));
        break :blk debug_device;
    } else {};

    const debug_info_queue = if (d3d12_debug) blk: {
        var debug_info_queue: *d3d12d.IInfoQueue = undefined;
        vhr(device.QueryInterface(&d3d12d.IInfoQueue.IID, @ptrCast(&debug_info_queue)));
        vhr(debug_info_queue.SetBreakOnSeverity(.ERROR, w32.TRUE));
        break :blk debug_info_queue;
    } else {};

    log.info("D3D12 device created.", .{});

    //
    // Check required features support
    //
    {
        var options: d3d12.FEATURE_DATA_D3D12_OPTIONS = undefined;
        var options12: d3d12.FEATURE_DATA_D3D12_OPTIONS12 = undefined;
        var shader_model: d3d12.FEATURE_DATA_SHADER_MODEL = .{ .HighestShaderModel = d3d12.SHADER_MODEL.HIGHEST };

        vhr(device.CheckFeatureSupport(.OPTIONS, &options, @sizeOf(d3d12.FEATURE_DATA_D3D12_OPTIONS)));
        vhr(device.CheckFeatureSupport(.OPTIONS12, &options12, @sizeOf(d3d12.FEATURE_DATA_D3D12_OPTIONS12)));
        vhr(device.CheckFeatureSupport(.SHADER_MODEL, &shader_model, @sizeOf(d3d12.FEATURE_DATA_SHADER_MODEL)));

        const is_supported = is_supported: {
            if (@intFromEnum(options.ResourceBindingTier) < @intFromEnum(d3d12.RESOURCE_BINDING_TIER.TIER_3)) {
                log.info("Resource Binding Tier 3 is NOT SUPPORTED - please update your graphics driver.", .{});
                break :is_supported false;
            }
            log.info("Resource Binding Tier 3 is SUPPORTED.", .{});

            if (options12.EnhancedBarriersSupported == w32.FALSE) {
                log.info("Enhanced Barriers API is NOT SUPPORTED - please update your graphics driver.", .{});
                break :is_supported false;
            }
            log.info("Enhanced Barriers API is SUPPORTED.", .{});

            if (@intFromEnum(shader_model.HighestShaderModel) < @intFromEnum(d3d12.SHADER_MODEL.@"6_6")) {
                log.info("Shader Model 6.6 is NOT SUPPORTED - please update your graphics driver.", .{});
                break :is_supported false;
            }
            log.info("Shader Model 6.6 is SUPPORTED.", .{});

            break :is_supported true;
        };
        if (!is_supported) {
            _ = w32.MessageBoxA(
                window,
                "Your graphics card does not support some required features. " ++
                    "Please update your graphics driver and try again.",
                "DirectX 12 initialization error",
                w32.MB_OK | w32.MB_ICONERROR,
            );
            w32.ExitProcess(0);
        }
    }

    //
    // Commands
    //
    var command_queue: *d3d12.ICommandQueue = undefined;
    vhr(device.CreateCommandQueue(&.{
        .Type = .DIRECT,
        .Priority = @intFromEnum(d3d12.COMMAND_QUEUE_PRIORITY.NORMAL),
        .Flags = .{},
        .NodeMask = 0,
    }, &d3d12.ICommandQueue.IID, @ptrCast(&command_queue)));

    const debug_command_queue = if (d3d12_debug) blk: {
        var debug_command_queue: *d3d12d.IDebugCommandQueue1 = undefined;
        vhr(command_queue.QueryInterface(&d3d12d.IDebugCommandQueue1.IID, @ptrCast(&debug_command_queue)));
        break :blk debug_command_queue;
    } else {};

    log.info("D3D12 command queue created.", .{});

    var command_allocators: [max_buffered_frames]*d3d12.ICommandAllocator = undefined;
    for (&command_allocators) |*cmdalloc| {
        vhr(device.CreateCommandAllocator(.DIRECT, &d3d12.ICommandAllocator.IID, @ptrCast(&cmdalloc.*)));
    }
    log.info("D3D12 command allocators created.", .{});

    var command_list: *IGraphicsCommandList = undefined;
    vhr(device.CreateCommandList1(0, .DIRECT, .{}, &IGraphicsCommandList.IID, @ptrCast(&command_list)));

    const debug_command_list = if (d3d12_debug) blk: {
        var debug_command_list: *d3d12d.IDebugCommandList3 = undefined;
        vhr(command_list.QueryInterface(&d3d12d.IDebugCommandList3.IID, @ptrCast(&debug_command_list)));
        break :blk debug_command_list;
    } else {};

    log.info("D3D12 command list created.", .{});

    //
    // Swap chain
    //
    const swap_chain_flags: dxgi.SWAP_CHAIN_FLAG = blk: {
        var allow_tearing: w32.BOOL = w32.FALSE;
        const hr = dxgi_factory.CheckFeatureSupport(.PRESENT_ALLOW_TEARING, &allow_tearing, @sizeOf(w32.BOOL));
        if (hr == w32.S_OK and allow_tearing == w32.TRUE) {
            log.info("Swap chain tearing is allowed.", .{});
            break :blk .{ .ALLOW_TEARING = true };
        }
        log.info("Swap chain tearing is NOT allowed.", .{});
        break :blk .{};
    };

    log.info("VSync is {s}.", .{if (d3d12_vsync) "enabled" else "disabled"});

    const window_width: u32, const window_height: u32 = blk: {
        var rect: w32.RECT = undefined;
        _ = w32.GetClientRect(window, &rect);
        break :blk .{ @intCast(rect.right - rect.left), @intCast(rect.bottom - rect.top) };
    };

    const swap_chain = swap_chain: {
        var swap_chain1: *dxgi.ISwapChain1 = undefined;
        vhr(dxgi_factory.CreateSwapChainForHwnd(
            @ptrCast(command_queue),
            window,
            &.{
                .Width = window_width,
                .Height = window_height,
                .Format = swap_chain_target_format,
                .Stereo = w32.FALSE,
                .SampleDesc = .{ .Count = 1 },
                .BufferUsage = .{ .RENDER_TARGET_OUTPUT = true },
                .BufferCount = max_buffered_frames,
                .Scaling = .NONE,
                .SwapEffect = .FLIP_DISCARD,
                .AlphaMode = .UNSPECIFIED,
                .Flags = swap_chain_flags,
            },
            null,
            null,
            @ptrCast(&swap_chain1),
        ));
        defer _ = swap_chain1.Release();
        var swap_chain: *dxgi.ISwapChain3 = undefined;
        vhr(swap_chain1.QueryInterface(&dxgi.ISwapChain3.IID, @ptrCast(&swap_chain)));
        break :swap_chain swap_chain;
    };

    // Disable ALT + ENTER
    vhr(dxgi_factory.MakeWindowAssociation(window, .{ .NO_WINDOW_CHANGES = true }));

    var swap_chain_targets: [max_buffered_frames]*d3d12.IResource = undefined;
    for (&swap_chain_targets, 0..) |*texture, i| {
        vhr(swap_chain.GetBuffer(@intCast(i), &d3d12.IResource.IID, @ptrCast(&texture.*)));
    }
    {
        var desc: dxgi.SWAP_CHAIN_DESC1 = undefined;
        vhr(swap_chain.GetDesc1(&desc));
        log.info("Swap chain created ({d}x{d}x{d}, {s}).", .{
            desc.Width,
            desc.Height,
            desc.BufferCount,
            @tagName(desc.Format),
        });
    }

    //
    // RTV descriptor heap
    //
    var rtv_dheap: *d3d12.IDescriptorHeap = undefined;
    vhr(device.CreateDescriptorHeap(&.{
        .Type = .RTV,
        .NumDescriptors = max_rtv_descriptors,
        .Flags = .{},
        .NodeMask = 0,
    }, &d3d12.IDescriptorHeap.IID, @ptrCast(&rtv_dheap)));

    const rtv_dheap_start = rtv_dheap.GetCPUDescriptorHandleForHeapStart();
    const rtv_dheap_descriptor_size = device.GetDescriptorHandleIncrementSize(.RTV);

    for (swap_chain_targets, 0..) |texture, i| {
        device.CreateRenderTargetView(
            texture,
            &.{
                .Format = display_target_format,
                .ViewDimension = .TEXTURE2D,
                .u = .{ .Texture2D = .{ .MipSlice = 0, .PlaneSlice = 0 } },
            },
            .{ .ptr = rtv_dheap_start.ptr + i * rtv_dheap_descriptor_size },
        );
    }

    log.info("RTV descriptor heap created (NumDescriptors: {d}, DescriptorSize: {d}).", .{
        max_rtv_descriptors,
        rtv_dheap_descriptor_size,
    });

    //
    // Shader descriptor heap
    //
    var shader_dheap: *d3d12.IDescriptorHeap = undefined;
    vhr(device.CreateDescriptorHeap(&.{
        .Type = .CBV_SRV_UAV,
        .NumDescriptors = max_shader_descriptors,
        .Flags = .{ .SHADER_VISIBLE = true },
        .NodeMask = 0,
    }, &d3d12.IDescriptorHeap.IID, @ptrCast(&shader_dheap)));

    const shader_dheap_start_cpu = shader_dheap.GetCPUDescriptorHandleForHeapStart();
    const shader_dheap_start_gpu = shader_dheap.GetGPUDescriptorHandleForHeapStart();
    const shader_dheap_descriptor_size = device.GetDescriptorHandleIncrementSize(.CBV_SRV_UAV);

    log.info("Shader descriptor heap created (NumDescriptors: {d}, DescriptorSize: {d}).", .{
        max_shader_descriptors,
        shader_dheap_descriptor_size,
    });

    //
    // Frame Fence
    //
    var frame_fence: *d3d12.IFence = undefined;
    vhr(device.CreateFence(0, .{}, &d3d12.IFence.IID, @ptrCast(&frame_fence)));

    const frame_fence_event = w32.CreateEventExA(null, "frame_fence_event", 0, w32.EVENT_ALL_ACCESS).?;

    log.info("Frame fence created.", .{});

    //
    // MSAA render target
    //
    const msaa_target = if (msaa_target_num_samples > 1) blk: {
        const msaa_target = create_msaa_srgb_target(device, window_width, window_height);
        device.CreateRenderTargetView(
            msaa_target,
            null,
            .{ .ptr = rtv_dheap_start.ptr + max_buffered_frames * rtv_dheap_descriptor_size },
        );
        const desc = msaa_target.GetDesc();
        log.info("MSAA render target created ({d}x{d}, NumSamples: {d}).", .{
            desc.Width,
            desc.Height,
            desc.SampleDesc.Count,
        });
        break :blk msaa_target;
    } else {};

    return .{
        .window = window,
        .window_width = window_width,
        .window_height = window_height,
        .dxgi_factory = dxgi_factory,
        .adapter = adapter,
        .device = device,
        .command_queue = command_queue,
        .command_allocators = command_allocators,
        .command_list = command_list,
        .swap_chain = swap_chain,
        .swap_chain_targets = swap_chain_targets,
        .swap_chain_flags = swap_chain_flags,
        .rtv_dheap = rtv_dheap,
        .rtv_dheap_start = rtv_dheap_start,
        .rtv_dheap_descriptor_size = rtv_dheap_descriptor_size,
        .shader_dheap = shader_dheap,
        .shader_dheap_start_cpu = shader_dheap_start_cpu,
        .shader_dheap_start_gpu = shader_dheap_start_gpu,
        .shader_dheap_descriptor_size = shader_dheap_descriptor_size,
        .frame_fence = frame_fence,
        .frame_fence_event = frame_fence_event,
        .frame_index = swap_chain.GetCurrentBackBufferIndex(),
        .msaa_target = msaa_target,
        .debug = debug,
        .debug_device = debug_device,
        .debug_info_queue = debug_info_queue,
        .debug_command_queue = debug_command_queue,
        .debug_command_list = debug_command_list,
    };
}

pub fn deinit(gc: *GpuContext) void {
    if (msaa_target_num_samples > 1) _ = gc.msaa_target.Release();
    _ = gc.command_list.Release();
    for (gc.command_allocators) |cmdalloc| _ = cmdalloc.Release();
    _ = gc.frame_fence.Release();
    _ = w32.CloseHandle(gc.frame_fence_event);
    _ = gc.shader_dheap.Release();
    _ = gc.rtv_dheap.Release();
    for (gc.swap_chain_targets) |texture| _ = texture.Release();
    _ = gc.swap_chain.Release();
    _ = gc.command_queue.Release();
    _ = gc.device.Release();
    _ = gc.dxgi_factory.Release();

    if (d3d12_debug) {
        _ = gc.debug_command_list.Release();
        _ = gc.debug_command_queue.Release();
        _ = gc.debug_info_queue.Release();
        _ = gc.debug.Release();

        vhr(gc.debug_device.ReportLiveDeviceObjects(.{ .DETAIL = true, .IGNORE_INTERNAL = true }));

        const refcount = gc.debug_device.Release();
        std.debug.assert(refcount == 0);
    }
    gc.* = undefined;
}

pub fn vhr(hr: w32.HRESULT) void {
    if (hr != 0) @panic("HRESULT error!");
}

fn create_msaa_srgb_target(device: *IDevice, width: u32, height: u32) *d3d12.IResource {
    var texture: *d3d12.IResource = undefined;
    vhr(device.CreateCommittedResource3(
        &.{ .Type = .DEFAULT },
        d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
        &.{
            .Dimension = .TEXTURE2D,
            .Width = @intCast(width),
            .Height = @intCast(height),
            .DepthOrArraySize = 1,
            .MipLevels = 1,
            .Format = msaa_target_format,
            .SampleDesc = .{ .Count = msaa_target_num_samples },
            .Flags = .{ .ALLOW_RENDER_TARGET = true },
        },
        .RENDER_TARGET,
        &.{ .Format = msaa_target_format, .u = .{ .Color = [_]f32{ 0, 0, 0, 0 } } },
        null,
        0,
        null,
        &d3d12.IResource.IID,
        @ptrCast(&texture),
    ));
    return texture;
}
