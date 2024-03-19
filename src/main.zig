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

export const D3D12SDKVersion: u32 = 613;
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

    geometry: *d2d1.IGeometry,

    const player = 0;
    const food = 1;
    const level1 = 2; // Mesh levels need to be defined last in ascending order.
    const level2 = level1 + 1;

    const last_level = level2;

    const num_mesh_types = last_level + 1;
};

const map_size_x = 1400.0;
const map_size_y = 1050.0;
const player_start_x = -600.0;
const player_start_y = 50.0;
const num_levels = Mesh.last_level - Mesh.level1 + 1;

fn is_key_down(vkey: c_int) bool {
    return (@as(w32.USHORT, @bitCast(w32.GetAsyncKeyState(vkey))) & 0x8000) != 0;
}

const AppState = struct {
    allocator: std.mem.Allocator,

    gpu_context: GpuContext,

    vertex_buffer: *d3d12.IResource,
    object_buffer: *d3d12.IResource,
    frame_state_buffer: *d3d12.IResource,

    pso: *d3d12.IPipelineState,
    pso_rs: *d3d12.IRootSignature,

    meshes: std.ArrayList(Mesh),
    objects: std.ArrayList(cgc.Object),

    d2d_factory: *d2d1.IFactory,

    player_is_dead: f32 = 0.0,
    player_to_next_level: f32 = 0.0,
    num_food_objects: u32,
    current_level: u32,

    fn init(allocator: std.mem.Allocator) !AppState {
        var gc = GpuContext.init(
            create_window(
                @divTrunc(w32.GetSystemMetrics(w32.SM_CXSCREEN), 2),
                @divTrunc(w32.GetSystemMetrics(w32.SM_CYSCREEN), 2),
            ),
        );

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

        const meshes, const vertex_buffer = try define_and_upload_meshes(allocator, &gc, d2d_factory);

        const current_level = 1;

        const objects, const num_food_objects, const object_buffer = try define_and_upload_objects(allocator, &gc, current_level);

        return AppState{
            .allocator = allocator,
            .gpu_context = gc,
            .vertex_buffer = vertex_buffer,
            .object_buffer = object_buffer,
            .frame_state_buffer = frame_state_buffer,
            .pso = pso,
            .pso_rs = pso_rs,
            .meshes = meshes,
            .objects = objects,
            .d2d_factory = d2d_factory,
            .num_food_objects = num_food_objects,
            .current_level = current_level,
        };
    }

    fn deinit(app: *AppState) void {
        for (app.meshes.items) |mesh| _ = mesh.geometry.Release();
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

        _, const delta_time = update_frame_stats(app.gpu_context.window, window_name);

        var player = &app.objects.items[0];

        if (app.player_is_dead > 0.0) {
            app.player_is_dead -= delta_time;

            if (app.player_is_dead <= 0.0) {
                app.player_is_dead = 0.0;

                player.x = player_start_x;
                player.y = player_start_y;
                player.rotation = 0.0;

                // Re-spawn food objects.
                for (app.objects.items[1..]) |*object| {
                    if (object.mesh_index == 0) {
                        object.mesh_index = Mesh.food;
                        app.num_food_objects += 1;
                    }
                }
            }
            return true;
        }

        if (app.player_to_next_level > 0.0) {
            app.player_to_next_level -= delta_time;

            if (app.player_to_next_level <= 0.0) {
                app.player_to_next_level = 0.0;

                // Advance to the next level.
                app.current_level += 1;
                if (app.current_level > num_levels) {
                    _ = w32.MessageBoxA(
                        app.gpu_context.window,
                        "CONGRATULATIONS!!! YOU'VE COMPLETED THE GAME!!!",
                        "YOU ARE AWESOME",
                        w32.MB_OK,
                    );
                    w32.PostQuitMessage(0);
                    return true;
                }

                app.objects.deinit();

                app.gpu_context.finish_gpu_commands();
                _ = app.object_buffer.Release();

                app.objects, app.num_food_objects, app.object_buffer = define_and_upload_objects(
                    app.allocator,
                    &app.gpu_context,
                    app.current_level,
                ) catch unreachable;
            }
            return true;
        }

        const translation_speed = 250.0;
        const rotation_speed = 5.0;

        if (is_key_down(w32.VK_RIGHT) or is_key_down('D')) {
            player.rotation += rotation_speed * delta_time;
        } else if (is_key_down(w32.VK_LEFT) or is_key_down('A')) {
            player.rotation -= rotation_speed * delta_time;
        }

        player.x += @cos(player.rotation) * translation_speed * delta_time;
        player.y += @sin(player.rotation) * translation_speed * delta_time;

        for (app.objects.items[1..]) |*object| {
            if (object.mesh_index == 0) continue; // Already eaten food.

            var contains: w32.BOOL = .FALSE;
            vhr(app.meshes.items[object.mesh_index].geometry.FillContainsPoint(
                .{ .x = player.x, .y = player.y },
                &d2d1.MATRIX_3X2_F.translation(object.x, object.y),
                d2d1.DEFAULT_FLATTENING_TOLERANCE,
                &contains,
            ));

            if (contains == .TRUE) {
                if (object.mesh_index == Mesh.food) {
                    object.mesh_index = 0; // Mark this food as eaten.
                    app.num_food_objects -= 1;
                    if (app.num_food_objects == 0) {
                        app.player_to_next_level = 1.0;
                        return true;
                    }
                } else {
                    app.player_is_dead = 1.0;
                    return true;
                }
                break;
            }
        }

        const window_width: f32 = @floatFromInt(app.gpu_context.window_width);
        const window_height: f32 = @floatFromInt(app.gpu_context.window_height);
        const window_aspect = window_width / window_height;

        if (player.x < -0.5 * map_size_y * window_aspect) {
            player.x = 0.5 * map_size_y * window_aspect;
            player.rotation += std.math.tau;
        } else if (player.x > 0.5 * map_size_y * window_aspect) {
            player.x = -0.5 * map_size_y * window_aspect;
            player.rotation += std.math.tau;
        }

        if (player.y < 0.0) {
            player.y = map_size_y;
            player.rotation += std.math.tau;
        } else if (player.y > map_size_y) {
            player.y = 0.0;
            player.rotation += std.math.tau;
        }

        return true;
    }

    fn draw(app: *AppState) void {
        const gc = &app.gpu_context;

        gc.begin_command_list();

        gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
            .Type = .BUFFER,
            .NumBarriers = 2,
            .u = .{ .pBufferBarriers = &[_]d3d12.BUFFER_BARRIER{ .{
                .SyncBefore = .{},
                .SyncAfter = .{ .COPY = true },
                .AccessBefore = .{ .NO_ACCESS = true },
                .AccessAfter = .{ .COPY_DEST = true },
                .pResource = app.frame_state_buffer,
            }, .{
                .SyncBefore = .{},
                .SyncAfter = .{ .COPY = true },
                .AccessBefore = .{ .NO_ACCESS = true },
                .AccessAfter = .{ .COPY_DEST = true },
                .pResource = app.object_buffer,
            } } },
        }});

        {
            const proj = proj: {
                const width: f32 = @floatFromInt(gc.window_width);
                const height: f32 = @floatFromInt(gc.window_height);
                const aspect = width / height;

                break :proj orthographic_off_center(
                    -0.5 * map_size_y * aspect,
                    0.5 * map_size_y * aspect,
                    0.0,
                    map_size_y,
                    0.0,
                    1.0,
                );
            };

            const upload_mem, const buffer, const offset =
                gc.allocate_upload_buffer_region(cgc.FrameState, 1);

            upload_mem[0] = .{
                .proj = transpose(proj),
            };

            gc.command_list.CopyBufferRegion(
                app.frame_state_buffer,
                0,
                buffer,
                offset,
                upload_mem.len * @sizeOf(@TypeOf(upload_mem[0])),
            );
        }

        {
            const upload_mem, const buffer, const offset =
                gc.allocate_upload_buffer_region(cgc.Object, @intCast(app.objects.items.len));

            for (app.objects.items, 0..) |object, i| upload_mem[i] = object;

            gc.command_list.CopyBufferRegion(
                app.object_buffer,
                0,
                buffer,
                offset,
                upload_mem.len * @sizeOf(@TypeOf(upload_mem[0])),
            );
        }

        gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
            .Type = .BUFFER,
            .NumBarriers = 2,
            .u = .{ .pBufferBarriers = &[_]d3d12.BUFFER_BARRIER{ .{
                .SyncBefore = .{ .COPY = true },
                .SyncAfter = .{ .DRAW = true },
                .AccessBefore = .{ .COPY_DEST = true },
                .AccessAfter = .{ .CONSTANT_BUFFER = true },
                .pResource = app.frame_state_buffer,
            }, .{
                .SyncBefore = .{ .COPY = true },
                .SyncAfter = .{ .DRAW = true },
                .AccessBefore = .{ .COPY_DEST = true },
                .AccessAfter = .{ .SHADER_RESOURCE = true },
                .pResource = app.object_buffer,
            } } },
        }});

        gc.command_list.OMSetRenderTargets(
            1,
            &[_]d3d12.CPU_DESCRIPTOR_HANDLE{gc.display_target_descriptor()},
            .TRUE,
            null,
        );
        gc.command_list.ClearRenderTargetView(gc.display_target_descriptor(), &.{ 1.0, 1.0, 1.0, 0.0 }, 0, null);

        gc.command_list.IASetPrimitiveTopology(.TRIANGLELIST);
        gc.command_list.SetPipelineState(app.pso);
        gc.command_list.SetGraphicsRootSignature(app.pso_rs);

        // Draw all objects except player
        for (app.objects.items[1..], 1..) |object, object_id| {
            if (object.mesh_index == 0) continue; // Already eaten food.

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
        // Draw player (always on top of other objects).
        gc.command_list.SetGraphicsRoot32BitConstants(
            0,
            2,
            &[_]u32{ app.meshes.items[Mesh.player].first_vertex, 0 },
            0,
        );
        gc.command_list.DrawInstanced(
            app.meshes.items[Mesh.player].num_vertices,
            1,
            0,
            0,
        );

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

fn add_food(objects: *std.ArrayList(cgc.Object), x: f32, y: f32) void {
    const fc = 0xaa_0f_6c_0b;
    objects.append(.{ .color = fc, .mesh_index = Mesh.food, .x = x, .y = y }) catch unreachable;
}

fn define_and_upload_objects(
    allocator: std.mem.Allocator,
    gc: *GpuContext,
    current_level: u32,
) !struct { std.ArrayList(cgc.Object), u32, *d3d12.IResource } {
    var objects = std.ArrayList(cgc.Object).init(allocator);

    try objects.append(.{
        .color = 0xaa_bb_00_00,
        .mesh_index = Mesh.player,
        .x = player_start_x,
        .y = player_start_y,
    });
    try objects.append(.{
        .color = 0,
        .mesh_index = Mesh.level1 + current_level - 1,
        .x = 0.0,
        .y = 0.0,
    });

    var num_food_objects = objects.items.len;
    if (current_level == 1) {
        add_food(&objects, -197.0, 352.0);
        add_food(&objects, 232.0, 364.0);
        add_food(&objects, 100.0, 802.0);
        add_food(&objects, -160.0, 800.0);
    } else if (current_level == 2) {
        add_food(&objects, -374.0, 427.5);
        add_food(&objects, -541.0, 386.0);
        add_food(&objects, -4.0, 498.0);
        add_food(&objects, -341.0, 244.0);
        add_food(&objects, 61.0, 580.0);
        add_food(&objects, 167.0, 636.0);
        add_food(&objects, -214.5, 192.6);
        add_food(&objects, -439.0, 762.6);
        add_food(&objects, -391.0, 850.0);
        add_food(&objects, -621.0, 709.0);
        add_food(&objects, 213.0, 385.0);
        add_food(&objects, 628.0, 280.0);
        add_food(&objects, 467.0, 82.0);
        add_food(&objects, 213.0, 385.0);
    } else {
        unreachable;
    }
    num_food_objects = objects.items.len - num_food_objects;

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

    vhr(gc.command_allocators[0].Reset());
    vhr(gc.command_list.Reset(gc.command_allocators[0], null));

    const upload_mem, const buffer, const offset =
        gc.allocate_upload_buffer_region(cgc.Object, @intCast(objects.items.len));

    for (objects.items, 0..) |object, i| upload_mem[i] = object;

    gc.command_list.CopyBufferRegion(
        object_buffer,
        0,
        buffer,
        offset,
        upload_mem.len * @sizeOf(@TypeOf(upload_mem[0])),
    );

    vhr(gc.command_list.Close());
    gc.command_queue.ExecuteCommandLists(1, &[_]*d3d12.ICommandList{@ptrCast(gc.command_list)});
    gc.finish_gpu_commands();

    return .{ objects, @intCast(num_food_objects), object_buffer };
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
        //var geo: *d2d1.IEllipseGeometry = undefined;
        //vhr(d2d_factory.CreateEllipseGeometry(
        //    &.{
        //        .point = .{ .x = 0.0, .y = 0.0 },
        //        .radiusX = 15.0,
        //        .radiusY = 10.0,
        //    },
        //    @ptrCast(&geo),
        //));

        var geo: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo)));

        var geo_sink: *d2d1.IGeometrySink = undefined;
        vhr(geo.Open(@ptrCast(&geo_sink)));
        defer _ = geo_sink.Release();

        const path11 = [_]f32{
            10.5,   -9, 8.901,  -7, 9.701, -5,
            2.101,  -8, -7.999, -8, -14.4, -2,
            -17.2,  1,  -14.2,  5,  -11.1, 6,
            -4.699, 9,  3.101,  9,  9.601, 6,
            8.601,  9,  12.6,   11, 14.6,  9,
            16.5,   8,  15.2,   4,  12.8,  4,
            15.1,   2,  14.9,   -1, 12.6,  -3,
            15.4,   -3, 16.6,   -7, 14.1,  -8,
            13.6,   -9, 13.1,   -9, 12.5,  -9,
        };

        geo_sink.BeginFigure(.{ .x = 12.5, .y = -9.0 }, .FILLED);
        geo_sink.AddBeziers(@ptrCast(&path11), @sizeOf(@TypeOf(path11)) / @sizeOf(d2d1.BEZIER_SEGMENT));
        geo_sink.EndFigure(.CLOSED);
        vhr(geo_sink.Close());

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

        meshes.items[Mesh.player] = .{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = @ptrCast(geo),
        };
    }

    {
        var geo: *d2d1.IEllipseGeometry = undefined;
        vhr(d2d_factory.CreateEllipseGeometry(
            &.{
                .point = .{ .x = 0.0, .y = 0.0 },
                .radiusX = 15.0,
                .radiusY = 15.0,
            },
            @ptrCast(&geo),
        ));

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

        meshes.items[Mesh.food] = .{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = @ptrCast(geo),
        };
    }

    // Level 1
    {
        var geo: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo)));

        var geo_sink: *d2d1.IGeometrySink = undefined;
        vhr(geo.Open(@ptrCast(&geo_sink)));
        defer _ = geo_sink.Release();

        const path9 = [_]f32{
            -89.49, 177.3, -90.59, 177.6, -91.69, 178.2,
            -128.5, 197.2, -69.09, 391.6, -92.09, 429.5,
            -115,   467.4, -386.5, 426.9, -394.2, 468.3,
            -401.9, 509.7, -189.6, 539.3, -186.8, 582.3,
            -183.9, 625.3, -316.2, 737.7, -298.6, 773.2,
            -280.9, 808.7, -152.9, 635.5, -112.6, 652.8,
            -72.19, 670.1, -72.09, 879,   -32.59, 872.7,
            7.012,  866.4, -6.488, 699.7, 34.61,  687.2,
            75.61,  674.6, 279.5,  764.6, 306.2,  730.1,
            332.8,  695.6, 103.4,  641.3, 118.5,  602.1,
            133.5,  563,   404.3,  480.4, 394.1,  442.3,
            383.8,  404.2, 161.9,  482.9, 130.3,  450.9,
            98.81,  418.9, 193.4,  224.4, 161.9,  201.7,
            130.5,  179,   0.5118, 408.2, -41.59, 397.8,
            -82.39, 387.7, -56.59, 173.3, -88.39, 177.2,
        };

        geo_sink.BeginFigure(.{ .x = -88.39, .y = 177.2 }, .FILLED);
        geo_sink.AddBeziers(@ptrCast(&path9), @sizeOf(@TypeOf(path9)) / @sizeOf(d2d1.BEZIER_SEGMENT));
        geo_sink.EndFigure(.CLOSED);
        vhr(geo_sink.Close());

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

        meshes.items[Mesh.level1] = .{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = @ptrCast(geo),
        };
    }

    // Level 2
    {
        var geo: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo)));

        var geo_sink: *d2d1.IGeometrySink = undefined;
        vhr(geo.Open(@ptrCast(&geo_sink)));
        defer _ = geo_sink.Release();

        const path1 = [_]f32{
            -567.1, 259,   -616.3, 313.1, -616.3, 375.7,
            -616.3, 416,   -612.9, 469,   -578.9, 490.8,
            -568.7, 497.4, -548.6, 497.2, -542.7, 486.6,
            -523.9, 452.7, -594.2, 420.3, -592.6, 381.6,
            -591.6, 357.2, -562.4, 341.7, -555.8, 318.1,
            -550.2, 297.9, -561,   275.2, -554.6, 255.2,
            -538.3, 204.1, -446,   172.9, -463.8, 122.3,
            -471.1, 101.6, -506.4, 95.16, -526.7, 103.3,
            -547.2, 111.5, -554,   139.4, -559.3, 160.8,
            -562.2, 172.5, -556.5, 185,   -558.2, 197,
        };
        const path3 = [_]f32{
            -473.5, 310.3, -474,   334.6, -475.1, 358.4,
            -476,   379.2, -476.4, 400.1, -473.9, 420.7,
            -469.7, 455.7, -476.1, 499.4, -450.8, 524,
            -435.6, 538.7, -400.9, 553,   -388.5, 535.9,
            -369,   509,   -432.2, 481.5, -436.5, 448.6,
            -440.4, 419.1, -437.7, 381.4, -415.2, 362,
            -392.5, 342.4, -343.6, 377.7, -325.6, 353.7,
            -315.8, 340.6, -321.2, 314.3, -335.1, 305.6,
            -357.3, 291.7, -388.8, 339.7, -411,   325.8,
            -425.7, 316.6, -421.5, 292.1, -421.1, 274.7,
            -420.5, 250.2, -382.7, 216.7, -403.3, 203.5,
            -418.7, 193.7, -434.9, 223.4, -446,   237.9,
            -456.9, 252.1, -462.8, 269.9, -467.4, 287.2,
        };
        const path5 = [_]f32{
            -100.4, 343.8, -121.5, 433.8, -127, 499,
            -132.8, 567.9, -113,   647.2, -65,  697,
            6.891,  771.6, 139,    854.2, 228,  801,
            239.3,  794.3, 240.8,  773.3, 234,  762,
            185.1,  681.2, 33.81,  735.8, -34,  670,
            -75.96, 629.3, -98.81, 564.4, -96,  506,
            -93.68, 457.8, -77.48, 392.3, -32,  376,
            9.719,  361.1, 56.11,  401.3, 89,   431,
            114.5,  454,   110.4,  504.4, 141,  520,
            205.5,  552.8, 319.2,  559.7, 357,  498,
            365.2,  484.6, 353.7,  461.8, 340,  454,
            288.7,  424.7, 219.2,  506.6, 165,  483,
            135.7,  470.2, 141.7,  424.5, 118,  403,
            76.09,  365.1, 15.86,  306.9, -38,  324,
        };
        const path6 = [_]f32{
            -518.2, 737.3, -611.7, 791.9, -594, 851,
            -573.8, 918.3, -494.6, 967.4, -425, 977,
            -411.2, 978.9, -388.5, 975.7, -386, 962,
            -374.4, 898.4, -512.1, 894.9, -531, 833,
            -542.1, 796.8, -533.2, 745.8, -503, 723,
            -425.1, 664.1, -262.5, 813.4, -210, 731,
            -197.6, 711.5, -221.4, 681.3, -241, 669,
            -309.4, 626.2, -414.6, 708.8, -483, 666,
            -517.7, 644.2, -500.6, 572.9, -538, 556,
            -565.3, 543.6, -616.9, 550.1, -625, 579,
            -637.2, 622.6, -540.4, 632.7, -531, 677,
        };
        const path7 = [_]f32{
            285.9, 148.3, 351.2, 203.3, 388, 250,
            423.4, 294.9, 485.4, 315.4, 517, 363,
            548.1, 409.8, 575.4, 467.1, 570, 523,
            565.7, 567.6, 522.2, 599.1, 504, 640,
            483.1, 686.9, 449,   735,   455, 786,
            460.8, 835.5, 484.7, 905.6, 534, 913,
            550.6, 915.5, 568.6, 896.4, 572, 880,
            580.5, 838.7, 518.5, 808.2, 517, 766,
            515,   707.5, 551.8, 653.1, 582, 603,
            595.5, 580.5, 629.5, 569,   633, 543,
            638.5, 501.8, 592.6, 469.6, 580, 430,
            570.3, 399.3, 576.8, 364,   563, 335,
            550.7, 309.2, 509.3, 298.5, 507, 270,
            504.1, 233.3, 572.9, 212,   565, 176,
            560.4, 155.3, 533,   138.2, 512, 141,
            479,   145.4, 479.3, 217.9, 446, 216,
            387.9, 212.8, 402.2, 88.14, 346, 73,
            331.5, 69.08, 309.8, 77.73, 305, 92,
        };

        geo_sink.BeginFigure(.{ .x = -558.2, .y = 197.0 }, .FILLED);
        geo_sink.AddBeziers(@ptrCast(&path1), @sizeOf(@TypeOf(path1)) / @sizeOf(d2d1.BEZIER_SEGMENT));
        geo_sink.EndFigure(.CLOSED);
        geo_sink.BeginFigure(.{ .x = -467.4, .y = 287.2 }, .FILLED);
        geo_sink.AddBeziers(@ptrCast(&path3), @sizeOf(@TypeOf(path3)) / @sizeOf(d2d1.BEZIER_SEGMENT));
        geo_sink.EndFigure(.CLOSED);
        geo_sink.BeginFigure(.{ .x = -38.0, .y = 324.0 }, .FILLED);
        geo_sink.AddBeziers(@ptrCast(&path5), @sizeOf(@TypeOf(path5)) / @sizeOf(d2d1.BEZIER_SEGMENT));
        geo_sink.EndFigure(.CLOSED);
        geo_sink.BeginFigure(.{ .x = -531.0, .y = 677.0 }, .FILLED);
        geo_sink.AddBeziers(@ptrCast(&path6), @sizeOf(@TypeOf(path6)) / @sizeOf(d2d1.BEZIER_SEGMENT));
        geo_sink.EndFigure(.CLOSED);
        geo_sink.BeginFigure(.{ .x = 305.0, .y = 92.0 }, .FILLED);
        geo_sink.AddBeziers(@ptrCast(&path7), @sizeOf(@TypeOf(path7)) / @sizeOf(d2d1.BEZIER_SEGMENT));
        geo_sink.EndFigure(.CLOSED);
        vhr(geo_sink.Close());

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

        meshes.items[Mesh.level2] = .{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = @ptrCast(geo),
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

    vhr(gc.command_allocators[0].Reset());
    vhr(gc.command_list.Reset(gc.command_allocators[0], null));

    const upload_mem, const buffer, const offset =
        gc.allocate_upload_buffer_region(cgc.Vertex, @intCast(vertices.items.len));

    for (vertices.items, 0..) |vert, i| upload_mem[i] = vert;

    gc.command_list.CopyBufferRegion(
        vertex_buffer,
        0,
        buffer,
        offset,
        upload_mem.len * @sizeOf(@TypeOf(upload_mem[0])),
    );

    vhr(gc.command_list.Close());
    gc.command_queue.ExecuteCommandLists(1, &[_]*d3d12.ICommandList{@ptrCast(gc.command_list)});
    gc.finish_gpu_commands();

    for (meshes.items) |mesh| {
        var contains: w32.BOOL = .FALSE;
        vhr(mesh.geometry.FillContainsPoint(
            .{ .x = 0.0, .y = 0.0 },
            &d2d1.MATRIX_3X2_F.translation(0.0, 0.0),
            d2d1.DEFAULT_FLATTENING_TOLERANCE,
            &contains,
        ));
    }

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

fn create_window(width: i32, height: i32) w32.HWND {
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

    const window = w32.CreateWindowExA(
        0,
        window_name,
        window_name,
        w32.WS_OVERLAPPEDWINDOW,
        w32.CW_USEDEFAULT,
        w32.CW_USEDEFAULT,
        width,
        height,
        null,
        null,
        winclass.hInstance,
        null,
    ).?;

    _ = w32.ShowWindow(window, w32.SW_SHOWMAXIMIZED);

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

    fn _query_interface(
        _: *w32.IUnknown,
        _: *const w32.GUID,
        _: ?*?*anyopaque,
    ) callconv(w32.WINAPI) w32.HRESULT {
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
