const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d12 = @import("win32/d3d12.zig");
const d3d12d = @import("win32/d3d12sdklayers.zig");
const dxgi = @import("win32/dxgi.zig");

pub const std_options = .{
    .log_level = .info,
};

export const D3D12SDKVersion: u32 = 611;
export const D3D12SDKPath: [*:0]const u8 = ".\\d3d12\\";

const window_name = "zig-d3d12-starter";

const GpuContext = @import("GpuContext.zig");
const vhr = GpuContext.vhr;

pub fn main() !void {
    _ = w32.CoInitializeEx(null, w32.COINIT_MULTITHREADED);
    defer w32.CoUninitialize();

    _ = w32.SetProcessDPIAware();

    var gc = try GpuContext.init(create_window(1600, 1200));
    defer gc.deinit();

    const root_signature: *d3d12.IRootSignature, const pipeline: *d3d12.IPipelineState = blk: {
        const vs_cso = @embedFile("cso/s00.vs.cso");
        const ps_cso = @embedFile("cso/s00.ps.cso");

        const pso_desc = pso_desc: {
            var pso_desc = d3d12.GRAPHICS_PIPELINE_STATE_DESC.init_default();
            pso_desc.DepthStencilState.DepthEnable = w32.FALSE;
            pso_desc.RTVFormats[0] = .R8G8B8A8_UNORM;
            pso_desc.NumRenderTargets = 1;
            pso_desc.BlendState.RenderTarget[0].RenderTargetWriteMask = 0xf;
            pso_desc.PrimitiveTopologyType = .TRIANGLE;
            pso_desc.VS = .{ .pShaderBytecode = vs_cso, .BytecodeLength = vs_cso.len };
            pso_desc.PS = .{ .pShaderBytecode = ps_cso, .BytecodeLength = ps_cso.len };
            break :pso_desc pso_desc;
        };

        var root_signature: *d3d12.IRootSignature = undefined;
        vhr(gc.device.CreateRootSignature(
            0,
            pso_desc.VS.pShaderBytecode.?,
            pso_desc.VS.BytecodeLength,
            &d3d12.IRootSignature.IID,
            @ptrCast(&root_signature),
        ));

        var pipeline: *d3d12.IPipelineState = undefined;
        vhr(gc.device.CreateGraphicsPipelineState(
            &pso_desc,
            &d3d12.IPipelineState.IID,
            @ptrCast(&pipeline),
        ));

        break :blk .{ root_signature, pipeline };
    };
    defer {
        _ = pipeline.Release();
        _ = root_signature.Release();
    }

    var frac: f32 = 0.0;
    var frac_delta: f32 = 0.005;

    //
    // Main Loop
    //
    main_loop: while (true) {
        {
            var message = std.mem.zeroes(w32.MSG);
            while (w32.PeekMessageA(&message, null, 0, 0, w32.PM_REMOVE) == w32.TRUE) {
                _ = w32.TranslateMessage(&message);
                _ = w32.DispatchMessageA(&message);
                if (message.message == w32.WM_QUIT) break :main_loop;
            }

            const status = gc.handle_window_resize();
            if (status == .has_been_minimized) {
                w32.Sleep(10);
                continue :main_loop;
            }
        }

        const command_allocator = gc.command_allocators[gc.frame_index];

        vhr(command_allocator.Reset());
        vhr(gc.command_list.Reset(command_allocator, null));

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

        const back_buffer_descriptor = d3d12.CPU_DESCRIPTOR_HANDLE{
            .ptr = gc.rtv_heap_start.ptr +
                gc.frame_index * gc.rtv_heap_descriptor_size,
        };

        gc.command_list.ResourceBarrier(1, &[_]d3d12.RESOURCE_BARRIER{.{
            .Type = .TRANSITION,
            .Flags = .{},
            .u = .{
                .Transition = .{
                    .pResource = gc.swap_chain_textures[gc.frame_index],
                    .Subresource = d3d12.RESOURCE_BARRIER_ALL_SUBRESOURCES,
                    .StateBefore = d3d12.RESOURCE_STATES.PRESENT,
                    .StateAfter = .{ .RENDER_TARGET = true },
                },
            },
        }});

        gc.command_list.OMSetRenderTargets(
            1,
            &[_]d3d12.CPU_DESCRIPTOR_HANDLE{back_buffer_descriptor},
            w32.TRUE,
            null,
        );
        gc.command_list.ClearRenderTargetView(back_buffer_descriptor, &.{ 0.2, frac, 0.8, 1.0 }, 0, null);

        gc.command_list.IASetPrimitiveTopology(.TRIANGLELIST);
        gc.command_list.SetPipelineState(pipeline);
        gc.command_list.SetGraphicsRootSignature(root_signature);
        gc.command_list.DrawInstanced(3, 1, 0, 0);

        gc.command_list.ResourceBarrier(1, &[_]d3d12.RESOURCE_BARRIER{.{
            .Type = .TRANSITION,
            .Flags = .{},
            .u = .{
                .Transition = .{
                    .pResource = gc.swap_chain_textures[gc.frame_index],
                    .Subresource = d3d12.RESOURCE_BARRIER_ALL_SUBRESOURCES,
                    .StateBefore = .{ .RENDER_TARGET = true },
                    .StateAfter = d3d12.RESOURCE_STATES.PRESENT,
                },
            },
        }});
        vhr(gc.command_list.Close());

        gc.command_queue.ExecuteCommandLists(1, &[_]*d3d12.ICommandList{@ptrCast(gc.command_list)});
        gc.present();

        frac += frac_delta;
        if (frac > 1.0 or frac < 0.0) {
            frac_delta = -frac_delta;
        }
    }

    gc.finish_gpu_commands();
}

fn process_window_message(
    window: w32.HWND,
    message: w32.UINT,
    wparam: w32.WPARAM,
    lparam: w32.LPARAM,
) callconv(w32.WINAPI) w32.LRESULT {
    switch (message) {
        w32.WM_KEYDOWN => {
            if (wparam == w32.VK_ESCAPE) {
                w32.PostQuitMessage(0);
                return 0;
            }
        },
        w32.WM_GETMINMAXINFO => {
            var info: *w32.MINMAXINFO = @ptrFromInt(@as(usize, @intCast(lparam)));
            info.ptMinTrackSize.x = 400;
            info.ptMinTrackSize.y = 400;
            return 0;
        },
        w32.WM_DESTROY => {
            w32.PostQuitMessage(0);
            return 0;
        },
        else => {},
    }
    return w32.DefWindowProcA(window, message, wparam, lparam);
}

fn create_window(width: u32, height: u32) w32.HWND {
    const winclass = w32.WNDCLASSEXA{
        .style = 0,
        .lpfnWndProc = process_window_message,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = @ptrCast(w32.GetModuleHandleA(null)),
        .hIcon = null,
        .hCursor = w32.LoadCursorA(null, @ptrFromInt(32512)),
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = window_name,
        .hIconSm = null,
    };
    _ = w32.RegisterClassExA(&winclass);

    const style = w32.WS_OVERLAPPEDWINDOW;

    var rect = w32.RECT{
        .left = 0,
        .top = 0,
        .right = @intCast(width),
        .bottom = @intCast(height),
    };
    _ = w32.AdjustWindowRectEx(&rect, style, w32.FALSE, 0);

    const window = w32.CreateWindowExA(
        0,
        window_name,
        window_name,
        style + w32.WS_VISIBLE,
        w32.CW_USEDEFAULT,
        w32.CW_USEDEFAULT,
        rect.right - rect.left,
        rect.bottom - rect.top,
        null,
        null,
        winclass.hInstance,
        null,
    ).?;

    return window;
}
