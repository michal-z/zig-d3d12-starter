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

pub const RECT_F = extern struct {
    left: FLOAT,
    top: FLOAT,
    right: FLOAT,
    bottom: FLOAT,
};

pub const VECTOR_2F = extern struct {
    x: FLOAT,
    y: FLOAT,
};

pub const MATRIX_3X2_F = extern struct {
    m: [3][2]FLOAT,

    pub fn translation(x: f32, y: f32) MATRIX_3X2_F {
        return .{
            .m = [_][2]FLOAT{
                .{ 1.0, 0.0 },
                .{ 0.0, 1.0 },
                .{ x, y },
            },
        };
    }
};

pub const POINT_2F = extern struct {
    x: FLOAT,
    y: FLOAT,
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

pub const DEFAULT_FLATTENING_TOLERANCE = 0.25;

pub const IGeometry = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;
    pub const FillContainsPoint = IGeometry.Methods(@This()).FillContainsPoint;

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
        CombineWithGeometry: *anyopaque,
        Outline: *anyopaque,
        ComputeArea: *anyopaque,
        ComputeLength: *anyopaque,
        ComputePointAtLength: *anyopaque,
        Widen: *anyopaque,
    };
};

pub const IRectangleGeometry = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetBounds = IGeometry.Methods(@This()).GetBounds;
    pub const Tessellate = IGeometry.Methods(@This()).Tessellate;

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
        CreateGeometryGroup: *anyopaque,
        CreateTransformedGeometry: *anyopaque,
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
