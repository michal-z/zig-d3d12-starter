const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d12 = @import("win32/d3d12.zig");
const d3d12d = @import("win32/d3d12sdklayers.zig");
const dxgi = @import("win32/dxgi.zig");
const d2d1 = @import("win32/d2d1.zig");
const cgc = @cImport(@cInclude("cpu_gpu_common.h"));

pub const std_options = .{
    .log_level = .info,
};

export const D3D12SDKVersion: u32 = 611;
export const D3D12SDKPath: [*:0]const u8 = ".\\d3d12\\";

const window_name = "zig-d3d12-starter";

const GpuContext = @import("GpuContext.zig");
const vhr = GpuContext.vhr;

pub fn main() !void {
    _ = w32.SetProcessDPIAware();

    _ = cgc.RDH_OBJECTS_DYNAMIC;
    std.debug.print("aaaaaaaaaa: {d}\n", .{@sizeOf(cgc.Vertex)});

    _ = w32.CoInitializeEx(null, w32.COINIT_MULTITHREADED);
    defer w32.CoUninitialize();

    var app = AppState.init();
    defer app.deinit();

    var d2d_factory: *d2d1.IFactory = undefined;
    vhr(d2d1.CreateFactory(
        .SINGLE_THREADED,
        &d2d1.IFactory.IID,
        if (GpuContext.d3d12_debug) &.{ .debugLevel = .INFORMATION } else &.{ .debugLevel = .NONE },
        @ptrCast(&d2d_factory),
    ));
    defer _ = d2d_factory.Release();

    while (true) {
        var message = std.mem.zeroes(w32.MSG);
        if (w32.PeekMessageA(&message, null, 0, 0, w32.PM_REMOVE) == .TRUE) {
            _ = w32.TranslateMessage(&message);
            _ = w32.DispatchMessageA(&message);
            if (message.message == w32.WM_QUIT) break;
        }

        if (app.update())
            app.draw();
    }
}

const AppState = struct {
    gpu_context: GpuContext,

    pso: *d3d12.IPipelineState,
    pso_root_signature: *d3d12.IRootSignature,

    fn init() AppState {
        var gc = GpuContext.init(create_window(1600, 1200));

        const pso_root_signature: *d3d12.IRootSignature, const pso: *d3d12.IPipelineState = blk: {
            const vs_cso = @embedFile("cso/s00.vs.cso");
            const ps_cso = @embedFile("cso/s00.ps.cso");

            var root_signature: *d3d12.IRootSignature = undefined;
            vhr(gc.device.CreateRootSignature(
                0,
                vs_cso,
                vs_cso.len,
                &d3d12.IRootSignature.IID,
                @ptrCast(&root_signature),
            ));

            var pipeline: *d3d12.IPipelineState = undefined;
            vhr(gc.device.CreateGraphicsPipelineState(
                &.{
                    .DepthStencilState = .{ .DepthEnable = .FALSE },
                    .RTVFormats = .{GpuContext.display_target_format} ++ .{.UNKNOWN} ** 7,
                    .NumRenderTargets = 1,
                    .BlendState = .{
                        .RenderTarget = .{.{
                            .RenderTargetWriteMask = 0x0f,
                        }} ++ .{.{}} ** 7,
                    },
                    .PrimitiveTopologyType = .TRIANGLE,
                    .VS = .{ .pShaderBytecode = vs_cso, .BytecodeLength = vs_cso.len },
                    .PS = .{ .pShaderBytecode = ps_cso, .BytecodeLength = ps_cso.len },
                    .SampleDesc = .{ .Count = GpuContext.display_target_num_samples },
                },
                &d3d12.IPipelineState.IID,
                @ptrCast(&pipeline),
            ));

            break :blk .{ root_signature, pipeline };
        };

        return .{
            .gpu_context = gc,
            .pso = pso,
            .pso_root_signature = pso_root_signature,
        };
    }

    fn deinit(app: *AppState) void {
        app.gpu_context.finish_gpu_commands();

        _ = app.pso.Release();
        _ = app.pso_root_signature.Release();

        app.gpu_context.deinit();

        app.* = undefined;
    }

    fn update(app: *AppState) bool {
        const status = app.gpu_context.handle_window_resize();
        if (status == .minimized) {
            w32.Sleep(10);
            return false;
        }

        _ = update_frame_stats(app.gpu_context.window, window_name);

        return true;
    }

    fn draw(app: *AppState) void {
        var gc = &app.gpu_context;

        gc.begin_command_list();
        gc.command_list.OMSetRenderTargets(
            1,
            &[_]d3d12.CPU_DESCRIPTOR_HANDLE{gc.display_target_descriptor()},
            .TRUE,
            null,
        );
        gc.command_list.ClearRenderTargetView(gc.display_target_descriptor(), &.{ 0, 0, 0, 0 }, 0, null);
        gc.command_list.IASetPrimitiveTopology(.TRIANGLELIST);
        gc.command_list.SetPipelineState(app.pso);
        gc.command_list.SetGraphicsRootSignature(app.pso_root_signature);
        gc.command_list.DrawInstanced(3, 1, 0, 0);
        gc.end_command_list();

        gc.command_queue.ExecuteCommandLists(1, &[_]*d3d12.ICommandList{@ptrCast(gc.command_list)});
        gc.present_frame();
    }
};

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
    var rect = w32.RECT{ .left = 0, .top = 0, .right = @intCast(width), .bottom = @intCast(height) };
    _ = w32.AdjustWindowRectEx(&rect, style, .FALSE, 0);

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

fn update_frame_stats(window: w32.HWND, name: [:0]const u8) struct { f64, f32 } {
    const state = struct {
        var timer: std.time.Timer = undefined;
        var previous_time_ns: u64 = 0;
        var header_refresh_time_ns: u64 = 0;
        var frame_count: u64 = ~@as(u64, 0);
    };

    if (state.frame_count == ~@as(u64, 0)) {
        state.timer = std.time.Timer.start() catch unreachable;
        state.previous_time_ns = 0;
        state.header_refresh_time_ns = 0;
        state.frame_count = 0;
    }

    const now_ns = state.timer.read();
    const time = @as(f64, @floatFromInt(now_ns)) / std.time.ns_per_s;
    const delta_time = @as(f32, @floatFromInt(now_ns - state.previous_time_ns)) / std.time.ns_per_s;
    state.previous_time_ns = now_ns;

    if ((now_ns - state.header_refresh_time_ns) >= std.time.ns_per_s) {
        const t = @as(f64, @floatFromInt(now_ns - state.header_refresh_time_ns)) / std.time.ns_per_s;
        const fps = @as(f64, @floatFromInt(state.frame_count)) / t;
        const ms = (1.0 / fps) * 1000.0;

        var buffer = [_]u8{0} ** 128;
        const buffer_slice = buffer[0 .. buffer.len - 1];
        const header = std.fmt.bufPrint(
            buffer_slice,
            "[{d:.1} fps  {d:.3} ms] {s}",
            .{ fps, ms, name },
        ) catch buffer_slice;

        _ = w32.SetWindowTextA(window, @ptrCast(header.ptr));

        state.header_refresh_time_ns = now_ns;
        state.frame_count = 0;
    }
    state.frame_count += 1;

    return .{ time, delta_time };
}
