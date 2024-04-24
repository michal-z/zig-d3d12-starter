const std = @import("std");
const w32 = @import("win32.zig");
const IUnknown = w32.IUnknown;
const HRESULT = w32.HRESULT;
const FLOAT = w32.FLOAT;
const WINAPI = w32.WINAPI;
const UINT32 = w32.UINT32;
const UINT = w32.UINT;
const GUID = w32.GUID;
const BOOL = w32.BOOL;
const LPCWSTR = w32.LPCWSTR;
const UINT64 = w32.UINT64;
const BYTE = w32.BYTE;
const dxgi = @import("dxgi.zig");
const wic = @import("wincodec.zig");
const dwrite = @import("dwrite.zig");
const objidl = @import("objidl.zig");

pub const RECT_F = extern struct {
    left: FLOAT,
    top: FLOAT,
    right: FLOAT,
    bottom: FLOAT,
};

pub const RECT_U = extern struct {
    left: UINT32,
    top: UINT32,
    right: UINT32,
    bottom: UINT32,
};

pub const VECTOR_2F = extern struct {
    x: FLOAT,
    y: FLOAT,
};

pub const BRUSH_PROPERTIES = extern struct {
    opacity: FLOAT,
    transform: MATRIX_3X2_F,
};

pub const RADIAL_GRADIENT_BRUSH_PROPERTIES = extern struct {
    center: POINT_2F,
    gradientOriginOffset: POINT_2F,
    radiusX: FLOAT,
    radiusY: FLOAT,
};

pub const BITMAP_INTERPOLATION_MODE = enum(UINT) {
    NEAREST_NEIGHBOR = 0,
    LINEAR = 1,
};

pub const GAMMA = enum(UINT) {
    @"2_2" = 0,
    @"1_0" = 1,
};

pub const EXTEND_MODE = enum(UINT) {
    CLAMP = 0,
    WRAP = 1,
    MIRROR = 2,
};

pub const GRADIENT_STOP = extern struct {
    position: FLOAT,
    color: COLOR_F,
};

pub const MATRIX_3X2_F = extern struct {
    m: [3][2]FLOAT,

    pub const identity = MATRIX_3X2_F{
        .m = [_][2]FLOAT{
            .{ 1.0, 0.0 },
            .{ 0.0, 1.0 },
            .{ 0.0, 0.0 },
        },
    };

    pub fn translation(x: f32, y: f32) MATRIX_3X2_F {
        return .{
            .m = [_][2]FLOAT{
                .{ 1.0, 0.0 },
                .{ 0.0, 1.0 },
                .{ x, y },
            },
        };
    }

    pub fn scaling(sx: f32, sy: f32) MATRIX_3X2_F {
        return .{
            .m = [_][2]FLOAT{
                .{ sx, 0.0 },
                .{ 0.0, sy },
                .{ 0.0, 0.0 },
            },
        };
    }

    pub fn rotation_translation(r: f32, x: f32, y: f32) MATRIX_3X2_F {
        const sin_r = @sin(r);
        const cos_r = @cos(r);
        return .{
            .m = [_][2]FLOAT{
                .{ cos_r, sin_r },
                .{ -sin_r, cos_r },
                .{ x, y },
            },
        };
    }

    pub fn mul(a: MATRIX_3X2_F, b: MATRIX_3X2_F) MATRIX_3X2_F {
        return .{
            .m = [_][2]FLOAT{
                .{
                    a.m[0][0] * b.m[0][0] + a.m[0][1] * b.m[1][0],
                    a.m[0][0] * b.m[0][1] + a.m[0][1] * b.m[1][1],
                },
                .{
                    a.m[1][0] * b.m[0][0] + a.m[1][1] * b.m[1][0],
                    a.m[1][0] * b.m[0][1] + a.m[1][1] * b.m[1][1],
                },
                .{
                    a.m[2][0] * b.m[0][0] + a.m[2][1] * b.m[1][0] + b.m[2][0],
                    a.m[2][0] * b.m[0][1] + a.m[2][1] * b.m[1][1] + b.m[2][1],
                },
            },
        };
    }
};

pub const DEVICE_CONTEXT_OPTIONS = packed struct(UINT) {
    ENABLE_MULTITHREADED_OPTIMIZATIONS: bool = false,
    __unused: u31 = 0,
};

pub const BITMAP_OPTIONS = packed struct(UINT) {
    TARGET: bool = false,
    CANNOT_DRAW: bool = false,
    CPU_READ: bool = false,
    GDI_COMPATIBLE: bool = false,
    __unused: u28 = 0,
};

pub const MAP_OPTIONS = packed struct(UINT) {
    READ: bool = false,
    WRITE: bool = false,
    DISCARD: bool = false,
    __unused: u29 = 0,
};

pub const POINT_2F = extern struct {
    x: FLOAT,
    y: FLOAT,
};

pub const POINT_2U = extern struct {
    x: UINT32,
    y: UINT32,
};

pub const TRIANGLE = extern struct {
    point1: POINT_2F,
    point2: POINT_2F,
    point3: POINT_2F,
};

pub const ROUNDED_RECT = extern struct {
    rect: RECT_F,
    radiusX: FLOAT,
    radiusY: FLOAT,
};

pub const ELLIPSE = extern struct {
    point: POINT_2F,
    radiusX: FLOAT,
    radiusY: FLOAT,
};

pub const FILL_MODE = enum(UINT) {
    ALTERNATE = 0,
    WINDING = 1,
};

pub const COMBINE_MODE = enum(UINT) {
    UNION = 0,
    INTERSECT = 1,
    XOR = 2,
    EXCLUDE = 3,
};

pub const PATH_SEGMENT = packed struct(UINT) {
    FORCE_UNSTROKED: bool = false,
    FORCE_ROUND_LINE_JOIN: bool = false,
    __unused: u30 = 0,
};

pub const FIGURE_BEGIN = enum(UINT) {
    FILLED = 0,
    HOLLOW = 1,
};

pub const FIGURE_END = enum(UINT) {
    OPEN = 0,
    CLOSED = 1,
};

pub const BEZIER_SEGMENT = extern struct {
    point1: POINT_2F,
    point2: POINT_2F,
    point3: POINT_2F,
};

pub const ARC_SIZE = enum(UINT) {
    SMALL = 0,
    LARGE = 1,
};

pub const ARC_SEGMENT = extern struct {
    point: POINT_2F,
    size: SIZE_F,
    rotationAngle: FLOAT,
    sweepDirection: SWEEP_DIRECTION,
    arcSize: ARC_SIZE,
};

pub const QUADRATIC_BEZIER_SEGMENT = extern struct {
    point1: POINT_2F,
    point2: POINT_2F,
};

pub const SIZE_F = extern struct {
    width: FLOAT,
    height: FLOAT,
};

pub const SIZE_U = extern struct {
    width: UINT32,
    height: UINT32,
};

pub const SWEEP_DIRECTION = enum(UINT) {
    COUNTER_CLOCKWISE = 0,
    CLOCKWISE = 1,
};

pub const CAP_STYLE = enum(UINT) {
    FLAT = 0,
    SQUARE = 1,
    ROUND = 2,
    TRIANGLE = 3,
};

pub const DASH_STYLE = enum(UINT) {
    SOLID = 0,
    DASH = 1,
    DOT = 2,
    DASH_DOT = 3,
    DASH_DOT_DOT = 4,
    CUSTOM = 5,
};

pub const LINE_JOIN = enum(UINT) {
    MITER = 0,
    BEVEL = 1,
    ROUND = 2,
    MITER_OR_BEVEL = 3,
};

pub const STROKE_STYLE_PROPERTIES = extern struct {
    startCap: CAP_STYLE,
    endCap: CAP_STYLE,
    dashCap: CAP_STYLE,
    lineJoin: LINE_JOIN,
    miterLimit: FLOAT,
    dashStyle: DASH_STYLE,
    dashOffset: FLOAT,
};

pub const COLOR_F = extern struct {
    r: FLOAT,
    g: FLOAT,
    b: FLOAT,
    a: FLOAT,

    pub const Code = enum(u32) {
        AliceBlue = 0xF0F8FF,
        AntiqueWhite = 0xFAEBD7,
        Aquamarine = 0x7FFFD4,
        Azure = 0xF0FFFF,
        Beige = 0xF5F5DC,
        Bisque = 0xFFE4C4,
        Black = 0x000000,
        BlanchedAlmond = 0xFFEBCD,
        Blue = 0x0000FF,
        BlueViolet = 0x8A2BE2,
        Brown = 0xA52A2A,
        BurlyWood = 0xDEB887,
        CadetBlue = 0x5F9EA0,
        Chartreuse = 0x7FFF00,
        Chocolate = 0xD2691E,
        Coral = 0xFF7F50,
        CornflowerBlue = 0x6495ED,
        Cornsilk = 0xFFF8DC,
        Crimson = 0xDC143C,
        Cyan = 0x00FFFF,
        DarkBlue = 0x00008B,
        DarkCyan = 0x008B8B,
        DarkGoldenrod = 0xB8860B,
        DarkGray = 0xA9A9A9,
        DarkGreen = 0x006400,
        DarkKhaki = 0xBDB76B,
        DarkMagenta = 0x8B008B,
        DarkOliveGreen = 0x556B2F,
        DarkOrange = 0xFF8C00,
        DarkOrchid = 0x9932CC,
        DarkRed = 0x8B0000,
        DarkSalmon = 0xE9967A,
        DarkSeaGreen = 0x8FBC8F,
        DarkSlateBlue = 0x483D8B,
        DarkSlateGray = 0x2F4F4F,
        DarkTurquoise = 0x00CED1,
        DarkViolet = 0x9400D3,
        DeepPink = 0xFF1493,
        DeepSkyBlue = 0x00BFFF,
        DimGray = 0x696969,
        DodgerBlue = 0x1E90FF,
        Firebrick = 0xB22222,
        FloralWhite = 0xFFFAF0,
        ForestGreen = 0x228B22,
        Gainsboro = 0xDCDCDC,
        GhostWhite = 0xF8F8FF,
        Gold = 0xFFD700,
        Goldenrod = 0xDAA520,
        Gray = 0x808080,
        Green = 0x008000,
        GreenYellow = 0xADFF2F,
        Honeydew = 0xF0FFF0,
        HotPink = 0xFF69B4,
        IndianRed = 0xCD5C5C,
        Indigo = 0x4B0082,
        Ivory = 0xFFFFF0,
        Khaki = 0xF0E68C,
        Lavender = 0xE6E6FA,
        LavenderBlush = 0xFFF0F5,
        LawnGreen = 0x7CFC00,
        LemonChiffon = 0xFFFACD,
        LightBlue = 0xADD8E6,
        LightCoral = 0xF08080,
        LightCyan = 0xE0FFFF,
        LightGoldenrodYellow = 0xFAFAD2,
        LightGreen = 0x90EE90,
        LightGray = 0xD3D3D3,
        LightPink = 0xFFB6C1,
        LightSalmon = 0xFFA07A,
        LightSeaGreen = 0x20B2AA,
        LightSkyBlue = 0x87CEFA,
        LightSlateGray = 0x778899,
        LightSteelBlue = 0xB0C4DE,
        LightYellow = 0xFFFFE0,
        Lime = 0x00FF00,
        LimeGreen = 0x32CD32,
        Linen = 0xFAF0E6,
        Magenta = 0xFF00FF,
        Maroon = 0x800000,
        MediumAquamarine = 0x66CDAA,
        MediumBlue = 0x0000CD,
        MediumOrchid = 0xBA55D3,
        MediumPurple = 0x9370DB,
        MediumSeaGreen = 0x3CB371,
        MediumSlateBlue = 0x7B68EE,
        MediumSpringGreen = 0x00FA9A,
        MediumTurquoise = 0x48D1CC,
        MediumVioletRed = 0xC71585,
        MidnightBlue = 0x191970,
        MintCream = 0xF5FFFA,
        MistyRose = 0xFFE4E1,
        Moccasin = 0xFFE4B5,
        NavajoWhite = 0xFFDEAD,
        Navy = 0x000080,
        OldLace = 0xFDF5E6,
        Olive = 0x808000,
        OliveDrab = 0x6B8E23,
        Orange = 0xFFA500,
        OrangeRed = 0xFF4500,
        Orchid = 0xDA70D6,
        PaleGoldenrod = 0xEEE8AA,
        PaleGreen = 0x98FB98,
        PaleTurquoise = 0xAFEEEE,
        PaleVioletRed = 0xDB7093,
        PapayaWhip = 0xFFEFD5,
        PeachPuff = 0xFFDAB9,
        Peru = 0xCD853F,
        Pink = 0xFFC0CB,
        Plum = 0xDDA0DD,
        PowderBlue = 0xB0E0E6,
        Purple = 0x800080,
        Red = 0xFF0000,
        RosyBrown = 0xBC8F8F,
        RoyalBlue = 0x4169E1,
        SaddleBrown = 0x8B4513,
        Salmon = 0xFA8072,
        SandyBrown = 0xF4A460,
        SeaGreen = 0x2E8B57,
        SeaShell = 0xFFF5EE,
        Sienna = 0xA0522D,
        Silver = 0xC0C0C0,
        SkyBlue = 0x87CEEB,
        SlateBlue = 0x6A5ACD,
        SlateGray = 0x708090,
        Snow = 0xFFFAFA,
        SpringGreen = 0x00FF7F,
        SteelBlue = 0x4682B4,
        Tan = 0xD2B48C,
        Teal = 0x008080,
        Thistle = 0xD8BFD8,
        Tomato = 0xFF6347,
        Turquoise = 0x40E0D0,
        Violet = 0xEE82EE,
        Wheat = 0xF5DEB3,
        White = 0xFFFFFF,
        WhiteSmoke = 0xF5F5F5,
        Yellow = 0xFFFF00,
        YellowGreen = 0x9ACD32,
    };

    pub const red_shift = 16;
    pub const green_shift = 8;
    pub const blue_shift = 0;

    pub const red_mask = 0xff << red_shift;
    pub const green_mask = 0xff << green_shift;
    pub const blue_mask = 0xff << blue_shift;

    pub fn init(code: Code, alpha: f32) COLOR_F {
        const color_u32 = @as(u32, @intFromEnum(code));
        return .{
            .r = @as(f32, @floatFromInt((color_u32 & red_mask) >> red_shift)) / 255.0,
            .g = @as(f32, @floatFromInt((color_u32 & green_mask) >> green_shift)) / 255.0,
            .b = @as(f32, @floatFromInt((color_u32 & blue_mask) >> blue_shift)) / 255.0,
            .a = alpha,
        };
    }
};

pub const ITessellationSink = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const AddTriangles = ITessellationSink(@This()).AddTriangles;
    pub const Close = ITessellationSink(@This()).Close;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AddTriangles(self: *T, triangles: [*]const TRIANGLE, num_triangles: UINT32) void {
                @as(*const ITessellationSink.VTable, @ptrCast(self.__v))
                    .AddTriangles(@ptrCast(self), triangles, num_triangles);
            }
            pub inline fn Close(self: *T) HRESULT {
                return @as(*const ITessellationSink.VTable, @ptrCast(self.__v))
                    .Close(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        AddTriangles: *const fn (*ITessellationSink, [*]const TRIANGLE, UINT32) callconv(WINAPI) void,
        Close: *const fn (*ITessellationSink) callconv(WINAPI) HRESULT,
    };
};

pub const IResource = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        GetFactory: *anyopaque,
    };
};

pub const IImage = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IResource.VTable,
    };
};

pub const IBitmap = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CopyFromBitmap = IBitmap.Methods(@This()).CopyFromBitmap;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CopyFromBitmap(
                self: *T,
                dest_point: ?*const POINT_2U,
                bitmap: *IBitmap,
                src_rect: ?*const RECT_U,
            ) HRESULT {
                return @as(*const IBitmap.VTable, @ptrCast(self.__v)).CopyFromBitmap(
                    @ptrCast(self),
                    dest_point,
                    bitmap,
                    src_rect,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IImage.VTable,
        GetSize: *anyopaque,
        GetPixelSize: *anyopaque,
        GetPixelFormat: *anyopaque,
        GetPixelDpi: *anyopaque,
        CopyFromBitmap: *const fn (
            *IBitmap,
            ?*const POINT_2U,
            *IBitmap,
            ?*const RECT_U,
        ) callconv(WINAPI) HRESULT,
        CopyFromRenderTarget: *anyopaque,
        CopyFromMemory: *anyopaque,
    };
};

pub const DEFAULT_FLATTENING_TOLERANCE = 0.25;

pub const IGeometry = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;
    pub const FillContainsPoint = IGeometry.Methods(@This()).FillContainsPoint;
    pub const Widen = IGeometry.Methods(@This()).Widen;
    pub const CombineWithGeometry = IGeometry.Methods(@This()).CombineWithGeometry;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetBounds(self: *T, world_transform: ?*const MATRIX_3X2_F, bounds: *RECT_F) HRESULT {
                return @as(*const IGeometry.VTable, @ptrCast(self.__v))
                    .GetBounds(@ptrCast(self), world_transform, bounds);
            }
            pub inline fn Tessellate(
                self: *T,
                world_transform: ?*const MATRIX_3X2_F,
                flattening_tolerance: FLOAT,
                tessellation_sink: *ITessellationSink,
            ) HRESULT {
                return @as(*const IGeometry.VTable, @ptrCast(self.__v))
                    .Tessellate(@ptrCast(self), world_transform, flattening_tolerance, tessellation_sink);
            }
            pub inline fn FillContainsPoint(
                self: *T,
                point: POINT_2F,
                world_transform: ?*const MATRIX_3X2_F,
                flattening_tolerance: FLOAT,
                contains: *BOOL,
            ) HRESULT {
                return @as(*const IGeometry.VTable, @ptrCast(self.__v))
                    .FillContainsPoint(@ptrCast(self), point, world_transform, flattening_tolerance, contains);
            }
            pub inline fn Widen(
                self: *T,
                stroke_width: FLOAT,
                stroke_style: ?*IStrokeStyle,
                world_transform: ?*const MATRIX_3X2_F,
                flattening_tolerance: FLOAT,
                geo_sink: *ISimplifiedGeometrySink,
            ) HRESULT {
                return @as(*const IGeometry.VTable, @ptrCast(self.__v)).Widen(
                    @ptrCast(self),
                    stroke_width,
                    stroke_style,
                    world_transform,
                    flattening_tolerance,
                    geo_sink,
                );
            }
            pub inline fn CombineWithGeometry(
                self: *T,
                input_geo: *IGeometry,
                mode: COMBINE_MODE,
                input_geo_transform: ?*const MATRIX_3X2_F,
                flattening_tolerance: FLOAT,
                geo_sink: *ISimplifiedGeometrySink,
            ) HRESULT {
                return @as(*const IGeometry.VTable, @ptrCast(self.__v)).CombineWithGeometry(
                    @ptrCast(self),
                    input_geo,
                    mode,
                    input_geo_transform,
                    flattening_tolerance,
                    geo_sink,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IResource.VTable,
        GetBounds: *const fn (*IGeometry, ?*const MATRIX_3X2_F, *RECT_F) callconv(WINAPI) HRESULT,
        GetWidenedBounds: *anyopaque,
        StrokeContainsPoint: *anyopaque,
        FillContainsPoint: *const fn (
            *IGeometry,
            POINT_2F,
            ?*const MATRIX_3X2_F,
            FLOAT,
            *BOOL,
        ) callconv(WINAPI) HRESULT,
        CompareWithGeometry: *anyopaque,
        Simplify: *anyopaque,
        Tessellate: *const fn (
            *IGeometry,
            ?*const MATRIX_3X2_F,
            FLOAT,
            *ITessellationSink,
        ) callconv(WINAPI) HRESULT,
        CombineWithGeometry: *const fn (
            *IGeometry,
            *IGeometry,
            COMBINE_MODE,
            ?*const MATRIX_3X2_F,
            FLOAT,
            *ISimplifiedGeometrySink,
        ) callconv(WINAPI) HRESULT,
        Outline: *anyopaque,
        ComputeArea: *anyopaque,
        ComputeLength: *anyopaque,
        ComputePointAtLength: *anyopaque,
        Widen: *const fn (
            *IGeometry,
            FLOAT,
            ?*IStrokeStyle,
            ?*const MATRIX_3X2_F,
            FLOAT,
            *ISimplifiedGeometrySink,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const IRectangleGeometry = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;
    pub const Widen = IGeometry.Methods(@This()).Widen;

    pub const VTable = extern struct {
        base: IGeometry.VTable,
        GetRect: *anyopaque,
    };
};

pub const IRoundedRectangleGeometry = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;
    pub const Widen = IGeometry.Methods(@This()).Widen;

    pub const VTable = extern struct {
        base: IGeometry.VTable,
        GetRoundedRect: *anyopaque,
    };
};

pub const IEllipseGeometry = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;
    pub const Widen = IGeometry.Methods(@This()).Widen;

    pub const VTable = extern struct {
        base: IGeometry.VTable,
        GetEllipse: *anyopaque,
    };
};

pub const IGeometryGroup = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;
    pub const Widen = IGeometry.Methods(@This()).Widen;

    pub const VTable = extern struct {
        base: IGeometry.VTable,
        GetFillMode: *anyopaque,
        GetSourceGeometryCount: *anyopaque,
        GetSourceGeometries: *anyopaque,
    };
};

pub const ITransformedGeometry = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;
    pub const Widen = IGeometry.Methods(@This()).Widen;
    pub const CombineWithGeometry = IGeometry.Methods(@This()).CombineWithGeometry;

    pub const VTable = extern struct {
        base: IGeometry.VTable,
        GetSourceGeometry: *anyopaque,
        GetTransform: *anyopaque,
    };
};

pub const IPathGeometry = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;
    pub const Widen = IGeometry.Methods(@This()).Widen;

    pub const Open = IPathGeometry.Methods(@This()).Open;
    pub const GetSegmentCount = IPathGeometry.Methods(@This()).GetSegmentCount;
    pub const GetFigureCount = IPathGeometry.Methods(@This()).GetFigureCount;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Open(self: *T, sink: *?*IGeometrySink) HRESULT {
                return @as(*const IPathGeometry.VTable, @ptrCast(self.__v)).Open(@ptrCast(self), sink);
            }
            pub inline fn GetSegmentCount(self: *T, count: *UINT32) HRESULT {
                return @as(*const IPathGeometry.VTable, @ptrCast(self.__v)).GetSegmentCount(@ptrCast(self), count);
            }
            pub inline fn GetFigureCount(self: *T, count: *UINT32) HRESULT {
                return @as(*const IPathGeometry.VTable, @ptrCast(self.__v)).GetFigureCount(@ptrCast(self), count);
            }
        };
    }

    pub const VTable = extern struct {
        base: IGeometry.VTable,
        Open: *const fn (*IPathGeometry, *?*IGeometrySink) callconv(WINAPI) HRESULT,
        Stream: *anyopaque,
        GetSegmentCount: *const fn (*IPathGeometry, *UINT32) callconv(WINAPI) HRESULT,
        GetFigureCount: *const fn (*IPathGeometry, *UINT32) callconv(WINAPI) HRESULT,
    };
};

pub const ISimplifiedGeometrySink = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const SetFillMode = ISimplifiedGeometrySink.Methods(@This()).SetFillMode;
    pub const SetSegmentFlags = ISimplifiedGeometrySink.Methods(@This()).SetSegmentFlags;
    pub const BeginFigure = ISimplifiedGeometrySink.Methods(@This()).BeginFigure;
    pub const AddLines = ISimplifiedGeometrySink.Methods(@This()).AddLines;
    pub const AddBeziers = ISimplifiedGeometrySink.Methods(@This()).AddBeziers;
    pub const EndFigure = ISimplifiedGeometrySink.Methods(@This()).EndFigure;
    pub const Close = ISimplifiedGeometrySink.Methods(@This()).Close;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetFillMode(self: *T, mode: FILL_MODE) void {
                @as(*const ISimplifiedGeometrySink.VTable, @ptrCast(self.__v)).SetFillMode(@ptrCast(self), mode);
            }
            pub inline fn SetSegmentFlags(self: *T, flags: PATH_SEGMENT) void {
                @as(*const ISimplifiedGeometrySink.VTable, @ptrCast(self.__v))
                    .SetSegmentFlags(@ptrCast(self), flags);
            }
            pub inline fn BeginFigure(self: *T, point: POINT_2F, begin: FIGURE_BEGIN) void {
                @as(*const ISimplifiedGeometrySink.VTable, @ptrCast(self.__v))
                    .BeginFigure(@ptrCast(self), point, begin);
            }
            pub inline fn AddLines(self: *T, points: [*]const POINT_2F, count: UINT32) void {
                @as(*const ISimplifiedGeometrySink.VTable, @ptrCast(self.__v))
                    .AddLines(@ptrCast(self), points, count);
            }
            pub inline fn AddBeziers(self: *T, segments: [*]const BEZIER_SEGMENT, num_segments: UINT32) void {
                @as(*const ISimplifiedGeometrySink.VTable, @ptrCast(self.__v))
                    .AddBeziers(@ptrCast(self), segments, num_segments);
            }
            pub inline fn EndFigure(self: *T, end: FIGURE_END) void {
                @as(*const ISimplifiedGeometrySink.VTable, @ptrCast(self.__v)).EndFigure(@ptrCast(self), end);
            }
            pub inline fn Close(self: *T) HRESULT {
                return @as(*const ISimplifiedGeometrySink.VTable, @ptrCast(self.__v)).Close(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetFillMode: *const fn (*ISimplifiedGeometrySink, FILL_MODE) callconv(WINAPI) void,
        SetSegmentFlags: *const fn (*ISimplifiedGeometrySink, PATH_SEGMENT) callconv(WINAPI) void,
        BeginFigure: *const fn (*ISimplifiedGeometrySink, POINT_2F, FIGURE_BEGIN) callconv(WINAPI) void,
        AddLines: *const fn (*ISimplifiedGeometrySink, [*]const POINT_2F, UINT32) callconv(WINAPI) void,
        AddBeziers: *const fn (*ISimplifiedGeometrySink, [*]const BEZIER_SEGMENT, UINT32) callconv(WINAPI) void,
        EndFigure: *const fn (*ISimplifiedGeometrySink, FIGURE_END) callconv(WINAPI) void,
        Close: *const fn (*ISimplifiedGeometrySink) callconv(WINAPI) HRESULT,
    };
};

pub const IGeometrySink = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const SetFillMode = ISimplifiedGeometrySink.Methods(@This()).SetFillMode;
    pub const SetSegmentFlags = ISimplifiedGeometrySink.Methods(@This()).SetSegmentFlags;
    pub const BeginFigure = ISimplifiedGeometrySink.Methods(@This()).BeginFigure;
    pub const AddLines = ISimplifiedGeometrySink.Methods(@This()).AddLines;
    pub const AddBeziers = ISimplifiedGeometrySink.Methods(@This()).AddBeziers;
    pub const EndFigure = ISimplifiedGeometrySink.Methods(@This()).EndFigure;
    pub const Close = ISimplifiedGeometrySink.Methods(@This()).Close;

    pub const AddLine = IGeometrySink.Methods(@This()).AddLine;
    pub const AddBezier = IGeometrySink.Methods(@This()).AddBezier;
    pub const AddQuadraticBezier = IGeometrySink.Methods(@This()).AddQuadraticBezier;
    pub const AddQuadraticBeziers = IGeometrySink.Methods(@This()).AddQuadraticBeziers;
    pub const AddArc = IGeometrySink.Methods(@This()).AddArc;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AddLine(self: *T, point: POINT_2F) void {
                @as(*const IGeometrySink.VTable, @ptrCast(self.__v))
                    .AddLine(@ptrCast(self), point);
            }
            pub inline fn AddBezier(self: *T, segment: *const BEZIER_SEGMENT) void {
                @as(*const IGeometrySink.VTable, @ptrCast(self.__v))
                    .AddBezier(@ptrCast(self), segment);
            }
            pub inline fn AddQuadraticBezier(self: *T, segment: *const QUADRATIC_BEZIER_SEGMENT) void {
                @as(*const IGeometrySink.VTable, @ptrCast(self.__v))
                    .AddQuadraticBezier(@ptrCast(self), segment);
            }
            pub inline fn AddQuadraticBeziers(
                self: *T,
                segments: [*]const QUADRATIC_BEZIER_SEGMENT,
                num_segments: UINT32,
            ) void {
                @as(*const IGeometrySink.VTable, @ptrCast(self.__v))
                    .AddQuadraticBeziers(@ptrCast(self), segments, num_segments);
            }
            pub inline fn AddArc(self: *T, segment: *const ARC_SEGMENT) void {
                @as(*const IGeometrySink.VTable, @ptrCast(self.__v))
                    .AddArc(@ptrCast(self), segment);
            }
        };
    }

    pub const VTable = extern struct {
        base: ISimplifiedGeometrySink.VTable,
        AddLine: *const fn (*IGeometrySink, POINT_2F) callconv(WINAPI) void,
        AddBezier: *const fn (*IGeometrySink, *const BEZIER_SEGMENT) callconv(WINAPI) void,
        AddQuadraticBezier: *const fn (*IGeometrySink, *const QUADRATIC_BEZIER_SEGMENT) callconv(WINAPI) void,
        AddQuadraticBeziers: *const fn (
            *IGeometrySink,
            [*]const QUADRATIC_BEZIER_SEGMENT,
            UINT32,
        ) callconv(WINAPI) void,
        AddArc: *const fn (*IGeometrySink, *const ARC_SEGMENT) callconv(WINAPI) void,
    };
};

pub const IStrokeStyle = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IResource.VTable,
        GetStartCap: *anyopaque,
        GetEndCap: *anyopaque,
        GetDashCap: *anyopaque,
        GetMiterLimit: *anyopaque,
        GetLineJoin: *anyopaque,
        GetDashOffset: *anyopaque,
        GetDashStyle: *anyopaque,
        GetDashesCount: *anyopaque,
        GetDashes: *anyopaque,
    };
};

pub const IFactory = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{06152247-6f50-465a-9245-118bfd3b6007}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateRectangleGeometry = IFactory.Methods(@This()).CreateRectangleGeometry;
    pub const CreateRoundedRectangleGeometry = IFactory.Methods(@This()).CreateRoundedRectangleGeometry;
    pub const CreateEllipseGeometry = IFactory.Methods(@This()).CreateEllipseGeometry;
    pub const CreatePathGeometry = IFactory.Methods(@This()).CreatePathGeometry;
    pub const CreateTransformedGeometry = IFactory.Methods(@This()).CreateTransformedGeometry;
    pub const CreateGeometryGroup = IFactory.Methods(@This()).CreateGeometryGroup;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateRectangleGeometry(
                self: *T,
                rect: *const RECT_F,
                geo: *?*IRectangleGeometry,
            ) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v))
                    .CreateRectangleGeometry(@ptrCast(self), rect, geo);
            }
            pub inline fn CreateRoundedRectangleGeometry(
                self: *T,
                rect: *const ROUNDED_RECT,
                geo: *?*IRoundedRectangleGeometry,
            ) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v))
                    .CreateRoundedRectangleGeometry(@ptrCast(self), rect, geo);
            }
            pub inline fn CreateEllipseGeometry(
                self: *T,
                ellipse: *const ELLIPSE,
                geo: *?*IEllipseGeometry,
            ) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v))
                    .CreateEllipseGeometry(@ptrCast(self), ellipse, geo);
            }
            pub inline fn CreateTransformedGeometry(
                self: *T,
                source_geo: *IGeometry,
                transform: *const MATRIX_3X2_F,
                geo: *?*ITransformedGeometry,
            ) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v)).CreateTransformedGeometry(
                    @ptrCast(self),
                    source_geo,
                    transform,
                    geo,
                );
            }
            pub inline fn CreatePathGeometry(self: *T, geo: *?*IPathGeometry) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v)).CreatePathGeometry(@ptrCast(self), geo);
            }
            pub inline fn CreateStrokeStyle(
                self: *T,
                properties: *const STROKE_STYLE_PROPERTIES,
                dashes: ?[*]const FLOAT,
                dashes_count: UINT32,
                stroke_style: *?*IStrokeStyle,
            ) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v))
                    .CreateStrokeStyle(@ptrCast(self), properties, dashes, dashes_count, stroke_style);
            }
            pub inline fn CreateGeometryGroup(
                self: *T,
                fill_mode: FILL_MODE,
                geos: [*]const *IGeometry,
                num_geos: UINT32,
                geo: *?*IGeometryGroup,
            ) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v))
                    .CreateGeometryGroup(@ptrCast(self), fill_mode, geos, num_geos, geo);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        ReloadSystemMetrics: *anyopaque,
        GetDesktopDpi: *anyopaque,
        CreateRectangleGeometry: *const fn (
            *IFactory,
            *const RECT_F,
            *?*IRectangleGeometry,
        ) callconv(WINAPI) HRESULT,
        CreateRoundedRectangleGeometry: *const fn (
            *IFactory,
            *const ROUNDED_RECT,
            *?*IRoundedRectangleGeometry,
        ) callconv(WINAPI) HRESULT,
        CreateEllipseGeometry: *const fn (
            *IFactory,
            *const ELLIPSE,
            *?*IEllipseGeometry,
        ) callconv(WINAPI) HRESULT,
        CreateGeometryGroup: *const fn (
            *IFactory,
            FILL_MODE,
            [*]const *IGeometry,
            UINT32,
            *?*IGeometryGroup,
        ) callconv(WINAPI) HRESULT,
        CreateTransformedGeometry: *const fn (
            *IFactory,
            *IGeometry,
            *const MATRIX_3X2_F,
            *?*ITransformedGeometry,
        ) callconv(WINAPI) HRESULT,
        CreatePathGeometry: *const fn (*IFactory, *?*IPathGeometry) callconv(WINAPI) HRESULT,
        CreateStrokeStyle: *const fn (
            *IFactory,
            *const STROKE_STYLE_PROPERTIES,
            ?[*]const FLOAT,
            UINT32,
            *?*IStrokeStyle,
        ) callconv(WINAPI) HRESULT,
        CreateDrawingStateBlock: *anyopaque,
        CreateWicBitmapRenderTarget: *anyopaque,
        CreateHwndRenderTarget: *anyopaque,
        CreateDxgiSurfaceRenderTarget: *anyopaque,
        CreateDCRenderTarget: *anyopaque,
    };
};

pub const IFactory1 = extern struct {
    __v: *const VTable,

    pub const VTable = extern struct {
        base: IFactory.VTable,
        CreateDevice: *anyopaque,
        CreateStrokeStyle1: *anyopaque,
        CreatePathGeometry1: *anyopaque,
        CreateDrawingStateBlock1: *anyopaque,
        CreateGdiMetafile: *anyopaque,
        RegisterEffectFromStream: *anyopaque,
        RegisterEffectFromString: *anyopaque,
        UnregisterEffect: *anyopaque,
        GetRegisteredEffects: *anyopaque,
        GetEffectProperties: *anyopaque,
    };
};

pub const IFactory2 = extern struct {
    __v: *const VTable,

    pub const VTable = extern struct {
        base: IFactory1.VTable,
        CreateDevice1: *anyopaque,
    };
};

pub const IFactory3 = extern struct {
    __v: *const VTable,

    pub const VTable = extern struct {
        base: IFactory2.VTable,
        CreateDevice2: *anyopaque,
    };
};

pub const IFactory4 = extern struct {
    __v: *const VTable,

    pub const VTable = extern struct {
        base: IFactory3.VTable,
        CreateDevice3: *anyopaque,
    };
};

pub const IFactory5 = extern struct {
    __v: *const VTable,

    pub const VTable = extern struct {
        base: IFactory4.VTable,
        CreateDevice4: *anyopaque,
    };
};

pub const IFactory6 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{f9976f46-f642-44c1-97ca-da32ea2a2635}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateRectangleGeometry = IFactory.Methods(@This()).CreateRectangleGeometry;
    pub const CreateRoundedRectangleGeometry = IFactory.Methods(@This()).CreateRoundedRectangleGeometry;
    pub const CreateEllipseGeometry = IFactory.Methods(@This()).CreateEllipseGeometry;
    pub const CreatePathGeometry = IFactory.Methods(@This()).CreatePathGeometry;
    pub const CreateTransformedGeometry = IFactory.Methods(@This()).CreateTransformedGeometry;
    pub const CreateGeometryGroup = IFactory.Methods(@This()).CreateGeometryGroup;

    pub const CreateDevice5 = IFactory6.Methods(@This()).CreateDevice5;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateDevice5(self: *T, dxgi_device: *dxgi.IDevice, device: *?*IDevice5) HRESULT {
                return @as(*const IFactory6.VTable, @ptrCast(self.__v)).CreateDevice5(
                    @ptrCast(self),
                    dxgi_device,
                    device,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IFactory5.VTable,
        CreateDevice5: *const fn (*IFactory6, *dxgi.IDevice, *?*IDevice5) callconv(WINAPI) HRESULT,
    };
};

pub const IDevice = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IResource.VTable,
        CreateDeviceContext: *anyopaque,
        CreatePrintControl: *anyopaque,
        SetMaximumTextureMemory: *anyopaque,
        GetMaximumTextureMemory: *anyopaque,
        ClearResources: *anyopaque,
    };
};

pub const IDevice1 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IDevice.VTable,
        GetRenderingPriority: *anyopaque,
        SetRenderingPriority: *anyopaque,
        CreateDeviceContext1: *anyopaque,
    };
};

pub const IDevice2 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IDevice1.VTable,
        CreateDeviceContext2: *anyopaque,
        FlushDeviceContexts: *anyopaque,
        GetDxgiDevice: *anyopaque,
    };
};

pub const IDevice3 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IDevice2.VTable,
        CreateDeviceContext3: *anyopaque,
    };
};

pub const IDevice4 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IDevice3.VTable,
        CreateDeviceContext4: *anyopaque,
        SetMaximumColorGlyphCacheMemory: *anyopaque,
        GetMaximumColorGlyphCacheMemory: *anyopaque,
    };
};

pub const IDevice5 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateDeviceContext5 = IDevice5.Methods(@This()).CreateDeviceContext5;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateDeviceContext5(
                self: *T,
                options: DEVICE_CONTEXT_OPTIONS,
                devctx: *?*IDeviceContext5,
            ) HRESULT {
                return @as(*const IDevice5.VTable, @ptrCast(self.__v))
                    .CreateDeviceContext5(@ptrCast(self), options, devctx);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice4.VTable,
        CreateDeviceContext5: *const fn (
            *IDevice5,
            DEVICE_CONTEXT_OPTIONS,
            *?*IDeviceContext5,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const IGradientStopCollection = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IResource.VTable,
        GetGradientStopCount: *anyopaque,
        GetGradientStops: *anyopaque,
        GetColorInterpolationGamma: *anyopaque,
        GetExtendMode: *anyopaque,
    };
};

pub const IBrush = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IResource.VTable,
        SetOpacity: *anyopaque,
        SetTransform: *anyopaque,
        GetOpacity: *anyopaque,
        GetTransform: *anyopaque,
    };
};

pub const ISolidColorBrush = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetColor(self: *T, color: *const COLOR_F) void {
                @as(*const ISolidColorBrush.VTable, @ptrCast(self.__v)).SetColor(@ptrCast(self), color);
            }
            pub inline fn GetColor(self: *T) COLOR_F {
                var color: COLOR_F = undefined;
                _ = @as(*const ISolidColorBrush.VTable, @ptrCast(self.__v)).GetColor(@ptrCast(self), &color);
                return color;
            }
        };
    }

    pub const VTable = extern struct {
        base: IBrush.VTable,
        SetColor: *const fn (*ISolidColorBrush, *const COLOR_F) callconv(WINAPI) void,
        GetColor: *const fn (*ISolidColorBrush, *COLOR_F) callconv(WINAPI) *COLOR_F,
    };
};

pub const ILinearGradientBrush = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IBrush.VTable,
        SetStartPoint: *anyopaque,
        SetEndPoint: *anyopaque,
        GetStartPoint: *anyopaque,
        GetEndPoint: *anyopaque,
        GetGradientStopCollection: *anyopaque,
    };
};

pub const IRadialGradientBrush = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IBrush.VTable,
        SetCenter: *anyopaque,
        SetGradientOriginOffset: *anyopaque,
        SetRadiusX: *anyopaque,
        SetRadiusY: *anyopaque,
        GetCenter: *anyopaque,
        GetGradientOriginOffset: *anyopaque,
        GetRadiusX: *anyopaque,
        GetRadiusY: *anyopaque,
        GetGradientStopCollection: *anyopaque,
    };
};

pub const DRAW_TEXT_OPTIONS = packed struct(UINT) {
    NO_SNAP: bool = false,
    CLIP: bool = false,
    ENABLE_COLOR_FONT: bool = false,
    DISABLE_COLOR_BITMAP_SNAPPING: bool = false,
    __unused: u28 = 0,
};

pub const TAG = UINT64;

pub const IRenderTarget = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateSolidColorBrush = IRenderTarget.Methods(@This()).CreateSolidColorBrush;
    pub const CreateGradientStopCollection = IRenderTarget.Methods(@This()).CreateGradientStopCollection;
    pub const CreateRadialGradientBrush = IRenderTarget.Methods(@This()).CreateRadialGradientBrush;
    pub const DrawLine = IRenderTarget.Methods(@This()).DrawLine;
    pub const DrawRectangle = IRenderTarget.Methods(@This()).DrawRectangle;
    pub const FillRectangle = IRenderTarget.Methods(@This()).FillRectangle;
    pub const DrawRoundedRectangle = IRenderTarget.Methods(@This()).DrawRoundedRectangle;
    pub const FillRoundedRectangle = IRenderTarget.Methods(@This()).FillRoundedRectangle;
    pub const DrawEllipse = IRenderTarget.Methods(@This()).DrawEllipse;
    pub const FillEllipse = IRenderTarget.Methods(@This()).FillEllipse;
    pub const DrawGeometry = IRenderTarget.Methods(@This()).DrawGeometry;
    pub const FillGeometry = IRenderTarget.Methods(@This()).FillGeometry;
    pub const DrawBitmap = IRenderTarget.Methods(@This()).DrawBitmap;
    pub const DrawText = IRenderTarget.Methods(@This()).DrawText;
    pub const SetTransform = IRenderTarget.Methods(@This()).SetTransform;
    pub const Clear = IRenderTarget.Methods(@This()).Clear;
    pub const BeginDraw = IRenderTarget.Methods(@This()).BeginDraw;
    pub const EndDraw = IRenderTarget.Methods(@This()).EndDraw;
    pub const GetSize = IRenderTarget.Methods(@This()).GetSize;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateSolidColorBrush(
                self: *T,
                color: *const COLOR_F,
                properties: ?*const BRUSH_PROPERTIES,
                brush: *?*ISolidColorBrush,
            ) HRESULT {
                return @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).CreateSolidColorBrush(
                    @ptrCast(self),
                    color,
                    properties,
                    brush,
                );
            }
            pub inline fn CreateGradientStopCollection(
                self: *T,
                stops: [*]const GRADIENT_STOP,
                num_stops: UINT32,
                gamma: GAMMA,
                extend_mode: EXTEND_MODE,
                stop_collection: *?*IGradientStopCollection,
            ) HRESULT {
                return @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).CreateGradientStopCollection(
                    @ptrCast(self),
                    stops,
                    num_stops,
                    gamma,
                    extend_mode,
                    stop_collection,
                );
            }
            pub inline fn CreateRadialGradientBrush(
                self: *T,
                gradient_properties: *const RADIAL_GRADIENT_BRUSH_PROPERTIES,
                brush_properties: ?*const BRUSH_PROPERTIES,
                stop_collection: *IGradientStopCollection,
                brush: *?*IRadialGradientBrush,
            ) HRESULT {
                return @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).CreateRadialGradientBrush(
                    @ptrCast(self),
                    gradient_properties,
                    brush_properties,
                    stop_collection,
                    brush,
                );
            }
            pub inline fn DrawLine(
                self: *T,
                p0: POINT_2F,
                p1: POINT_2F,
                brush: *IBrush,
                width: FLOAT,
                style: ?*IStrokeStyle,
            ) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).DrawLine(
                    @ptrCast(self),
                    p0,
                    p1,
                    brush,
                    width,
                    style,
                );
            }
            pub inline fn DrawRectangle(
                self: *T,
                rect: *const RECT_F,
                brush: *IBrush,
                width: FLOAT,
                stroke: ?*IStrokeStyle,
            ) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).DrawRectangle(
                    @ptrCast(self),
                    rect,
                    brush,
                    width,
                    stroke,
                );
            }
            pub inline fn FillRectangle(self: *T, rect: *const RECT_F, brush: *IBrush) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).FillRectangle(@ptrCast(self), rect, brush);
            }
            pub inline fn DrawRoundedRectangle(
                self: *T,
                rect: *const ROUNDED_RECT,
                brush: *IBrush,
                width: FLOAT,
                stroke: ?*IStrokeStyle,
            ) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).DrawRoundedRectangle(
                    @ptrCast(self),
                    rect,
                    brush,
                    width,
                    stroke,
                );
            }
            pub inline fn FillRoundedRectangle(self: *T, rect: *const ROUNDED_RECT, brush: *IBrush) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).FillRoundedRectangle(
                    @ptrCast(self),
                    rect,
                    brush,
                );
            }
            pub inline fn DrawEllipse(
                self: *T,
                ellipse: *const ELLIPSE,
                brush: *IBrush,
                width: FLOAT,
                stroke: ?*IStrokeStyle,
            ) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).DrawEllipse(
                    @ptrCast(self),
                    ellipse,
                    brush,
                    width,
                    stroke,
                );
            }
            pub inline fn FillEllipse(self: *T, ellipse: *const ELLIPSE, brush: *IBrush) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).FillEllipse(@ptrCast(self), ellipse, brush);
            }
            pub inline fn DrawGeometry(
                self: *T,
                geo: *IGeometry,
                brush: *IBrush,
                width: FLOAT,
                stroke: ?*IStrokeStyle,
            ) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).DrawGeometry(
                    @ptrCast(self),
                    geo,
                    brush,
                    width,
                    stroke,
                );
            }
            pub inline fn FillGeometry(self: *T, geo: *IGeometry, brush: *IBrush, opacity_brush: ?*IBrush) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).FillGeometry(
                    @ptrCast(self),
                    geo,
                    brush,
                    opacity_brush,
                );
            }
            pub inline fn DrawBitmap(
                self: *T,
                bitmap: *IBitmap,
                dst_rect: ?*const RECT_F,
                opacity: FLOAT,
                interpolation_mode: BITMAP_INTERPOLATION_MODE,
                src_rect: ?*const RECT_F,
            ) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).DrawBitmap(
                    @ptrCast(self),
                    bitmap,
                    dst_rect,
                    opacity,
                    interpolation_mode,
                    src_rect,
                );
            }
            pub inline fn DrawText(
                self: *T,
                string: LPCWSTR,
                length: UINT,
                format: *dwrite.ITextFormat,
                layout_rect: *const RECT_F,
                brush: *IBrush,
                options: DRAW_TEXT_OPTIONS,
                measuring_mode: dwrite.MEASURING_MODE,
            ) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).DrawText(
                    @ptrCast(self),
                    string,
                    length,
                    format,
                    layout_rect,
                    brush,
                    options,
                    measuring_mode,
                );
            }
            pub inline fn SetTransform(self: *T, m: *const MATRIX_3X2_F) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).SetTransform(@ptrCast(self), m);
            }
            pub inline fn Clear(self: *T, color: ?*const COLOR_F) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).Clear(@ptrCast(self), color);
            }
            pub inline fn BeginDraw(self: *T) void {
                @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).BeginDraw(@ptrCast(self));
            }
            pub inline fn EndDraw(self: *T, tag1: ?*TAG, tag2: ?*TAG) HRESULT {
                return @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).EndDraw(@ptrCast(self), tag1, tag2);
            }
            pub inline fn GetSize(self: *T) SIZE_F {
                var size: SIZE_F = undefined;
                _ = @as(*const IRenderTarget.VTable, @ptrCast(self.__v)).GetSize(@ptrCast(self), &size);
                return size;
            }
        };
    }

    pub const VTable = extern struct {
        const T = IRenderTarget;
        base: IResource.VTable,
        CreateBitmap: *anyopaque,
        CreateBitmapFromWicBitmap: *anyopaque,
        CreateSharedBitmap: *anyopaque,
        CreateBitmapBrush: *anyopaque,
        CreateSolidColorBrush: *const fn (
            *T,
            *const COLOR_F,
            ?*const BRUSH_PROPERTIES,
            *?*ISolidColorBrush,
        ) callconv(WINAPI) HRESULT,
        CreateGradientStopCollection: *const fn (
            *T,
            [*]const GRADIENT_STOP,
            UINT32,
            GAMMA,
            EXTEND_MODE,
            *?*IGradientStopCollection,
        ) callconv(WINAPI) HRESULT,
        CreateLinearGradientBrush: *anyopaque,
        CreateRadialGradientBrush: *const fn (
            *T,
            *const RADIAL_GRADIENT_BRUSH_PROPERTIES,
            ?*const BRUSH_PROPERTIES,
            *IGradientStopCollection,
            *?*IRadialGradientBrush,
        ) callconv(WINAPI) HRESULT,
        CreateCompatibleRenderTarget: *anyopaque,
        CreateLayer: *anyopaque,
        CreateMesh: *anyopaque,
        DrawLine: *const fn (
            *T,
            POINT_2F,
            POINT_2F,
            *IBrush,
            FLOAT,
            ?*IStrokeStyle,
        ) callconv(WINAPI) void,
        DrawRectangle: *const fn (*T, *const RECT_F, *IBrush, FLOAT, ?*IStrokeStyle) callconv(WINAPI) void,
        FillRectangle: *const fn (*T, *const RECT_F, *IBrush) callconv(WINAPI) void,
        DrawRoundedRectangle: *const fn (
            *T,
            *const ROUNDED_RECT,
            *IBrush,
            FLOAT,
            ?*IStrokeStyle,
        ) callconv(WINAPI) void,
        FillRoundedRectangle: *const fn (*T, *const ROUNDED_RECT, *IBrush) callconv(WINAPI) void,
        DrawEllipse: *const fn (*T, *const ELLIPSE, *IBrush, FLOAT, ?*IStrokeStyle) callconv(WINAPI) void,
        FillEllipse: *const fn (*T, *const ELLIPSE, *IBrush) callconv(WINAPI) void,
        DrawGeometry: *const fn (*T, *IGeometry, *IBrush, FLOAT, ?*IStrokeStyle) callconv(WINAPI) void,
        FillGeometry: *const fn (*T, *IGeometry, *IBrush, ?*IBrush) callconv(WINAPI) void,
        FillMesh: *anyopaque,
        FillOpacityMask: *anyopaque,
        DrawBitmap: *const fn (
            *T,
            *IBitmap,
            ?*const RECT_F,
            FLOAT,
            BITMAP_INTERPOLATION_MODE,
            ?*const RECT_F,
        ) callconv(WINAPI) void,
        DrawText: *const fn (
            *T,
            LPCWSTR,
            UINT,
            *dwrite.ITextFormat,
            *const RECT_F,
            *IBrush,
            DRAW_TEXT_OPTIONS,
            dwrite.MEASURING_MODE,
        ) callconv(WINAPI) void,
        DrawTextLayout: *anyopaque,
        DrawGlyphRun: *anyopaque,
        SetTransform: *const fn (*T, *const MATRIX_3X2_F) callconv(WINAPI) void,
        GetTransform: *anyopaque,
        SetAntialiasMode: *anyopaque,
        GetAntialiasMode: *anyopaque,
        SetTextAntialiasMode: *anyopaque,
        GetTextAntialiasMode: *anyopaque,
        SetTextRenderingParams: *anyopaque,
        GetTextRenderingParams: *anyopaque,
        SetTags: *anyopaque,
        GetTags: *anyopaque,
        PushLayer: *anyopaque,
        PopLayer: *anyopaque,
        Flush: *anyopaque,
        SaveDrawingState: *anyopaque,
        RestoreDrawingState: *anyopaque,
        PushAxisAlignedClip: *anyopaque,
        PopAxisAlignedClip: *anyopaque,
        Clear: *const fn (*T, ?*const COLOR_F) callconv(WINAPI) void,
        BeginDraw: *const fn (*T) callconv(WINAPI) void,
        EndDraw: *const fn (*T, ?*TAG, ?*TAG) callconv(WINAPI) HRESULT,
        GetPixelFormat: *anyopaque,
        SetDpi: *anyopaque,
        GetDpi: *anyopaque,
        GetSize: *const fn (*T, *SIZE_F) callconv(WINAPI) *SIZE_F,
        GetPixelSize: *anyopaque,
        GetMaximumBitmapSize: *anyopaque,
        IsSupported: *anyopaque,
    };
};

pub const PIXEL_FORMAT = extern struct {
    format: dxgi.FORMAT,
    alphaMode: ALPHA_MODE,
};

pub const ALPHA_MODE = enum(UINT) {
    UNKNOWN = 0,
    PREMULTIPLIED = 1,
    STRAIGHT = 2,
    IGNORE = 3,
};

pub const BITMAP_PROPERTIES1 = extern struct {
    pixelFormat: PIXEL_FORMAT,
    dpiX: FLOAT,
    dpiY: FLOAT,
    bitmapOptions: BITMAP_OPTIONS,
    colorContext: ?*IColorContext,
};

pub const IColorContext = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IResource.VTable,
        GetColorSpace: *anyopaque,
        GetProfileSize: *anyopaque,
        GetProfile: *anyopaque,
    };
};

pub const MAPPED_RECT = extern struct {
    pitch: UINT32,
    bits: [*]BYTE,
};

pub const IBitmap1 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CopyFromBitmap = IBitmap.Methods(@This()).CopyFromBitmap;

    pub const Map = IBitmap1.Methods(@This()).Map;
    pub const Unmap = IBitmap1.Methods(@This()).Unmap;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Map(
                self: *T,
                options: MAP_OPTIONS,
                mapped_rect: *MAPPED_RECT,
            ) HRESULT {
                return @as(*const IBitmap1.VTable, @ptrCast(self.__v)).Map(
                    @ptrCast(self),
                    options,
                    mapped_rect,
                );
            }
            pub inline fn Unmap(self: *T) HRESULT {
                return @as(*const IBitmap1.VTable, @ptrCast(self.__v)).Unmap(
                    @ptrCast(self),
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IBitmap.VTable,
        GetColorContext: *anyopaque,
        GetOptions: *anyopaque,
        GetSurface: *anyopaque,
        Map: *const fn (*IBitmap1, MAP_OPTIONS, *MAPPED_RECT) callconv(WINAPI) HRESULT,
        Unmap: *const fn (*IBitmap1) callconv(WINAPI) HRESULT,
    };
};

pub const IDeviceContext = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateSolidColorBrush = IRenderTarget.Methods(@This()).CreateSolidColorBrush;
    pub const CreateGradientStopCollection = IRenderTarget.Methods(@This()).CreateGradientStopCollection;
    pub const CreateRadialGradientBrush = IRenderTarget.Methods(@This()).CreateRadialGradientBrush;
    pub const DrawLine = IRenderTarget.Methods(@This()).DrawLine;
    pub const DrawRectangle = IRenderTarget.Methods(@This()).DrawRectangle;
    pub const FillRectangle = IRenderTarget.Methods(@This()).FillRectangle;
    pub const DrawRoundedRectangle = IRenderTarget.Methods(@This()).DrawRoundedRectangle;
    pub const FillRoundedRectangle = IRenderTarget.Methods(@This()).FillRoundedRectangle;
    pub const DrawEllipse = IRenderTarget.Methods(@This()).DrawEllipse;
    pub const FillEllipse = IRenderTarget.Methods(@This()).FillEllipse;
    pub const DrawGeometry = IRenderTarget.Methods(@This()).DrawGeometry;
    pub const FillGeometry = IRenderTarget.Methods(@This()).FillGeometry;
    pub const DrawBitmap = IRenderTarget.Methods(@This()).DrawBitmap;
    pub const DrawText = IRenderTarget.Methods(@This()).DrawText;
    pub const SetTransform = IRenderTarget.Methods(@This()).SetTransform;
    pub const Clear = IRenderTarget.Methods(@This()).Clear;
    pub const BeginDraw = IRenderTarget.Methods(@This()).BeginDraw;
    pub const EndDraw = IRenderTarget.Methods(@This()).EndDraw;
    pub const GetSize = IRenderTarget.Methods(@This()).GetSize;

    pub const CreateBitmap1 = IDeviceContext.Methods(@This()).CreateBitmap1;
    pub const CreateBitmapFromWicBitmap1 = IDeviceContext.Methods(@This()).CreateBitmapFromWicBitmap1;
    pub const SetTarget = IDeviceContext.Methods(@This()).SetTarget;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateBitmapFromDxgiSurface(
                self: *T,
                surface: *dxgi.ISurface,
                properties: ?*const BITMAP_PROPERTIES1,
                bitmap: *?*IBitmap1,
            ) HRESULT {
                return @as(*const IDeviceContext.VTable, @ptrCast(self.__v)).CreateBitmapFromDxgiSurface(
                    @ptrCast(self),
                    surface,
                    properties,
                    bitmap,
                );
            }
            pub inline fn SetTarget(self: *T, image: ?*IImage) void {
                @as(*const IDeviceContext.VTable, @ptrCast(self.__v)).SetTarget(@ptrCast(self), image);
            }
            pub inline fn CreateBitmap1(
                self: *T,
                size: SIZE_U,
                src_data: ?*const anyopaque,
                pitch: UINT32,
                properties: *const BITMAP_PROPERTIES1,
                bitmap: *?*IBitmap1,
            ) HRESULT {
                return @as(*const IDeviceContext.VTable, @ptrCast(self.__v)).CreateBitmap1(
                    @ptrCast(self),
                    size,
                    src_data,
                    pitch,
                    properties,
                    bitmap,
                );
            }
            pub inline fn CreateBitmapFromWicBitmap1(
                self: *T,
                wic_bitmap_source: *wic.IBitmapSource,
                properties: ?*const BITMAP_PROPERTIES1,
                bitmap: *?*IBitmap1,
            ) HRESULT {
                return @as(*const IDeviceContext.VTable, @ptrCast(self.__v)).CreateBitmapFromWicBitmap1(
                    @ptrCast(self),
                    wic_bitmap_source,
                    properties,
                    bitmap,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IRenderTarget.VTable,
        CreateBitmap1: *const fn (
            *IDeviceContext,
            SIZE_U,
            ?*const anyopaque,
            UINT32,
            *const BITMAP_PROPERTIES1,
            *?*IBitmap1,
        ) callconv(WINAPI) HRESULT,
        CreateBitmapFromWicBitmap1: *const fn (
            *IDeviceContext,
            *wic.IBitmapSource,
            ?*const BITMAP_PROPERTIES1,
            *?*IBitmap1,
        ) callconv(WINAPI) HRESULT,
        CreateColorContext: *anyopaque,
        CreateColorContextFromFilename: *anyopaque,
        CreateColorContextFromWicColorContext: *anyopaque,
        CreateBitmapFromDxgiSurface: *const fn (
            *IDeviceContext,
            *dxgi.ISurface,
            ?*const BITMAP_PROPERTIES1,
            *?*IBitmap1,
        ) callconv(WINAPI) HRESULT,
        CreateEffect: *anyopaque,
        CreateGradientStopCollection1: *anyopaque,
        CreateImageBrush: *anyopaque,
        CreateBitmapBrush1: *anyopaque,
        CreateCommandList: *anyopaque,
        IsDxgiFormatSupported: *anyopaque,
        IsBufferPrecisionSupported: *anyopaque,
        GetImageLocalBounds: *anyopaque,
        GetImageWorldBounds: *anyopaque,
        GetGlyphRunWorldBounds: *anyopaque,
        GetDevice: *anyopaque,
        SetTarget: *const fn (*IDeviceContext, ?*IImage) callconv(WINAPI) void,
        GetTarget: *anyopaque,
        SetRenderingControls: *anyopaque,
        GetRenderingControls: *anyopaque,
        SetPrimitiveBlend: *anyopaque,
        GetPrimitiveBlend: *anyopaque,
        SetUnitMode: *anyopaque,
        GetUnitMode: *anyopaque,
        DrawGlyphRun1: *anyopaque,
        DrawImage: *anyopaque,
        DrawGdiMetafile: *anyopaque,
        DrawBitmap1: *anyopaque,
        PushLayer1: *anyopaque,
        InvalidateEffectInputRectangle: *anyopaque,
        GetEffectInvalidRectangleCount: *anyopaque,
        GetEffectInvalidRectangles: *anyopaque,
        GetEffectRequiredInputRectangles: *anyopaque,
        FillOpacityMask1: *anyopaque,
    };
};

pub const IDeviceContext1 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateSolidColorBrush = IRenderTarget.Methods(@This()).CreateSolidColorBrush;
    pub const CreateGradientStopCollection = IRenderTarget.Methods(@This()).CreateGradientStopCollection;
    pub const CreateRadialGradientBrush = IRenderTarget.Methods(@This()).CreateRadialGradientBrush;
    pub const DrawLine = IRenderTarget.Methods(@This()).DrawLine;
    pub const DrawRectangle = IRenderTarget.Methods(@This()).DrawRectangle;
    pub const FillRectangle = IRenderTarget.Methods(@This()).FillRectangle;
    pub const DrawRoundedRectangle = IRenderTarget.Methods(@This()).DrawRoundedRectangle;
    pub const FillRoundedRectangle = IRenderTarget.Methods(@This()).FillRoundedRectangle;
    pub const DrawEllipse = IRenderTarget.Methods(@This()).DrawEllipse;
    pub const FillEllipse = IRenderTarget.Methods(@This()).FillEllipse;
    pub const DrawGeometry = IRenderTarget.Methods(@This()).DrawGeometry;
    pub const FillGeometry = IRenderTarget.Methods(@This()).FillGeometry;
    pub const DrawBitmap = IRenderTarget.Methods(@This()).DrawBitmap;
    pub const DrawText = IRenderTarget.Methods(@This()).DrawText;
    pub const SetTransform = IRenderTarget.Methods(@This()).SetTransform;
    pub const Clear = IRenderTarget.Methods(@This()).Clear;
    pub const BeginDraw = IRenderTarget.Methods(@This()).BeginDraw;
    pub const EndDraw = IRenderTarget.Methods(@This()).EndDraw;
    pub const GetSize = IRenderTarget.Methods(@This()).GetSize;

    pub const CreateBitmap1 = IDeviceContext.Methods(@This()).CreateBitmap1;
    pub const CreateBitmapFromWicBitmap1 = IDeviceContext.Methods(@This()).CreateBitmapFromWicBitmap1;
    pub const SetTarget = IDeviceContext.Methods(@This()).SetTarget;

    pub const VTable = extern struct {
        base: IDeviceContext.VTable,
        CreateFilledGeometryRealization: *anyopaque,
        CreateStrokedGeometryRealization: *anyopaque,
        DrawGeometryRealization: *anyopaque,
    };
};

pub const INK_NIB_SHAPE = enum(UINT) {
    ROUND = 0,
    SQUARE = 1,
};

pub const INK_POINT = extern struct {
    x: FLOAT,
    y: FLOAT,
    radius: FLOAT,
};

pub const INK_BEZIER_SEGMENT = extern struct {
    point1: INK_POINT,
    point2: INK_POINT,
    point3: INK_POINT,
};

pub const INK_STYLE_PROPERTIES = extern struct {
    nibShape: INK_NIB_SHAPE,
    nibTransform: MATRIX_3X2_F,
};

pub const IInk = extern struct {
    __v: *const VTable,

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetStartPoint(self: *T, point: *const INK_POINT) void {
                @as(*const IInk.VTable, @ptrCast(self.__v)).SetStartPoint(@ptrCast(self), point);
            }
            pub inline fn GetStartPoint(self: *T) INK_POINT {
                var point: INK_POINT = undefined;
                _ = @as(*const IInk.VTable, @ptrCast(self.__v)).GetStartPoint(@ptrCast(self), &point);
                return point;
            }
            pub inline fn AddSegments(self: *T, segments: [*]const INK_BEZIER_SEGMENT, count: UINT32) HRESULT {
                return @as(*const IInk.VTable, @ptrCast(self.__v)).AddSegments(@ptrCast(self), segments, count);
            }
            pub inline fn RemoveSegmentsAtEnd(self: *T, count: UINT32) HRESULT {
                return @as(*const IInk.VTable, @ptrCast(self.__v)).RemoveSegmentsAtEnd(@ptrCast(self), count);
            }
            pub inline fn SetSegments(
                self: *T,
                start_segment: UINT32,
                segments: [*]const INK_BEZIER_SEGMENT,
                count: UINT32,
            ) HRESULT {
                return @as(*const IInk.VTable, @ptrCast(self.__v)).SetSegments(
                    @ptrCast(self),
                    start_segment,
                    segments,
                    count,
                );
            }
            pub inline fn SetSegmentAtEnd(self: *T, segment: *const INK_BEZIER_SEGMENT) HRESULT {
                return @as(*const IInk.VTable, @ptrCast(self.__v)).SetSegmentAtEnd(@ptrCast(self), segment);
            }
            pub inline fn GetSegmentCount(self: *T) UINT32 {
                return @as(*const IInk.VTable, @ptrCast(self.__v)).GetSegmentCount(@ptrCast(self));
            }
            pub inline fn GetSegments(
                self: *T,
                start_segment: UINT32,
                segments: [*]const INK_BEZIER_SEGMENT,
                count: UINT32,
            ) HRESULT {
                return @as(*const IInk.VTable, @ptrCast(self.__v)).GetSegments(
                    @ptrCast(self),
                    start_segment,
                    segments,
                    count,
                );
            }
        };
    }

    pub const VTable = extern struct {
        const T = IInk;
        base: IResource.VTable,
        SetStartPoint: *const fn (*T, *const INK_POINT) callconv(WINAPI) void,
        GetStartPoint: *const fn (*T, *INK_POINT) callconv(WINAPI) *INK_POINT,
        AddSegments: *const fn (*T, [*]const INK_BEZIER_SEGMENT, UINT32) callconv(WINAPI) HRESULT,
        RemoveSegmentsAtEnd: *const fn (*T, UINT32) callconv(WINAPI) HRESULT,
        SetSegments: *const fn (*T, UINT32, [*]const INK_BEZIER_SEGMENT, UINT32) callconv(WINAPI) HRESULT,
        SetSegmentAtEnd: *const fn (*T, *const INK_BEZIER_SEGMENT) callconv(WINAPI) HRESULT,
        GetSegmentCount: *const fn (*T) callconv(WINAPI) UINT32,
        GetSegments: *const fn (*T, UINT32, [*]const INK_BEZIER_SEGMENT, UINT32) callconv(WINAPI) HRESULT,
        StreamAsGeometry: *anyopaque,
        GetBounds: *anyopaque,
    };
};

pub const IInkStyle = extern struct {
    __v: *const VTable,

    pub const VTable = extern struct {
        base: IResource.VTable,
        SetNibTransform: *anyopaque,
        GetNibTransform: *anyopaque,
        SetNibShape: *anyopaque,
        GetNibShape: *anyopaque,
    };
};

pub const IDeviceContext2 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateSolidColorBrush = IRenderTarget.Methods(@This()).CreateSolidColorBrush;
    pub const CreateGradientStopCollection = IRenderTarget.Methods(@This()).CreateGradientStopCollection;
    pub const CreateRadialGradientBrush = IRenderTarget.Methods(@This()).CreateRadialGradientBrush;
    pub const DrawLine = IRenderTarget.Methods(@This()).DrawLine;
    pub const DrawRectangle = IRenderTarget.Methods(@This()).DrawRectangle;
    pub const FillRectangle = IRenderTarget.Methods(@This()).FillRectangle;
    pub const DrawRoundedRectangle = IRenderTarget.Methods(@This()).DrawRoundedRectangle;
    pub const FillRoundedRectangle = IRenderTarget.Methods(@This()).FillRoundedRectangle;
    pub const DrawEllipse = IRenderTarget.Methods(@This()).DrawEllipse;
    pub const FillEllipse = IRenderTarget.Methods(@This()).FillEllipse;
    pub const DrawGeometry = IRenderTarget.Methods(@This()).DrawGeometry;
    pub const FillGeometry = IRenderTarget.Methods(@This()).FillGeometry;
    pub const DrawBitmap = IRenderTarget.Methods(@This()).DrawBitmap;
    pub const DrawText = IRenderTarget.Methods(@This()).DrawText;
    pub const SetTransform = IRenderTarget.Methods(@This()).SetTransform;
    pub const Clear = IRenderTarget.Methods(@This()).Clear;
    pub const BeginDraw = IRenderTarget.Methods(@This()).BeginDraw;
    pub const EndDraw = IRenderTarget.Methods(@This()).EndDraw;
    pub const GetSize = IRenderTarget.Methods(@This()).GetSize;

    pub const CreateBitmap1 = IDeviceContext.Methods(@This()).CreateBitmap1;
    pub const CreateBitmapFromWicBitmap1 = IDeviceContext.Methods(@This()).CreateBitmapFromWicBitmap1;
    pub const SetTarget = IDeviceContext.Methods(@This()).SetTarget;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateInk(self: *T, start_point: *const INK_POINT, ink: *?*IInk) HRESULT {
                return @as(*const IDeviceContext2.VTable, @ptrCast(self.__v)).CreateInk(
                    @ptrCast(self),
                    start_point,
                    ink,
                );
            }
            pub inline fn CreateInkStyle(
                self: *T,
                properties: ?*const INK_STYLE_PROPERTIES,
                ink_style: *?*IInkStyle,
            ) HRESULT {
                return @as(*const IDeviceContext2.VTable, @ptrCast(self.__v)).CreateInkStyle(
                    @ptrCast(self),
                    properties,
                    ink_style,
                );
            }
            pub inline fn DrawInk(self: *T, ink: *IInk, brush: *IBrush, style: ?*IInkStyle) void {
                return @as(*const IDeviceContext2.VTable, @ptrCast(self.__v)).DrawInk(
                    @ptrCast(self),
                    ink,
                    brush,
                    style,
                );
            }
        };
    }

    pub const VTable = extern struct {
        const T = IDeviceContext2;
        base: IDeviceContext1.VTable,
        CreateInk: *const fn (*T, *const INK_POINT, *?*IInk) callconv(WINAPI) HRESULT,
        CreateInkStyle: *const fn (*T, ?*const INK_STYLE_PROPERTIES, *?*IInkStyle) callconv(WINAPI) HRESULT,
        CreateGradientMesh: *anyopaque,
        CreateImageSourceFromWic: *anyopaque,
        CreateLookupTable3D: *anyopaque,
        CreateImageSourceFromDxgi: *anyopaque,
        GetGradientMeshWorldBounds: *anyopaque,
        DrawInk: *const fn (*T, *IInk, *IBrush, ?*IInkStyle) callconv(WINAPI) void,
        DrawGradientMesh: *anyopaque,
        DrawGdiMetafile1: *anyopaque,
        CreateTransformedImageSource: *anyopaque,
    };
};

pub const IDeviceContext3 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateSolidColorBrush = IRenderTarget.Methods(@This()).CreateSolidColorBrush;
    pub const CreateGradientStopCollection = IRenderTarget.Methods(@This()).CreateGradientStopCollection;
    pub const CreateRadialGradientBrush = IRenderTarget.Methods(@This()).CreateRadialGradientBrush;
    pub const DrawLine = IRenderTarget.Methods(@This()).DrawLine;
    pub const DrawRectangle = IRenderTarget.Methods(@This()).DrawRectangle;
    pub const FillRectangle = IRenderTarget.Methods(@This()).FillRectangle;
    pub const DrawRoundedRectangle = IRenderTarget.Methods(@This()).DrawRoundedRectangle;
    pub const FillRoundedRectangle = IRenderTarget.Methods(@This()).FillRoundedRectangle;
    pub const DrawEllipse = IRenderTarget.Methods(@This()).DrawEllipse;
    pub const FillEllipse = IRenderTarget.Methods(@This()).FillEllipse;
    pub const DrawGeometry = IRenderTarget.Methods(@This()).DrawGeometry;
    pub const FillGeometry = IRenderTarget.Methods(@This()).FillGeometry;
    pub const DrawBitmap = IRenderTarget.Methods(@This()).DrawBitmap;
    pub const DrawText = IRenderTarget.Methods(@This()).DrawText;
    pub const SetTransform = IRenderTarget.Methods(@This()).SetTransform;
    pub const Clear = IRenderTarget.Methods(@This()).Clear;
    pub const BeginDraw = IRenderTarget.Methods(@This()).BeginDraw;
    pub const EndDraw = IRenderTarget.Methods(@This()).EndDraw;
    pub const GetSize = IRenderTarget.Methods(@This()).GetSize;

    pub const CreateBitmap1 = IDeviceContext.Methods(@This()).CreateBitmap1;
    pub const CreateBitmapFromWicBitmap1 = IDeviceContext.Methods(@This()).CreateBitmapFromWicBitmap1;
    pub const SetTarget = IDeviceContext.Methods(@This()).SetTarget;

    pub const VTable = extern struct {
        base: IDeviceContext2.VTable,
        CreateSpriteBatch: *anyopaque,
        DrawSpriteBatch: *anyopaque,
    };
};

pub const IDeviceContext4 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateSolidColorBrush = IRenderTarget.Methods(@This()).CreateSolidColorBrush;
    pub const CreateGradientStopCollection = IRenderTarget.Methods(@This()).CreateGradientStopCollection;
    pub const CreateRadialGradientBrush = IRenderTarget.Methods(@This()).CreateRadialGradientBrush;
    pub const DrawLine = IRenderTarget.Methods(@This()).DrawLine;
    pub const DrawRectangle = IRenderTarget.Methods(@This()).DrawRectangle;
    pub const FillRectangle = IRenderTarget.Methods(@This()).FillRectangle;
    pub const DrawRoundedRectangle = IRenderTarget.Methods(@This()).DrawRoundedRectangle;
    pub const FillRoundedRectangle = IRenderTarget.Methods(@This()).FillRoundedRectangle;
    pub const DrawEllipse = IRenderTarget.Methods(@This()).DrawEllipse;
    pub const FillEllipse = IRenderTarget.Methods(@This()).FillEllipse;
    pub const DrawGeometry = IRenderTarget.Methods(@This()).DrawGeometry;
    pub const FillGeometry = IRenderTarget.Methods(@This()).FillGeometry;
    pub const DrawBitmap = IRenderTarget.Methods(@This()).DrawBitmap;
    pub const DrawText = IRenderTarget.Methods(@This()).DrawText;
    pub const SetTransform = IRenderTarget.Methods(@This()).SetTransform;
    pub const Clear = IRenderTarget.Methods(@This()).Clear;
    pub const BeginDraw = IRenderTarget.Methods(@This()).BeginDraw;
    pub const EndDraw = IRenderTarget.Methods(@This()).EndDraw;
    pub const GetSize = IRenderTarget.Methods(@This()).GetSize;

    pub const CreateBitmap1 = IDeviceContext.Methods(@This()).CreateBitmap1;
    pub const CreateBitmapFromWicBitmap1 = IDeviceContext.Methods(@This()).CreateBitmapFromWicBitmap1;
    pub const SetTarget = IDeviceContext.Methods(@This()).SetTarget;

    pub const VTable = extern struct {
        base: IDeviceContext3.VTable,
        CreateSvgGlyphStyle: *anyopaque,
        DrawText1: *anyopaque,
        DrawTextLayout1: *anyopaque,
        DrawColorBitmapGlyphRun: *anyopaque,
        DrawSvgGlyphRun: *anyopaque,
        GetColorBitmapGlyphImage: *anyopaque,
        GetSvgGlyphImage: *anyopaque,
    };
};

pub const ISvgDocument = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IResource.VTable,
        SetViewportSize: *anyopaque,
        GetViewportSize: *anyopaque,
        SetRoot: *anyopaque,
        GetRoot: *anyopaque,
        FindElementById: *anyopaque,
        Serialize: *anyopaque,
        Deserialize: *anyopaque,
        CreatePaint: *anyopaque,
        CreateStrokeDashArray: *anyopaque,
        CreatePointCollection: *anyopaque,
        CreatePathData: *anyopaque,
    };
};

pub const IDeviceContext5 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateSolidColorBrush = IRenderTarget.Methods(@This()).CreateSolidColorBrush;
    pub const CreateGradientStopCollection = IRenderTarget.Methods(@This()).CreateGradientStopCollection;
    pub const CreateRadialGradientBrush = IRenderTarget.Methods(@This()).CreateRadialGradientBrush;
    pub const DrawLine = IRenderTarget.Methods(@This()).DrawLine;
    pub const DrawRectangle = IRenderTarget.Methods(@This()).DrawRectangle;
    pub const FillRectangle = IRenderTarget.Methods(@This()).FillRectangle;
    pub const DrawRoundedRectangle = IRenderTarget.Methods(@This()).DrawRoundedRectangle;
    pub const FillRoundedRectangle = IRenderTarget.Methods(@This()).FillRoundedRectangle;
    pub const DrawEllipse = IRenderTarget.Methods(@This()).DrawEllipse;
    pub const FillEllipse = IRenderTarget.Methods(@This()).FillEllipse;
    pub const DrawGeometry = IRenderTarget.Methods(@This()).DrawGeometry;
    pub const FillGeometry = IRenderTarget.Methods(@This()).FillGeometry;
    pub const DrawBitmap = IRenderTarget.Methods(@This()).DrawBitmap;
    pub const DrawText = IRenderTarget.Methods(@This()).DrawText;
    pub const SetTransform = IRenderTarget.Methods(@This()).SetTransform;
    pub const Clear = IRenderTarget.Methods(@This()).Clear;
    pub const BeginDraw = IRenderTarget.Methods(@This()).BeginDraw;
    pub const EndDraw = IRenderTarget.Methods(@This()).EndDraw;
    pub const GetSize = IRenderTarget.Methods(@This()).GetSize;

    pub const CreateBitmap1 = IDeviceContext.Methods(@This()).CreateBitmap1;
    pub const CreateBitmapFromWicBitmap1 = IDeviceContext.Methods(@This()).CreateBitmapFromWicBitmap1;
    pub const SetTarget = IDeviceContext.Methods(@This()).SetTarget;

    pub const CreateSvgDocument = IDeviceContext5.Methods(@This()).CreateSvgDocument;
    pub const DrawSvgDocument = IDeviceContext5.Methods(@This()).DrawSvgDocument;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateSvgDocument(self: *T, input_xml_stream: ?*objidl.IStream, viewport_size: SIZE_F, document: **ISvgDocument) HRESULT {
                return @as(*const IDeviceContext5.VTable, @ptrCast(self.__v)).CreateSvgDocument(
                    @ptrCast(self),
                    input_xml_stream,
                    viewport_size,
                    document,
                );
            }
            pub inline fn DrawSvgDocument(self: *T, document: *ISvgDocument) void {
                @as(*const IDeviceContext5.VTable, @ptrCast(self.__v)).DrawSvgDocument(@ptrCast(self), document);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDeviceContext4.VTable,
        CreateSvgDocument: *const fn (*IDeviceContext5, ?*objidl.IStream, SIZE_F, **ISvgDocument) callconv(WINAPI) HRESULT,
        DrawSvgDocument: *const fn (*IDeviceContext5, *ISvgDocument) callconv(WINAPI) void,
        CreateColorContextFromDxgiColorSpace: *anyopaque,
        CreateColorContextFromSimpleColorProfile: *anyopaque,
    };
};

pub const FACTORY_TYPE = enum(UINT) {
    SINGLE_THREADED = 0,
    MULTI_THREADED = 1,
};

pub const DEBUG_LEVEL = enum(UINT) {
    NONE = 0,
    ERROR = 1,
    WARNING = 2,
    INFORMATION = 3,
};

pub const FACTORY_OPTIONS = extern struct {
    debugLevel: DEBUG_LEVEL,
};

pub const CreateFactory = D2D1CreateFactory;

extern "d2d1" fn D2D1CreateFactory(
    FACTORY_TYPE,
    *const GUID,
    ?*const FACTORY_OPTIONS,
    *?*anyopaque,
) callconv(WINAPI) HRESULT;
