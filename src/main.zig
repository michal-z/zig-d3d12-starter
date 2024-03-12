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

    _ = w32.CoInitializeEx(null, w32.COINIT_MULTITHREADED);
    defer w32.CoUninitialize();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var app = try AppState.init(allocator);
    defer app.deinit();

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

const Mesh = struct {
    first_vertex: u32,
    num_vertices: u32,

    const test_mesh0: usize = 0;
    const test_mesh1: usize = 1;
    const test_mesh2: usize = 2;
    const test_mesh3: usize = 3;
    const circle_50: usize = 4;
    const num_mesh_types = 5;
};

const screen_size = 800.0;

const AppState = struct {
    gpu_context: GpuContext,

    vertex_buffer: *d3d12.IResource,
    object_buffer: *d3d12.IResource,
    frame_state_buffer: *d3d12.IResource,

    pso: *d3d12.IPipelineState,
    pso_rs: *d3d12.IRootSignature,

    meshes: std.ArrayList(Mesh),
    objects: std.ArrayList(cgc.Object),

    d2d_factory: *d2d1.IFactory,

    fn init(allocator: std.mem.Allocator) !AppState {
        var gc = GpuContext.init(create_window(1600, 1200));

        const pso, const pso_rs = create_pso(gc.device);

        var frame_state_buffer: *d3d12.IResource = undefined;
        vhr(gc.device.CreateCommittedResource3(
            &.{ .Type = .DEFAULT },
            d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
            &.{
                .Dimension = .BUFFER,
                .Width = @sizeOf(cgc.FrameState),
                .Layout = .ROW_MAJOR,
            },
            .UNDEFINED,
            null,
            null,
            0,
            null,
            &d3d12.IResource.IID,
            @ptrCast(&frame_state_buffer),
        ));
        gc.device.CreateConstantBufferView(
            &.{
                .BufferLocation = frame_state_buffer.GetGPUVirtualAddress(),
                .SizeInBytes = @sizeOf(cgc.FrameState),
            },
            .{ .ptr = gc.shader_dheap_start_cpu.ptr +
                @as(u32, @intCast(cgc.rdh_frame_state_buffer)) *
                gc.shader_dheap_descriptor_size },
        );

        var d2d_factory: *d2d1.IFactory = undefined;
        vhr(d2d1.CreateFactory(
            .SINGLE_THREADED,
            &d2d1.IFactory.IID,
            if (GpuContext.d3d12_debug) &.{ .debugLevel = .INFORMATION } else &.{ .debugLevel = .NONE },
            @ptrCast(&d2d_factory),
        ));

        vhr(gc.command_allocators[0].Reset());
        vhr(gc.command_list.Reset(gc.command_allocators[0], null));

        const meshes, const vertex_buffer = try define_and_upload_meshes(allocator, &gc, d2d_factory);
        const objects, const object_buffer = try define_and_upload_objects(allocator, &gc);

        vhr(gc.command_list.Close());
        gc.command_queue.ExecuteCommandLists(1, &[_]*d3d12.ICommandList{@ptrCast(gc.command_list)});
        gc.finish_gpu_commands();

        return AppState{
            .gpu_context = gc,
            .vertex_buffer = vertex_buffer,
            .object_buffer = object_buffer,
            .frame_state_buffer = frame_state_buffer,
            .pso = pso,
            .pso_rs = pso_rs,
            .meshes = meshes,
            .objects = objects,
            .d2d_factory = d2d_factory,
        };
    }

    fn deinit(app: *AppState) void {
        app.meshes.deinit();
        app.objects.deinit();

        _ = app.d2d_factory.Release();

        app.gpu_context.finish_gpu_commands();

        _ = app.pso.Release();
        _ = app.pso_rs.Release();
        _ = app.vertex_buffer.Release();
        _ = app.object_buffer.Release();
        _ = app.frame_state_buffer.Release();

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
        const gc = &app.gpu_context;

        gc.begin_command_list();

        {
            const proj = if (true) blk: { //gc.window_width > gc.window_height) blk: {
                const aspect: f32 = @as(f32, @floatFromInt(gc.window_width)) / @as(f32, @floatFromInt(gc.window_height));

                break :blk orthographic_off_center(
                    0.0,
                    screen_size * aspect,
                    0.0,
                    screen_size,
                    0.0,
                    1.0,
                );
                //break :blk orthographic_off_center(
                //    -screen_size * 0.5 * aspect,
                //    screen_size * 0.5 * aspect,
                //    screen_size * 0.5,
                //    -screen_size * 0.5,
                //    0.0,
                //    1.0,
                //);
            } else blk: {
                const aspect: f32 = @as(f32, @floatFromInt(gc.window_height)) / @as(f32, @floatFromInt(gc.window_width));

                break :blk orthographic_off_center(
                    -screen_size * 0.5,
                    screen_size * 0.5,
                    screen_size * 0.5 * aspect,
                    -screen_size * 0.5 * aspect,
                    0.0,
                    1.0,
                );
            };

            const frame_state, const buffer, const offset =
                gc.allocate_upload_buffer_region(cgc.FrameState, 1);

            frame_state[0] = .{
                .proj = transpose(proj),
            };

            gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
                .Type = .BUFFER,
                .NumBarriers = 1,
                .u = .{
                    .pBufferBarriers = &[_]d3d12.BUFFER_BARRIER{.{
                        .SyncBefore = .{},
                        .SyncAfter = .{ .COPY = true },
                        .AccessBefore = .{ .NO_ACCESS = true },
                        .AccessAfter = .{ .COPY_DEST = true },
                        .pResource = app.frame_state_buffer,
                    }},
                },
            }});

            gc.command_list.CopyBufferRegion(
                app.frame_state_buffer,
                0,
                buffer,
                offset,
                @sizeOf(cgc.FrameState),
            );

            gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
                .Type = .BUFFER,
                .NumBarriers = 1,
                .u = .{
                    .pBufferBarriers = &[_]d3d12.BUFFER_BARRIER{.{
                        .SyncBefore = .{ .COPY = true },
                        .SyncAfter = .{ .DRAW = true },
                        .AccessBefore = .{ .COPY_DEST = true },
                        .AccessAfter = .{ .CONSTANT_BUFFER = true },
                        .pResource = app.frame_state_buffer,
                    }},
                },
            }});
        }

        gc.command_list.OMSetRenderTargets(
            1,
            &[_]d3d12.CPU_DESCRIPTOR_HANDLE{gc.display_target_descriptor()},
            .TRUE,
            null,
        );
        gc.command_list.ClearRenderTargetView(gc.display_target_descriptor(), &.{ 0, 0, 0, 0 }, 0, null);

        gc.command_list.IASetPrimitiveTopology(.TRIANGLELIST);
        gc.command_list.SetPipelineState(app.pso);
        gc.command_list.SetGraphicsRootSignature(app.pso_rs);

        for (app.objects.items, 0..) |object, object_id| {
            gc.command_list.SetGraphicsRoot32BitConstants(
                0,
                2,
                &[_]u32{
                    app.meshes.items[object.mesh_index].first_vertex,
                    @intCast(object_id),
                },
                0,
            );
            gc.command_list.DrawInstanced(
                app.meshes.items[object.mesh_index].num_vertices,
                1,
                0,
                0,
            );
        }

        gc.end_command_list();

        gc.command_queue.ExecuteCommandLists(1, &[_]*d3d12.ICommandList{@ptrCast(gc.command_list)});
        gc.present_frame();
    }
};

fn create_pso(device: *GpuContext.IDevice) struct { *d3d12.IPipelineState, *d3d12.IRootSignature } {
    const vs_cso = @embedFile("cso/s00.vs.cso");
    const ps_cso = @embedFile("cso/s00.ps.cso");

    var root_signature: *d3d12.IRootSignature = undefined;
    vhr(device.CreateRootSignature(
        0,
        vs_cso,
        vs_cso.len,
        &d3d12.IRootSignature.IID,
        @ptrCast(&root_signature),
    ));

    var pipeline: *d3d12.IPipelineState = undefined;
    vhr(device.CreateGraphicsPipelineState(
        &.{
            .DepthStencilState = .{ .DepthEnable = .FALSE },
            .RTVFormats = .{GpuContext.display_target_format} ++ .{.UNKNOWN} ** 7,
            .NumRenderTargets = 1,
            .BlendState = .{
                .RenderTarget = .{.{
                    .RenderTargetWriteMask = 0x0f,
                }} ++ .{.{}} ** 7,
            },
            .RasterizerState = .{
                //.FillMode = .WIREFRAME,
                .CullMode = .NONE,
            },
            .PrimitiveTopologyType = .TRIANGLE,
            .VS = .{ .pShaderBytecode = vs_cso, .BytecodeLength = vs_cso.len },
            .PS = .{ .pShaderBytecode = ps_cso, .BytecodeLength = ps_cso.len },
            .SampleDesc = .{ .Count = GpuContext.display_target_num_samples },
        },
        &d3d12.IPipelineState.IID,
        @ptrCast(&pipeline),
    ));

    return .{ pipeline, root_signature };
}

fn define_and_upload_objects(
    allocator: std.mem.Allocator,
    gc: *GpuContext,
) !struct { std.ArrayList(cgc.Object), *d3d12.IResource } {
    var objects = std.ArrayList(cgc.Object).init(allocator);

    try objects.append(.{ .color = 0xaa_ff_00_00, .mesh_index = Mesh.test_mesh0 });
    try objects.append(.{ .color = 0xaa_00_ff_00, .mesh_index = Mesh.test_mesh1 });
    try objects.append(.{
        .color = 0xaa_ff_ff_00,
        .mesh_index = Mesh.circle_50,
        .x = 300.0,
        .y = 500.0,
    });
    try objects.append(.{
        .color = 0xaa_ff_00_ff,
        .mesh_index = Mesh.circle_50,
        .x = 500.0,
        .y = 300.0,
    });
    try objects.append(.{ .color = 0xaa_00_ff_00, .mesh_index = Mesh.test_mesh2 });

    var object_buffer: *d3d12.IResource = undefined;
    vhr(gc.device.CreateCommittedResource3(
        &.{ .Type = .DEFAULT },
        d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
        &.{
            .Dimension = .BUFFER,
            .Width = objects.items.len * @sizeOf(cgc.Object),
            .Layout = .ROW_MAJOR,
        },
        .UNDEFINED,
        null,
        null,
        0,
        null,
        &d3d12.IResource.IID,
        @ptrCast(&object_buffer),
    ));

    gc.device.CreateShaderResourceView(
        object_buffer,
        &d3d12.SHADER_RESOURCE_VIEW_DESC.init_structured_buffer(
            0,
            @intCast(objects.items.len),
            @sizeOf(cgc.Object),
        ),
        .{ .ptr = gc.shader_dheap_start_cpu.ptr +
            @as(u32, @intCast(cgc.rdh_object_buffer)) *
            gc.shader_dheap_descriptor_size },
    );

    const mem, const buffer, const offset =
        gc.allocate_upload_buffer_region(cgc.Object, @intCast(objects.items.len));

    for (objects.items, 0..) |object, i| mem[i] = object;

    gc.command_list.CopyBufferRegion(
        object_buffer,
        0,
        buffer,
        offset,
        mem.len * @sizeOf(@TypeOf(mem[0])),
    );

    return .{ objects, object_buffer };
}

fn define_and_upload_meshes(
    allocator: std.mem.Allocator,
    gc: *GpuContext,
    d2d_factory: *d2d1.IFactory,
) !struct { std.ArrayList(Mesh), *d3d12.IResource } {
    var meshes = std.ArrayList(Mesh).init(allocator);
    try meshes.resize(Mesh.num_mesh_types);

    var vertices = std.ArrayList(cgc.Vertex).init(allocator);
    defer vertices.deinit();

    var tessellation_sink: TessellationSink = .{ .vertices = &vertices };

    {
        const first_vertex = vertices.items.len;

        try vertices.append(.{ .x = 0.0, .y = 0.0 });
        try vertices.append(.{ .x = 100.0, .y = 0.0 });
        try vertices.append(.{ .x = 0.0, .y = 100.0 });

        meshes.items[Mesh.test_mesh0] = .{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
        };
    }

    {
        const first_vertex = vertices.items.len;

        try vertices.append(.{ .x = screen_size, .y = screen_size });
        try vertices.append(.{ .x = screen_size - 100.0, .y = screen_size });
        try vertices.append(.{ .x = screen_size, .y = screen_size - 100.0 });

        meshes.items[Mesh.test_mesh1] = .{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
        };
    }

    {
        var geo: *d2d1.IEllipseGeometry = undefined;
        vhr(d2d_factory.CreateEllipseGeometry(
            &.{
                .point = .{ .x = 0.0, .y = 0.0 },
                .radiusX = 50.0,
                .radiusY = 50.0,
            },
            @ptrCast(&geo),
        ));
        defer _ = geo.Release();

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(
            null,
            d2d1.DEFAULT_FLATTENING_TOLERANCE,
            @ptrCast(&tessellation_sink),
        ));

        meshes.items[Mesh.circle_50] = .{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
        };
    }

    {
        var geo: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo)));
        defer _ = geo.Release();

        var geo_sink: *d2d1.IGeometrySink = undefined;
        vhr(geo.Open(@ptrCast(&geo_sink)));

        geo_sink.BeginFigure(.{ .x = 100.0, .y = 100.0 }, .FILLED);
        geo_sink.AddLine(.{ .x = 200.0, .y = 400.0 });
        geo_sink.AddLine(.{ .x = 300.0, .y = 500.0 });
        geo_sink.EndFigure(.OPEN);

        vhr(geo_sink.Close());
        _ = geo_sink.Release();

        //var geo1: *d2d1.IPathGeometry = undefined;
        //vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo1)));
        //defer _ = geo1.Release();

        //vhr(geo1.Open(@ptrCast(&geo_sink)));

        //geo.Widen(5.0, null, null, d2d1.DEFAULT_FLATTENING_TOLERANCE, geo_sink);

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(
            null,
            d2d1.DEFAULT_FLATTENING_TOLERANCE,
            @ptrCast(&tessellation_sink),
        ));

        meshes.items[Mesh.test_mesh2] = .{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
        };
    }

    var vertex_buffer: *d3d12.IResource = undefined;
    vhr(gc.device.CreateCommittedResource3(
        &.{ .Type = .DEFAULT },
        d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
        &.{
            .Dimension = .BUFFER,
            .Width = vertices.items.len * @sizeOf(cgc.Vertex),
            .Layout = .ROW_MAJOR,
        },
        .UNDEFINED,
        null,
        null,
        0,
        null,
        &d3d12.IResource.IID,
        @ptrCast(&vertex_buffer),
    ));

    gc.device.CreateShaderResourceView(
        vertex_buffer,
        &d3d12.SHADER_RESOURCE_VIEW_DESC.init_structured_buffer(
            0,
            @intCast(vertices.items.len),
            @sizeOf(cgc.Vertex),
        ),
        .{ .ptr = gc.shader_dheap_start_cpu.ptr +
            @as(u32, @intCast(cgc.rdh_vertex_buffer)) *
            gc.shader_dheap_descriptor_size },
    );

    const mem, const buffer, const offset =
        gc.allocate_upload_buffer_region(cgc.Vertex, @intCast(vertices.items.len));

    for (vertices.items, 0..) |vert, i| mem[i] = vert;

    gc.command_list.CopyBufferRegion(
        vertex_buffer,
        0,
        buffer,
        offset,
        mem.len * @sizeOf(@TypeOf(mem[0])),
    );

    return .{ meshes, vertex_buffer };
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

const TessellationSink = extern struct {
    __v: *const d2d1.ITessellationSink.VTable = &.{
        .base = .{
            .QueryInterface = _query_interface,
            .AddRef = _add_ref,
            .Release = _release,
        },
        .AddTriangles = _add_triangles,
        .Close = _close,
    },

    vertices: *std.ArrayList(cgc.Vertex),

    pub const QueryInterface = w32.IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = w32.IUnknown.Methods(@This()).AddRef;
    pub const Release = w32.IUnknown.Methods(@This()).Release;

    pub const AddTriangles = d2d1.ITessellationSink(@This()).AddTriangles;
    pub const Close = d2d1.ITessellationSink(@This()).Close;

    fn _query_interface(_: *w32.IUnknown, _: *const w32.GUID, _: ?*?*anyopaque) callconv(w32.WINAPI) w32.HRESULT {
        return w32.S_OK;
    }
    fn _add_ref(_: *w32.IUnknown) callconv(w32.WINAPI) w32.ULONG {
        return 0;
    }
    fn _release(_: *w32.IUnknown) callconv(w32.WINAPI) w32.ULONG {
        return 0;
    }

    fn _add_triangles(
        this: *d2d1.ITessellationSink,
        triangles: [*]const d2d1.TRIANGLE,
        num_triangles: w32.UINT32,
    ) callconv(w32.WINAPI) void {
        const self: *TessellationSink = @ptrCast(this);

        for (triangles[0..@intCast(num_triangles)]) |tri| {
            self.vertices.append(.{ .x = tri.point1.x, .y = tri.point1.y }) catch unreachable;
            self.vertices.append(.{ .x = tri.point2.x, .y = tri.point2.y }) catch unreachable;
            self.vertices.append(.{ .x = tri.point3.x, .y = tri.point3.y }) catch unreachable;
        }
    }
    fn _close(_: *d2d1.ITessellationSink) callconv(w32.WINAPI) w32.HRESULT {
        return w32.S_OK;
    }
};

fn orthographic_off_center(l: f32, r: f32, t: f32, b: f32, n: f32, f: f32) [16]f32 {
    std.debug.assert(!std.math.approxEqAbs(f32, f, n, 0.001));

    const d = 1 / (f - n);
    return .{
        2 / (r - l),        0.0,                0.0,    0.0,
        0.0,                2 / (t - b),        0.0,    0.0,
        0.0,                0.0,                d,      0.0,
        -(r + l) / (r - l), -(t + b) / (t - b), -d * n, 1.0,
    };
}

fn transpose(m: [16]f32) [16]f32 {
    return .{
        m[0], m[4], m[8],  m[12],
        m[1], m[5], m[9],  m[13],
        m[2], m[6], m[10], m[14],
        m[3], m[7], m[11], m[15],
    };
}
