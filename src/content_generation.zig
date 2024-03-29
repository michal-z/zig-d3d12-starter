const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d12 = @import("win32/d3d12.zig");
const d2d1 = @import("win32/d2d1.zig");
const cpu_gpu = @cImport(@cInclude("cpu_gpu_shared.h"));

const GpuContext = @import("GpuContext.zig");
const vhr = GpuContext.vhr;

pub const Mesh = struct {
    first_vertex: u32,
    num_vertices: u32,

    geometry: ?*d2d1.IGeometry,

    pub const num_levels = 5;

    pub const invalid: u32 = 0;
    pub var player: u32 = undefined;
    pub var food: u32 = undefined;

    var ellipse_50_35: u32 = undefined;
    var ellipse_50_35_stroke: u32 = undefined;
    var fullscreen_rect: u32 = undefined;
    var level1: u32 = undefined;
    var level1_stroke: u32 = undefined;
    var level2: u32 = undefined;
    var level2_stroke: u32 = undefined;
    var level3: u32 = undefined;
    var level3_stroke: u32 = undefined;
    var level4: u32 = undefined;
    var level4_stroke: u32 = undefined;
    var level5: u32 = undefined;
};

pub const map_size_x = 1400.0;
pub const map_size_y = 1050.0;
pub const player_start_x = -600.0;
pub const player_start_y = 20.0;

fn add_food(objects: *std.ArrayList(cpu_gpu.Object), num_food_objects: *u32, x: f32, y: f32) void {
    const fc = 0xaa_0f_6c_0b;
    objects.append(.{
        .flags = cpu_gpu.obj_flag_is_food,
        .color = .{ fc, 0 },
        .mesh_index = .{ Mesh.food, Mesh.invalid },
        .x = x,
        .y = y,
    }) catch unreachable;
    num_food_objects.* += 1;
}

pub fn define_and_upload_objects(
    allocator: std.mem.Allocator,
    gc: *GpuContext,
    current_level: u32,
) !struct { std.ArrayList(cpu_gpu.Object), u32, *d3d12.IResource } {
    var objects = std.ArrayList(cpu_gpu.Object).init(allocator);
    var num_food_objects: u32 = 0;

    if (current_level == 1) {
        try objects.append(.{
            .color = .{ 0xaa_fd_f6_e3, 0 },
            .mesh_index = .{ Mesh.fullscreen_rect, Mesh.invalid },
            .x = 0.0,
            .y = 0.0,
        });
        try objects.append(.{
            .color = .{ 0xaa_22_44_99, 0 },
            .mesh_index = .{ Mesh.level1, Mesh.level1_stroke },
            .x = 0.0,
            .y = 0.0,
        });
        add_food(&objects, &num_food_objects, -197.0, 352.0);
        add_food(&objects, &num_food_objects, 232.0, 364.0);
        add_food(&objects, &num_food_objects, 100.0, 802.0);
        add_food(&objects, &num_food_objects, -160.0, 800.0);
        try objects.append(.{
            .color = .{ 0xaa_22_44_99, 0 },
            .mesh_index = .{ Mesh.ellipse_50_35, Mesh.ellipse_50_35_stroke },
            .x = -map_size_x / 2,
            .y = 100.0,
            .move_direction = 0.0,
            .move_speed = 125.0,
            .rotation_speed = 0.025,
        });
        try objects.append(.{
            .color = .{ 0xaa_22_44_99, 0 },
            .mesh_index = .{ Mesh.ellipse_50_35, Mesh.ellipse_50_35_stroke },
            .x = map_size_x / 2,
            .y = 100.0,
            .move_direction = std.math.pi,
            .move_speed = 125.0,
            .rotation_speed = -0.025,
        });
    } else if (current_level == 2) {
        try objects.append(.{
            .color = .{ 0xaa_fd_f6_e3, 0 },
            .mesh_index = .{ Mesh.fullscreen_rect, Mesh.invalid },
            .x = 0.0,
            .y = 0.0,
        });
        try objects.append(.{
            .color = .{ 0xaa_22_44_99, 0 },
            .mesh_index = .{ Mesh.level2, Mesh.level2_stroke },
            .x = 0.0,
            .y = 0.0,
        });
        add_food(&objects, &num_food_objects, 252.0, 418.5);
        add_food(&objects, &num_food_objects, -231.2, 818.8);
        add_food(&objects, &num_food_objects, -41.37, 134.4);
        add_food(&objects, &num_food_objects, 499.2, 158.1);
        add_food(&objects, &num_food_objects, -631.7, 605.0);
        add_food(&objects, &num_food_objects, 49.85, 644.6);
        add_food(&objects, &num_food_objects, 384.9, 552.8);
    } else if (current_level == 3) {
        try objects.append(.{
            .color = .{ 0xaa_fd_f6_e3, 0 },
            .mesh_index = .{ Mesh.fullscreen_rect, Mesh.invalid },
            .x = 0.0,
            .y = 0.0,
        });
        try objects.append(.{
            .color = .{ 0xaa_22_44_99, 0 },
            .mesh_index = .{ Mesh.level3, Mesh.level3_stroke },
            .x = 0.0,
            .y = 0.0,
        });
        add_food(&objects, &num_food_objects, -374.0, 427.5);
        add_food(&objects, &num_food_objects, -541.0, 386.0);
        add_food(&objects, &num_food_objects, -4.0, 498.0);
        add_food(&objects, &num_food_objects, -341.0, 244.0);
        add_food(&objects, &num_food_objects, 61.0, 580.0);
        add_food(&objects, &num_food_objects, 167.0, 636.0);
        add_food(&objects, &num_food_objects, -214.5, 192.6);
        add_food(&objects, &num_food_objects, -439.0, 762.6);
        add_food(&objects, &num_food_objects, -391.0, 850.0);
        add_food(&objects, &num_food_objects, -621.0, 709.0);
        add_food(&objects, &num_food_objects, 213.0, 385.0);
        add_food(&objects, &num_food_objects, 628.0, 280.0);
        add_food(&objects, &num_food_objects, 467.0, 82.0);
        add_food(&objects, &num_food_objects, 213.0, 385.0);
    } else if (current_level == 4) {
        try objects.append(.{
            .color = .{ 0xaa_fd_f6_e3, 0 },
            .mesh_index = .{ Mesh.fullscreen_rect, Mesh.invalid },
            .x = 0.0,
            .y = 0.0,
        });
        try objects.append(.{
            .color = .{ 0xaa_22_44_99, 0 },
            .mesh_index = .{ Mesh.level4, Mesh.level4_stroke },
            .x = 0.0,
            .y = 0.0,
        });
        add_food(&objects, &num_food_objects, -197.0, 352.0);
        add_food(&objects, &num_food_objects, -5.0, 274.0);
        add_food(&objects, &num_food_objects, -296.0, 605.0);
        add_food(&objects, &num_food_objects, 232.0, 364.0);
        add_food(&objects, &num_food_objects, 252.0, 581.0);
        add_food(&objects, &num_food_objects, 100.0, 802.0);
        add_food(&objects, &num_food_objects, -160.0, 800.0);
    } else if (current_level == 5) {
        try objects.append(.{
            .color = .{ 0xaa_fd_f6_e3, 0 },
            .mesh_index = .{ Mesh.fullscreen_rect, Mesh.invalid },
            .x = 0.0,
            .y = 0.0,
        });
        try objects.append(.{
            .color = .{ 0, 0 },
            .mesh_index = .{ Mesh.level5, Mesh.invalid },
            .x = 0.0,
            .y = 0.0,
        });
        add_food(&objects, &num_food_objects, -17.0, 533.0);
        add_food(&objects, &num_food_objects, 313.0, 544.0);
        add_food(&objects, &num_food_objects, -106.0, 530.0);
        add_food(&objects, &num_food_objects, 261.0, 380.0);
        add_food(&objects, &num_food_objects, 295.0, 456.0);
        add_food(&objects, &num_food_objects, 67.0, 778.0);
        add_food(&objects, &num_food_objects, -133.0, 719.0);
        add_food(&objects, &num_food_objects, 398.0, 596.0);
        add_food(&objects, &num_food_objects, 412.0, 477.0);
        add_food(&objects, &num_food_objects, -415.0, 442.0);
        add_food(&objects, &num_food_objects, -424.0, 562.0);
        add_food(&objects, &num_food_objects, -396.0, 680.0);
        add_food(&objects, &num_food_objects, -327.0, 643.0);
        add_food(&objects, &num_food_objects, -39.0, 215.0);
        add_food(&objects, &num_food_objects, -72.0, 333.0);
    } else {
        unreachable;
    }

    // Player must be last object (for correct drawing order).
    try objects.append(.{
        .color = .{ 0xaa_bb_00_00, 0 },
        .mesh_index = .{ Mesh.player, Mesh.invalid },
        .x = player_start_x,
        .y = player_start_y,
        .move_speed = 250.0,
        .rotation_speed = 5.0,
    });

    var object_buffer: *d3d12.IResource = undefined;
    vhr(gc.device.CreateCommittedResource3(
        &.{ .Type = .DEFAULT },
        d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
        &.{
            .Dimension = .BUFFER,
            .Width = objects.items.len * @sizeOf(cpu_gpu.Object),
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
            @sizeOf(cpu_gpu.Object),
        ),
        .{ .ptr = gc.shader_dheap_start_cpu.ptr +
            @as(u32, @intCast(cpu_gpu.rdh_object_buffer)) *
            gc.shader_dheap_descriptor_size },
    );

    vhr(gc.command_allocators[0].Reset());
    vhr(gc.command_list.Reset(gc.command_allocators[0], null));

    const upload_mem, const buffer, const offset =
        gc.allocate_upload_buffer_region(cpu_gpu.Object, @intCast(objects.items.len));

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

pub fn define_and_upload_meshes(
    allocator: std.mem.Allocator,
    gc: *GpuContext,
    d2d_factory: *d2d1.IFactory,
) !struct { std.ArrayList(Mesh), *d3d12.IResource } {
    var vertices = std.ArrayList(cpu_gpu.Vertex).init(allocator);
    defer vertices.deinit();

    var tessellation_sink: TessellationSink = .{ .vertices = &vertices };

    var meshes = std.ArrayList(Mesh).init(allocator);

    // Index 0 is invalid mesh.
    try meshes.append(.{
        .first_vertex = 0,
        .num_vertices = 0,
        .geometry = null,
    });

    {
        var geo: *d2d1.IEllipseGeometry = undefined;
        vhr(d2d_factory.CreateEllipseGeometry(
            &.{
                .point = .{ .x = 0.0, .y = 0.0 },
                .radiusX = 15.0,
                .radiusY = 10.0,
            },
            @ptrCast(&geo),
        ));

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

        Mesh.player = @intCast(meshes.items.len);
        try meshes.append(.{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = @ptrCast(geo),
        });
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

        Mesh.food = @intCast(meshes.items.len);
        try meshes.append(.{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = @ptrCast(geo),
        });
    }

    {
        var geo_fill: *d2d1.IEllipseGeometry = undefined;
        vhr(d2d_factory.CreateEllipseGeometry(
            &.{
                .point = .{ .x = 0.0, .y = 0.0 },
                .radiusX = 50.0,
                .radiusY = 35.0,
            },
            @ptrCast(&geo_fill),
        ));

        {
            const first_vertex = vertices.items.len;

            vhr(geo_fill.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.ellipse_50_35 = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = @ptrCast(geo_fill),
            });
        }

        var geo_stroke: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_stroke)));

        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_stroke.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            vhr(geo_fill.Widen(9.0, null, null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(geo_sink)));
        }

        {
            const first_vertex = vertices.items.len;

            vhr(geo_stroke.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.ellipse_50_35_stroke = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = @ptrCast(geo_stroke),
            });
        }
    }

    {
        var geo: *d2d1.IRectangleGeometry = undefined;
        vhr(d2d_factory.CreateRectangleGeometry(
            &.{
                .left = -map_size_x / 2,
                .top = 0.0,
                .right = map_size_x / 2,
                .bottom = map_size_y,
            },
            @ptrCast(&geo),
        ));
        defer _ = geo.Release();

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

        Mesh.fullscreen_rect = @intCast(meshes.items.len);
        try meshes.append(.{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = null,
        });
    }

    // Level 1
    {
        // We *won't* need it for collision detection.
        var geo_fill: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_fill)));
        defer _ = geo_fill.Release();

        // We *will* need it for collision detection.
        var geo_stroke: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_stroke)));

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

        // Fill shape
        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_fill.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            geo_sink.BeginFigure(.{ .x = -88.39, .y = 177.2 }, .FILLED);
            geo_sink.AddBeziers(@ptrCast(&path9), @sizeOf(@TypeOf(path9)) / @sizeOf(d2d1.BEZIER_SEGMENT));
            geo_sink.EndFigure(.CLOSED);
        }

        // Stroke shape
        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_stroke.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            vhr(geo_fill.Widen(9.0, null, null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(geo_sink)));
        }

        // Tessellate fill shape
        {
            const first_vertex = vertices.items.len;

            vhr(geo_fill.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.level1 = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = null,
            });
        }

        // Tessellate stroke shape
        {
            const first_vertex = vertices.items.len;

            vhr(geo_stroke.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.level1_stroke = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = @ptrCast(geo_stroke),
            });
        }
    }

    // Level 2
    {
        var geo_fill: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_fill)));
        defer _ = geo_fill.Release();

        var geo_stroke: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_stroke)));

        const path4 = [_]f32{
            -520.3, 201.3, -572.5, 219.2, -598.2, 244.7,
            -642.4, 288.6, -583.9, 368.6, -572.7, 429.9,
            -563.2, 481.8, -538.7, 531.4, -537.4, 584.1,
            -534.3, 706.6, -659,   838.2, -601,   946.1,
            -578.1, 988.7, -515.6, 995.3, -468.1, 1004,
            -267.1, 1041,  -60.07, 975.5, 144.3,  974.4,
            294.3,  973.6, 479.3,  1088,  594,    991.4,
            666,    930.7, 627.6,  805.5, 631,    711.4,
            635.8,  576.9, 682.7,  419.6, 607,    308.3,
            575.6,  262.1, 509.3,  250.6, 455,    237.6,
            396.2,  223.5, 335.6,  218.6, 274.7,  218.1,
            213.8,  217.5, 152.4,  221.4, 92,     224.9,
            -33.67, 232.1, -197.3, 177.1, -246,   251.7,
            -294.8, 326.3, -190.7, 383.9, -203.6, 452.6,
            -216.5, 521.2, -252.6, 680.8, -79.99, 642.7,
            -22.73, 625.8, 75.09,  602,   114.6,  421.4,
            146.8,  274.3, 261.1,  290,   373,    347.9,
            433.3,  379.1, 485.6,  437.4, 506,    502.1,
            524.8,  561.7, 484.3,  579.4, 502.6,  639.2,
            519.5,  694.3, 468.5,  773.9, 373,    676,
            293.2,  594.2, 239.7,  651.8, 144.3,  690.1,
            38.58,  732.6, -49.61, 680.9, -12.43, 781,
            18.59,  864.4, -67.47, 830.1, -52.26, 912.2,
            -39.54, 980.8, -135.7, 965.2, -205,   973,
            -284.9, 982,   -395.1, 984.6, -439.8, 917.8,
            -468,   875.8, -436.2, 814.2, -415.7, 767.9,
            -392.2, 714.9, -328.2, 686.1, -306.8, 632.2,
            -296.1, 605.4, -295.3, 574.4, -299.8, 545.9,
            -310.5, 477.4, -363.7, 421.2, -379,   353.6,
            -384.8, 328.2, -381.1, 314.3, -383.3, 275.6,
            -386.2, 224.3, -427.1, 203.8, -473.7, 202.6,
        };

        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_fill.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            geo_sink.BeginFigure(.{ .x = -473.7, .y = 202.6 }, .FILLED);
            geo_sink.AddBeziers(@ptrCast(&path4), @sizeOf(@TypeOf(path4)) / @sizeOf(d2d1.BEZIER_SEGMENT));
            geo_sink.EndFigure(.CLOSED);
        }

        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_stroke.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            vhr(geo_fill.Widen(9.0, null, null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(geo_sink)));
        }

        {
            const first_vertex = vertices.items.len;

            vhr(geo_fill.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.level2 = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = null,
            });
        }

        {
            const first_vertex = vertices.items.len;

            vhr(geo_stroke.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.level2_stroke = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = @ptrCast(geo_stroke),
            });
        }
    }

    // Level 3
    {
        var geo_fill: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_fill)));
        defer _ = geo_fill.Release();

        var geo_stroke: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_stroke)));

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

        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_fill.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
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
        }

        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_stroke.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            vhr(geo_fill.Widen(9.0, null, null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(geo_sink)));
        }

        {
            const first_vertex = vertices.items.len;

            vhr(geo_fill.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.level3 = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = null,
            });
        }

        {
            const first_vertex = vertices.items.len;

            vhr(geo_stroke.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.level3_stroke = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = @ptrCast(geo_stroke),
            });
        }
    }

    // Level 4
    {
        var geo_fill: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_fill)));
        defer _ = geo_fill.Release();

        var geo_stroke: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_stroke)));

        const path1_0 = [_]f32{
            -244.8, 95.16, -257.1, 97.17, -271,   101,
            -403,   137.3, -514.8, 49.98, -588,   130,
            -786.9, 347.5, -651.3, 767.5, -443,   976,
            -310.6, 1109,  156.2,  908.5, 319.1,  949,
            544.6,  1005,  744,    946.9, 576,    878,
            516.2,  853.5, 514.7,  812.2, 522.6,  789.5,
            543.4,  730,   425.4,  797.4, 464,    816,
            617.3,  889.9, 258.7,  915.4, 95.2,   940,
            -68.33, 965,   -315.8, 1045,  -412,   892,
            -473.3, 794.5, -739.7, 696.8, -560.3, 343.9,
            -509.4, 243.8, -662.5, 253.7, -556,   171,
            -430.8, 73.79, -365.3, 182.7, -271,   171,
            -169.1, 158.3, -160.1, 90.76, -234.2, 94.61,
        };
        const path1_1 = [_]f32{
            -99.43, 153.6, -125,   172.4, -130.5, 183.2,
            -161.3, 243.5, -70.71, 323.9, -69.09, 391.6,
            -67.48, 458.7, -126.2, 417.7, -128,   465.4,
            -131.4, 556.8, -304.4, 386.5, -386.5, 426.9,
            -446.1, 456.2, -454.7, 541.4, -401.9, 509.7,
            -340.6, 472.9, -260.1, 527.8, -189.6, 539.3,
            -138.7, 547.6, -140.9, 595.9, -183.9, 625.3,
            -231.7, 658,   -260.1, 723.4, -316.2, 737.7,
            -385.8, 755.4, -358.8, 809,   -280.9, 808.7,
            -209.1, 808.4, -146.4, 707,   -152.9, 635.5,
            -156.8, 592.6, -104,   625.8, -72.19, 670.1,
            -31.56, 726.6, -80.45, 819.6, -69.24, 888.4,
            -61.4,  936.5, -15.7,  907.4, 13.16,  853,
            39.29,  803.8, -38.5,  745.3, -6.488, 699.7,
            34.9,   640.7, 15.68,  714,   75.61,  674.6,
            165.5,  615.5, 247.1,  697.8, 279.5,  764.6,
            306.2,  819.6, 363.9,  718.5, 287.4,  702.8,
            224.8,  689.9, 179.9,  621.8, 103.4,  641.3,
            44.89,  656.2, 57.85,  537.3, 133.5,  563,
            219,    592.1, 235.3,  484.4, 329.3,  493.4,
            406.9,  500.8, 413.3,  378.1, 348.8,  445.2,
            294.4,  501.8, 142.4,  380,   161.9,  482.9,
            169,    520.1, 117.3,  500.3, 98.81,  418.9,
            75.74,  317,   264.9,  233.9, 193.4,  224.4,
            138.3,  217.1, 53.9,   201.6, 82.5,   266,
            118.1,  346.3, -34.06, 345.2, 0.5117, 408.2,
            20.82,  445.2, 8.578,  466.9, -41.59, 397.8,
            -78.23, 347.3, -21.43, 345.2, -41.39, 290.7,
            -66.14, 223.1, -7.633, 241.1, -37.59, 178.3,
            -46.57, 159.5, -60.64, 153,   -75.19, 153.2,
        };

        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_fill.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            geo_sink.BeginFigure(.{ .x = -234.2, .y = 94.61 }, .FILLED);
            geo_sink.AddBeziers(@ptrCast(&path1_0), @sizeOf(@TypeOf(path1_0)) / @sizeOf(d2d1.BEZIER_SEGMENT));
            geo_sink.EndFigure(.CLOSED);
            geo_sink.BeginFigure(.{ .x = -75.19, .y = 153.2 }, .FILLED);
            geo_sink.AddBeziers(@ptrCast(&path1_1), @sizeOf(@TypeOf(path1_1)) / @sizeOf(d2d1.BEZIER_SEGMENT));
            geo_sink.EndFigure(.CLOSED);
        }

        {
            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_stroke.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            vhr(geo_fill.Widen(9.0, null, null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(geo_sink)));
        }

        {
            const first_vertex = vertices.items.len;

            vhr(geo_fill.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.level4 = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = null,
            });
        }

        {
            const first_vertex = vertices.items.len;

            vhr(geo_stroke.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

            Mesh.level4_stroke = @intCast(meshes.items.len);
            try meshes.append(.{
                .first_vertex = @intCast(first_vertex),
                .num_vertices = @intCast(vertices.items.len - first_vertex),
                .geometry = @ptrCast(geo_stroke),
            });
        }
    }

    // Level 5
    {
        var geo: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo)));

        var geo_sink: *d2d1.IGeometrySink = undefined;
        vhr(geo.Open(@ptrCast(&geo_sink)));
        defer _ = geo_sink.Release();

        const path2 = [_]f32{
            -182.8, 68.69, -347.7, 168.3, -425.2, 318.3,
            -505.7, 464.6, -497,   656.4, -396.2, 790.9,
            -289.2, 940.6, -81.88, 1012,  92.79,  949.3,
            278.6,  888.3, 402.2,  682.6, 365.8,  490,
            337.6,  312.5, 171.9,  171.4, -7.317, 168.7,
            -162.7, 161.9, -312.8, 266.8, -362.3, 413.7,
            -414.3, 551.5, -366.5, 719.7, -246.3, 806.1,
            -132.7, 894.7, 40.5,   899.1, 153.3,  806.9,
            268.3,  718.8, 311,    545.9, 238.8,  418,
            172.9,  292.6, 7.661,  228.6, -123.5, 286.9,
            -248.9, 337.4, -321.4, 492.2, -272,   619.7,
            -230.2, 740.6, -83.33, 813.6, 37.09,  766,
            148.2,  727,   214,    589.7, 166,    480.3,
            125.7,  374.9, -14.83, 321.1, -111.8, 383.5,
            -194.6, 431.3, -225.3, 553.6, -163.5, 629.9,
            -114.2, 698.3, -2.291, 712.3, 55.56,  647.3,
            106.9,  597.1, 104.5,  503.7, 52.34,  515.2,
            0.17,   526.7, 100,    524.4, 60.43,  608.7,
            28.96,  675.8, -65.56, 691.3, -122,   646.7,
            -193.9, 598.2, -197.9, 487,   -139.4, 426.3,
            -76.15, 351.3, 48.14,  356.3, 113.6,  425.8,
            191.8,  500.2, 183.5,  635.8, 106.2,  707.8,
            29.2,   787.9, -106.3, 787,   -189.2, 716.9,
            -280.1, 647,   -302.6, 510,   -246,   411.7,
            -191.7, 306.1, -60.13, 251.2, 53.49,  284.7,
            176.8,  315.6, 269.1,  437.2, 263.6,  564.6,
            262.4,  710.5, 143.2,  844.4, -2.296, 860.2,
            -162.4, 883.1, -326.8, 767.7, -360.7, 609.7,
            -402.4, 442.4, -296.7, 256.9, -133.8, 203.3,
            32.92,  142.8, 232.3,  227.4, 312.3,  383.9,
            396,    537.1, 351.2,  740.6, 221.1,  853.7,
            99.22,  966.2, -93.38, 984.2, -237.3, 904.3,
            -385.4, 828.6, -477.1, 658.7, -458.8, 493.5,
            -443.1, 311.6, -304.5, 147.3, -126.3, 105,
            70.46,  53.34, 291.6,  152.9, 389.2,  330.1,
            484.9,  495.8, 462,    715.2, 345.4,  864.6,
            315.4,  903.7, 280.5,  939.2, 241.3,  969.2,
            439,    850.3, 518.8,  578.8, 427.5,  368.9,
            355.5,  194.3, 175.1,  74,    -13.55, 72.85,
        };

        geo_sink.BeginFigure(.{ .x = -13.55, .y = 72.85 }, .FILLED);
        geo_sink.AddBeziers(@ptrCast(&path2), @sizeOf(@TypeOf(path2)) / @sizeOf(d2d1.BEZIER_SEGMENT));
        geo_sink.EndFigure(.CLOSED);
        vhr(geo_sink.Close());

        const first_vertex = vertices.items.len;

        vhr(geo.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(&tessellation_sink)));

        Mesh.level5 = @intCast(meshes.items.len);
        try meshes.append(.{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = @ptrCast(geo),
        });
    }

    var vertex_buffer: *d3d12.IResource = undefined;
    vhr(gc.device.CreateCommittedResource3(
        &.{ .Type = .DEFAULT },
        d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
        &.{
            .Dimension = .BUFFER,
            .Width = vertices.items.len * @sizeOf(cpu_gpu.Vertex),
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
            @sizeOf(cpu_gpu.Vertex),
        ),
        .{ .ptr = gc.shader_dheap_start_cpu.ptr +
            @as(u32, @intCast(cpu_gpu.rdh_vertex_buffer)) *
            gc.shader_dheap_descriptor_size },
    );

    vhr(gc.command_allocators[0].Reset());
    vhr(gc.command_list.Reset(gc.command_allocators[0], null));

    const upload_mem, const buffer, const offset =
        gc.allocate_upload_buffer_region(cpu_gpu.Vertex, @intCast(vertices.items.len));

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

    return .{ meshes, vertex_buffer };
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

    vertices: *std.ArrayList(cpu_gpu.Vertex),

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
