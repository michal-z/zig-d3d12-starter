const w32 = @import("win32.zig");
const UINT = w32.UINT;
const UINT64 = w32.UINT64;
const DWORD = w32.DWORD;
const FLOAT = w32.FLOAT;
const BOOL = w32.BOOL;
const GUID = w32.GUID;
const WINAPI = w32.WINAPI;
const IUnknown = w32.IUnknown;
const HRESULT = w32.HRESULT;
const WCHAR = w32.WCHAR;
const RECT = w32.RECT;
const INT = w32.INT;
const BYTE = w32.BYTE;
const HMONITOR = w32.HMONITOR;
const LARGE_INTEGER = w32.LARGE_INTEGER;
const HWND = w32.HWND;
const SIZE_T = w32.SIZE_T;
const LUID = w32.LUID;
const HANDLE = w32.HANDLE;
const POINT = w32.POINT;

pub const FORMAT = enum(UINT) {
    UNKNOWN = 0,
    R32G32B32A32_TYPELESS = 1,
    R32G32B32A32_FLOAT = 2,
    R32G32B32A32_UINT = 3,
    R32G32B32A32_SINT = 4,
    R32G32B32_TYPELESS = 5,
    R32G32B32_FLOAT = 6,
    R32G32B32_UINT = 7,
    R32G32B32_SINT = 8,
    R16G16B16A16_TYPELESS = 9,
    R16G16B16A16_FLOAT = 10,
    R16G16B16A16_UNORM = 11,
    R16G16B16A16_UINT = 12,
    R16G16B16A16_SNORM = 13,
    R16G16B16A16_SINT = 14,
    R32G32_TYPELESS = 15,
    R32G32_FLOAT = 16,
    R32G32_UINT = 17,
    R32G32_SINT = 18,
    R32G8X24_TYPELESS = 19,
    D32_FLOAT_S8X24_UINT = 20,
    R32_FLOAT_X8X24_TYPELESS = 21,
    X32_TYPELESS_G8X24_UINT = 22,
    R10G10B10A2_TYPELESS = 23,
    R10G10B10A2_UNORM = 24,
    R10G10B10A2_UINT = 25,
    R11G11B10_FLOAT = 26,
    R8G8B8A8_TYPELESS = 27,
    R8G8B8A8_UNORM = 28,
    R8G8B8A8_UNORM_SRGB = 29,
    R8G8B8A8_UINT = 30,
    R8G8B8A8_SNORM = 31,
    R8G8B8A8_SINT = 32,
    R16G16_TYPELESS = 33,
    R16G16_FLOAT = 34,
    R16G16_UNORM = 35,
    R16G16_UINT = 36,
    R16G16_SNORM = 37,
    R16G16_SINT = 38,
    R32_TYPELESS = 39,
    D32_FLOAT = 40,
    R32_FLOAT = 41,
    R32_UINT = 42,
    R32_SINT = 43,
    R24G8_TYPELESS = 44,
    D24_UNORM_S8_UINT = 45,
    R24_UNORM_X8_TYPELESS = 46,
    X24_TYPELESS_G8_UINT = 47,
    R8G8_TYPELESS = 48,
    R8G8_UNORM = 49,
    R8G8_UINT = 50,
    R8G8_SNORM = 51,
    R8G8_SINT = 52,
    R16_TYPELESS = 53,
    R16_FLOAT = 54,
    D16_UNORM = 55,
    R16_UNORM = 56,
    R16_UINT = 57,
    R16_SNORM = 58,
    R16_SINT = 59,
    R8_TYPELESS = 60,
    R8_UNORM = 61,
    R8_UINT = 62,
    R8_SNORM = 63,
    R8_SINT = 64,
    A8_UNORM = 65,
    R1_UNORM = 66,
    R9G9B9E5_SHAREDEXP = 67,
    R8G8_B8G8_UNORM = 68,
    G8R8_G8B8_UNORM = 69,
    BC1_TYPELESS = 70,
    BC1_UNORM = 71,
    BC1_UNORM_SRGB = 72,
    BC2_TYPELESS = 73,
    BC2_UNORM = 74,
    BC2_UNORM_SRGB = 75,
    BC3_TYPELESS = 76,
    BC3_UNORM = 77,
    BC3_UNORM_SRGB = 78,
    BC4_TYPELESS = 79,
    BC4_UNORM = 80,
    BC4_SNORM = 81,
    BC5_TYPELESS = 82,
    BC5_UNORM = 83,
    BC5_SNORM = 84,
    B5G6R5_UNORM = 85,
    B5G5R5A1_UNORM = 86,
    B8G8R8A8_UNORM = 87,
    B8G8R8X8_UNORM = 88,
    R10G10B10_XR_BIAS_A2_UNORM = 89,
    B8G8R8A8_TYPELESS = 90,
    B8G8R8A8_UNORM_SRGB = 91,
    B8G8R8X8_TYPELESS = 92,
    B8G8R8X8_UNORM_SRGB = 93,
    BC6H_TYPELESS = 94,
    BC6H_UF16 = 95,
    BC6H_SF16 = 96,
    BC7_TYPELESS = 97,
    BC7_UNORM = 98,
    BC7_UNORM_SRGB = 99,
    AYUV = 100,
    Y410 = 101,
    Y416 = 102,
    NV12 = 103,
    P010 = 104,
    P016 = 105,
    @"420_OPAQUE" = 106,
    YUY2 = 107,
    Y210 = 108,
    Y216 = 109,
    NV11 = 110,
    AI44 = 111,
    IA44 = 112,
    P8 = 113,
    A8P8 = 114,
    B4G4R4A4_UNORM = 115,
    P208 = 130,
    V208 = 131,
    V408 = 132,
    SAMPLER_FEEDBACK_MIN_MIP_OPAQUE = 189,
    SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE = 190,

    pub fn pixelSizeInBits(format: FORMAT) u32 {
        return switch (format) {
            .R32G32B32A32_TYPELESS,
            .R32G32B32A32_FLOAT,
            .R32G32B32A32_UINT,
            .R32G32B32A32_SINT,
            => 128,

            .R32G32B32_TYPELESS,
            .R32G32B32_FLOAT,
            .R32G32B32_UINT,
            .R32G32B32_SINT,
            => 96,

            .R16G16B16A16_TYPELESS,
            .R16G16B16A16_FLOAT,
            .R16G16B16A16_UNORM,
            .R16G16B16A16_UINT,
            .R16G16B16A16_SNORM,
            .R16G16B16A16_SINT,
            .R32G32_TYPELESS,
            .R32G32_FLOAT,
            .R32G32_UINT,
            .R32G32_SINT,
            .R32G8X24_TYPELESS,
            .D32_FLOAT_S8X24_UINT,
            .R32_FLOAT_X8X24_TYPELESS,
            .X32_TYPELESS_G8X24_UINT,
            .Y416,
            .Y210,
            .Y216,
            => 64,

            .R10G10B10A2_TYPELESS,
            .R10G10B10A2_UNORM,
            .R10G10B10A2_UINT,
            .R11G11B10_FLOAT,
            .R8G8B8A8_TYPELESS,
            .R8G8B8A8_UNORM,
            .R8G8B8A8_UNORM_SRGB,
            .R8G8B8A8_UINT,
            .R8G8B8A8_SNORM,
            .R8G8B8A8_SINT,
            .R16G16_TYPELESS,
            .R16G16_FLOAT,
            .R16G16_UNORM,
            .R16G16_UINT,
            .R16G16_SNORM,
            .R16G16_SINT,
            .R32_TYPELESS,
            .D32_FLOAT,
            .R32_FLOAT,
            .R32_UINT,
            .R32_SINT,
            .R24G8_TYPELESS,
            .D24_UNORM_S8_UINT,
            .R24_UNORM_X8_TYPELESS,
            .X24_TYPELESS_G8_UINT,
            .R9G9B9E5_SHAREDEXP,
            .R8G8_B8G8_UNORM,
            .G8R8_G8B8_UNORM,
            .B8G8R8A8_UNORM,
            .B8G8R8X8_UNORM,
            .R10G10B10_XR_BIAS_A2_UNORM,
            .B8G8R8A8_TYPELESS,
            .B8G8R8A8_UNORM_SRGB,
            .B8G8R8X8_TYPELESS,
            .B8G8R8X8_UNORM_SRGB,
            .AYUV,
            .Y410,
            .YUY2,
            => 32,

            .P010,
            .P016,
            .V408,
            => 24,

            .R8G8_TYPELESS,
            .R8G8_UNORM,
            .R8G8_UINT,
            .R8G8_SNORM,
            .R8G8_SINT,
            .R16_TYPELESS,
            .R16_FLOAT,
            .D16_UNORM,
            .R16_UNORM,
            .R16_UINT,
            .R16_SNORM,
            .R16_SINT,
            .B5G6R5_UNORM,
            .B5G5R5A1_UNORM,
            .A8P8,
            .B4G4R4A4_UNORM,
            => 16,

            .P208,
            .V208,
            => 16,

            .@"420_OPAQUE",
            .NV11,
            .NV12,
            => 12,

            .R8_TYPELESS,
            .R8_UNORM,
            .R8_UINT,
            .R8_SNORM,
            .R8_SINT,
            .A8_UNORM,
            .AI44,
            .IA44,
            .P8,
            => 8,

            .BC2_TYPELESS,
            .BC2_UNORM,
            .BC2_UNORM_SRGB,
            .BC3_TYPELESS,
            .BC3_UNORM,
            .BC3_UNORM_SRGB,
            .BC5_TYPELESS,
            .BC5_UNORM,
            .BC5_SNORM,
            .BC6H_TYPELESS,
            .BC6H_UF16,
            .BC6H_SF16,
            .BC7_TYPELESS,
            .BC7_UNORM,
            .BC7_UNORM_SRGB,
            => 8,

            .R1_UNORM => 1,

            .BC1_TYPELESS,
            .BC1_UNORM,
            .BC1_UNORM_SRGB,
            .BC4_TYPELESS,
            .BC4_UNORM,
            .BC4_SNORM,
            => 4,

            .UNKNOWN,
            .SAMPLER_FEEDBACK_MIP_REGION_USED_OPAQUE,
            .SAMPLER_FEEDBACK_MIN_MIP_OPAQUE,
            => unreachable,
        };
    }

    pub fn is_depth_stencil(format: FORMAT) bool {
        return switch (format) {
            .R32G8X24_TYPELESS,
            .D32_FLOAT_S8X24_UINT,
            .R32_FLOAT_X8X24_TYPELESS,
            .X32_TYPELESS_G8X24_UINT,
            .D32_FLOAT,
            .R24G8_TYPELESS,
            .D24_UNORM_S8_UINT,
            .R24_UNORM_X8_TYPELESS,
            .X24_TYPELESS_G8_UINT,
            .D16_UNORM,
            => true,

            else => false,
        };
    }
};

pub const RATIONAL = extern struct {
    Numerator: UINT,
    Denominator: UINT,
};

// The following values are used with SAMPLE_DESC::Quality:
pub const STANDARD_MULTISAMPLE_QUALITY_PATTERN = 0xffffffff;
pub const CENTER_MULTISAMPLE_QUALITY_PATTERN = 0xfffffffe;

pub const SAMPLE_DESC = extern struct {
    Count: UINT = 1,
    Quality: UINT = 0,
};

pub const COLOR_SPACE_TYPE = enum(UINT) {
    RGB_FULL_G22_NONE_P709 = 0,
    RGB_FULL_G10_NONE_P709 = 1,
    RGB_STUDIO_G22_NONE_P709 = 2,
    RGB_STUDIO_G22_NONE_P2020 = 3,
    RESERVED = 4,
    YCBCR_FULL_G22_NONE_P709_X601 = 5,
    YCBCR_STUDIO_G22_LEFT_P601 = 6,
    YCBCR_FULL_G22_LEFT_P601 = 7,
    YCBCR_STUDIO_G22_LEFT_P709 = 8,
    YCBCR_FULL_G22_LEFT_P709 = 9,
    YCBCR_STUDIO_G22_LEFT_P2020 = 10,
    YCBCR_FULL_G22_LEFT_P2020 = 11,
    RGB_FULL_G2084_NONE_P2020 = 12,
    YCBCR_STUDIO_G2084_LEFT_P2020 = 13,
    RGB_STUDIO_G2084_NONE_P2020 = 14,
    YCBCR_STUDIO_G22_TOPLEFT_P2020 = 15,
    YCBCR_STUDIO_G2084_TOPLEFT_P2020 = 16,
    RGB_FULL_G22_NONE_P2020 = 17,
    YCBCR_STUDIO_GHLG_TOPLEFT_P2020 = 18,
    YCBCR_FULL_GHLG_TOPLEFT_P2020 = 19,
    RGB_STUDIO_G24_NONE_P709 = 20,
    RGB_STUDIO_G24_NONE_P2020 = 21,
    YCBCR_STUDIO_G24_LEFT_P709 = 22,
    YCBCR_STUDIO_G24_LEFT_P2020 = 23,
    YCBCR_STUDIO_G24_TOPLEFT_P2020 = 24,
    CUSTOM = 0xFFFFFFFF,
};

pub const CPU_ACCESS = enum(UINT) {
    NONE = 0,
    DYNAMIC = 1,
    READ_WRITE = 2,
    SCRATCH = 3,
    FIELD = 15,
};

pub const RGB = extern struct {
    Red: FLOAT,
    Green: FLOAT,
    Blue: FLOAT,
};

pub const D3DCOLORVALUE = extern struct {
    r: FLOAT,
    g: FLOAT,
    b: FLOAT,
    a: FLOAT,
};

pub const RGBA = D3DCOLORVALUE;

pub const GAMMA_CONTROL = extern struct {
    Scale: RGB,
    Offset: RGB,
    GammaCurve: [1025]RGB,
};

pub const GAMMA_CONTROL_CAPABILITIES = extern struct {
    ScaleAndOffsetSupported: BOOL,
    MaxConvertedValue: FLOAT,
    MinConvertedValue: FLOAT,
    NumGammaControlPoints: UINT,
    ControlPointPositions: [1025]FLOAT,
};

pub const MODE_SCANLINE_ORDER = enum(UINT) {
    UNSPECIFIED = 0,
    PROGRESSIVE = 1,
    UPPER_FIELD_FIRST = 2,
    LOWER_FIELD_FIRST = 3,
};

pub const MODE_SCALING = enum(UINT) {
    UNSPECIFIED = 0,
    CENTERED = 1,
    STRETCHED = 2,
};

pub const MODE_ROTATION = enum(UINT) {
    UNSPECIFIED = 0,
    IDENTITY = 1,
    ROTATE90 = 2,
    ROTATE180 = 3,
    ROTATE270 = 4,
};

pub const MODE_DESC = extern struct {
    Width: UINT,
    Height: UINT,
    RefreshRate: RATIONAL,
    Format: FORMAT,
    ScanlineOrdering: MODE_SCANLINE_ORDER,
    Scaling: MODE_SCALING,
};

pub const USAGE = packed struct(UINT) {
    __unused0: bool = false,
    __unused1: bool = false,
    __unused2: bool = false,
    __unused3: bool = false,
    SHADER_INPUT: bool = false,
    RENDER_TARGET_OUTPUT: bool = false,
    BACK_BUFFER: bool = false,
    SHARED: bool = false,
    READ_ONLY: bool = false,
    DISCARD_ON_PRESENT: bool = false,
    UNORDERED_ACCESS: bool = false,
    __unused: u21 = 0,
};

pub const FRAME_STATISTICS = extern struct {
    PresentCount: UINT,
    PresentRefreshCount: UINT,
    SyncRefreshCount: UINT,
    SyncQPCTime: LARGE_INTEGER,
    SyncGPUTime: LARGE_INTEGER,
};

pub const MAPPED_RECT = extern struct {
    Pitch: INT,
    pBits: *BYTE,
};

pub const ADAPTER_DESC = extern struct {
    Description: [128]WCHAR,
    VendorId: UINT,
    DeviceId: UINT,
    SubSysId: UINT,
    Revision: UINT,
    DedicatedVideoMemory: SIZE_T,
    DedicatedSystemMemory: SIZE_T,
    SharedSystemMemory: SIZE_T,
    AdapterLuid: LUID,
};

pub const OUTPUT_DESC = extern struct {
    DeviceName: [32]WCHAR,
    DesktopCoordinates: RECT,
    AttachedToDesktop: BOOL,
    Rotation: MODE_ROTATION,
    Monitor: HMONITOR,
};

pub const SHARED_RESOURCE = extern struct {
    Handle: HANDLE,
};

pub const RESOURCE_PRIORITY = enum(UINT) {
    MINIMUM = 0x28000000,
    LOW = 0x50000000,
    NORMAL = 0x78000000,
    HIGH = 0xa0000000,
    MAXIMUM = 0xc8000000,
};

pub const RESIDENCY = enum(UINT) {
    FULLY_RESIDENT = 1,
    RESIDENT_IN_SHARED_MEMORY = 2,
    EVICTED_TO_DISK = 3,
};

pub const SURFACE_DESC = extern struct {
    Width: UINT,
    Height: UINT,
    Format: FORMAT,
    SampleDesc: SAMPLE_DESC,
};

pub const SWAP_EFFECT = enum(UINT) {
    DISCARD = 0,
    SEQUENTIAL = 1,
    FLIP_SEQUENTIAL = 3,
    FLIP_DISCARD = 4,
};

pub const SWAP_CHAIN_FLAG = packed struct(UINT) {
    NONPREROTATED: bool = false,
    ALLOW_MODE_SWITCH: bool = false,
    GDI_COMPATIBLE: bool = false,
    RESTRICTED_CONTENT: bool = false,
    RESTRICT_SHARED_RESOURCE_DRIVER: bool = false,
    DISPLAY_ONLY: bool = false,
    FRAME_LATENCY_WAITABLE_OBJECT: bool = false,
    FOREGROUND_LAYER: bool = false,
    FULLSCREEN_VIDEO: bool = false,
    YUV_VIDEO: bool = false,
    HW_PROTECTED: bool = false,
    ALLOW_TEARING: bool = false,
    RESTRICTED_TO_ALL_HOLOGRAPHIC_DISPLAYS: bool = false,
    __unused: u19 = 0,
};

pub const SWAP_CHAIN_DESC = extern struct {
    BufferDesc: MODE_DESC,
    SampleDesc: SAMPLE_DESC,
    BufferUsage: USAGE,
    BufferCount: UINT,
    OutputWindow: HWND,
    Windowed: BOOL,
    SwapEffect: SWAP_EFFECT,
    Flags: SWAP_CHAIN_FLAG,
};

pub const IObject = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetPrivateData(
                self: *T,
                guid: *const GUID,
                data_size: UINT,
                data: *const anyopaque,
            ) HRESULT {
                return @as(*const IObject.VTable, @ptrCast(self.__v))
                    .SetPrivateData(@ptrCast(self), guid, data_size, data);
            }
            pub inline fn SetPrivateDataInterface(self: *T, guid: *const GUID, data: ?*const IUnknown) HRESULT {
                return @as(*const IObject.VTable, @ptrCast(self.__v))
                    .SetPrivateDataInterface(@ptrCast(self), guid, data);
            }
            pub inline fn GetPrivateData(self: *T, guid: *const GUID, data_size: *UINT, data: *anyopaque) HRESULT {
                return @as(*const IObject.VTable, @ptrCast(self.__v))
                    .GetPrivateData(@ptrCast(self), guid, data_size, data);
            }
            pub inline fn GetParent(self: *T, guid: *const GUID, parent: *?*anyopaque) HRESULT {
                return @as(*const IObject.VTable, @ptrCast(self.__v)).GetParent(@ptrCast(self), guid, parent);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetPrivateData: *const fn (*IObject, *const GUID, UINT, *const anyopaque) callconv(WINAPI) HRESULT,
        SetPrivateDataInterface: *const fn (*IObject, *const GUID, ?*const IUnknown) callconv(WINAPI) HRESULT,
        GetPrivateData: *const fn (*IObject, *const GUID, *UINT, *anyopaque) callconv(WINAPI) HRESULT,
        GetParent: *const fn (*IObject, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT,
    };
};

pub const IDeviceSubObject = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDevice = IDeviceSubObject.Methods(@This()).GetDevice;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDevice(self: *T, guid: *const GUID, parent: *?*anyopaque) HRESULT {
                return @as(*const IDeviceSubObject.VTable, @ptrCast(self.__v))
                    .GetDevice(@ptrCast(self), guid, parent);
            }
        };
    }

    pub const VTable = extern struct {
        base: IObject.VTable,
        GetDevice: *const fn (*IDeviceSubObject, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT,
    };
};

pub const IResource = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDevice = IDeviceSubObject.Methods(@This()).GetDevice;

    pub const GetSharedHandle = IResource.Methods(@This()).GetSharedHandle;
    pub const GetUsage = IResource.Methods(@This()).GetUsage;
    pub const SetEvictionPriority = IResource.Methods(@This()).SetEvictionPriority;
    pub const GetEvictionPriority = IResource.Methods(@This()).GetEvictionPriority;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetSharedHandle(self: *T, handle: *HANDLE) HRESULT {
                return @as(*const IResource.VTable, @ptrCast(self.__v))
                    .GetSharedHandle(@ptrCast(self), handle);
            }
            pub inline fn GetUsage(self: *T, usage: *USAGE) HRESULT {
                return @as(*const IResource.VTable, @ptrCast(self.__v)).GetUsage(@ptrCast(self), usage);
            }
            pub inline fn SetEvictionPriority(self: *T, priority: UINT) HRESULT {
                return @as(*const IResource.VTable, @ptrCast(self.__v))
                    .SetEvictionPriority(@ptrCast(self), priority);
            }
            pub inline fn GetEvictionPriority(self: *T, priority: *UINT) HRESULT {
                return @as(*const IResource.VTable, @ptrCast(self.__v))
                    .GetEvictionPriority(@ptrCast(self), priority);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDeviceSubObject.VTable,
        GetSharedHandle: *const fn (*IResource, *HANDLE) callconv(WINAPI) HRESULT,
        GetUsage: *const fn (*IResource, *USAGE) callconv(WINAPI) HRESULT,
        SetEvictionPriority: *const fn (*IResource, UINT) callconv(WINAPI) HRESULT,
        GetEvictionPriority: *const fn (*IResource, *UINT) callconv(WINAPI) HRESULT,
    };
};

pub const IKeyedMutex = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDevice = IDeviceSubObject.Methods(@This()).GetDevice;

    pub const AcquireSync = IKeyedMutex.Methods(@This()).AcquireSync;
    pub const ReleaseSync = IKeyedMutex.Methods(@This()).ReleaseSync;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AcquireSync(self: *T, key: UINT64, milliseconds: DWORD) HRESULT {
                return @as(*const IKeyedMutex.VTable, @ptrCast(self.__v))
                    .AcquireSync(@ptrCast(self), key, milliseconds);
            }
            pub inline fn ReleaseSync(self: *T, key: UINT64) HRESULT {
                return @as(*const IKeyedMutex.VTable, @ptrCast(self.__v)).ReleaseSync(@ptrCast(self), key);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDeviceSubObject.VTable,
        AcquireSync: *const fn (*IKeyedMutex, UINT64, DWORD) callconv(WINAPI) HRESULT,
        ReleaseSync: *const fn (*IKeyedMutex, UINT64) callconv(WINAPI) HRESULT,
    };
};

pub const MAP_FLAG = packed struct(UINT) {
    READ: bool = false,
    WRITE: bool = false,
    DISCARD: bool = false,
    __unused: u29 = 0,
};

pub const ISurface = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDevice = IDeviceSubObject.Methods(@This()).GetDevice;

    pub const GetDesc = ISurface.Methods(@This()).GetDesc;
    pub const Map = ISurface.Methods(@This()).Map;
    pub const Unmap = ISurface.Methods(@This()).Unmap;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc(self: *T, desc: *SURFACE_DESC) HRESULT {
                return @as(*const ISurface.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), desc);
            }
            pub inline fn Map(self: *T, locked_rect: *MAPPED_RECT, flags: MAP_FLAG) HRESULT {
                return @as(*const ISurface.VTable, @ptrCast(self.__v)).Map(@ptrCast(self), locked_rect, flags);
            }
            pub inline fn Unmap(self: *T) HRESULT {
                return @as(*const ISurface.VTable, @ptrCast(self.__v)).Unmap(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IDeviceSubObject.VTable,
        GetDesc: *const fn (*ISurface, *SURFACE_DESC) callconv(WINAPI) HRESULT,
        Map: *const fn (*ISurface, *MAPPED_RECT, MAP_FLAG) callconv(WINAPI) HRESULT,
        Unmap: *const fn (*ISurface) callconv(WINAPI) HRESULT,
    };
};

pub const IAdapter = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumOutputs = IAdapter.Methods(@This()).EnumOutputs;
    pub const GetDesc = IAdapter.Methods(@This()).GetDesc;
    pub const CheckInterfaceSupport = IAdapter.Methods(@This()).CheckInterfaceSupport;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn EnumOutputs(self: *T, index: UINT, output: *?*IOutput) HRESULT {
                return @as(*const IAdapter.VTable, @ptrCast(self.__v))
                    .EnumOutputs(@ptrCast(self), index, output);
            }
            pub inline fn GetDesc(self: *T, desc: *ADAPTER_DESC) HRESULT {
                return @as(*const IAdapter.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), desc);
            }
            pub inline fn CheckInterfaceSupport(self: *T, guid: *const GUID, umd_ver: *LARGE_INTEGER) HRESULT {
                return @as(*const IAdapter.VTable, @ptrCast(self.__v))
                    .CheckInterfaceSupport(@ptrCast(self), guid, umd_ver);
            }
        };
    }

    pub const VTable = extern struct {
        base: IObject.VTable,
        EnumOutputs: *const fn (*IAdapter, UINT, *?*IOutput) callconv(WINAPI) HRESULT,
        GetDesc: *const fn (*IAdapter, *ADAPTER_DESC) callconv(WINAPI) HRESULT,
        CheckInterfaceSupport: *const fn (*IAdapter, *const GUID, *LARGE_INTEGER) callconv(WINAPI) HRESULT,
    };
};

pub const ENUM_MODES = packed struct(UINT) {
    INTERLACED: bool = false,
    SCALING: bool = false,
    STEREO: bool = false,
    DISABLED_STEREO: bool = false,
    __unused: u28 = 0,
};

pub const IOutput = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDesc = IOutput.Methods(@This()).GetDesc;
    pub const GetDisplayModeList = IOutput.Methods(@This()).GetDisplayModeList;
    pub const FindClosestMatchingMode = IOutput.Methods(@This()).FindClosestMatchingMode;
    pub const WaitForVBlank = IOutput.Methods(@This()).WaitForVBlank;
    pub const TakeOwnership = IOutput.Methods(@This()).TakeOwnership;
    pub const ReleaseOwnership = IOutput.Methods(@This()).ReleaseOwnership;
    pub const GetGammaControlCapabilities = IOutput.Methods(@This()).GetGammaControlCapabilities;
    pub const SetGammaControl = IOutput.Methods(@This()).SetGammaControl;
    pub const GetGammaControl = IOutput.Methods(@This()).GetGammaControl;
    pub const SetDisplaySurface = IOutput.Methods(@This()).SetDisplaySurface;
    pub const GetDisplaySurfaceData = IOutput.Methods(@This()).GetDisplaySurfaceData;
    pub const GetFrameStatistics = IOutput.Methods(@This()).GetFrameStatistics;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc(self: *T, desc: *OUTPUT_DESC) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), desc);
            }
            pub inline fn GetDisplayModeList(
                self: *T,
                enum_format: FORMAT,
                flags: ENUM_MODES,
                num_nodes: *UINT,
                desc: ?*MODE_DESC,
            ) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v))
                    .GetDisplayModeList(@ptrCast(self), enum_format, flags, num_nodes, desc);
            }
            pub inline fn FindClosestMatchingMode(
                self: *T,
                mode_to_match: *const MODE_DESC,
                closest_match: *MODE_DESC,
                concerned_device: ?*IUnknown,
            ) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v)).FindClosestMatchingMode(
                    @ptrCast(self),
                    mode_to_match,
                    closest_match,
                    concerned_device,
                );
            }
            pub inline fn WaitForVBlank(self: *T) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v)).WaitForVBlank(@ptrCast(self));
            }
            pub inline fn TakeOwnership(self: *T, device: *IUnknown, exclusive: BOOL) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v))
                    .TakeOwnership(@ptrCast(self), device, exclusive);
            }
            pub inline fn ReleaseOwnership(self: *T) void {
                @as(*const IOutput.VTable, @ptrCast(self.__v)).ReleaseOwnership(@ptrCast(self));
            }
            pub inline fn GetGammaControlCapabilities(self: *T, gamma_caps: *GAMMA_CONTROL_CAPABILITIES) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v))
                    .GetGammaControlCapabilities(@ptrCast(self), gamma_caps);
            }
            pub inline fn SetGammaControl(self: *T, array: *const GAMMA_CONTROL) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v)).SetGammaControl(@ptrCast(self), array);
            }
            pub inline fn GetGammaControl(self: *T, array: *GAMMA_CONTROL) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v)).GetGammaControl(@ptrCast(self), array);
            }
            pub inline fn SetDisplaySurface(self: *T, scanout_surface: *ISurface) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v))
                    .SetDisplaySurface(@ptrCast(self), scanout_surface);
            }
            pub inline fn GetDisplaySurfaceData(self: *T, destination: *ISurface) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v))
                    .GetDisplaySurfaceData(@ptrCast(self), destination);
            }
            pub inline fn GetFrameStatistics(self: *T, stats: *FRAME_STATISTICS) HRESULT {
                return @as(*const IOutput.VTable, @ptrCast(self.__v)).GetFrameStatistics(@ptrCast(self), stats);
            }
        };
    }

    pub const VTable = extern struct {
        base: IObject.VTable,
        GetDesc: *const fn (self: *IOutput, desc: *OUTPUT_DESC) callconv(WINAPI) HRESULT,
        GetDisplayModeList: *const fn (*IOutput, FORMAT, ENUM_MODES, *UINT, ?*MODE_DESC) callconv(WINAPI) HRESULT,
        FindClosestMatchingMode: *const fn (
            *IOutput,
            *const MODE_DESC,
            *MODE_DESC,
            ?*IUnknown,
        ) callconv(WINAPI) HRESULT,
        WaitForVBlank: *const fn (*IOutput) callconv(WINAPI) HRESULT,
        TakeOwnership: *const fn (*IOutput, *IUnknown, BOOL) callconv(WINAPI) HRESULT,
        ReleaseOwnership: *const fn (*IOutput) callconv(WINAPI) void,
        GetGammaControlCapabilities: *const fn (*IOutput, *GAMMA_CONTROL_CAPABILITIES) callconv(WINAPI) HRESULT,
        SetGammaControl: *const fn (*IOutput, *const GAMMA_CONTROL) callconv(WINAPI) HRESULT,
        GetGammaControl: *const fn (*IOutput, *GAMMA_CONTROL) callconv(WINAPI) HRESULT,
        SetDisplaySurface: *const fn (*IOutput, *ISurface) callconv(WINAPI) HRESULT,
        GetDisplaySurfaceData: *const fn (*IOutput, *ISurface) callconv(WINAPI) HRESULT,
        GetFrameStatistics: *const fn (*IOutput, *FRAME_STATISTICS) callconv(WINAPI) HRESULT,
    };
};

pub const MAX_SWAP_CHAIN_BUFFERS = 16;

pub const PRESENT_FLAG = packed struct(UINT) {
    TEST: bool = false,
    DO_NOT_SEQUENCE: bool = false,
    RESTART: bool = false,
    DO_NOT_WAIT: bool = false,
    STEREO_PREFER_RIGHT: bool = false,
    STEREO_TEMPORARY_MONO: bool = false,
    RESTRICT_TO_OUTPUT: bool = false,
    __unused7: bool = false,
    USE_DURATION: bool = false,
    ALLOW_TEARING: bool = false,
    __unused: u22 = 0,
};

pub const ISwapChain = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDevice = IDeviceSubObject.Methods(@This()).GetDevice;

    pub const Present = ISwapChain.Methods(@This()).Present;
    pub const GetBuffer = ISwapChain.Methods(@This()).GetBuffer;
    pub const SetFullscreenState = ISwapChain.Methods(@This()).SetFullscreenState;
    pub const GetFullscreenState = ISwapChain.Methods(@This()).GetFullscreenState;
    pub const GetDesc = ISwapChain.Methods(@This()).GetDesc;
    pub const ResizeBuffers = ISwapChain.Methods(@This()).ResizeBuffers;
    pub const ResizeTarget = ISwapChain.Methods(@This()).ResizeTarget;
    pub const GetContainingOutput = ISwapChain.Methods(@This()).GetContainingOutput;
    pub const GetFrameStatistics = ISwapChain.Methods(@This()).GetFrameStatistics;
    pub const GetLastPresentCount = ISwapChain.Methods(@This()).GetLastPresentCount;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Present(self: *T, sync_interval: UINT, flags: PRESENT_FLAG) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v))
                    .Present(@ptrCast(self), sync_interval, flags);
            }
            pub inline fn GetBuffer(self: *T, index: u32, guid: *const GUID, surface: *?*anyopaque) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v))
                    .GetBuffer(@ptrCast(self), index, guid, surface);
            }
            pub inline fn SetFullscreenState(self: *T, target: ?*IOutput) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v)).SetFullscreenState(@ptrCast(self), target);
            }
            pub inline fn GetFullscreenState(self: *T, fullscreen: ?*BOOL, target: ?*?*IOutput) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v))
                    .GetFullscreenState(@ptrCast(self), fullscreen, target);
            }
            pub inline fn GetDesc(self: *T, desc: *SWAP_CHAIN_DESC) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), desc);
            }
            pub inline fn ResizeBuffers(
                self: *T,
                count: UINT,
                width: UINT,
                height: UINT,
                format: FORMAT,
                flags: SWAP_CHAIN_FLAG,
            ) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v))
                    .ResizeBuffers(@ptrCast(self), count, width, height, format, flags);
            }
            pub inline fn ResizeTarget(self: *T, params: *const MODE_DESC) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v)).ResizeTarget(@ptrCast(self), params);
            }
            pub inline fn GetContainingOutput(self: *T, output: *?*IOutput) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v)).GetContainingOutput(@ptrCast(self), output);
            }
            pub inline fn GetFrameStatistics(self: *T, stats: *FRAME_STATISTICS) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v)).GetFrameStatistics(@ptrCast(self), stats);
            }
            pub inline fn GetLastPresentCount(self: *T, count: *UINT) HRESULT {
                return @as(*const ISwapChain.VTable, @ptrCast(self.__v)).GetLastPresentCount(@ptrCast(self), count);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDeviceSubObject.VTable,
        Present: *const fn (*ISwapChain, UINT, PRESENT_FLAG) callconv(WINAPI) HRESULT,
        GetBuffer: *const fn (*ISwapChain, u32, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT,
        SetFullscreenState: *const fn (*ISwapChain, ?*IOutput) callconv(WINAPI) HRESULT,
        GetFullscreenState: *const fn (*ISwapChain, ?*BOOL, ?*?*IOutput) callconv(WINAPI) HRESULT,
        GetDesc: *const fn (*ISwapChain, *SWAP_CHAIN_DESC) callconv(WINAPI) HRESULT,
        ResizeBuffers: *const fn (*ISwapChain, UINT, UINT, UINT, FORMAT, SWAP_CHAIN_FLAG) callconv(WINAPI) HRESULT,
        ResizeTarget: *const fn (*ISwapChain, *const MODE_DESC) callconv(WINAPI) HRESULT,
        GetContainingOutput: *const fn (*ISwapChain, *?*IOutput) callconv(WINAPI) HRESULT,
        GetFrameStatistics: *const fn (*ISwapChain, *FRAME_STATISTICS) callconv(WINAPI) HRESULT,
        GetLastPresentCount: *const fn (*ISwapChain, *UINT) callconv(WINAPI) HRESULT,
    };
};

pub const MWA_FLAGS = packed struct(UINT) {
    NO_WINDOW_CHANGES: bool = false,
    NO_ALT_ENTER: bool = false,
    NO_PRINT_SCREEN: bool = false,
    __unused: u29 = 0,
};

pub const IFactory = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumAdapters = IFactory.Methods(@This()).EnumAdapters;
    pub const MakeWindowAssociation = IFactory.Methods(@This()).MakeWindowAssociation;
    pub const GetWindowAssociation = IFactory.Methods(@This()).GetWindowAssociation;
    pub const CreateSwapChain = IFactory.Methods(@This()).CreateSwapChain;
    pub const CreateSoftwareAdapter = IFactory.Methods(@This()).CreateSoftwareAdapter;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn EnumAdapters(self: *T, index: UINT, adapter: *?*IAdapter) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v)).EnumAdapters(@ptrCast(self), index, adapter);
            }
            pub inline fn MakeWindowAssociation(self: *T, window: HWND, flags: MWA_FLAGS) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v))
                    .MakeWindowAssociation(@ptrCast(self), window, flags);
            }
            pub inline fn GetWindowAssociation(self: *T, window: *HWND) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v)).GetWindowAssociation(@ptrCast(self), window);
            }
            pub inline fn CreateSwapChain(
                self: *T,
                device: *IUnknown,
                desc: *SWAP_CHAIN_DESC,
                swap_chain: ?*?*ISwapChain,
            ) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v)).CreateSwapChain(
                    @ptrCast(self),
                    device,
                    desc,
                    swap_chain,
                );
            }
            pub inline fn CreateSoftwareAdapter(self: *T, adapter: *?*IAdapter) HRESULT {
                return @as(*const IFactory.VTable, @ptrCast(self.__v)).CreateSoftwareAdapter(
                    @ptrCast(self),
                    adapter,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IObject.VTable,
        EnumAdapters: *const fn (*IFactory, UINT, *?*IAdapter) callconv(WINAPI) HRESULT,
        MakeWindowAssociation: *const fn (*IFactory, HWND, MWA_FLAGS) callconv(WINAPI) HRESULT,
        GetWindowAssociation: *const fn (*IFactory, *HWND) callconv(WINAPI) HRESULT,
        CreateSwapChain: *const fn (*IFactory, *IUnknown, *SWAP_CHAIN_DESC, ?*?*ISwapChain) callconv(WINAPI) HRESULT,
        CreateSoftwareAdapter: *const fn (*IFactory, *?*IAdapter) callconv(WINAPI) HRESULT,
    };
};

pub const IDevice = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{54ec77fa-1377-44e6-8c32-88fd5f44c84c}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetAdapter = IDevice.Methods(@This()).GetAdapter;
    pub const CreateSurface = IDevice.Methods(@This()).CreateSurface;
    pub const QueryResourceResidency = IDevice.Methods(@This()).QueryResourceResidency;
    pub const SetGPUThreadPriority = IDevice.Methods(@This()).SetGPUThreadPriority;
    pub const GetGPUThreadPriority = IDevice.Methods(@This()).GetGPUThreadPriority;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetAdapter(self: *T, adapter: *?*IAdapter) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).GetAdapter(@ptrCast(self), adapter);
            }
            pub inline fn CreateSurface(
                self: *T,
                desc: *const SURFACE_DESC,
                num_surfaces: UINT,
                usage: USAGE,
                shared_resource: ?*const SHARED_RESOURCE,
                surface: *?*ISurface,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).CreateSurface(
                    @ptrCast(self),
                    desc,
                    num_surfaces,
                    usage,
                    shared_resource,
                    surface,
                );
            }
            pub inline fn QueryResourceResidency(
                self: *T,
                resources: *const *IUnknown,
                status: [*]RESIDENCY,
                num_resources: UINT,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .QueryResourceResidency(@ptrCast(self), resources, status, num_resources);
            }
            pub inline fn SetGPUThreadPriority(self: *T, priority: INT) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).SetGPUThreadPriority(
                    @ptrCast(self),
                    priority,
                );
            }
            pub inline fn GetGPUThreadPriority(self: *T, priority: *INT) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).GetGPUThreadPriority(
                    @ptrCast(self),
                    priority,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IObject.VTable,
        GetAdapter: *const fn (self: *IDevice, adapter: *?*IAdapter) callconv(WINAPI) HRESULT,
        CreateSurface: *const fn (
            *IDevice,
            *const SURFACE_DESC,
            UINT,
            USAGE,
            ?*const SHARED_RESOURCE,
            *?*ISurface,
        ) callconv(WINAPI) HRESULT,
        QueryResourceResidency: *const fn (
            *IDevice,
            *const *IUnknown,
            [*]RESIDENCY,
            UINT,
        ) callconv(WINAPI) HRESULT,
        SetGPUThreadPriority: *const fn (self: *IDevice, priority: INT) callconv(WINAPI) HRESULT,
        GetGPUThreadPriority: *const fn (self: *IDevice, priority: *INT) callconv(WINAPI) HRESULT,
    };
};

pub const ADAPTER_FLAGS = packed struct(UINT) {
    REMOTE: bool = false,
    SOFTWARE: bool = false,
    __unused: u30 = 0,
};

pub const ADAPTER_DESC1 = extern struct {
    Description: [128]WCHAR,
    VendorId: UINT,
    DeviceId: UINT,
    SubSysId: UINT,
    Revision: UINT,
    DedicatedVideoMemory: SIZE_T,
    DedicatedSystemMemory: SIZE_T,
    SharedSystemMemory: SIZE_T,
    AdapterLuid: LUID,
    Flags: ADAPTER_FLAGS,
};

pub const GRAPHICS_PREEMPTION_GRANULARITY = enum(UINT) {
    DMA_BUFFER_BOUNDARY = 0,
    PRIMITIVE_BOUNDARY = 1,
    TRIANGLE_BOUNDARY = 2,
    PIXEL_BOUNDARY = 3,
    INSTRUCTION_BOUNDARY = 4,
};

pub const COMPUTE_PREEMPTION_GRANULARITY = enum(UINT) {
    DMA_BUFFER_BOUNDARY = 0,
    PRIMITIVE_BOUNDARY = 1,
    TRIANGLE_BOUNDARY = 2,
    PIXEL_BOUNDARY = 3,
    INSTRUCTION_BOUNDARY = 4,
};

pub const ADAPTER_DESC2 = extern struct {
    Description: [128]WCHAR,
    VendorId: UINT,
    DeviceId: UINT,
    SubSysId: UINT,
    Revision: UINT,
    DedicatedVideoMemory: SIZE_T,
    DedicatedSystemMemory: SIZE_T,
    SharedSystemMemory: SIZE_T,
    AdapterLuid: LUID,
    Flags: ADAPTER_FLAGS,
    GraphicsPreemptionGranularity: GRAPHICS_PREEMPTION_GRANULARITY,
    ComputePreemptionGranularity: COMPUTE_PREEMPTION_GRANULARITY,
};

pub const IFactory1 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumAdapters = IFactory.Methods(@This()).EnumAdapters;
    pub const MakeWindowAssociation = IFactory.Methods(@This()).MakeWindowAssociation;
    pub const GetWindowAssociation = IFactory.Methods(@This()).GetWindowAssociation;
    pub const CreateSwapChain = IFactory.Methods(@This()).CreateSwapChain;
    pub const CreateSoftwareAdapter = IFactory.Methods(@This()).CreateSoftwareAdapter;

    pub const EnumAdapters1 = IFactory1.Methods(@This()).EnumAdapters1;
    pub const IsCurrent = IFactory1.Methods(@This()).IsCurrent;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn EnumAdapters1(self: *T, index: UINT, adapter: *?*IAdapter1) HRESULT {
                return @as(*const IFactory1.VTable, @ptrCast(self.__v))
                    .EnumAdapters1(@ptrCast(self), index, adapter);
            }
            pub inline fn IsCurrent(self: *T) BOOL {
                return @as(*const IFactory1.VTable, @ptrCast(self.__v)).IsCurrent(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IFactory.VTable,
        EnumAdapters1: *const fn (*IFactory1, UINT, *?*IAdapter1) callconv(WINAPI) HRESULT,
        IsCurrent: *const fn (*IFactory1) callconv(WINAPI) BOOL,
    };
};

pub const IFactory2 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumAdapters = IFactory.Methods(@This()).EnumAdapters;
    pub const MakeWindowAssociation = IFactory.Methods(@This()).MakeWindowAssociation;
    pub const GetWindowAssociation = IFactory.Methods(@This()).GetWindowAssociation;
    pub const CreateSwapChain = IFactory.Methods(@This()).CreateSwapChain;
    pub const CreateSoftwareAdapter = IFactory.Methods(@This()).CreateSoftwareAdapter;

    pub const EnumAdapters1 = IFactory1.Methods(@This()).EnumAdapters1;
    pub const IsCurrent = IFactory1.Methods(@This()).IsCurrent;

    pub const CreateSwapChainForHwnd = IFactory2.Methods(@This()).CreateSwapChainForHwnd;
    // TODO: Add IFactory2 methods

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateSwapChainForHwnd(
                self: *T,
                device: *IUnknown,
                hwnd: HWND,
                desc: *const SWAP_CHAIN_DESC1,
                fullscreen_desc: ?*const SWAP_CHAIN_FULLSCREEN_DESC,
                restrict_to_output: ?*IOutput,
                swap_chain: ?*?*ISwapChain1,
            ) HRESULT {
                return @as(*const IFactory2.VTable, @ptrCast(self.__v)).CreateSwapChainForHwnd(
                    @ptrCast(self),
                    device,
                    hwnd,
                    desc,
                    fullscreen_desc,
                    restrict_to_output,
                    swap_chain,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IFactory1.VTable,
        IsWindowedStereoEnabled: *anyopaque,
        CreateSwapChainForHwnd: *const fn (
            *IFactory2,
            *IUnknown,
            HWND,
            *const SWAP_CHAIN_DESC1,
            ?*const SWAP_CHAIN_FULLSCREEN_DESC,
            ?*IOutput,
            ?*?*ISwapChain1,
        ) callconv(WINAPI) HRESULT,
        CreateSwapChainForCoreWindow: *anyopaque,
        GetSharedResourceAdapterLuid: *anyopaque,
        RegisterStereoStatusWindow: *anyopaque,
        RegisterStereoStatusEvent: *anyopaque,
        UnregisterStereoStatus: *anyopaque,
        RegisterOcclusionStatusWindow: *anyopaque,
        RegisterOcclusionStatusEvent: *anyopaque,
        UnregisterOcclusionStatus: *anyopaque,
        CreateSwapChainForComposition: *anyopaque,
    };
};

pub const IFactory3 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumAdapters = IFactory.Methods(@This()).EnumAdapters;
    pub const MakeWindowAssociation = IFactory.Methods(@This()).MakeWindowAssociation;
    pub const GetWindowAssociation = IFactory.Methods(@This()).GetWindowAssociation;
    pub const CreateSwapChain = IFactory.Methods(@This()).CreateSwapChain;
    pub const CreateSoftwareAdapter = IFactory.Methods(@This()).CreateSoftwareAdapter;

    pub const EnumAdapters1 = IFactory1.Methods(@This()).EnumAdapters1;
    pub const IsCurrent = IFactory1.Methods(@This()).IsCurrent;

    pub const CreateSwapChainForHwnd = IFactory2.Methods(@This()).CreateSwapChainForHwnd;
    // TODO: Add IFactory2 methods

    // TODO: Add IFactory3 methods

    pub const VTable = extern struct {
        base: IFactory2.VTable,
        GetCreationFlags: *anyopaque,
    };
};

pub const IFactory4 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumAdapters = IFactory.Methods(@This()).EnumAdapters;
    pub const MakeWindowAssociation = IFactory.Methods(@This()).MakeWindowAssociation;
    pub const GetWindowAssociation = IFactory.Methods(@This()).GetWindowAssociation;
    pub const CreateSwapChain = IFactory.Methods(@This()).CreateSwapChain;
    pub const CreateSoftwareAdapter = IFactory.Methods(@This()).CreateSoftwareAdapter;

    pub const EnumAdapters1 = IFactory1.Methods(@This()).EnumAdapters1;
    pub const IsCurrent = IFactory1.Methods(@This()).IsCurrent;

    pub const CreateSwapChainForHwnd = IFactory2.Methods(@This()).CreateSwapChainForHwnd;
    // TODO: Add IFactory2 methods

    // TODO: Add IFactory3 methods

    // TODO: Add IFactory4 methods

    pub const VTable = extern struct {
        base: IFactory3.VTable,
        EnumAdapterByLuid: *anyopaque,
        EnumWarpAdapter: *anyopaque,
    };
};

pub const FEATURE = enum(UINT) {
    PRESENT_ALLOW_TEARING = 0,
};

pub const IFactory5 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{7632e1f5-ee65-4dca-87fd-84cd75f8838d}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumAdapters = IFactory.Methods(@This()).EnumAdapters;
    pub const MakeWindowAssociation = IFactory.Methods(@This()).MakeWindowAssociation;
    pub const GetWindowAssociation = IFactory.Methods(@This()).GetWindowAssociation;
    pub const CreateSwapChain = IFactory.Methods(@This()).CreateSwapChain;
    pub const CreateSoftwareAdapter = IFactory.Methods(@This()).CreateSoftwareAdapter;

    pub const EnumAdapters1 = IFactory1.Methods(@This()).EnumAdapters1;
    pub const IsCurrent = IFactory1.Methods(@This()).IsCurrent;

    pub const CreateSwapChainForHwnd = IFactory2.Methods(@This()).CreateSwapChainForHwnd;
    // TODO: Add IFactory2 methods

    // TODO: Add IFactory3 methods

    // TODO: Add IFactory4 methods

    pub const CheckFeatureSupport = IFactory5.Methods(@This()).CheckFeatureSupport;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CheckFeatureSupport(
                self: *T,
                feature: FEATURE,
                support_data: *anyopaque,
                support_data_size: UINT,
            ) HRESULT {
                return @as(*const IFactory5.VTable, @ptrCast(self.__v)).CheckFeatureSupport(
                    @ptrCast(self),
                    feature,
                    support_data,
                    support_data_size,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IFactory4.VTable,
        CheckFeatureSupport: *const fn (*IFactory5, FEATURE, *anyopaque, UINT) callconv(WINAPI) HRESULT,
    };
};

pub const GPU_PREFERENCE = enum(UINT) {
    UNSPECIFIED,
    MINIMUM,
    HIGH_PERFORMANCE,
};

pub const IFactory6 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{c1b6694f-ff09-44a9-b03c-77900a0a1d17}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumAdapters = IFactory.Methods(@This()).EnumAdapters;
    pub const MakeWindowAssociation = IFactory.Methods(@This()).MakeWindowAssociation;
    pub const GetWindowAssociation = IFactory.Methods(@This()).GetWindowAssociation;
    pub const CreateSwapChain = IFactory.Methods(@This()).CreateSwapChain;
    pub const CreateSoftwareAdapter = IFactory.Methods(@This()).CreateSoftwareAdapter;

    pub const EnumAdapters1 = IFactory1.Methods(@This()).EnumAdapters1;
    pub const IsCurrent = IFactory1.Methods(@This()).IsCurrent;

    pub const CreateSwapChainForHwnd = IFactory2.Methods(@This()).CreateSwapChainForHwnd;
    // TODO: Add IFactory2 methods

    // TODO: Add IFactory3 methods

    // TODO: Add IFactory4 methods

    pub const CheckFeatureSupport = IFactory5.Methods(@This()).CheckFeatureSupport;

    pub const EnumAdapterByGpuPreference = IFactory6.Methods(@This()).EnumAdapterByGpuPreference;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn EnumAdapterByGpuPreference(
                self: *T,
                adapter_index: UINT,
                gpu_preference: GPU_PREFERENCE,
                riid: *const GUID,
                adapter: *?*IAdapter3,
            ) HRESULT {
                return @as(*const IFactory6.VTable, @ptrCast(self.__v)).EnumAdapterByGpuPreference(
                    @ptrCast(self),
                    adapter_index,
                    gpu_preference,
                    riid,
                    adapter,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IFactory5.VTable,
        EnumAdapterByGpuPreference: *const fn (
            *IFactory6,
            UINT,
            GPU_PREFERENCE,
            *const GUID,
            *?*IAdapter3,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const IAdapter1 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{29038f61-3839-4626-91fd-086879011a05}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumOutputs = IAdapter.Methods(@This()).EnumOutputs;
    pub const GetDesc = IAdapter.Methods(@This()).GetDesc;
    pub const CheckInterfaceSupport = IAdapter.Methods(@This()).CheckInterfaceSupport;

    pub const GetDesc1 = IAdapter1.Methods(@This()).GetDesc1;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc1(self: *T, desc: *ADAPTER_DESC1) HRESULT {
                return @as(*const IAdapter1.VTable, @ptrCast(self.__v)).GetDesc1(@ptrCast(self), desc);
            }
        };
    }

    pub const VTable = extern struct {
        base: IAdapter.VTable,
        GetDesc1: *const fn (*IAdapter1, *ADAPTER_DESC1) callconv(WINAPI) HRESULT,
    };
};

pub const IAdapter2 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{0AA1AE0A-FA0E-4B84-8644-E05FF8E5ACB5}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumOutputs = IAdapter.Methods(@This()).EnumOutputs;
    pub const GetDesc = IAdapter.Methods(@This()).GetDesc;
    pub const CheckInterfaceSupport = IAdapter.Methods(@This()).CheckInterfaceSupport;

    pub const GetDesc1 = IAdapter1.Methods(@This()).GetDesc1;

    pub const GetDesc2 = IAdapter2.Methods(@This()).GetDesc2;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc2(self: *T, desc: *ADAPTER_DESC2) HRESULT {
                return @as(*const IAdapter2.VTable, @ptrCast(self.__v)).GetDesc2(@ptrCast(self), desc);
            }
        };
    }

    pub const VTable = extern struct {
        base: IAdapter1.VTable,
        GetDesc2: *const fn (*IAdapter2, *ADAPTER_DESC2) callconv(WINAPI) HRESULT,
    };
};

pub const MEMORY_SEGMENT_GROUP = enum(UINT) {
    LOCAL = 0,
    NON_LOCAL = 1,
};

pub const QUERY_VIDEO_MEMORY_INFO = extern struct {
    Budget: UINT64,
    CurrentUsage: UINT64,
    AvailableForReservation: UINT64,
    CurrentReservation: UINT64,
};

pub const IAdapter3 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{645967A4-1392-4310-A798-8053CE3E93FD}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const EnumOutputs = IAdapter.Methods(@This()).EnumOutputs;
    pub const GetDesc = IAdapter.Methods(@This()).GetDesc;
    pub const CheckInterfaceSupport = IAdapter.Methods(@This()).CheckInterfaceSupport;

    pub const GetDesc1 = IAdapter1.Methods(@This()).GetDesc1;

    pub const GetDesc2 = IAdapter2.Methods(@This()).GetDesc2;

    pub const RegisterHardwareContentProtectionTeardownStatusEvent = IAdapter3.Methods(@This()).RegisterHardwareContentProtectionTeardownStatusEvent;
    pub const UnregisterHardwareContentProtectionTeardownStatus = IAdapter3.Methods(@This()).UnregisterHardwareContentProtectionTeardownStatus;
    pub const QueryVideoMemoryInfo = IAdapter3.Methods(@This()).QueryVideoMemoryInfo;
    pub const SetVideoMemoryReservation = IAdapter3.Methods(@This()).SetVideoMemoryReservation;
    pub const RegisterVideoMemoryBudgetChangeNotificationEvent = IAdapter3.Methods(@This()).RegisterVideoMemoryBudgetChangeNotificationEvent;
    pub const UnregisterVideoMemoryBudgetChangeNotification = IAdapter3.Methods(@This()).UnregisterVideoMemoryBudgetChangeNotification;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn RegisterHardwareContentProtectionTeardownStatusEvent(
                self: *T,
                event: HANDLE,
                cookie: *DWORD,
            ) HRESULT {
                return @as(*const IAdapter3.VTable, @ptrCast(self.__v))
                    .RegisterHardwareContentProtectionTeardownStatusEvent(@ptrCast(self), event, cookie);
            }
            pub inline fn UnregisterHardwareContentProtectionTeardownStatus(self: *T, cookie: DWORD) void {
                return @as(*const IAdapter3.VTable, @ptrCast(self.__v))
                    .UnregisterHardwareContentProtectionTeardownStatus(@ptrCast(self), cookie);
            }
            pub inline fn QueryVideoMemoryInfo(
                self: *T,
                node_index: UINT,
                memory_segment_group: MEMORY_SEGMENT_GROUP,
                video_memory_info: *QUERY_VIDEO_MEMORY_INFO,
            ) HRESULT {
                return @as(*const IAdapter3.VTable, @ptrCast(self.__v))
                    .QueryVideoMemoryInfo(@ptrCast(self), node_index, memory_segment_group, video_memory_info);
            }
            pub inline fn SetVideoMemoryReservation(
                self: *T,
                node_index: UINT,
                memory_segment_group: MEMORY_SEGMENT_GROUP,
                reservation: UINT64,
            ) HRESULT {
                return @as(*const IAdapter3.VTable, @ptrCast(self.__v))
                    .SetVideoMemoryReservation(@ptrCast(self), node_index, memory_segment_group, reservation);
            }
            pub inline fn RegisterVideoMemoryBudgetChangeNotificationEvent(
                self: *T,
                event: HANDLE,
                cookie: *DWORD,
            ) HRESULT {
                return @as(*const IAdapter3.VTable, @ptrCast(self.__v))
                    .RegisterVideoMemoryBudgetChangeNotificationEvent(@ptrCast(self), event, cookie);
            }
            pub inline fn UnregisterVideoMemoryBudgetChangeNotification(self: *T, cookie: DWORD) void {
                return @as(*const IAdapter3.VTable, @ptrCast(self.__v))
                    .UnregisterVideoMemoryBudgetChangeNotification(@ptrCast(self), cookie);
            }
        };
    }

    pub const VTable = extern struct {
        base: IAdapter2.VTable,
        RegisterHardwareContentProtectionTeardownStatusEvent: *const fn (
            *IAdapter3,
            HANDLE,
            *DWORD,
        ) callconv(WINAPI) HRESULT,
        UnregisterHardwareContentProtectionTeardownStatus: *const fn (*IAdapter3, DWORD) callconv(WINAPI) void,
        QueryVideoMemoryInfo: *const fn (
            *IAdapter3,
            UINT,
            MEMORY_SEGMENT_GROUP,
            *QUERY_VIDEO_MEMORY_INFO,
        ) callconv(WINAPI) HRESULT,
        SetVideoMemoryReservation: *const fn (
            *IAdapter3,
            UINT,
            MEMORY_SEGMENT_GROUP,
            UINT64,
        ) callconv(WINAPI) HRESULT,
        RegisterVideoMemoryBudgetChangeNotificationEvent: *const fn (
            *IAdapter3,
            HANDLE,
            *DWORD,
        ) callconv(WINAPI) HRESULT,
        UnregisterVideoMemoryBudgetChangeNotification: *const fn (*IAdapter3, DWORD) callconv(WINAPI) void,
    };
};

pub const IDevice1 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetAdapter = IDevice.Methods(@This()).GetAdapter;
    pub const CreateSurface = IDevice.Methods(@This()).CreateSurface;
    pub const QueryResourceResidency = IDevice.Methods(@This()).QueryResourceResidency;
    pub const SetGPUThreadPriority = IDevice.Methods(@This()).SetGPUThreadPriority;
    pub const GetGPUThreadPriority = IDevice.Methods(@This()).GetGPUThreadPriority;

    pub const SetMaximumFrameLatency = IDevice1.Methods(@This()).SetMaximumFrameLatency;
    pub const GetMaximumFrameLatency = IDevice1.Methods(@This()).GetMaximumFrameLatency;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetMaximumFrameLatency(self: *T, max_latency: UINT) HRESULT {
                return @as(*const IDevice1.VTable, @ptrCast(self.__v))
                    .SetMaximumFrameLatency(@ptrCast(self), max_latency);
            }
            pub inline fn GetMaximumFrameLatency(self: *T, max_latency: *UINT) HRESULT {
                return @as(*const IDevice1.VTable, @ptrCast(self.__v))
                    .GetMaximumFrameLatency(@ptrCast(self), max_latency);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice.VTable,
        SetMaximumFrameLatency: *const fn (self: *IDevice1, max_latency: UINT) callconv(WINAPI) HRESULT,
        GetMaximumFrameLatency: *const fn (self: *IDevice1, max_latency: *UINT) callconv(WINAPI) HRESULT,
    };
};

pub const CREATE_FACTORY_DEBUG = 0x1;

extern "dxgi" fn CreateDXGIFactory2(UINT, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT;
extern "dxgi" fn DXGIGetDebugInterface1(UINT, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT;

pub const CreateFactory2 = CreateDXGIFactory2;
pub const GetDebugInterface1 = DXGIGetDebugInterface1;

pub const SCALING = enum(UINT) {
    STRETCH = 0,
    NONE = 1,
    ASPECT_RATIO_STRETCH = 2,
};

pub const ALPHA_MODE = enum(UINT) {
    UNSPECIFIED = 0,
    PREMULTIPLIED = 1,
    STRAIGHT = 2,
    IGNORE = 3,
};

pub const SWAP_CHAIN_DESC1 = extern struct {
    Width: UINT,
    Height: UINT,
    Format: FORMAT,
    Stereo: BOOL,
    SampleDesc: SAMPLE_DESC,
    BufferUsage: USAGE,
    BufferCount: UINT,
    Scaling: SCALING,
    SwapEffect: SWAP_EFFECT,
    AlphaMode: ALPHA_MODE,
    Flags: SWAP_CHAIN_FLAG,
};

pub const SWAP_CHAIN_FULLSCREEN_DESC = extern struct {
    RefreshRate: RATIONAL,
    ScanlineOrdering: MODE_SCANLINE_ORDER,
    Scaling: MODE_SCALING,
    Windowed: BOOL,
};

pub const PRESENT_PARAMETERS = extern struct {
    DirtyRectsCount: UINT,
    pDirtyRects: ?*RECT,
    pScrollRect: *RECT,
    pScrollOffset: *POINT,
};

pub const ISwapChain1 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDevice = IDeviceSubObject.Methods(@This()).GetDevice;

    pub const Present = ISwapChain.Methods(@This()).Present;
    pub const GetBuffer = ISwapChain.Methods(@This()).GetBuffer;
    pub const SetFullscreenState = ISwapChain.Methods(@This()).SetFullscreenState;
    pub const GetFullscreenState = ISwapChain.Methods(@This()).GetFullscreenState;
    pub const GetDesc = ISwapChain.Methods(@This()).GetDesc;
    pub const ResizeBuffers = ISwapChain.Methods(@This()).ResizeBuffers;
    pub const ResizeTarget = ISwapChain.Methods(@This()).ResizeTarget;
    pub const GetContainingOutput = ISwapChain.Methods(@This()).GetContainingOutput;
    pub const GetFrameStatistics = ISwapChain.Methods(@This()).GetFrameStatistics;
    pub const GetLastPresentCount = ISwapChain.Methods(@This()).GetLastPresentCount;

    pub const GetDesc1 = ISwapChain1.Methods(@This()).GetDesc1;
    pub const GetFullscreenDesc = ISwapChain1.Methods(@This()).GetFullscreenDesc;
    pub const GetHwnd = ISwapChain1.Methods(@This()).GetHwnd;
    pub const GetCoreWindow = ISwapChain1.Methods(@This()).GetCoreWindow;
    pub const Present1 = ISwapChain1.Methods(@This()).Present1;
    pub const IsTemporaryMonoSupported = ISwapChain1.Methods(@This()).IsTemporaryMonoSupported;
    pub const GetRestrictToOutput = ISwapChain1.Methods(@This()).GetRestrictToOutput;
    pub const SetBackgroundColor = ISwapChain1.Methods(@This()).SetBackgroundColor;
    pub const GetBackgroundColor = ISwapChain1.Methods(@This()).GetBackgroundColor;
    pub const SetRotation = ISwapChain1.Methods(@This()).SetRotation;
    pub const GetRotation = ISwapChain1.Methods(@This()).GetRotation;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc1(self: *T, desc: *SWAP_CHAIN_DESC1) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v)).GetDesc1(@ptrCast(self), desc);
            }
            pub inline fn GetFullscreenDesc(self: *T, desc: *SWAP_CHAIN_FULLSCREEN_DESC) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v)).GetFullscreenDesc(@ptrCast(self), desc);
            }
            pub inline fn GetHwnd(self: *T, hwnd: *HWND) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v)).GetHwnd(@ptrCast(self), hwnd);
            }
            pub inline fn GetCoreWindow(self: *T, guid: *const GUID, unknown: *?*anyopaque) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v))
                    .GetCoreWindow(@ptrCast(self), guid, unknown);
            }
            pub inline fn Present1(
                self: *T,
                sync_interval: UINT,
                flags: PRESENT_FLAG,
                params: *const PRESENT_PARAMETERS,
            ) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v))
                    .Present1(@ptrCast(self), sync_interval, flags, params);
            }
            pub inline fn IsTemporaryMonoSupported(self: *T) BOOL {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v)).IsTemporaryMonoSupported(@ptrCast(self));
            }
            pub inline fn GetRestrictToOutput(self: *T, output: *?*IOutput) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v))
                    .GetRestrictToOutput(@ptrCast(self), output);
            }
            pub inline fn SetBackgroundColor(self: *T, color: *const RGBA) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v)).SetBackgroundColor(@ptrCast(self), color);
            }
            pub inline fn GetBackgroundColor(self: *T, color: *RGBA) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v)).GetBackgroundColor(@ptrCast(self), color);
            }
            pub inline fn SetRotation(self: *T, rotation: MODE_ROTATION) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v)).SetRotation(@ptrCast(self), rotation);
            }
            pub inline fn GetRotation(self: *T, rotation: *MODE_ROTATION) HRESULT {
                return @as(*const ISwapChain1.VTable, @ptrCast(self.__v)).GetRotation(@ptrCast(self), rotation);
            }
        };
    }

    pub const VTable = extern struct {
        base: ISwapChain.VTable,
        GetDesc1: *const fn (*ISwapChain1, *SWAP_CHAIN_DESC1) callconv(WINAPI) HRESULT,
        GetFullscreenDesc: *const fn (*ISwapChain1, *SWAP_CHAIN_FULLSCREEN_DESC) callconv(WINAPI) HRESULT,
        GetHwnd: *const fn (*ISwapChain1, *HWND) callconv(WINAPI) HRESULT,
        GetCoreWindow: *const fn (*ISwapChain1, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT,
        Present1: *const fn (*ISwapChain1, UINT, PRESENT_FLAG, *const PRESENT_PARAMETERS) callconv(WINAPI) HRESULT,
        IsTemporaryMonoSupported: *const fn (*ISwapChain1) callconv(WINAPI) BOOL,
        GetRestrictToOutput: *const fn (*ISwapChain1, *?*IOutput) callconv(WINAPI) HRESULT,
        SetBackgroundColor: *const fn (*ISwapChain1, *const RGBA) callconv(WINAPI) HRESULT,
        GetBackgroundColor: *const fn (*ISwapChain1, *RGBA) callconv(WINAPI) HRESULT,
        SetRotation: *const fn (*ISwapChain1, MODE_ROTATION) callconv(WINAPI) HRESULT,
        GetRotation: *const fn (*ISwapChain1, *MODE_ROTATION) callconv(WINAPI) HRESULT,
    };
};

pub const MATRIX_3X2_F = extern struct {
    _11: FLOAT,
    _12: FLOAT,
    _21: FLOAT,
    _22: FLOAT,
    _31: FLOAT,
    _32: FLOAT,
};

pub const ISwapChain2 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDevice = IDeviceSubObject.Methods(@This()).GetDevice;

    pub const Present = ISwapChain.Methods(@This()).Present;
    pub const GetBuffer = ISwapChain.Methods(@This()).GetBuffer;
    pub const SetFullscreenState = ISwapChain.Methods(@This()).SetFullscreenState;
    pub const GetFullscreenState = ISwapChain.Methods(@This()).GetFullscreenState;
    pub const GetDesc = ISwapChain.Methods(@This()).GetDesc;
    pub const ResizeBuffers = ISwapChain.Methods(@This()).ResizeBuffers;
    pub const ResizeTarget = ISwapChain.Methods(@This()).ResizeTarget;
    pub const GetContainingOutput = ISwapChain.Methods(@This()).GetContainingOutput;
    pub const GetFrameStatistics = ISwapChain.Methods(@This()).GetFrameStatistics;
    pub const GetLastPresentCount = ISwapChain.Methods(@This()).GetLastPresentCount;

    pub const GetDesc1 = ISwapChain1.Methods(@This()).GetDesc1;
    pub const GetFullscreenDesc = ISwapChain1.Methods(@This()).GetFullscreenDesc;
    pub const GetHwnd = ISwapChain1.Methods(@This()).GetHwnd;
    pub const GetCoreWindow = ISwapChain1.Methods(@This()).GetCoreWindow;
    pub const Present1 = ISwapChain1.Methods(@This()).Present1;
    pub const IsTemporaryMonoSupported = ISwapChain1.Methods(@This()).IsTemporaryMonoSupported;
    pub const GetRestrictToOutput = ISwapChain1.Methods(@This()).GetRestrictToOutput;
    pub const SetBackgroundColor = ISwapChain1.Methods(@This()).SetBackgroundColor;
    pub const GetBackgroundColor = ISwapChain1.Methods(@This()).GetBackgroundColor;
    pub const SetRotation = ISwapChain1.Methods(@This()).SetRotation;
    pub const GetRotation = ISwapChain1.Methods(@This()).GetRotation;

    pub const SetSourceSize = ISwapChain2.Methods(@This()).SetSourceSize;
    pub const GetSourceSize = ISwapChain2.Methods(@This()).GetSourceSize;
    pub const SetMaximumFrameLatency = ISwapChain2.Methods(@This()).SetMaximumFrameLatency;
    pub const GetMaximumFrameLatency = ISwapChain2.Methods(@This()).GetMaximumFrameLatency;
    pub const GetFrameLatencyWaitableObject = ISwapChain2.Methods(@This()).GetFrameLatencyWaitableObject;
    pub const SetMatrixTransform = ISwapChain2.Methods(@This()).SetMatrixTransform;
    pub const GetMatrixTransform = ISwapChain2.Methods(@This()).GetMatrixTransform;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetSourceSize(self: *T, width: UINT, height: UINT) HRESULT {
                return @as(*const ISwapChain2.VTable, @ptrCast(self.__v))
                    .SetSourceSize(@ptrCast(self), width, height);
            }
            pub inline fn GetSourceSize(self: *T, width: *UINT, height: *UINT) HRESULT {
                return @as(*const ISwapChain2.VTable, @ptrCast(self.__v))
                    .GetSourceSize(@ptrCast(self), width, height);
            }
            pub inline fn SetMaximumFrameLatency(self: *T, max_latency: UINT) HRESULT {
                return @as(*const ISwapChain2.VTable, @ptrCast(self.__v))
                    .SetMaximumFrameLatency(@ptrCast(self), max_latency);
            }
            pub inline fn GetMaximumFrameLatency(self: *T, max_latency: *UINT) HRESULT {
                return @as(*const ISwapChain2.VTable, @ptrCast(self.__v))
                    .GetMaximumFrameLatency(@ptrCast(self), max_latency);
            }
            pub inline fn GetFrameLatencyWaitableObject(self: *T) HANDLE {
                return @as(*const ISwapChain2.VTable, @ptrCast(self.__v))
                    .GetFrameLatencyWaitableObject(@ptrCast(self));
            }
            pub inline fn SetMatrixTransform(self: *T, matrix: *const MATRIX_3X2_F) HRESULT {
                return @as(*const ISwapChain2.VTable, @ptrCast(self.__v))
                    .SetMatrixTransform(@ptrCast(self), matrix);
            }
            pub inline fn GetMatrixTransform(self: *T, matrix: *MATRIX_3X2_F) HRESULT {
                return @as(*const ISwapChain2.VTable, @ptrCast(self.__v))
                    .GetMatrixTransform(@ptrCast(self), matrix);
            }
        };
    }

    pub const VTable = extern struct {
        base: ISwapChain1.VTable,
        SetSourceSize: *const fn (*ISwapChain2, UINT, UINT) callconv(WINAPI) HRESULT,
        GetSourceSize: *const fn (*ISwapChain2, *UINT, *UINT) callconv(WINAPI) HRESULT,
        SetMaximumFrameLatency: *const fn (*ISwapChain2, UINT) callconv(WINAPI) HRESULT,
        GetMaximumFrameLatency: *const fn (*ISwapChain2, *UINT) callconv(WINAPI) HRESULT,
        GetFrameLatencyWaitableObject: *const fn (*ISwapChain2) callconv(WINAPI) HANDLE,
        SetMatrixTransform: *const fn (*ISwapChain2, *const MATRIX_3X2_F) callconv(WINAPI) HRESULT,
        GetMatrixTransform: *const fn (*ISwapChain2, *MATRIX_3X2_F) callconv(WINAPI) HRESULT,
    };
};

pub const ISwapChain3 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{94d99bdb-f1f8-4ab0-b236-7da0170edab1}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const GetParent = IObject.Methods(@This()).GetParent;

    pub const GetDevice = IDeviceSubObject.Methods(@This()).GetDevice;

    pub const Present = ISwapChain.Methods(@This()).Present;
    pub const GetBuffer = ISwapChain.Methods(@This()).GetBuffer;
    pub const SetFullscreenState = ISwapChain.Methods(@This()).SetFullscreenState;
    pub const GetFullscreenState = ISwapChain.Methods(@This()).GetFullscreenState;
    pub const GetDesc = ISwapChain.Methods(@This()).GetDesc;
    pub const ResizeBuffers = ISwapChain.Methods(@This()).ResizeBuffers;
    pub const ResizeTarget = ISwapChain.Methods(@This()).ResizeTarget;
    pub const GetContainingOutput = ISwapChain.Methods(@This()).GetContainingOutput;
    pub const GetFrameStatistics = ISwapChain.Methods(@This()).GetFrameStatistics;
    pub const GetLastPresentCount = ISwapChain.Methods(@This()).GetLastPresentCount;

    pub const GetDesc1 = ISwapChain1.Methods(@This()).GetDesc1;
    pub const GetFullscreenDesc = ISwapChain1.Methods(@This()).GetFullscreenDesc;
    pub const GetHwnd = ISwapChain1.Methods(@This()).GetHwnd;
    pub const GetCoreWindow = ISwapChain1.Methods(@This()).GetCoreWindow;
    pub const Present1 = ISwapChain1.Methods(@This()).Present1;
    pub const IsTemporaryMonoSupported = ISwapChain1.Methods(@This()).IsTemporaryMonoSupported;
    pub const GetRestrictToOutput = ISwapChain1.Methods(@This()).GetRestrictToOutput;
    pub const SetBackgroundColor = ISwapChain1.Methods(@This()).SetBackgroundColor;
    pub const GetBackgroundColor = ISwapChain1.Methods(@This()).GetBackgroundColor;
    pub const SetRotation = ISwapChain1.Methods(@This()).SetRotation;
    pub const GetRotation = ISwapChain1.Methods(@This()).GetRotation;

    pub const SetSourceSize = ISwapChain2.Methods(@This()).SetSourceSize;
    pub const GetSourceSize = ISwapChain2.Methods(@This()).GetSourceSize;
    pub const SetMaximumFrameLatency = ISwapChain2.Methods(@This()).SetMaximumFrameLatency;
    pub const GetMaximumFrameLatency = ISwapChain2.Methods(@This()).GetMaximumFrameLatency;
    pub const GetFrameLatencyWaitableObject = ISwapChain2.Methods(@This()).GetFrameLatencyWaitableObject;
    pub const SetMatrixTransform = ISwapChain2.Methods(@This()).SetMatrixTransform;
    pub const GetMatrixTransform = ISwapChain2.Methods(@This()).GetMatrixTransform;

    pub const GetCurrentBackBufferIndex = ISwapChain3.Methods(@This()).GetCurrentBackBufferIndex;
    pub const CheckColorSpaceSupport = ISwapChain3.Methods(@This()).CheckColorSpaceSupport;
    pub const SetColorSpace1 = ISwapChain3.Methods(@This()).SetColorSpace1;
    pub const ResizeBuffers1 = ISwapChain3.Methods(@This()).ResizeBuffers1;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetCurrentBackBufferIndex(self: *T) UINT {
                return @as(*const ISwapChain3.VTable, @ptrCast(self.__v)).GetCurrentBackBufferIndex(@ptrCast(self));
            }
            pub inline fn CheckColorSpaceSupport(self: *T, space: COLOR_SPACE_TYPE, support: *UINT) HRESULT {
                return @as(*const ISwapChain3.VTable, @ptrCast(self.__v))
                    .CheckColorSpaceSupport(@ptrCast(self), space, support);
            }
            pub inline fn SetColorSpace1(self: *T, space: COLOR_SPACE_TYPE) HRESULT {
                return @as(*const ISwapChain3.VTable, @ptrCast(self.__v)).SetColorSpace1(@ptrCast(self), space);
            }
            pub inline fn ResizeBuffers1(
                self: *T,
                buffer_count: UINT,
                width: UINT,
                height: UINT,
                format: FORMAT,
                swap_chain_flags: SWAP_CHAIN_FLAG,
                creation_node_mask: [*]const UINT,
                present_queue: [*]const *IUnknown,
            ) HRESULT {
                return @as(*const ISwapChain3.VTable, @ptrCast(self.__v)).ResizeBuffers1(
                    @ptrCast(self),
                    buffer_count,
                    width,
                    height,
                    format,
                    swap_chain_flags,
                    creation_node_mask,
                    present_queue,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: ISwapChain2.VTable,
        GetCurrentBackBufferIndex: *const fn (*ISwapChain3) callconv(WINAPI) UINT,
        CheckColorSpaceSupport: *const fn (*ISwapChain3, COLOR_SPACE_TYPE, *UINT) callconv(WINAPI) HRESULT,
        SetColorSpace1: *const fn (*ISwapChain3, COLOR_SPACE_TYPE) callconv(WINAPI) HRESULT,
        ResizeBuffers1: *const fn (
            *ISwapChain3,
            UINT,
            UINT,
            UINT,
            FORMAT,
            SWAP_CHAIN_FLAG,
            [*]const UINT,
            [*]const *IUnknown,
        ) callconv(WINAPI) HRESULT,
    };
};

// https://docs.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-status
pub const STATUS_OCCLUDED = @as(HRESULT, @bitCast(@as(c_ulong, 0x087A0001)));
pub const STATUS_MODE_CHANGED = @as(HRESULT, @bitCast(@as(c_ulong, 0x087A0007)));
pub const STATUS_MODE_CHANGE_IN_PROGRESS = @as(HRESULT, @bitCast(@as(c_ulong, 0x087A0008)));

// https://docs.microsoft.com/en-us/windows/win32/direct3ddxgi/dxgi-error
pub const ERROR_ACCESS_DENIED = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A002B)));
pub const ERROR_ACCESS_LOST = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0026)));
pub const ERROR_ALREADY_EXISTS = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0036)));
pub const ERROR_CANNOT_PROTECT_CONTENT = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A002A)));
pub const ERROR_DEVICE_HUNG = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0006)));
pub const ERROR_DEVICE_REMOVED = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0005)));
pub const ERROR_DEVICE_RESET = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0007)));
pub const ERROR_DRIVER_INTERNAL_ERROR = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0020)));
pub const ERROR_FRAME_STATISTICS_DISJOINT = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A000B)));
pub const ERROR_GRAPHICS_VIDPN_SOURCE_IN_USE = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A000C)));
pub const ERROR_INVALID_CALL = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0001)));
pub const ERROR_MORE_DATA = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0003)));
pub const ERROR_NAME_ALREADY_EXISTS = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A002C)));
pub const ERROR_NONEXCLUSIVE = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0021)));
pub const ERROR_NOT_CURRENTLY_AVAILABLE = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0022)));
pub const ERROR_NOT_FOUND = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0002)));
pub const ERROR_REMOTE_CLIENT_DISCONNECTED = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0023)));
pub const ERROR_REMOTE_OUTOFMEMORY = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0024)));
pub const ERROR_RESTRICT_TO_OUTPUT_STALE = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0029)));
pub const ERROR_SDK_COMPONENT_MISSING = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A002D)));
pub const ERROR_SESSION_DISCONNECTED = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0028)));
pub const ERROR_UNSUPPORTED = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0004)));
pub const ERROR_WAIT_TIMEOUT = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A0027)));
pub const ERROR_WAS_STILL_DRAWING = @as(HRESULT, @bitCast(@as(c_ulong, 0x887A000A)));
