const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d12 = @import("win32/d3d12.zig");
const d2d1 = @import("win32/d2d1.zig");
const cpu_gpu = @cImport(@cInclude("cpu_gpu_shared.h"));
const gen_level = @import("gen_level.zig");

const GpuContext = @import("GpuContext.zig");
const vhr = GpuContext.vhr;

const map_size_x = gen_level.map_size_x;
const map_size_y = gen_level.map_size_y;

pub const Mesh = struct {
    first_vertex: u32,
    num_vertices: u32,

    geometry: ?*d2d1.IGeometry,

    pub const invalid: u32 = 0;
    pub var player: u32 = undefined;
    pub var food: u32 = undefined;
    pub var fullscreen_rect: u32 = undefined;

    pub var circle_40: u32 = undefined;
    pub var circle_40_stroke: u32 = undefined;
    pub var circle_150: u32 = undefined;
    pub var circle_150_stroke: u32 = undefined;
    pub var ellipse_50_35: u32 = undefined;
    pub var ellipse_50_35_stroke: u32 = undefined;
    pub var round_rect_900_50: u32 = undefined;
    pub var round_rect_900_50_stroke: u32 = undefined;
    pub var arm_450: u32 = undefined;
    pub var arm_450_stroke: u32 = undefined;
    pub var arm_300: u32 = undefined;
    pub var arm_300_stroke: u32 = undefined;

    pub var gear_12_150: u32 = undefined;
    pub var gear_12_150_stroke: u32 = undefined;

    pub var star: u32 = undefined;
    pub var star_stroke: u32 = undefined;

    pub var spiral: u32 = undefined;

    pub var strange_star_and_wall: u32 = undefined;
    pub var strange_star_and_wall_stroke: u32 = undefined;
};

fn tessellate_geometry(
    geo: *d2d1.IGeometry,
    vertices: std.ArrayList(cpu_gpu.Vertex),
    tessellation_sink: *TessellationSink,
    meshes: *std.ArrayList(Mesh),
) !u32 {
    const first_vertex = vertices.items.len;

    vhr(geo.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(tessellation_sink)));

    const mesh_index: u32 = @intCast(meshes.items.len);
    try meshes.append(.{
        .first_vertex = @intCast(first_vertex),
        .num_vertices = @intCast(vertices.items.len - first_vertex),
        .geometry = geo,
    });
    return mesh_index;
}

fn tessellate_geometry_stroke(
    d2d_factory: *d2d1.IFactory6,
    geo_fill: *d2d1.IGeometry,
    width: f32,
    vertices: std.ArrayList(cpu_gpu.Vertex),
    tessellation_sink: *TessellationSink,
    meshes: *std.ArrayList(Mesh),
) !u32 {
    var geo_stroke: *d2d1.IPathGeometry = undefined;
    vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_stroke)));

    {
        var geo_sink: *d2d1.IGeometrySink = undefined;
        vhr(geo_stroke.Open(@ptrCast(&geo_sink)));
        defer {
            vhr(geo_sink.Close());
            _ = geo_sink.Release();
        }
        vhr(geo_fill.Widen(width, null, null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(geo_sink)));
    }

    const first_vertex = vertices.items.len;

    vhr(geo_stroke.Tessellate(null, d2d1.DEFAULT_FLATTENING_TOLERANCE, @ptrCast(tessellation_sink)));

    const mesh_index: u32 = @intCast(meshes.items.len);
    try meshes.append(.{
        .first_vertex = @intCast(first_vertex),
        .num_vertices = @intCast(vertices.items.len - first_vertex),
        .geometry = @ptrCast(geo_stroke),
    });
    return mesh_index;
}

const stroke_width = 9.0;

pub fn define_and_upload_meshes(
    allocator: std.mem.Allocator,
    gc: *GpuContext,
    d2d_factory: *d2d1.IFactory6,
) !struct { std.ArrayList(Mesh), *d3d12.IResource } {
    var vertices = std.ArrayList(cpu_gpu.Vertex).init(allocator);
    defer vertices.deinit();

    var tessellation_sink: TessellationSink = .{ .vertices = &vertices };

    var meshes = std.ArrayList(Mesh).init(allocator);

    // Index 0 is invalid mesh.
    try meshes.append(.{ .first_vertex = 0, .num_vertices = 0, .geometry = null });

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
        Mesh.player = try tessellate_geometry(@ptrCast(geo), vertices, &tessellation_sink, &meshes);
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
        Mesh.food = try tessellate_geometry(@ptrCast(geo), vertices, &tessellation_sink, &meshes);
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
        Mesh.ellipse_50_35 = try tessellate_geometry(@ptrCast(geo_fill), vertices, &tessellation_sink, &meshes);
        Mesh.ellipse_50_35_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    {
        var geo_fill: *d2d1.IEllipseGeometry = undefined;
        vhr(d2d_factory.CreateEllipseGeometry(
            &.{
                .point = .{ .x = 0.0, .y = 0.0 },
                .radiusX = 40.0,
                .radiusY = 40.0,
            },
            @ptrCast(&geo_fill),
        ));
        Mesh.circle_40 = try tessellate_geometry(@ptrCast(geo_fill), vertices, &tessellation_sink, &meshes);
        Mesh.circle_40_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    {
        var geo_fill: *d2d1.IEllipseGeometry = undefined;
        vhr(d2d_factory.CreateEllipseGeometry(
            &.{
                .point = .{ .x = 0.0, .y = 0.0 },
                .radiusX = 150.0,
                .radiusY = 150.0,
            },
            @ptrCast(&geo_fill),
        ));
        Mesh.circle_150 = try tessellate_geometry(@ptrCast(geo_fill), vertices, &tessellation_sink, &meshes);
        Mesh.circle_150_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    {
        const first_vertex = vertices.items.len;

        try vertices.append(.{ .x = -map_size_x / 2, .y = 0.0, .u = 0.0, .v = 0.0 });
        try vertices.append(.{ .x = map_size_x / 2, .y = 0.0, .u = 1.0, .v = 0.0 });
        try vertices.append(.{ .x = map_size_x / 2, .y = map_size_y, .u = 1.0, .v = 1.0 });
        try vertices.append(.{ .x = -map_size_x / 2, .y = 0.0, .u = 0.0, .v = 0.0 });
        try vertices.append(.{ .x = map_size_x / 2, .y = map_size_y, .u = 1.0, .v = 1.0 });
        try vertices.append(.{ .x = -map_size_x / 2, .y = map_size_y, .u = 0.0, .v = 1.0 });

        const mesh_index: u32 = @intCast(meshes.items.len);
        try meshes.append(.{
            .first_vertex = @intCast(first_vertex),
            .num_vertices = @intCast(vertices.items.len - first_vertex),
            .geometry = null,
        });

        Mesh.fullscreen_rect = mesh_index;
    }

    {
        const geo_fill: *d2d1.IGeometry = blk: {
            const w = 900.0;
            const h = 50.0;
            var temp: *d2d1.IRoundedRectangleGeometry = undefined;
            vhr(d2d_factory.CreateRoundedRectangleGeometry(
                &.{
                    .rect = .{ .left = 0.0, .top = 0.0, .right = w, .bottom = h },
                    .radiusX = 20.0,
                    .radiusY = 20.0,
                },
                @ptrCast(&temp),
            ));
            defer _ = temp.Release();

            var geo: *d2d1.ITransformedGeometry = undefined;
            vhr(d2d_factory.CreateTransformedGeometry(
                @ptrCast(temp),
                &d2d1.MATRIX_3X2_F.translation(-w / 2, -h / 2),
                @ptrCast(&geo),
            ));
            break :blk @ptrCast(geo);
        };
        Mesh.round_rect_900_50 = try tessellate_geometry(
            @ptrCast(geo_fill),
            vertices,
            &tessellation_sink,
            &meshes,
        );
        Mesh.round_rect_900_50_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    {
        const geo_fill: *d2d1.IGeometry = blk: {
            const w = 450.0;
            const h = 50.0;
            var temp: *d2d1.IRoundedRectangleGeometry = undefined;
            vhr(d2d_factory.CreateRoundedRectangleGeometry(
                &.{
                    .rect = .{ .left = 0.0, .top = 0.0, .right = w, .bottom = h },
                    .radiusX = 20.0,
                    .radiusY = 20.0,
                },
                @ptrCast(&temp),
            ));
            defer _ = temp.Release();

            var geo: *d2d1.ITransformedGeometry = undefined;
            vhr(d2d_factory.CreateTransformedGeometry(
                @ptrCast(temp),
                &d2d1.MATRIX_3X2_F.translation(0.0, -h / 2),
                @ptrCast(&geo),
            ));
            break :blk @ptrCast(geo);
        };

        Mesh.arm_450 = try tessellate_geometry(
            @ptrCast(geo_fill),
            vertices,
            &tessellation_sink,
            &meshes,
        );
        Mesh.arm_450_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    {
        const geo_fill: *d2d1.IGeometry = blk: {
            const w = 300.0;
            const h = 50.0;
            var temp: *d2d1.IRoundedRectangleGeometry = undefined;
            vhr(d2d_factory.CreateRoundedRectangleGeometry(
                &.{
                    .rect = .{ .left = 0.0, .top = 0.0, .right = w, .bottom = h },
                    .radiusX = 20.0,
                    .radiusY = 20.0,
                },
                @ptrCast(&temp),
            ));
            defer _ = temp.Release();

            var geo: *d2d1.ITransformedGeometry = undefined;
            vhr(d2d_factory.CreateTransformedGeometry(
                @ptrCast(temp),
                &d2d1.MATRIX_3X2_F.translation(0.0, -h / 2),
                @ptrCast(&geo),
            ));
            break :blk @ptrCast(geo);
        };

        Mesh.arm_300 = try tessellate_geometry(
            @ptrCast(geo_fill),
            vertices,
            &tessellation_sink,
            &meshes,
        );
        Mesh.arm_300_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    // gear_12_150 (number of tooths: 12, tooth size: 150.0)
    {
        var geo_fill: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_fill)));
        {
            const path9 = [_]f32{
                266.3,  -39.11, 284,    -37.39, 333.9,  -14.82, 333.9,  14.82,
                284,    37.39,  266.3,  39.11,  236.2,  34.69,  221.9,  88.06,
                250.2,  99.3,   264.7,  109.6,  296.6,  154.1,  281.8,  179.8,
                227.3,  174.4,  211.1,  167,    187.2,  148.1,  148.1,  187.2,
                167,    211.1,  174.4,  227.3,  179.8,  281.8,  154.1,  296.6,
                109.6,  264.7,  99.3,   250.2,  88.06,  221.9,  34.69,  236.2,
                39.11,  266.3,  37.39,  284,    14.82,  333.9,  -14.82, 333.9,
                -37.39, 284,    -39.11, 266.3,  -34.69, 236.2,  -88.06, 221.9,
                -99.3,  250.2,  -109.6, 264.7,  -154.1, 296.6,  -179.8, 281.8,
                -174.4, 227.3,  -167,   211.1,  -148.1, 187.2,  -187.2, 148.1,
                -211.1, 167,    -227.3, 174.4,  -281.8, 179.8,  -296.6, 154.1,
                -264.7, 109.6,  -250.2, 99.3,   -221.9, 88.06,  -236.2, 34.69,
                -266.3, 39.11,  -284,   37.39,  -333.9, 14.82,  -333.9, -14.82,
                -284,   -37.39, -266.3, -39.11, -236.2, -34.69, -221.9, -88.06,
                -250.2, -99.3,  -264.7, -109.6, -296.6, -154.1, -281.8, -179.8,
                -227.3, -174.4, -211.1, -167,   -187.2, -148.1, -148.1, -187.2,
                -167,   -211.1, -174.4, -227.3, -179.8, -281.8, -154.1, -296.6,
                -109.6, -264.7, -99.3,  -250.2, -88.06, -221.9, -34.69, -236.2,
                -39.11, -266.3, -37.39, -284,   -14.82, -333.9, 14.82,  -333.9,
                37.39,  -284,   39.11,  -266.3, 34.69,  -236.2, 88.06,  -221.9,
                99.3,   -250.2, 109.6,  -264.7, 154.1,  -296.6, 179.8,  -281.8,
                174.4,  -227.3, 167,    -211.1, 148.1,  -187.2, 187.2,  -148.1,
                211.1,  -167,   227.3,  -174.4, 281.8,  -179.8, 296.6,  -154.1,
                264.7,  -109.6, 250.2,  -99.3,  221.9,  -88.06,
            };

            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_fill.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            geo_sink.BeginFigure(.{ .x = 236.2, .y = -34.69 }, .FILLED);
            geo_sink.AddLines(@ptrCast(&path9), @sizeOf(@TypeOf(path9)) / @sizeOf(d2d1.POINT_2F));
            geo_sink.EndFigure(.CLOSED);
        }
        Mesh.gear_12_150 = try tessellate_geometry(@ptrCast(geo_fill), vertices, &tessellation_sink, &meshes);
        Mesh.gear_12_150_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    // level: star
    {
        var geo_fill: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_fill)));
        {
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
        Mesh.star = try tessellate_geometry(@ptrCast(geo_fill), vertices, &tessellation_sink, &meshes);
        Mesh.star_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    // level: strange_star_and_wall
    {
        var geo_fill: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_fill)));
        {
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
        Mesh.strange_star_and_wall = try tessellate_geometry(
            @ptrCast(geo_fill),
            vertices,
            &tessellation_sink,
            &meshes,
        );
        Mesh.strange_star_and_wall_stroke = try tessellate_geometry_stroke(
            d2d_factory,
            @ptrCast(geo_fill),
            stroke_width,
            vertices,
            &tessellation_sink,
            &meshes,
        );
    }

    // level: spiral
    {
        var geo_fill: *d2d1.IPathGeometry = undefined;
        vhr(d2d_factory.CreatePathGeometry(@ptrCast(&geo_fill)));
        {
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

            var geo_sink: *d2d1.IGeometrySink = undefined;
            vhr(geo_fill.Open(@ptrCast(&geo_sink)));
            defer {
                vhr(geo_sink.Close());
                _ = geo_sink.Release();
            }
            geo_sink.BeginFigure(.{ .x = -13.55, .y = 72.85 }, .FILLED);
            geo_sink.AddBeziers(@ptrCast(&path2), @sizeOf(@TypeOf(path2)) / @sizeOf(d2d1.BEZIER_SEGMENT));
            geo_sink.EndFigure(.CLOSED);
        }
        Mesh.spiral = try tessellate_geometry(@ptrCast(geo_fill), vertices, &tessellation_sink, &meshes);
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
    gc.command_queue.ExecuteCommandLists(1, &.{@ptrCast(gc.command_list)});
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
