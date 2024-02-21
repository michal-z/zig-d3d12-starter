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

window: w32.HWND,
window_width: u32,
window_height: u32,

dxgi_factory: *dxgi.IFactory6,
adapter: *dxgi.IAdapter3,
device: *IDevice,

command_queue: *d3d12.ICommandQueue,
command_allocators: [max_buffered_frames]*d3d12.ICommandAllocator,
command_list: *IGraphicsCommandList,

swap_chain_flags: dxgi.SWAP_CHAIN_FLAG,
swap_chain_present_interval: w32.UINT = if (d3d12_vsync) 1 else 0,

debug: if (d3d12_debug) *d3d12d.IDebug5 else void,
debug_device: if (d3d12_debug) *d3d12.IDebugDevice else void,
debug_info_queue: if (d3d12_debug) *d3d12d.IInfoQueue else void,
debug_command_queue: if (d3d12_debug) *d3d12d.IDebugCommandQueue1 else void,
debug_command_list: if (d3d12_debug) *d3d12d.IDebugCommandList3 else void,

pub fn init(window: w32.HWND) !GpuContext {
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
    } else undefined;

    var device: *IDevice = undefined;
    if (d3d12.CreateDevice(@ptrCast(adapter), .@"11_1", &IDevice.IID, @ptrCast(&device)) != w32.S_OK) {
        return error.CreateDeviceFailed;
    }

    const debug_device = if (d3d12_debug) blk: {
        var debug_device: *d3d12.IDebugDevice = undefined;
        vhr(device.QueryInterface(&d3d12.IDebugDevice.IID, @ptrCast(&debug_device)));
        break :blk debug_device;
    } else undefined;

    const debug_info_queue = if (d3d12_debug) blk: {
        var debug_info_queue: *d3d12d.IInfoQueue = undefined;
        vhr(device.QueryInterface(&d3d12d.IInfoQueue.IID, @ptrCast(&debug_info_queue)));
        vhr(debug_info_queue.SetBreakOnSeverity(.ERROR, w32.TRUE));
        break :blk debug_info_queue;
    } else undefined;

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

        if (@intFromEnum(options.ResourceBindingTier) < @intFromEnum(d3d12.RESOURCE_BINDING_TIER.TIER_3)) {
            log.info("Resource Binding Tier 3 is NOT SUPPORTED - please update your graphics driver.", .{});
            return error.NoSupportForRequiredFeatures;
        }
        log.info("Resource Binding Tier 3 is SUPPORTED.", .{});

        if (options12.EnhancedBarriersSupported == w32.FALSE) {
            log.info("Enhanced Barriers API is NOT SUPPORTED - please update your graphics driver.", .{});
            return error.NoSupportForRequiredFeatures;
        }
        log.info("Enhanced Barriers API is SUPPORTED.", .{});

        if (@intFromEnum(shader_model.HighestShaderModel) < @intFromEnum(d3d12.SHADER_MODEL.@"6_6")) {
            log.info("Shader Model 6.6 is NOT SUPPORTED - please update your graphics driver.", .{});
            return error.NoSupportForRequiredFeatures;
        }
        log.info("Shader Model 6.6 is SUPPORTED.", .{});
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
    } else undefined;

    log.info("D3D12 command queue created", .{});

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
    } else undefined;

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

    const window_width: u32, const window_height: u32 = blk: {
        var rect: w32.RECT = undefined;
        _ = w32.GetClientRect(window, &rect);
        break :blk .{ @intCast(rect.right - rect.left), @intCast(rect.bottom - rect.top) };
    };

    return GpuContext{
        .window = window,
        .window_width = window_width,
        .window_height = window_height,
        .dxgi_factory = dxgi_factory,
        .adapter = adapter,
        .device = device,
        .command_queue = command_queue,
        .command_allocators = command_allocators,
        .command_list = command_list,
        .swap_chain_flags = swap_chain_flags,
        .debug = debug,
        .debug_device = debug_device,
        .debug_info_queue = debug_info_queue,
        .debug_command_queue = debug_command_queue,
        .debug_command_list = debug_command_list,
    };
}

pub fn deinit(gc: *GpuContext) void {
    _ = gc;
}

fn vhr(hr: w32.HRESULT) void {
    if (hr != 0) @panic("HRESULT error!");
}
