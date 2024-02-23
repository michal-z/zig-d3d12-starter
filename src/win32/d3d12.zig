const std = @import("std");
const w32 = @import("win32.zig");
const dxgi = @import("dxgi.zig");
const d3d = @import("d3dcommon.zig");
const UINT = w32.UINT;
const IUnknown = w32.IUnknown;
const HRESULT = w32.HRESULT;
const GUID = w32.GUID;
const LUID = w32.LUID;
const WINAPI = w32.WINAPI;
const FLOAT = w32.FLOAT;
const LPCWSTR = w32.LPCWSTR;
const LPCSTR = w32.LPCSTR;
const UINT8 = w32.UINT8;
const UINT16 = w32.UINT16;
const UINT32 = w32.UINT32;
const UINT64 = w32.UINT64;
const INT = w32.INT;
const INT8 = w32.INT8;
const BYTE = w32.BYTE;
const DWORD = w32.DWORD;
const SIZE_T = w32.SIZE_T;
const HANDLE = w32.HANDLE;
const SECURITY_ATTRIBUTES = w32.SECURITY_ATTRIBUTES;
const BOOL = w32.BOOL;
const FALSE = w32.FALSE;
const TRUE = w32.TRUE;

pub const RESOURCE_BARRIER_ALL_SUBRESOURCES = 0xffff_ffff;

pub const SHADER_IDENTIFIER_SIZE_IN_BYTES = 32;

pub const GPU_VIRTUAL_ADDRESS = UINT64;

pub const PRIMITIVE_TOPOLOGY = d3d.PRIMITIVE_TOPOLOGY;

pub const CPU_DESCRIPTOR_HANDLE = extern struct {
    ptr: UINT64,
};

pub const GPU_DESCRIPTOR_HANDLE = extern struct {
    ptr: UINT64,
};

pub const PRIMITIVE_TOPOLOGY_TYPE = enum(UINT) {
    UNDEFINED = 0,
    POINT = 1,
    LINE = 2,
    TRIANGLE = 3,
    PATCH = 4,
};

pub const HEAP_TYPE = enum(UINT) {
    DEFAULT = 1,
    UPLOAD = 2,
    READBACK = 3,
    CUSTOM = 4,
};

pub const CPU_PAGE_PROPERTY = enum(UINT) {
    UNKNOWN = 0,
    NOT_AVAILABLE = 1,
    WRITE_COMBINE = 2,
    WRITE_BACK = 3,
};

pub const MEMORY_POOL = enum(UINT) {
    UNKNOWN = 0,
    L0 = 1,
    L1 = 2,
};

pub const HEAP_PROPERTIES = extern struct {
    Type: HEAP_TYPE,
    CPUPageProperty: CPU_PAGE_PROPERTY,
    MemoryPoolPreference: MEMORY_POOL,
    CreationNodeMask: UINT,
    VisibleNodeMask: UINT,

    pub fn init_type(heap_type: HEAP_TYPE) HEAP_PROPERTIES {
        var v = std.mem.zeroes(@This());
        v = HEAP_PROPERTIES{
            .Type = heap_type,
            .CPUPageProperty = .UNKNOWN,
            .MemoryPoolPreference = .UNKNOWN,
            .CreationNodeMask = 0,
            .VisibleNodeMask = 0,
        };
        return v;
    }
};

pub const HEAP_FLAGS = packed struct(UINT) {
    SHARED: bool = false,
    __unused1: bool = false,
    DENY_BUFFERS: bool = false,
    ALLOW_DISPLAY: bool = false,
    __unused4: bool = false,
    SHARED_CROSS_ADAPTER: bool = false,
    DENY_RT_DS_TEXTURES: bool = false,
    DENY_NON_RT_DS_TEXTURES: bool = false,
    HARDWARE_PROTECTED: bool = false,
    ALLOW_WRITE_WATCH: bool = false,
    ALLOW_SHADER_ATOMICS: bool = false,
    CREATE_NOT_RESIDENT: bool = false,
    CREATE_NOT_ZEROED: bool = false,
    __unused: u19 = 0,

    pub const ALLOW_ALL_BUFFERS_AND_TEXTURES = HEAP_FLAGS{};
    pub const ALLOW_ONLY_NON_RT_DS_TEXTURES = HEAP_FLAGS{ .DENY_BUFFERS = true, .DENY_RT_DS_TEXTURES = true };
    pub const ALLOW_ONLY_BUFFERS = HEAP_FLAGS{ .DENY_RT_DS_TEXTURES = true, .DENY_NON_RT_DS_TEXTURES = true };
    pub const HEAP_FLAG_ALLOW_ONLY_RT_DS_TEXTURES = HEAP_FLAGS{
        .DENY_BUFFERS = true,
        .DENY_NON_RT_DS_TEXTURES = true,
    };
};

pub const HEAP_DESC = extern struct {
    SizeInBytes: UINT64,
    Properties: HEAP_PROPERTIES,
    Alignment: UINT64,
    Flags: HEAP_FLAGS,
};

pub const RANGE = extern struct {
    Begin: UINT64,
    End: UINT64,
};

pub const BOX = extern struct {
    left: UINT,
    top: UINT,
    front: UINT,
    right: UINT,
    bottom: UINT,
    back: UINT,
};

pub const RESOURCE_DIMENSION = enum(UINT) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE2D = 3,
    TEXTURE3D = 4,
};

pub const TEXTURE_LAYOUT = enum(UINT) {
    UNKNOWN = 0,
    ROW_MAJOR = 1,
    @"64KB_UNDEFINED_SWIZZLE" = 2,
    @"64KB_STANDARD_SWIZZLE" = 3,
};

pub const RESOURCE_FLAGS = packed struct(UINT) {
    ALLOW_RENDER_TARGET: bool = false,
    ALLOW_DEPTH_STENCIL: bool = false,
    ALLOW_UNORDERED_ACCESS: bool = false,
    DENY_SHADER_RESOURCE: bool = false,
    ALLOW_CROSS_ADAPTER: bool = false,
    ALLOW_SIMULTANEOUS_ACCESS: bool = false,
    VIDEO_DECODE_REFERENCE_ONLY: bool = false,
    VIDEO_ENCODE_REFERENCE_ONLY: bool = false,
    __unused: u24 = 0,
};

pub const RESOURCE_DESC = extern struct {
    Dimension: RESOURCE_DIMENSION,
    Alignment: UINT64,
    Width: UINT64,
    Height: UINT,
    DepthOrArraySize: UINT16,
    MipLevels: UINT16,
    Format: dxgi.FORMAT,
    SampleDesc: dxgi.SAMPLE_DESC,
    Layout: TEXTURE_LAYOUT,
    Flags: RESOURCE_FLAGS,

    pub fn init_buffer(width: UINT64) RESOURCE_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .Dimension = .BUFFER,
            .Alignment = 0,
            .Width = width,
            .Height = 1,
            .DepthOrArraySize = 1,
            .MipLevels = 1,
            .Format = .UNKNOWN,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .Layout = .ROW_MAJOR,
            .Flags = .{},
        };
        return v;
    }

    pub fn init_tex2d(format: dxgi.FORMAT, width: UINT64, height: UINT, mip_levels: u32) RESOURCE_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .Dimension = .TEXTURE2D,
            .Alignment = 0,
            .Width = width,
            .Height = height,
            .DepthOrArraySize = 1,
            .MipLevels = @as(u16, @intCast(mip_levels)),
            .Format = format,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .Layout = .UNKNOWN,
            .Flags = .{},
        };
        return v;
    }

    pub fn init_texcube(format: dxgi.FORMAT, width: UINT64, height: UINT, mip_levels: u32) RESOURCE_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .Dimension = .TEXTURE2D,
            .Alignment = 0,
            .Width = width,
            .Height = height,
            .DepthOrArraySize = 6,
            .MipLevels = @as(u16, @intCast(mip_levels)),
            .Format = format,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .Layout = .UNKNOWN,
            .Flags = .{},
        };
        return v;
    }
};

pub const FENCE_FLAGS = packed struct(UINT) {
    SHARED: bool = false,
    SHARED_CROSS_ADAPTER: bool = false,
    NON_MONITORED: bool = false,
    __unused: u29 = 0,
};

pub const DESCRIPTOR_HEAP_TYPE = enum(UINT) {
    CBV_SRV_UAV = 0,
    SAMPLER = 1,
    RTV = 2,
    DSV = 3,
};

pub const DESCRIPTOR_HEAP_FLAGS = packed struct(UINT) {
    SHADER_VISIBLE: bool = false,
    __unused: u31 = 0,
};

pub const DESCRIPTOR_HEAP_DESC = extern struct {
    Type: DESCRIPTOR_HEAP_TYPE,
    NumDescriptors: UINT,
    Flags: DESCRIPTOR_HEAP_FLAGS,
    NodeMask: UINT,
};

pub const DESCRIPTOR_RANGE_TYPE = enum(UINT) {
    SRV = 0,
    UAV = 1,
    CBV = 2,
    SAMPLER = 3,
};

pub const DESCRIPTOR_RANGE = extern struct {
    RangeType: DESCRIPTOR_RANGE_TYPE,
    NumDescriptors: UINT,
    BaseShaderRegister: UINT,
    RegisterSpace: UINT,
    OffsetInDescriptorsFromStart: UINT,
};

pub const ROOT_DESCRIPTOR_TABLE = extern struct {
    NumDescriptorRanges: UINT,
    pDescriptorRanges: ?[*]const DESCRIPTOR_RANGE,
};

pub const ROOT_CONSTANTS = extern struct {
    ShaderRegister: UINT,
    RegisterSpace: UINT,
    Num32BitValues: UINT,
};

pub const ROOT_DESCRIPTOR = extern struct {
    ShaderRegister: UINT,
    RegisterSpace: UINT,
};

pub const ROOT_PARAMETER_TYPE = enum(UINT) {
    DESCRIPTOR_TABLE = 0,
    @"32BIT_CONSTANTS" = 1,
    CBV = 2,
    SRV = 3,
    UAV = 4,
};

pub const SHADER_VISIBILITY = enum(UINT) {
    ALL = 0,
    VERTEX = 1,
    HULL = 2,
    DOMAIN = 3,
    GEOMETRY = 4,
    PIXEL = 5,
    AMPLIFICATION = 6,
    MESH = 7,
};

pub const ROOT_PARAMETER = extern struct {
    ParameterType: ROOT_PARAMETER_TYPE,
    u: extern union {
        DescriptorTable: ROOT_DESCRIPTOR_TABLE,
        Constants: ROOT_CONSTANTS,
        Descriptor: ROOT_DESCRIPTOR,
    },
    ShaderVisibility: SHADER_VISIBILITY,
};

pub const STATIC_BORDER_COLOR = enum(UINT) {
    TRANSPARENT_BLACK = 0,
    OPAQUE_BLACK = 1,
    OPAQUE_WHITE = 2,
};

pub const STATIC_SAMPLER_DESC = extern struct {
    Filter: FILTER,
    AddressU: TEXTURE_ADDRESS_MODE,
    AddressV: TEXTURE_ADDRESS_MODE,
    AddressW: TEXTURE_ADDRESS_MODE,
    MipLODBias: FLOAT,
    MaxAnisotropy: UINT,
    ComparisonFunc: COMPARISON_FUNC,
    BorderColor: STATIC_BORDER_COLOR,
    MinLOD: FLOAT,
    MaxLOD: FLOAT,
    ShaderRegister: UINT,
    RegisterSpace: UINT,
    ShaderVisibility: SHADER_VISIBILITY,
};

pub const ROOT_SIGNATURE_FLAGS = packed struct(UINT) {
    ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT: bool = false,
    DENY_VERTEX_SHADER_ROOT_ACCESS: bool = false,
    DENY_HULL_SHADER_ROOT_ACCESS: bool = false,
    DENY_DOMAIN_SHADER_ROOT_ACCESS: bool = false,
    DENY_GEOMETRY_SHADER_ROOT_ACCESS: bool = false,
    DENY_PIXEL_SHADER_ROOT_ACCESS: bool = false,
    ALLOW_STREAM_OUTPUT: bool = false,
    LOCAL_ROOT_SIGNATURE: bool = false,
    DENY_AMPLIFICATION_SHADER_ROOT_ACCESS: bool = false,
    DENY_MESH_SHADER_ROOT_ACCESS: bool = false,
    CBV_SRV_UAV_HEAP_DIRECTLY_INDEXED: bool = false,
    SAMPLER_HEAP_DIRECTLY_INDEXED: bool = false,
    __unused: u20 = 0,
};

pub const ROOT_SIGNATURE_DESC = extern struct {
    NumParamenters: UINT,
    pParameters: ?[*]const ROOT_PARAMETER,
    NumStaticSamplers: UINT,
    pStaticSamplers: ?[*]const STATIC_SAMPLER_DESC,
    Flags: ROOT_SIGNATURE_FLAGS,
};

pub const DESCRIPTOR_RANGE_FLAGS = packed struct(UINT) {
    DESCRIPTORS_VOLATILE: bool = false, // 0x1
    DATA_VOLATILE: bool = false,
    DATA_STATIC_WHILE_SET_AT_EXECUTE: bool = false,
    DATA_STATIC: bool = false,
    __unused4: bool = false, // 0x10
    __unused5: bool = false,
    __unused6: bool = false,
    __unused7: bool = false,
    __unused8: bool = false, // 0x100
    __unused9: bool = false,
    __unused10: bool = false,
    __unused11: bool = false,
    __unused12: bool = false, // 0x1000
    __unused13: bool = false,
    __unused14: bool = false,
    __unused15: bool = false,
    DESCRIPTORS_STATIC_KEEPING_BUFFER_BOUNDS_CHECKS: bool = false, // 0x10000
    __unused: u15 = 0,
};

pub const DESCRIPTOR_RANGE1 = extern struct {
    RangeType: DESCRIPTOR_RANGE_TYPE,
    NumDescriptors: UINT,
    BaseShaderRegister: UINT,
    RegisterSpace: UINT,
    Flags: DESCRIPTOR_RANGE_FLAGS,
    OffsetInDescriptorsFromTableStart: UINT,
};

pub const ROOT_DESCRIPTOR_TABLE1 = extern struct {
    NumDescriptorRanges: UINT,
    pDescriptorRanges: ?[*]const DESCRIPTOR_RANGE1,
};

pub const ROOT_DESCRIPTOR_FLAGS = packed struct(UINT) {
    __unused0: bool = false,
    DATA_VOLATILE: bool = false,
    DATA_STATIC_WHILE_SET_AT_EXECUTE: bool = false,
    DATA_STATIC: bool = false,
};

pub const ROOT_DESCRIPTOR1 = extern struct {
    ShaderRegister: UINT,
    RegisterSpace: UINT,
    Flags: ROOT_DESCRIPTOR_FLAGS,
};

pub const ROOT_PARAMETER1 = extern struct {
    ParameterType: ROOT_PARAMETER_TYPE,
    u: extern union {
        DescriptorTable: ROOT_DESCRIPTOR_TABLE1,
        Constants: ROOT_CONSTANTS,
        Descriptor: ROOT_DESCRIPTOR1,
    },
    ShaderVisibility: SHADER_VISIBILITY,
};

pub const ROOT_SIGNATURE_DESC1 = extern struct {
    NumParamenters: UINT,
    pParameters: ?[*]const ROOT_PARAMETER1,
    NumStaticSamplers: UINT,
    pStaticSamplers: ?[*]const STATIC_SAMPLER_DESC,
    Flags: ROOT_SIGNATURE_FLAGS,
};

pub const ROOT_SIGNATURE_VERSION = enum(UINT) {
    VERSION_1_0 = 0x1,
    VERSION_1_1 = 0x2,
};

pub const VERSIONED_ROOT_SIGNATURE_DESC = extern struct {
    Version: ROOT_SIGNATURE_VERSION,
    u: extern union {
        Desc_1_0: ROOT_SIGNATURE_DESC,
        Desc_1_1: ROOT_SIGNATURE_DESC1,
    },
};

pub const COMMAND_LIST_TYPE = enum(UINT) {
    DIRECT = 0,
    BUNDLE = 1,
    COMPUTE = 2,
    COPY = 3,
    VIDEO_DECODE = 4,
    VIDEO_PROCESS = 5,
    VIDEO_ENCODE = 6,
};

pub const RESOURCE_BARRIER_TYPE = enum(UINT) {
    TRANSITION = 0,
    ALIASING = 1,
    UAV = 2,
};

pub const RESOURCE_TRANSITION_BARRIER = extern struct {
    pResource: *IResource,
    Subresource: UINT,
    StateBefore: RESOURCE_STATES,
    StateAfter: RESOURCE_STATES,
};

pub const RESOURCE_ALIASING_BARRIER = extern struct {
    pResourceBefore: ?*IResource,
    pResourceAfter: ?*IResource,
};

pub const RESOURCE_UAV_BARRIER = extern struct {
    pResource: ?*IResource,
};

pub const RESOURCE_BARRIER_FLAGS = packed struct(UINT) {
    BEGIN_ONLY: bool = false,
    END_ONLY: bool = false,
    __unused: u30 = 0,
};

pub const RESOURCE_BARRIER = extern struct {
    Type: RESOURCE_BARRIER_TYPE,
    Flags: RESOURCE_BARRIER_FLAGS,
    u: extern union {
        Transition: RESOURCE_TRANSITION_BARRIER,
        Aliasing: RESOURCE_ALIASING_BARRIER,
        UAV: RESOURCE_UAV_BARRIER,
    },

    pub fn init_uav(resource: *IResource) RESOURCE_BARRIER {
        var v = std.mem.zeroes(@This());
        v = .{ .Type = .UAV, .Flags = .{}, .u = .{ .UAV = .{ .pResource = resource } } };
        return v;
    }
};

pub const SUBRESOURCE_DATA = extern struct {
    pData: ?[*]u8,
    RowPitch: UINT,
    SlicePitch: UINT,
};

pub const MEMCPY_DEST = extern struct {
    pData: ?[*]u8,
    RowPitch: UINT,
    SlicePitch: UINT,
};

pub const SUBRESOURCE_FOOTPRINT = extern struct {
    Format: dxgi.FORMAT,
    Width: UINT,
    Height: UINT,
    Depth: UINT,
    RowPitch: UINT,
};

pub const PLACED_SUBRESOURCE_FOOTPRINT = extern struct {
    Offset: UINT64,
    Footprint: SUBRESOURCE_FOOTPRINT,
};

pub const TEXTURE_COPY_TYPE = enum(UINT) {
    SUBRESOURCE_INDEX = 0,
    PLACED_FOOTPRINT = 1,
};

pub const TEXTURE_COPY_LOCATION = extern struct {
    pResource: *IResource,
    Type: TEXTURE_COPY_TYPE,
    u: extern union {
        PlacedFootprint: PLACED_SUBRESOURCE_FOOTPRINT,
        SubresourceIndex: UINT,
    },
};

pub const TILED_RESOURCE_COORDINATE = extern struct {
    X: UINT,
    Y: UINT,
    Z: UINT,
    Subresource: UINT,
};

pub const TILE_REGION_SIZE = extern struct {
    NumTiles: UINT,
    UseBox: BOOL,
    Width: UINT,
    Height: UINT16,
    Depth: UINT16,
};

pub const TILE_RANGE_FLAGS = packed struct(UINT) {
    NULL: bool = false,
    SKIP: bool = false,
    REUSE_SINGLE_TILE: bool = false,
    __unused: u29 = 0,
};

pub const SUBRESOURCE_TILING = extern struct {
    WidthInTiles: UINT,
    HeightInTiles: UINT16,
    DepthInTiles: UINT16,
    StartTileIndexInOverallResource: UINT,
};

pub const TILE_SHAPE = extern struct {
    WidthInTexels: UINT,
    HeightInTexels: UINT,
    DepthInTexels: UINT,
};

pub const TILE_MAPPING_FLAGS = packed struct(UINT) {
    NO_HAZARD: bool = false,
    __unused: u31 = 0,
};

pub const TILE_COPY_FLAGS = packed struct(UINT) {
    NO_HAZARD: bool = false,
    LINEAR_BUFFER_TO_SWIZZLED_TILED_RESOURCE: bool = false,
    SWIZZLED_TILED_RESOURCE_TO_LINEAR_BUFFER: bool = false,
    __unused: u29 = 0,
};

pub const VIEWPORT = extern struct {
    TopLeftX: FLOAT,
    TopLeftY: FLOAT,
    Width: FLOAT,
    Height: FLOAT,
    MinDepth: FLOAT,
    MaxDepth: FLOAT,
};

pub const RECT = w32.RECT;

pub const RESOURCE_STATES = packed struct(UINT) {
    VERTEX_AND_CONSTANT_BUFFER: bool = false, // 0x1
    INDEX_BUFFER: bool = false,
    RENDER_TARGET: bool = false,
    UNORDERED_ACCESS: bool = false,
    DEPTH_WRITE: bool = false, // 0x10
    DEPTH_READ: bool = false,
    NON_PIXEL_SHADER_RESOURCE: bool = false,
    PIXEL_SHADER_RESOURCE: bool = false,
    STREAM_OUT: bool = false, // 0x100
    INDIRECT_ARGUMENT_OR_PREDICATION: bool = false,
    COPY_DEST: bool = false,
    COPY_SOURCE: bool = false,
    RESOLVE_DEST: bool = false, // 0x1000
    RESOLVE_SOURCE: bool = false,
    __unused14: bool = false,
    __unused15: bool = false,
    VIDEO_DECODE_READ: bool = false, // 0x10000
    VIDEO_DECODE_WRITE: bool = false,
    VIDEO_PROCESS_READ: bool = false,
    VIDEO_PROCESS_WRITE: bool = false,
    __unused20: bool = false, // 0x100000
    VIDEO_ENCODE_READ: bool = false,
    RAYTRACING_ACCELERATION_STRUCTURE: bool = false,
    VIDEO_ENCODE_WRITE: bool = false,
    SHADING_RATE_SOURCE: bool = false, // 0x1000000
    __unused: u7 = 0,

    pub const COMMON = RESOURCE_STATES{};
    pub const PRESENT = RESOURCE_STATES{};
    pub const GENERIC_READ = RESOURCE_STATES{
        .VERTEX_AND_CONSTANT_BUFFER = true,
        .INDEX_BUFFER = true,
        .NON_PIXEL_SHADER_RESOURCE = true,
        .PIXEL_SHADER_RESOURCE = true,
        .INDIRECT_ARGUMENT_OR_PREDICATION = true,
        .COPY_SOURCE = true,
    };
    pub const ALL_SHADER_RESOURCE = RESOURCE_STATES{
        .NON_PIXEL_SHADER_RESOURCE = true,
        .PIXEL_SHADER_RESOURCE = true,
    };
};

pub const INDEX_BUFFER_STRIP_CUT_VALUE = enum(UINT) {
    DISABLED = 0,
    OxFFFF = 1,
    OxFFFFFFFF = 2,
};

pub const VERTEX_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT,
    StrideInBytes: UINT,
};

pub const INDEX_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT,
    Format: dxgi.FORMAT,
};

pub const STREAM_OUTPUT_BUFFER_VIEW = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT64,
    BufferFilledSizeLocation: GPU_VIRTUAL_ADDRESS,
};

pub const CLEAR_FLAGS = packed struct(UINT) {
    DEPTH: bool = false,
    STENCIL: bool = false,
    __unused: u30 = 0,
};

pub const DISCARD_REGION = extern struct {
    NumRects: UINT,
    pRects: *const RECT,
    FirstSubresource: UINT,
    NumSubresources: UINT,
};

pub const QUERY_HEAP_TYPE = enum(UINT) {
    OCCLUSION = 0,
    TIMESTAMP = 1,
    PIPELINE_STATISTICS = 2,
    SO_STATISTICS = 3,
};

pub const QUERY_HEAP_DESC = extern struct {
    Type: QUERY_HEAP_TYPE,
    Count: UINT,
    NodeMask: UINT,
};

pub const QUERY_TYPE = enum(UINT) {
    OCCLUSION = 0,
    BINARY_OCCLUSION = 1,
    TIMESTAMP = 2,
    PIPELINE_STATISTICS = 3,
    SO_STATISTICS_STREAM0 = 4,
    SO_STATISTICS_STREAM1 = 5,
    SO_STATISTICS_STREAM2 = 6,
    SO_STATISTICS_STREAM3 = 7,
    VIDEO_DECODE_STATISTICS = 8,
    PIPELINE_STATISTICS1 = 10,
};

pub const PREDICATION_OP = enum(UINT) {
    EQUAL_ZERO = 0,
    NOT_EQUAL_ZERO = 1,
};

pub const INDIRECT_ARGUMENT_TYPE = enum(UINT) {
    DRAW = 0,
    DRAW_INDEXED = 1,
    DISPATCH = 2,
    VERTEX_BUFFER_VIEW = 3,
    INDEX_BUFFER_VIEW = 4,
    CONSTANT = 5,
    CONSTANT_BUFFER_VIEW = 6,
    SHADER_RESOURCE_VIEW = 7,
    UNORDERED_ACCESS_VIEW = 8,
    DISPATCH_RAYS = 9,
    DISPATCH_MESH = 10,
};

pub const INDIRECT_ARGUMENT_DESC = extern struct {
    Type: INDIRECT_ARGUMENT_TYPE,
    u: extern union {
        VertexBuffer: extern struct {
            Slot: UINT,
        },
        Constant: extern struct {
            RootParameterIndex: UINT,
            DestOffsetIn32BitValues: UINT,
            Num32BitValuesToSet: UINT,
        },
        ConstantBufferView: extern struct {
            RootParameterIndex: UINT,
        },
        ShaderResourceView: extern struct {
            RootParameterIndex: UINT,
        },
        UnorderedAccessView: extern struct {
            RootParameterIndex: UINT,
        },
    },
};

pub const COMMAND_SIGNATURE_DESC = extern struct {
    ByteStride: UINT,
    NumArgumentDescs: UINT,
    pArgumentDescs: *const INDIRECT_ARGUMENT_DESC,
    NodeMask: UINT,
};

pub const PACKED_MIP_INFO = extern struct {
    NumStandardMips: UINT8,
    NumPackedMips: UINT8,
    NumTilesForPackedMips: UINT,
    StartTileIndexInOverallResource: UINT,
};

pub const COMMAND_QUEUE_FLAGS = packed struct(UINT) {
    DISABLE_GPU_TIMEOUT: bool = false,
    __unused: u31 = 0,
};

pub const COMMAND_QUEUE_PRIORITY = enum(UINT) {
    NORMAL = 0,
    HIGH = 100,
    GLOBAL_REALTIME = 10000,
};

pub const COMMAND_QUEUE_DESC = extern struct {
    Type: COMMAND_LIST_TYPE,
    Priority: INT,
    Flags: COMMAND_QUEUE_FLAGS,
    NodeMask: UINT,
};

pub const SHADER_BYTECODE = extern struct {
    pShaderBytecode: ?*const anyopaque,
    BytecodeLength: UINT64,

    pub inline fn init_zero() SHADER_BYTECODE {
        return std.mem.zeroes(@This());
    }
};

pub const SO_DECLARATION_ENTRY = extern struct {
    Stream: UINT,
    SemanticName: LPCSTR,
    SemanticIndex: UINT,
    StartComponent: UINT8,
    ComponentCount: UINT8,
    OutputSlot: UINT8,
};

pub const STREAM_OUTPUT_DESC = extern struct {
    pSODeclaration: ?[*]const SO_DECLARATION_ENTRY,
    NumEntries: UINT,
    pBufferStrides: ?[*]const UINT,
    NumStrides: UINT,
    RasterizedStream: UINT,

    pub inline fn init_zero() STREAM_OUTPUT_DESC {
        return std.mem.zeroes(@This());
    }
};

pub const BLEND = enum(UINT) {
    ZERO = 1,
    ONE = 2,
    SRC_COLOR = 3,
    INV_SRC_COLOR = 4,
    SRC_ALPHA = 5,
    INV_SRC_ALPHA = 6,
    DEST_ALPHA = 7,
    INV_DEST_ALPHA = 8,
    DEST_COLOR = 9,
    INV_DEST_COLOR = 10,
    SRC_ALPHA_SAT = 11,
    BLEND_FACTOR = 14,
    INV_BLEND_FACTOR = 15,
    SRC1_COLOR = 16,
    INV_SRC1_COLOR = 17,
    SRC1_ALPHA = 18,
    INV_SRC1_ALPHA = 19,
};

pub const BLEND_OP = enum(UINT) {
    ADD = 1,
    SUBTRACT = 2,
    REV_SUBTRACT = 3,
    MIN = 4,
    MAX = 5,
};

pub const COLOR_WRITE_ENABLE = packed struct(UINT) {
    RED: bool = false,
    GREEN: bool = false,
    BLUE: bool = false,
    ALPHA: bool = false,
    __unused: u28 = 0,

    pub const ALL = COLOR_WRITE_ENABLE{ .RED = true, .GREEN = true, .BLUE = true, .ALPHA = true };
};

pub const LOGIC_OP = enum(UINT) {
    CLEAR = 0,
    SET = 1,
    COPY = 2,
    COPY_INVERTED = 3,
    NOOP = 4,
    INVERT = 5,
    AND = 6,
    NAND = 7,
    OR = 8,
    NOR = 9,
    XOR = 10,
    EQUIV = 11,
    AND_REVERSE = 12,
    AND_INVERTED = 13,
    OR_REVERSE = 14,
    OR_INVERTED = 15,
};

pub const RENDER_TARGET_BLEND_DESC = extern struct {
    BlendEnable: BOOL,
    LogicOpEnable: BOOL,
    SrcBlend: BLEND,
    DestBlend: BLEND,
    BlendOp: BLEND_OP,
    SrcBlendAlpha: BLEND,
    DestBlendAlpha: BLEND,
    BlendOpAlpha: BLEND_OP,
    LogicOp: LOGIC_OP,
    RenderTargetWriteMask: UINT8,

    pub fn init_default() RENDER_TARGET_BLEND_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .BlendEnable = FALSE,
            .LogicOpEnable = FALSE,
            .SrcBlend = .ONE,
            .DestBlend = .ZERO,
            .BlendOp = .ADD,
            .SrcBlendAlpha = .ONE,
            .DestBlendAlpha = .ZERO,
            .BlendOpAlpha = .ADD,
            .LogicOp = .NOOP,
            .RenderTargetWriteMask = 0x0,
        };
        return v;
    }
};

pub const BLEND_DESC = extern struct {
    AlphaToCoverageEnable: BOOL,
    IndependentBlendEnable: BOOL,
    RenderTarget: [8]RENDER_TARGET_BLEND_DESC,

    pub fn init_default() BLEND_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .AlphaToCoverageEnable = FALSE,
            .IndependentBlendEnable = FALSE,
            .RenderTarget = [_]RENDER_TARGET_BLEND_DESC{RENDER_TARGET_BLEND_DESC.init_default()} ** 8,
        };
        return v;
    }
};

pub const RASTERIZER_DESC = extern struct {
    FillMode: FILL_MODE,
    CullMode: CULL_MODE,
    FrontCounterClockwise: BOOL,
    DepthBias: INT,
    DepthBiasClamp: FLOAT,
    SlopeScaledDepthBias: FLOAT,
    DepthClipEnable: BOOL,
    MultisampleEnable: BOOL,
    AntialiasedLineEnable: BOOL,
    ForcedSampleCount: UINT,
    ConservativeRaster: CONSERVATIVE_RASTERIZATION_MODE,

    pub fn init_default() RASTERIZER_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .FillMode = .SOLID,
            .CullMode = .BACK,
            .FrontCounterClockwise = FALSE,
            .DepthBias = 0,
            .DepthBiasClamp = 0.0,
            .SlopeScaledDepthBias = 0.0,
            .DepthClipEnable = TRUE,
            .MultisampleEnable = FALSE,
            .AntialiasedLineEnable = FALSE,
            .ForcedSampleCount = 0,
            .ConservativeRaster = .OFF,
        };
        return v;
    }
};

pub const FILL_MODE = enum(UINT) {
    WIREFRAME = 2,
    SOLID = 3,
};

pub const CULL_MODE = enum(UINT) {
    NONE = 1,
    FRONT = 2,
    BACK = 3,
};

pub const CONSERVATIVE_RASTERIZATION_MODE = enum(UINT) {
    OFF = 0,
    ON = 1,
};

pub const COMPARISON_FUNC = enum(UINT) {
    NEVER = 1,
    LESS = 2,
    EQUAL = 3,
    LESS_EQUAL = 4,
    GREATER = 5,
    NOT_EQUAL = 6,
    GREATER_EQUAL = 7,
    ALWAYS = 8,
};

pub const DEPTH_WRITE_MASK = enum(UINT) {
    ZERO = 0,
    ALL = 1,
};

pub const STENCIL_OP = enum(UINT) {
    KEEP = 1,
    ZERO = 2,
    REPLACE = 3,
    INCR_SAT = 4,
    DECR_SAT = 5,
    INVERT = 6,
    INCR = 7,
    DECR = 8,
};

pub const DEPTH_STENCILOP_DESC = extern struct {
    StencilFailOp: STENCIL_OP,
    StencilDepthFailOp: STENCIL_OP,
    StencilPassOp: STENCIL_OP,
    StencilFunc: COMPARISON_FUNC,

    pub fn init_default() DEPTH_STENCILOP_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .StencilFailOp = .KEEP,
            .StencilDepthFailOp = .KEEP,
            .StencilPassOp = .KEEP,
            .StencilFunc = .ALWAYS,
        };
        return v;
    }
};

pub const DEPTH_STENCIL_DESC = extern struct {
    DepthEnable: BOOL,
    DepthWriteMask: DEPTH_WRITE_MASK,
    DepthFunc: COMPARISON_FUNC,
    StencilEnable: BOOL,
    StencilReadMask: UINT8,
    StencilWriteMask: UINT8,
    FrontFace: DEPTH_STENCILOP_DESC,
    BackFace: DEPTH_STENCILOP_DESC,

    pub fn init_default() DEPTH_STENCIL_DESC {
        var desc = std.mem.zeroes(@This());
        desc = .{
            .DepthEnable = TRUE,
            .DepthWriteMask = .ALL,
            .DepthFunc = .LESS,
            .StencilEnable = FALSE,
            .StencilReadMask = 0xff,
            .StencilWriteMask = 0xff,
            .FrontFace = DEPTH_STENCILOP_DESC.init_default(),
            .BackFace = DEPTH_STENCILOP_DESC.init_default(),
        };
        return desc;
    }
};

pub const DEPTH_STENCIL_DESC1 = extern struct {
    DepthEnable: BOOL,
    DepthWriteMask: DEPTH_WRITE_MASK,
    DepthFunc: COMPARISON_FUNC,
    StencilEnable: BOOL,
    StencilReadMask: UINT8,
    StencilWriteMask: UINT8,
    FrontFace: DEPTH_STENCILOP_DESC,
    BackFace: DEPTH_STENCILOP_DESC,
    DepthBoundsTestEnable: BOOL,

    pub fn init_default() DEPTH_STENCIL_DESC1 {
        var desc = std.mem.zeroes(@This());
        desc = .{
            .DepthEnable = TRUE,
            .DepthWriteMask = .ALL,
            .DepthFunc = .LESS,
            .StencilEnable = FALSE,
            .StencilReadMask = 0xff,
            .StencilWriteMask = 0xff,
            .FrontFace = DEPTH_STENCILOP_DESC.init_default(),
            .BackFace = DEPTH_STENCILOP_DESC.init_default(),
            .DepthBoundsTestEnable = FALSE,
        };
        return desc;
    }
};

pub const INPUT_LAYOUT_DESC = extern struct {
    pInputElementDescs: ?[*]const INPUT_ELEMENT_DESC,
    NumElements: UINT,

    pub inline fn init_zero() INPUT_LAYOUT_DESC {
        return std.mem.zeroes(@This());
    }
};

pub const INPUT_CLASSIFICATION = enum(UINT) {
    PER_VERTEX_DATA = 0,
    PER_INSTANCE_DATA = 1,
};

pub const INPUT_ELEMENT_DESC = extern struct {
    SemanticName: LPCSTR,
    SemanticIndex: UINT,
    Format: dxgi.FORMAT,
    InputSlot: UINT,
    AlignedByteOffset: UINT,
    InputSlotClass: INPUT_CLASSIFICATION,
    InstanceDataStepRate: UINT,

    pub inline fn init(
        semanticName: LPCSTR,
        semanticIndex: UINT,
        format: dxgi.FORMAT,
        inputSlot: UINT,
        alignedByteOffset: UINT,
        inputSlotClass: INPUT_CLASSIFICATION,
        instanceDataStepRate: UINT,
    ) INPUT_ELEMENT_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .SemanticName = semanticName,
            .SemanticIndex = semanticIndex,
            .Format = format,
            .InputSlot = inputSlot,
            .AlignedByteOffset = alignedByteOffset,
            .InputSlotClass = inputSlotClass,
            .InstanceDataStepRate = instanceDataStepRate,
        };
        return v;
    }
};

pub const CACHED_PIPELINE_STATE = extern struct {
    pCachedBlob: ?*const anyopaque,
    CachedBlobSizeInBytes: UINT64,

    pub inline fn init_zero() CACHED_PIPELINE_STATE {
        return std.mem.zeroes(@This());
    }
};

pub const PIPELINE_STATE_FLAGS = packed struct(UINT) {
    TOOL_DEBUG: bool = false,
    __unused1: bool = false,
    DYNAMIC_DEPTH_BIAS: bool = false,
    DYNAMIC_INDEX_BUFFER_STRIP_CUT: bool = false,
    __unused: u28 = 0,
};

pub const GRAPHICS_PIPELINE_STATE_DESC = extern struct {
    pRootSignature: ?*IRootSignature,
    VS: SHADER_BYTECODE,
    PS: SHADER_BYTECODE,
    DS: SHADER_BYTECODE,
    HS: SHADER_BYTECODE,
    GS: SHADER_BYTECODE,
    StreamOutput: STREAM_OUTPUT_DESC,
    BlendState: BLEND_DESC,
    SampleMask: UINT,
    RasterizerState: RASTERIZER_DESC,
    DepthStencilState: DEPTH_STENCIL_DESC,
    InputLayout: INPUT_LAYOUT_DESC,
    IBStripCutValue: INDEX_BUFFER_STRIP_CUT_VALUE,
    PrimitiveTopologyType: PRIMITIVE_TOPOLOGY_TYPE,
    NumRenderTargets: UINT,
    RTVFormats: [8]dxgi.FORMAT,
    DSVFormat: dxgi.FORMAT,
    SampleDesc: dxgi.SAMPLE_DESC,
    NodeMask: UINT,
    CachedPSO: CACHED_PIPELINE_STATE,
    Flags: PIPELINE_STATE_FLAGS,

    pub fn init_default() GRAPHICS_PIPELINE_STATE_DESC {
        var v = std.mem.zeroes(@This());
        v = GRAPHICS_PIPELINE_STATE_DESC{
            .pRootSignature = null,
            .VS = SHADER_BYTECODE.init_zero(),
            .PS = SHADER_BYTECODE.init_zero(),
            .DS = SHADER_BYTECODE.init_zero(),
            .HS = SHADER_BYTECODE.init_zero(),
            .GS = SHADER_BYTECODE.init_zero(),
            .StreamOutput = STREAM_OUTPUT_DESC.init_zero(),
            .BlendState = BLEND_DESC.init_default(),
            .SampleMask = 0xffff_ffff,
            .RasterizerState = RASTERIZER_DESC.init_default(),
            .DepthStencilState = DEPTH_STENCIL_DESC.init_default(),
            .InputLayout = INPUT_LAYOUT_DESC.init_zero(),
            .IBStripCutValue = .DISABLED,
            .PrimitiveTopologyType = .UNDEFINED,
            .NumRenderTargets = 0,
            .RTVFormats = [_]dxgi.FORMAT{.UNKNOWN} ** 8,
            .DSVFormat = .UNKNOWN,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .NodeMask = 0,
            .CachedPSO = CACHED_PIPELINE_STATE.init_zero(),
            .Flags = .{},
        };
        return v;
    }
};

pub const COMPUTE_PIPELINE_STATE_DESC = extern struct {
    pRootSignature: ?*IRootSignature,
    CS: SHADER_BYTECODE,
    NodeMask: UINT,
    CachedPSO: CACHED_PIPELINE_STATE,
    Flags: PIPELINE_STATE_FLAGS,

    pub fn init_default() COMPUTE_PIPELINE_STATE_DESC {
        var v = std.mem.zeroes(@This());
        v = COMPUTE_PIPELINE_STATE_DESC{
            .pRootSignature = null,
            .CS = SHADER_BYTECODE.init_zero(),
            .NodeMask = 0,
            .CachedPSO = CACHED_PIPELINE_STATE.init_zero(),
            .Flags = .{},
        };
        return v;
    }
};

pub const FEATURE = enum(UINT) {
    OPTIONS = 0,
    ARCHITECTURE = 1,
    FEATURE_LEVELS = 2,
    FORMAT_SUPPORT = 3,
    MULTISAMPLE_QUALITY_LEVELS = 4,
    FORMAT_INFO = 5,
    GPU_VIRTUAL_ADDRESS_SUPPORT = 6,
    SHADER_MODEL = 7,
    OPTIONS1 = 8,
    PROTECTED_RESOURCE_SESSION_SUPPORT = 10,
    ROOT_SIGNATURE = 12,
    ARCHITECTURE1 = 16,
    OPTIONS2 = 18,
    SHADER_CACHE = 19,
    COMMAND_QUEUE_PRIORITY = 20,
    OPTIONS3 = 21,
    EXISTING_HEAPS = 22,
    OPTIONS4 = 23,
    SERIALIZATION = 24,
    CROSS_NODE = 25,
    OPTIONS5 = 27,
    DISPLAYABLE = 28,
    OPTIONS6 = 30,
    QUERY_META_COMMAND = 31,
    OPTIONS7 = 32,
    PROTECTED_RESOURCE_SESSION_TYPE_COUNT = 33,
    PROTECTED_RESOURCE_SESSION_TYPES = 34,
    OPTIONS8 = 36,
    OPTIONS9 = 37,
    OPTIONS10 = 39,
    OPTIONS11 = 40,
    OPTIONS12 = 41,
};

pub const SHADER_MODEL = enum(UINT) {
    @"5_1" = 0x51,
    @"6_0" = 0x60,
    @"6_1" = 0x61,
    @"6_2" = 0x62,
    @"6_3" = 0x63,
    @"6_4" = 0x64,
    @"6_5" = 0x65,
    @"6_6" = 0x66,
    @"6_7" = 0x67,
    @"6_8" = 0x68,
    pub const HIGHEST = .@"6_8";
};

pub const RESOURCE_BINDING_TIER = enum(UINT) {
    TIER_1 = 1,
    TIER_2 = 2,
    TIER_3 = 3,
};

pub const RESOURCE_HEAP_TIER = enum(UINT) {
    TIER_1 = 1,
    TIER_2 = 2,
};

pub const SHADER_MIN_PRECISION_SUPPORT = packed struct(UINT) {
    @"10_BIT": bool = false,
    @"16_BIT": bool = false,
    __unused: u30 = 0,
};

pub const TILED_RESOURCES_TIER = enum(UINT) {
    NOT_SUPPORTED = 0,
    TIER_1 = 1,
    TIER_2 = 2,
    TIER_3 = 3,
    TIER_4 = 4,
};

pub const CONSERVATIVE_RASTERIZATION_TIER = enum(UINT) {
    NOT_SUPPORTED = 0,
    TIER_1 = 1,
    TIER_2 = 2,
    TIER_3 = 3,
};

pub const CROSS_NODE_SHARING_TIER = enum(UINT) {
    NOT_SUPPORTED = 0,
    TIER_1_EMULATED = 1,
    TIER_1 = 2,
    TIER_2 = 3,
    TIER_3 = 4,
};

pub const FEATURE_DATA_D3D12_OPTIONS = extern struct {
    DoublePrecisionFloatShaderOps: BOOL,
    OutputMergerLogicOp: BOOL,
    MinPrecisionSupport: SHADER_MIN_PRECISION_SUPPORT,
    TiledResourcesTier: TILED_RESOURCES_TIER,
    ResourceBindingTier: RESOURCE_BINDING_TIER,
    PSSpecifiedStencilRefSupported: BOOL,
    TypedUAVLoadAdditionalFormats: BOOL,
    ROVsSupported: BOOL,
    ConservativeRasterizationTier: CONSERVATIVE_RASTERIZATION_TIER,
    MaxGPUVirtualAddressBitsPerResource: UINT,
    StandardSwizzle64KBSupported: BOOL,
    CrossNodeSharingTier: CROSS_NODE_SHARING_TIER,
    CrossAdapterRowMajorTextureSupported: BOOL,
    VPAndRTArrayIndexFromAnyShaderFeedingRasterizerSupportedWithoutGSEmulation: BOOL,
    ResourceHeapTier: RESOURCE_HEAP_TIER,
};

pub const FEATURE_DATA_SHADER_MODEL = extern struct {
    HighestShaderModel: SHADER_MODEL,
};

pub const FEATURE_DATA_FORMAT_INFO = extern struct {
    Format: dxgi.FORMAT,
    PlaneCount: u8,
};

pub const RENDER_PASS_TIER = enum(UINT) {
    TIER_0 = 0,
    TIER_1 = 1,
    TIER_2 = 2,
};

pub const RAYTRACING_TIER = enum(UINT) {
    NOT_SUPPORTED = 0,
    TIER_1_0 = 10,
    TIER_1_1 = 11,
};

pub const MESH_SHADER_TIER = enum(UINT) {
    NOT_SUPPORTED = 0,
    TIER_1 = 10,
};

pub const SAMPLER_FEEDBACK_TIER = enum(UINT) {
    NOT_SUPPORTED = 0,
    TIER_0_9 = 90,
    TIER_1_0 = 100,
};

pub const FEATURE_DATA_D3D12_OPTIONS7 = extern struct {
    MeshShaderTier: MESH_SHADER_TIER,
    SamplerFeedbackTier: SAMPLER_FEEDBACK_TIER,
};

pub const COMMAND_LIST_SUPPORT_FLAGS = packed struct(UINT) {
    DIRECT: bool = false,
    BUNDLE: bool = false,
    COMPUTE: bool = false,
    COPY: bool = false,
    VIDEO_DECODE: bool = false,
    VIDEO_PROCESS: bool = false,
    VIDEO_ENCODE: bool = false,
    __unused: u25 = 0,
};

pub const VIEW_INSTANCING_TIER = enum(UINT) {
    NOT_SUPPORTED = 0,
    TIER_1 = 1,
    TIER_2 = 2,
    TIER_3 = 3,
};

pub const TRI_STATE = enum(INT) {
    UNKNOWN = -1,
    FALSE = 0,
    TRUE = 1,
};

pub const FEATURE_DATA_D3D12_OPTIONS3 = extern struct {
    CopyQueueTimestampQueriesSupported: BOOL,
    CastingFullyTypedFormatSupported: BOOL,
    WriteBufferImmediateSupportFlags: COMMAND_LIST_SUPPORT_FLAGS,
    ViewInstancingTier: VIEW_INSTANCING_TIER,
    BarycentricsSupported: BOOL,
};

pub const FEATURE_DATA_D3D12_OPTIONS5 = extern struct {
    SRVOnlyTiledResourceTier3: BOOL,
    RenderPassesTier: RENDER_PASS_TIER,
    RaytracingTier: RAYTRACING_TIER,
};

pub const FEATURE_DATA_D3D12_OPTIONS12 = extern struct {
    MSPrimitivesPipelineStatisticIncludesCulledPrimitives: TRI_STATE,
    EnhancedBarriersSupported: BOOL,
    RelaxedFormatCastingSupported: BOOL,
};

pub const CONSTANT_BUFFER_VIEW_DESC = extern struct {
    BufferLocation: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT,
};

pub inline fn encodeShader4ComponentMapping(src0: UINT, src1: UINT, src2: UINT, src3: UINT) UINT {
    return (src0 & 0x7) | ((src1 & 0x7) << 3) | ((src2 & 0x7) << (3 * 2)) | ((src3 & 0x7) << (3 * 3)) |
        (1 << (3 * 4));
}
pub const DEFAULT_SHADER_4_COMPONENT_MAPPING = encodeShader4ComponentMapping(0, 1, 2, 3);

pub const BUFFER_SRV_FLAGS = packed struct(UINT) {
    RAW: bool = false,
    __unused: u31 = 0,
};

pub const BUFFER_SRV = extern struct {
    FirstElement: UINT64,
    NumElements: UINT,
    StructureByteStride: UINT,
    Flags: BUFFER_SRV_FLAGS,
};

pub const TEX1D_SRV = extern struct {
    MostDetailedMip: UINT,
    MipLevels: UINT,
    ResourceMinLODClamp: FLOAT,
};

pub const TEX1D_ARRAY_SRV = extern struct {
    MostDetailedMip: UINT,
    MipLevels: UINT,
    FirstArraySlice: UINT,
    ArraySize: UINT,
    ResourceMinLODClamp: FLOAT,
};

pub const TEX2D_SRV = extern struct {
    MostDetailedMip: UINT,
    MipLevels: UINT,
    PlaneSlice: UINT,
    ResourceMinLODClamp: FLOAT,
};

pub const TEX2D_ARRAY_SRV = extern struct {
    MostDetailedMip: UINT,
    MipLevels: UINT,
    FirstArraySlice: UINT,
    ArraySize: UINT,
    PlaneSlice: UINT,
    ResourceMinLODClamp: FLOAT,
};

pub const TEX3D_SRV = extern struct {
    MostDetailedMip: UINT,
    MipLevels: UINT,
    ResourceMinLODClamp: FLOAT,
};

pub const TEXCUBE_SRV = extern struct {
    MostDetailedMip: UINT,
    MipLevels: UINT,
    ResourceMinLODClamp: FLOAT,
};

pub const TEXCUBE_ARRAY_SRV = extern struct {
    MostDetailedMip: UINT,
    MipLevels: UINT,
    First2DArrayFace: UINT,
    NumCubes: UINT,
    ResourceMinLODClamp: FLOAT,
};

pub const TEX2DMS_SRV = extern struct {
    UnusedField_NothingToDefine: UINT,
};

pub const TEX2DMS_ARRAY_SRV = extern struct {
    FirstArraySlice: UINT,
    ArraySize: UINT,
};

pub const SRV_DIMENSION = enum(UINT) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE2DMS = 6,
    TEXTURE2DMSARRAY = 7,
    TEXTURE3D = 8,
    TEXTURECUBE = 9,
    TEXTURECUBEARRAY = 10,
};

pub const SHADER_RESOURCE_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT,
    ViewDimension: SRV_DIMENSION,
    Shader4ComponentMapping: UINT,
    u: extern union {
        Buffer: BUFFER_SRV,
        Texture1D: TEX1D_SRV,
        Texture1DArray: TEX1D_ARRAY_SRV,
        Texture2D: TEX2D_SRV,
        Texture2DArray: TEX2D_ARRAY_SRV,
        Texture2DMS: TEX2DMS_SRV,
        Texture2DMSArray: TEX2DMS_ARRAY_SRV,
        Texture3D: TEX3D_SRV,
        TextureCube: TEXCUBE_SRV,
        TextureCubeArray: TEXCUBE_ARRAY_SRV,
    },

    pub fn init_typed_buffer(
        format: dxgi.FORMAT,
        first_element: UINT64,
        num_elements: UINT,
    ) SHADER_RESOURCE_VIEW_DESC {
        var desc = std.mem.zeroes(@This());
        desc = .{
            .Format = format,
            .ViewDimension = .BUFFER,
            .Shader4ComponentMapping = DEFAULT_SHADER_4_COMPONENT_MAPPING,
            .u = .{
                .Buffer = .{
                    .FirstElement = first_element,
                    .NumElements = num_elements,
                    .StructureByteStride = 0,
                    .Flags = .{},
                },
            },
        };
        return desc;
    }

    pub fn init_structured_buffer(
        first_element: UINT64,
        num_elements: UINT,
        stride: UINT,
    ) SHADER_RESOURCE_VIEW_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .Format = .UNKNOWN,
            .ViewDimension = .BUFFER,
            .Shader4ComponentMapping = DEFAULT_SHADER_4_COMPONENT_MAPPING,
            .u = .{
                .Buffer = .{
                    .FirstElement = first_element,
                    .NumElements = num_elements,
                    .StructureByteStride = stride,
                    .Flags = .{},
                },
            },
        };
        return v;
    }
};

pub const FILTER = enum(UINT) {
    MIN_MAG_MIP_POINT = 0,
    MIN_MAG_POINT_MIP_LINEAR = 0x1,
    MIN_POINT_MAG_LINEAR_MIP_POINT = 0x4,
    MIN_POINT_MAG_MIP_LINEAR = 0x5,
    MIN_LINEAR_MAG_MIP_POINT = 0x10,
    MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x11,
    MIN_MAG_LINEAR_MIP_POINT = 0x14,
    MIN_MAG_MIP_LINEAR = 0x15,
    ANISOTROPIC = 0x55,
    COMPARISON_MIN_MAG_MIP_POINT = 0x80,
    COMPARISON_MIN_MAG_POINT_MIP_LINEAR = 0x81,
    COMPARISON_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x84,
    COMPARISON_MIN_POINT_MAG_MIP_LINEAR = 0x85,
    COMPARISON_MIN_LINEAR_MAG_MIP_POINT = 0x90,
    COMPARISON_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x91,
    COMPARISON_MIN_MAG_LINEAR_MIP_POINT = 0x94,
    COMPARISON_MIN_MAG_MIP_LINEAR = 0x95,
    COMPARISON_ANISOTROPIC = 0xd5,
    MINIMUM_MIN_MAG_MIP_POINT = 0x100,
    MINIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x101,
    MINIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x104,
    MINIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x105,
    MINIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x110,
    MINIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x111,
    MINIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x114,
    MINIMUM_MIN_MAG_MIP_LINEAR = 0x115,
    MINIMUM_ANISOTROPIC = 0x155,
    MAXIMUM_MIN_MAG_MIP_POINT = 0x180,
    MAXIMUM_MIN_MAG_POINT_MIP_LINEAR = 0x181,
    MAXIMUM_MIN_POINT_MAG_LINEAR_MIP_POINT = 0x184,
    MAXIMUM_MIN_POINT_MAG_MIP_LINEAR = 0x185,
    MAXIMUM_MIN_LINEAR_MAG_MIP_POINT = 0x190,
    MAXIMUM_MIN_LINEAR_MAG_POINT_MIP_LINEAR = 0x191,
    MAXIMUM_MIN_MAG_LINEAR_MIP_POINT = 0x194,
    MAXIMUM_MIN_MAG_MIP_LINEAR = 0x195,
    MAXIMUM_ANISOTROPIC = 0x1d5,
};

pub const FILTER_TYPE = enum(UINT) {
    POINT = 0,
    LINEAR = 1,
};

pub const FILTER_REDUCTION_TYPE = enum(UINT) {
    STANDARD = 0,
    COMPARISON = 1,
    MINIMUM = 2,
    MAXIMUM = 3,
};

pub const TEXTURE_ADDRESS_MODE = enum(UINT) {
    WRAP = 1,
    MIRROR = 2,
    CLAMP = 3,
    BORDER = 4,
    MIRROR_ONCE = 5,
};

pub const SAMPLER_DESC = extern struct {
    Filter: FILTER,
    AddressU: TEXTURE_ADDRESS_MODE,
    AddressV: TEXTURE_ADDRESS_MODE,
    AddressW: TEXTURE_ADDRESS_MODE,
    MipLODBias: FLOAT,
    MaxAnisotropy: UINT,
    ComparisonFunc: COMPARISON_FUNC,
    BorderColor: [4]FLOAT,
    MinLOD: FLOAT,
    MaxLOD: FLOAT,
};

pub const BUFFER_UAV_FLAGS = packed struct(UINT) {
    RAW: bool = false,
    __unused: u31 = 0,
};

pub const BUFFER_UAV = extern struct {
    FirstElement: UINT64,
    NumElements: UINT,
    StructureByteStride: UINT,
    CounterOffsetInBytes: UINT64,
    Flags: BUFFER_UAV_FLAGS,
};

pub const TEX1D_UAV = extern struct {
    MipSlice: UINT,
};

pub const TEX1D_ARRAY_UAV = extern struct {
    MipSlice: UINT,
    FirstArraySlice: UINT,
    ArraySize: UINT,
};

pub const TEX2D_UAV = extern struct {
    MipSlice: UINT,
    PlaneSlice: UINT,
};

pub const TEX2D_ARRAY_UAV = extern struct {
    MipSlice: UINT,
    FirstArraySlice: UINT,
    ArraySize: UINT,
    PlaneSlice: UINT,
};

pub const TEX3D_UAV = extern struct {
    MipSlice: UINT,
    FirstWSlice: UINT,
    WSize: UINT,
};

pub const UAV_DIMENSION = enum(UINT) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE3D = 8,
};

pub const UNORDERED_ACCESS_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT,
    ViewDimension: UAV_DIMENSION,
    u: extern union {
        Buffer: BUFFER_UAV,
        Texture1D: TEX1D_UAV,
        Texture1DArray: TEX1D_ARRAY_UAV,
        Texture2D: TEX2D_UAV,
        Texture2DArray: TEX2D_ARRAY_UAV,
        Texture3D: TEX3D_UAV,
    },

    pub fn init_typed_buffer(
        format: dxgi.FORMAT,
        first_element: UINT64,
        num_elements: UINT,
        counter_offset: UINT64,
    ) UNORDERED_ACCESS_VIEW_DESC {
        var desc = std.mem.zeroes(@This());
        desc = .{
            .Format = format,
            .ViewDimension = .BUFFER,
            .u = .{
                .Buffer = .{
                    .FirstElement = first_element,
                    .NumElements = num_elements,
                    .StructureByteStride = 0,
                    .CounterOffsetInBytes = counter_offset,
                    .Flags = .{},
                },
            },
        };
        return desc;
    }

    pub fn init_structured_buffer(
        first_element: UINT64,
        num_elements: UINT,
        stride: UINT,
        counter_offset: UINT64,
    ) UNORDERED_ACCESS_VIEW_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .Format = .UNKNOWN,
            .ViewDimension = .BUFFER,
            .u = .{
                .Buffer = .{
                    .FirstElement = first_element,
                    .NumElements = num_elements,
                    .StructureByteStride = stride,
                    .CounterOffsetInBytes = counter_offset,
                    .Flags = .{},
                },
            },
        };
        return v;
    }
};

pub const BUFFER_RTV = extern struct {
    FirstElement: UINT64,
    NumElements: UINT,
};

pub const TEX1D_RTV = extern struct {
    MipSlice: UINT,
};

pub const TEX1D_ARRAY_RTV = extern struct {
    MipSlice: UINT,
    FirstArraySlice: UINT,
    ArraySize: UINT,
};

pub const TEX2D_RTV = extern struct {
    MipSlice: UINT,
    PlaneSlice: UINT,
};

pub const TEX2DMS_RTV = extern struct {
    UnusedField_NothingToDefine: UINT,
};

pub const TEX2D_ARRAY_RTV = extern struct {
    MipSlice: UINT,
    FirstArraySlice: UINT,
    ArraySize: UINT,
    PlaneSlice: UINT,
};

pub const TEX2DMS_ARRAY_RTV = extern struct {
    FirstArraySlice: UINT,
    ArraySize: UINT,
};

pub const TEX3D_RTV = extern struct {
    MipSlice: UINT,
    FirstWSlice: UINT,
    WSize: UINT,
};

pub const RTV_DIMENSION = enum(UINT) {
    UNKNOWN = 0,
    BUFFER = 1,
    TEXTURE1D = 2,
    TEXTURE1DARRAY = 3,
    TEXTURE2D = 4,
    TEXTURE2DARRAY = 5,
    TEXTURE2DMS = 6,
    TEXTURE2DMSARRAY = 7,
    TEXTURE3D = 8,
};

pub const RENDER_TARGET_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT,
    ViewDimension: RTV_DIMENSION,
    u: extern union {
        Buffer: BUFFER_RTV,
        Texture1D: TEX1D_RTV,
        Texture1DArray: TEX1D_ARRAY_RTV,
        Texture2D: TEX2D_RTV,
        Texture2DArray: TEX2D_ARRAY_RTV,
        Texture2DMS: TEX2DMS_RTV,
        Texture2DMSArray: TEX2DMS_ARRAY_RTV,
        Texture3D: TEX3D_RTV,
    },
};

pub const TEX1D_DSV = extern struct {
    MipSlice: UINT,
};

pub const TEX1D_ARRAY_DSV = extern struct {
    MipSlice: UINT,
    FirstArraySlice: UINT,
    ArraySize: UINT,
};

pub const TEX2D_DSV = extern struct {
    MipSlice: UINT,
};

pub const TEX2D_ARRAY_DSV = extern struct {
    MipSlice: UINT,
    FirstArraySlice: UINT,
    ArraySize: UINT,
};

pub const TEX2DMS_DSV = extern struct {
    UnusedField_NothingToDefine: UINT,
};

pub const TEX2DMS_ARRAY_DSV = extern struct {
    FirstArraySlice: UINT,
    ArraySize: UINT,
};

pub const DSV_FLAGS = packed struct(UINT) {
    READ_ONLY_DEPTH: bool = false,
    READ_ONLY_STENCIL: bool = false,
    __unused: u30 = 0,
};

pub const DSV_DIMENSION = enum(UINT) {
    UNKNOWN = 0,
    TEXTURE1D = 1,
    TEXTURE1DARRAY = 2,
    TEXTURE2D = 3,
    TEXTURE2DARRAY = 4,
    TEXTURE2DMS = 5,
    TEXTURE2DMSARRAY = 6,
};

pub const DEPTH_STENCIL_VIEW_DESC = extern struct {
    Format: dxgi.FORMAT,
    ViewDimension: DSV_DIMENSION,
    Flags: DSV_FLAGS,
    u: extern union {
        Texture1D: TEX1D_DSV,
        Texture1DArray: TEX1D_ARRAY_DSV,
        Texture2D: TEX2D_DSV,
        Texture2DArray: TEX2D_ARRAY_DSV,
        Texture2DMS: TEX2DMS_DSV,
        Texture2DMSArray: TEX2DMS_ARRAY_DSV,
    },
};

pub const RESOURCE_ALLOCATION_INFO = extern struct {
    SizeInBytes: UINT64,
    Alignment: UINT64,
};

pub const DEPTH_STENCIL_VALUE = extern struct {
    Depth: FLOAT,
    Stencil: UINT8,
};

pub const CLEAR_VALUE = extern struct {
    Format: dxgi.FORMAT,
    u: extern union {
        Color: [4]FLOAT,
        DepthStencil: DEPTH_STENCIL_VALUE,
    },

    pub fn init_color(format: dxgi.FORMAT, in_color: *const [4]FLOAT) CLEAR_VALUE {
        var v = std.mem.zeroes(@This());
        v = .{
            .Format = format,
            .u = .{ .Color = in_color.* },
        };
        return v;
    }

    pub fn init_depth_stencil(format: dxgi.FORMAT, depth: FLOAT, stencil: UINT8) CLEAR_VALUE {
        var v = std.mem.zeroes(@This());
        v = .{
            .Format = format,
            .u = .{ .DepthStencil = .{ .Depth = depth, .Stencil = stencil } },
        };
        return v;
    }
};

pub const IObject = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetPrivateData(self: *T, guid: *const GUID, data_size: *UINT, data: ?*anyopaque) HRESULT {
                return @as(*const IObject.VTable, @ptrCast(self.__v))
                    .GetPrivateData(@ptrCast(self), guid, data_size, data);
            }
            pub inline fn SetPrivateData(
                self: *T,
                guid: *const GUID,
                data_size: UINT,
                data: ?*const anyopaque,
            ) HRESULT {
                return @as(*const IObject.VTable, @ptrCast(self.__v))
                    .SetPrivateData(@ptrCast(self), guid, data_size, data);
            }
            pub inline fn SetPrivateDataInterface(self: *T, guid: *const GUID, data: ?*const IUnknown) HRESULT {
                return @as(*const IObject.VTable, @ptrCast(self.__v))
                    .SetPrivateDataInterface(@ptrCast(self), guid, data);
            }
            pub inline fn SetName(self: *T, name: LPCWSTR) HRESULT {
                return @as(*const IObject.VTable, @ptrCast(self.__v)).SetName(@ptrCast(self), name);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        GetPrivateData: *const fn (*IObject, *const GUID, *UINT, ?*anyopaque) callconv(WINAPI) HRESULT,
        SetPrivateData: *const fn (*IObject, *const GUID, UINT, ?*const anyopaque) callconv(WINAPI) HRESULT,
        SetPrivateDataInterface: *const fn (*IObject, *const GUID, ?*const IUnknown) callconv(WINAPI) HRESULT,
        SetName: *const fn (*IObject, LPCWSTR) callconv(WINAPI) HRESULT,
    };
};

pub const IDeviceChild = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDevice(self: *T, guid: *const GUID, device: *?*anyopaque) HRESULT {
                return @as(*const IDeviceChild.VTable, @ptrCast(self.__v)).GetDevice(@ptrCast(self), guid, device);
            }
        };
    }

    pub const VTable = extern struct {
        base: IObject.VTable,
        GetDevice: *const fn (*IDeviceChild, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT,
    };
};

pub const IPageable = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const VTable = extern struct {
        base: IDeviceChild.VTable,
    };
};

pub const IRootSignature = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{c54a6b66-72df-4ee8-8be5-a946a1429214}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const VTable = extern struct {
        base: IDeviceChild.VTable,
    };
};

pub const IQueryHeap = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{0d9658ae-ed45-469e-a61d-970ec583cab4}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const VTable = extern struct {
        base: IPageable.VTable,
    };
};

pub const ICommandSignature = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const VTable = extern struct {
        base: IPageable.VTable,
    };
};

pub const IHeap = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{6b3b2502-6e51-45b3-90ee-9884265e8df3}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetDesc = IHeap.Methods(@This()).GetDesc;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc(self: *T) HEAP_DESC {
                var desc: HEAP_DESC = undefined;
                _ = @as(*const IHeap.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), &desc);
                return desc;
            }
        };
    }

    pub const VTable = extern struct {
        base: IPageable.VTable,
        GetDesc: *const fn (*IHeap, *HEAP_DESC) callconv(WINAPI) *HEAP_DESC,
    };
};

pub const IResource = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{696442be-a72e-4059-bc79-5b5c98040fad}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const Map = IResource.Methods(@This()).Map;
    pub const Unmap = IResource.Methods(@This()).Unmap;
    pub const GetDesc = IResource.Methods(@This()).GetDesc;
    pub const GetGPUVirtualAddress = IResource.Methods(@This()).GetGPUVirtualAddress;
    pub const WriteToSubresource = IResource.Methods(@This()).WriteToSubresource;
    pub const ReadFromSubresource = IResource.Methods(@This()).ReadFromSubresource;
    pub const GetHeapProperties = IResource.Methods(@This()).GetHeapProperties;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Map(self: *T, subresource: UINT, read_range: ?*const RANGE, data: *?*anyopaque) HRESULT {
                return @as(*const IResource.VTable, @ptrCast(self.__v))
                    .Map(@ptrCast(self), subresource, read_range, data);
            }
            pub inline fn Unmap(self: *T, subresource: UINT, written_range: ?*const RANGE) void {
                @as(*const IResource.VTable, @ptrCast(self.__v))
                    .Unmap(@ptrCast(self), subresource, written_range);
            }
            pub inline fn GetDesc(self: *T) RESOURCE_DESC {
                var desc: RESOURCE_DESC = undefined;
                _ = @as(*const IResource.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), &desc);
                return desc;
            }
            pub inline fn GetGPUVirtualAddress(self: *T) GPU_VIRTUAL_ADDRESS {
                return @as(*const IResource.VTable, @ptrCast(self.__v)).GetGPUVirtualAddress(@ptrCast(self));
            }
            pub inline fn WriteToSubresource(
                self: *T,
                dst_subresource: UINT,
                dst_box: ?*const BOX,
                src_data: *const anyopaque,
                src_row_pitch: UINT,
                src_depth_pitch: UINT,
            ) HRESULT {
                return @as(*const IResource.VTable, @ptrCast(self.__v)).WriteToSubresource(
                    @ptrCast(self),
                    dst_subresource,
                    dst_box,
                    src_data,
                    src_row_pitch,
                    src_depth_pitch,
                );
            }
            pub inline fn ReadFromSubresource(
                self: *T,
                dst_data: *anyopaque,
                dst_row_pitch: UINT,
                dst_depth_pitch: UINT,
                src_subresource: UINT,
                src_box: ?*const BOX,
            ) HRESULT {
                return @as(*const IResource.VTable, @ptrCast(self.__v)).ReadFromSubresource(
                    @ptrCast(self),
                    dst_data,
                    dst_row_pitch,
                    dst_depth_pitch,
                    src_subresource,
                    src_box,
                );
            }
            pub inline fn GetHeapProperties(
                self: *T,
                properties: ?*HEAP_PROPERTIES,
                flags: ?*HEAP_FLAGS,
            ) HRESULT {
                return @as(*const IResource.VTable, @ptrCast(self.__v))
                    .GetHeapProperties(@ptrCast(self), properties, flags);
            }
        };
    }

    pub const VTable = extern struct {
        base: IPageable.VTable,
        Map: *const fn (*IResource, UINT, ?*const RANGE, *?*anyopaque) callconv(WINAPI) HRESULT,
        Unmap: *const fn (*IResource, UINT, ?*const RANGE) callconv(WINAPI) void,
        GetDesc: *const fn (*IResource, *RESOURCE_DESC) callconv(WINAPI) *RESOURCE_DESC,
        GetGPUVirtualAddress: *const fn (*IResource) callconv(WINAPI) GPU_VIRTUAL_ADDRESS,
        WriteToSubresource: *const fn (
            *IResource,
            UINT,
            ?*const BOX,
            *const anyopaque,
            UINT,
            UINT,
        ) callconv(WINAPI) HRESULT,
        ReadFromSubresource: *const fn (
            *IResource,
            *anyopaque,
            UINT,
            UINT,
            UINT,
            ?*const BOX,
        ) callconv(WINAPI) HRESULT,
        GetHeapProperties: *const fn (*IResource, ?*HEAP_PROPERTIES, ?*HEAP_FLAGS) callconv(WINAPI) HRESULT,
    };
};

pub const IResource1 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const Map = IResource.Methods(@This()).Map;
    pub const Unmap = IResource.Methods(@This()).Unmap;
    pub const GetDesc = IResource.Methods(@This()).GetDesc;
    pub const GetGPUVirtualAddress = IResource.Methods(@This()).GetGPUVirtualAddress;
    pub const WriteToSubresource = IResource.Methods(@This()).WriteToSubresource;
    pub const ReadFromSubresource = IResource.Methods(@This()).ReadFromSubresource;
    pub const GetHeapProperties = IResource.Methods(@This()).GetHeapProperties;

    pub const GetProtectedResourceSession = IResource1.Methods(@This()).GetProtectedResourceSession;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetProtectedResourceSession(self: *T, guid: *const GUID, session: *?*anyopaque) HRESULT {
                return @as(*const IResource1.VTable, @ptrCast(self.__v))
                    .GetProtectedResourceSession(@ptrCast(self), guid, session);
            }
        };
    }

    pub const VTable = extern struct {
        base: IResource.VTable,
        GetProtectedResourceSession: *const fn (*IResource1, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT,
    };
};

pub const ICommandAllocator = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{6102dee4-af59-4b09-b999-b44d73f09b24}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const Reset = ICommandAllocator.Methods(@This()).Reset;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Reset(self: *T) HRESULT {
                return @as(*const ICommandAllocator.VTable, @ptrCast(self.__v)).Reset(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IPageable.VTable,
        Reset: *const fn (*ICommandAllocator) callconv(WINAPI) HRESULT,
    };
};

pub const IFence = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{0a753dcf-c4d8-4b91-adf6-be5a60d95a76}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetCompletedValue = IFence.Methods(@This()).GetCompletedValue;
    pub const SetEventOnCompletion = IFence.Methods(@This()).SetEventOnCompletion;
    pub const Signal = IFence.Methods(@This()).Signal;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetCompletedValue(self: *T) UINT64 {
                return @as(*const IFence.VTable, @ptrCast(self.__v)).GetCompletedValue(@ptrCast(self));
            }
            pub inline fn SetEventOnCompletion(self: *T, value: UINT64, event: HANDLE) HRESULT {
                return @as(*const IFence.VTable, @ptrCast(self.__v))
                    .SetEventOnCompletion(@ptrCast(self), value, event);
            }
            pub inline fn Signal(self: *T, value: UINT64) HRESULT {
                return @as(*const IFence.VTable, @ptrCast(self.__v)).Signal(@ptrCast(self), value);
            }
        };
    }

    pub const VTable = extern struct {
        base: IPageable.VTable,
        GetCompletedValue: *const fn (*IFence) callconv(WINAPI) UINT64,
        SetEventOnCompletion: *const fn (*IFence, UINT64, HANDLE) callconv(WINAPI) HRESULT,
        Signal: *const fn (*IFence, UINT64) callconv(WINAPI) HRESULT,
    };
};

pub const IFence1 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetCompletedValue = IFence.Methods(@This()).GetCompletedValue;
    pub const SetEventOnCompletion = IFence.Methods(@This()).SetEventOnCompletion;
    pub const Signal = IFence.Methods(@This()).Signal;

    pub const GetCreationFlags = IFence1.Methods(@This()).GetCreationFlags;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetCreationFlags(self: *T) FENCE_FLAGS {
                return @as(*const IFence1.VTable, @ptrCast(self.__v)).GetCreationFlags(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IFence.VTable,
        GetCreationFlags: *const fn (*IFence1) callconv(WINAPI) FENCE_FLAGS,
    };
};

pub const IPipelineState = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{765a30f3-f624-4c6f-a828-ace948622445}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetCachedBlob = IPipelineState.Methods(@This()).GetCachedBlob;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetCachedBlob(self: *T, blob: **d3d.IBlob) HRESULT {
                return @as(*const IPipelineState.VTable, @ptrCast(self.__v)).GetCachedBlob(@ptrCast(self), blob);
            }
        };
    }

    pub const VTable = extern struct {
        base: IPageable.VTable,
        GetCachedBlob: *const fn (*IPipelineState, **d3d.IBlob) callconv(WINAPI) HRESULT,
    };
};

pub const IDescriptorHeap = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{8efb471d-616c-4f49-90f7-127bb763fa51}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetDesc = IDescriptorHeap.Methods(@This()).GetDesc;
    pub const GetCPUDescriptorHandleForHeapStart = IDescriptorHeap.Methods(@This()).GetCPUDescriptorHandleForHeapStart;
    pub const GetGPUDescriptorHandleForHeapStart = IDescriptorHeap.Methods(@This()).GetGPUDescriptorHandleForHeapStart;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc(self: *T) DESCRIPTOR_HEAP_DESC {
                var desc: DESCRIPTOR_HEAP_DESC = undefined;
                _ = @as(*const IDescriptorHeap.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), &desc);
                return desc;
            }
            pub inline fn GetCPUDescriptorHandleForHeapStart(self: *T) CPU_DESCRIPTOR_HANDLE {
                var handle: CPU_DESCRIPTOR_HANDLE = undefined;
                _ = @as(*const IDescriptorHeap.VTable, @ptrCast(self.__v))
                    .GetCPUDescriptorHandleForHeapStart(@ptrCast(self), &handle);
                return handle;
            }
            pub inline fn GetGPUDescriptorHandleForHeapStart(self: *T) GPU_DESCRIPTOR_HANDLE {
                var handle: GPU_DESCRIPTOR_HANDLE = undefined;
                _ = @as(*const IDescriptorHeap.VTable, @ptrCast(self.__v))
                    .GetGPUDescriptorHandleForHeapStart(@ptrCast(self), &handle);
                return handle;
            }
        };
    }

    pub const VTable = extern struct {
        base: IPageable.VTable,
        GetDesc: *const fn (*IDescriptorHeap, *DESCRIPTOR_HEAP_DESC) callconv(WINAPI) *DESCRIPTOR_HEAP_DESC,
        GetCPUDescriptorHandleForHeapStart: *const fn (
            *IDescriptorHeap,
            *CPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) *CPU_DESCRIPTOR_HANDLE,
        GetGPUDescriptorHandleForHeapStart: *const fn (
            *IDescriptorHeap,
            *GPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) *GPU_DESCRIPTOR_HANDLE,
    };
};

pub const ICommandList = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetType(self: *T) COMMAND_LIST_TYPE {
                return @as(*const ICommandList.VTable, @ptrCast(self.__v)).GetType(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IDeviceChild.VTable,
        GetType: *const fn (*ICommandList) callconv(WINAPI) COMMAND_LIST_TYPE,
    };
};

pub const IGraphicsCommandList = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{5b160d0f-ac1b-4185-8ba8-b3ae42a5a455}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Close(self: *T) HRESULT {
                return @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).Close(@ptrCast(self));
            }
            pub inline fn Reset(self: *T, alloc: *ICommandAllocator, initial_state: ?*IPipelineState) HRESULT {
                return @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .Reset(@ptrCast(self), alloc, initial_state);
            }
            pub inline fn ClearState(self: *T, pso: ?*IPipelineState) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ClearState(@ptrCast(self), pso);
            }
            pub inline fn DrawInstanced(
                self: *T,
                vertex_count_per_instance: UINT,
                instance_count: UINT,
                start_vertex_location: UINT,
                start_instance_location: UINT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).DrawInstanced(
                    @ptrCast(self),
                    vertex_count_per_instance,
                    instance_count,
                    start_vertex_location,
                    start_instance_location,
                );
            }
            pub inline fn DrawIndexedInstanced(
                self: *T,
                index_count_per_instance: UINT,
                instance_count: UINT,
                start_index_location: UINT,
                base_vertex_location: INT,
                start_instance_location: UINT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).DrawIndexedInstanced(
                    @ptrCast(self),
                    index_count_per_instance,
                    instance_count,
                    start_index_location,
                    base_vertex_location,
                    start_instance_location,
                );
            }
            pub inline fn Dispatch(self: *T, count_x: UINT, count_y: UINT, count_z: UINT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .Dispatch(@ptrCast(self), count_x, count_y, count_z);
            }
            pub inline fn CopyBufferRegion(
                self: *T,
                dst_buffer: *IResource,
                dst_offset: UINT64,
                src_buffer: *IResource,
                src_offset: UINT64,
                num_bytes: UINT64,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).CopyBufferRegion(
                    @ptrCast(self),
                    dst_buffer,
                    dst_offset,
                    src_buffer,
                    src_offset,
                    num_bytes,
                );
            }
            pub inline fn CopyTextureRegion(
                self: *T,
                dst: *const TEXTURE_COPY_LOCATION,
                dst_x: UINT,
                dst_y: UINT,
                dst_z: UINT,
                src: *const TEXTURE_COPY_LOCATION,
                src_box: ?*const BOX,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).CopyTextureRegion(
                    @ptrCast(self),
                    dst,
                    dst_x,
                    dst_y,
                    dst_z,
                    src,
                    src_box,
                );
            }
            pub inline fn CopyResource(self: *T, dst: *IResource, src: *IResource) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).CopyResource(@ptrCast(self), dst, src);
            }
            pub inline fn CopyTiles(
                self: *T,
                tiled_resource: *IResource,
                tile_region_start_coordinate: *const TILED_RESOURCE_COORDINATE,
                tile_region_size: *const TILE_REGION_SIZE,
                buffer: *IResource,
                buffer_start_offset_in_bytes: UINT64,
                flags: TILE_COPY_FLAGS,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).CopyTiles(
                    @ptrCast(self),
                    tiled_resource,
                    tile_region_start_coordinate,
                    tile_region_size,
                    buffer,
                    buffer_start_offset_in_bytes,
                    flags,
                );
            }
            pub inline fn ResolveSubresource(
                self: *T,
                dst_resource: *IResource,
                dst_subresource: UINT,
                src_resource: *IResource,
                src_subresource: UINT,
                format: dxgi.FORMAT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ResolveSubresource(
                    @ptrCast(self),
                    dst_resource,
                    dst_subresource,
                    src_resource,
                    src_subresource,
                    format,
                );
            }
            pub inline fn IASetPrimitiveTopology(self: *T, topology: PRIMITIVE_TOPOLOGY) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .IASetPrimitiveTopology(@ptrCast(self), topology);
            }
            pub inline fn RSSetViewports(self: *T, num: UINT, viewports: [*]const VIEWPORT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .RSSetViewports(@ptrCast(self), num, viewports);
            }
            pub inline fn RSSetScissorRects(self: *T, num: UINT, rects: [*]const RECT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .RSSetScissorRects(@ptrCast(self), num, rects);
            }
            pub inline fn OMSetBlendFactor(self: *T, blend_factor: *const [4]FLOAT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .OMSetBlendFactor(@ptrCast(self), blend_factor);
            }
            pub inline fn OMSetStencilRef(self: *T, stencil_ref: UINT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).OMSetStencilRef(@ptrCast(self), stencil_ref);
            }
            pub inline fn SetPipelineState(self: *T, pso: *IPipelineState) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetPipelineState(@ptrCast(self), pso);
            }
            pub inline fn ResourceBarrier(self: *T, num: UINT, barriers: [*]const RESOURCE_BARRIER) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .ResourceBarrier(@ptrCast(self), num, barriers);
            }
            pub inline fn ExecuteBundle(self: *T, cmdlist: *IGraphicsCommandList) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ExecuteBundle(@ptrCast(self), cmdlist);
            }
            pub inline fn SetDescriptorHeaps(self: *T, num: UINT, heaps: [*]const *IDescriptorHeap) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .SetDescriptorHeaps(@ptrCast(self), num, heaps);
            }
            pub inline fn SetComputeRootSignature(self: *T, root_signature: ?*IRootSignature) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .SetComputeRootSignature(@ptrCast(self), root_signature);
            }
            pub inline fn SetGraphicsRootSignature(self: *T, root_signature: ?*IRootSignature) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .SetGraphicsRootSignature(@ptrCast(self), root_signature);
            }
            pub inline fn SetComputeRootDescriptorTable(
                self: *T,
                root_index: UINT,
                base_descriptor: GPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetComputeRootDescriptorTable(
                    @ptrCast(self),
                    root_index,
                    base_descriptor,
                );
            }
            pub inline fn SetGraphicsRootDescriptorTable(
                self: *T,
                root_index: UINT,
                base_descriptor: GPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetGraphicsRootDescriptorTable(
                    @ptrCast(self),
                    root_index,
                    base_descriptor,
                );
            }
            pub inline fn SetComputeRoot32BitConstant(self: *T, index: UINT, data: UINT, off: UINT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetComputeRoot32BitConstant(
                    @ptrCast(self),
                    index,
                    data,
                    off,
                );
            }
            pub inline fn SetGraphicsRoot32BitConstant(self: *T, index: UINT, data: UINT, off: UINT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetGraphicsRoot32BitConstant(
                    @ptrCast(self),
                    index,
                    data,
                    off,
                );
            }
            pub inline fn SetComputeRoot32BitConstants(
                self: *T,
                root_index: UINT,
                num: UINT,
                data: *const anyopaque,
                offset: UINT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetComputeRoot32BitConstants(
                    @ptrCast(self),
                    root_index,
                    num,
                    data,
                    offset,
                );
            }
            pub inline fn SetGraphicsRoot32BitConstants(
                self: *T,
                root_index: UINT,
                num: UINT,
                data: *const anyopaque,
                offset: UINT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetGraphicsRoot32BitConstants(
                    @ptrCast(self),
                    root_index,
                    num,
                    data,
                    offset,
                );
            }
            pub inline fn SetComputeRootConstantBufferView(
                self: *T,
                index: UINT,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetComputeRootConstantBufferView(
                    @ptrCast(self),
                    index,
                    buffer_location,
                );
            }
            pub inline fn SetGraphicsRootConstantBufferView(
                self: *T,
                index: UINT,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetGraphicsRootConstantBufferView(
                    @ptrCast(self),
                    index,
                    buffer_location,
                );
            }
            pub inline fn SetComputeRootShaderResourceView(
                self: *T,
                index: UINT,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetComputeRootShaderResourceView(
                    @ptrCast(self),
                    index,
                    buffer_location,
                );
            }
            pub inline fn SetGraphicsRootShaderResourceView(
                self: *T,
                index: UINT,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetGraphicsRootShaderResourceView(
                    @ptrCast(self),
                    index,
                    buffer_location,
                );
            }
            pub inline fn SetComputeRootUnorderedAccessView(
                self: *T,
                index: UINT,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetComputeRootUnorderedAccessView(
                    @ptrCast(self),
                    index,
                    buffer_location,
                );
            }
            pub inline fn SetGraphicsRootUnorderedAccessView(
                self: *T,
                index: UINT,
                buffer_location: GPU_VIRTUAL_ADDRESS,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetGraphicsRootUnorderedAccessView(
                    @ptrCast(self),
                    index,
                    buffer_location,
                );
            }
            pub inline fn IASetIndexBuffer(self: *T, view: ?*const INDEX_BUFFER_VIEW) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).IASetIndexBuffer(@ptrCast(self), view);
            }
            pub inline fn IASetVertexBuffers(
                self: *T,
                start_slot: UINT,
                num_views: UINT,
                views: ?[*]const VERTEX_BUFFER_VIEW,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).IASetVertexBuffers(
                    @ptrCast(self),
                    start_slot,
                    num_views,
                    views,
                );
            }
            pub inline fn SOSetTargets(
                self: *T,
                start_slot: UINT,
                num_views: UINT,
                views: ?[*]const STREAM_OUTPUT_BUFFER_VIEW,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .SOSetTargets(@ptrCast(self), start_slot, num_views, views);
            }
            pub inline fn OMSetRenderTargets(
                self: *T,
                num_rt_descriptors: UINT,
                rt_descriptors: ?[*]const CPU_DESCRIPTOR_HANDLE,
                single_handle: BOOL,
                ds_descriptors: ?*const CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).OMSetRenderTargets(
                    @ptrCast(self),
                    num_rt_descriptors,
                    rt_descriptors,
                    single_handle,
                    ds_descriptors,
                );
            }
            pub inline fn ClearDepthStencilView(
                self: *T,
                ds_view: CPU_DESCRIPTOR_HANDLE,
                clear_flags: CLEAR_FLAGS,
                depth: FLOAT,
                stencil: UINT8,
                num_rects: UINT,
                rects: ?[*]const RECT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ClearDepthStencilView(
                    @ptrCast(self),
                    ds_view,
                    clear_flags,
                    depth,
                    stencil,
                    num_rects,
                    rects,
                );
            }
            pub inline fn ClearRenderTargetView(
                self: *T,
                rt_view: CPU_DESCRIPTOR_HANDLE,
                rgba: *const [4]FLOAT,
                num_rects: UINT,
                rects: ?[*]const RECT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ClearRenderTargetView(
                    @ptrCast(self),
                    rt_view,
                    rgba,
                    num_rects,
                    rects,
                );
            }
            pub inline fn ClearUnorderedAccessViewUint(
                self: *T,
                gpu_view: GPU_DESCRIPTOR_HANDLE,
                cpu_view: CPU_DESCRIPTOR_HANDLE,
                resource: *IResource,
                values: *const [4]UINT,
                num_rects: UINT,
                rects: ?[*]const RECT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ClearUnorderedAccessViewUint(
                    @ptrCast(self),
                    gpu_view,
                    cpu_view,
                    resource,
                    values,
                    num_rects,
                    rects,
                );
            }
            pub inline fn ClearUnorderedAccessViewFloat(
                self: *T,
                gpu_view: GPU_DESCRIPTOR_HANDLE,
                cpu_view: CPU_DESCRIPTOR_HANDLE,
                resource: *IResource,
                values: *const [4]FLOAT,
                num_rects: UINT,
                rects: ?[*]const RECT,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ClearUnorderedAccessViewFloat(
                    @ptrCast(self),
                    gpu_view,
                    cpu_view,
                    resource,
                    values,
                    num_rects,
                    rects,
                );
            }
            pub inline fn DiscardResource(self: *T, resource: *IResource, region: ?*const DISCARD_REGION) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .DiscardResource(@ptrCast(self), resource, region);
            }
            pub inline fn BeginQuery(self: *T, query: *IQueryHeap, query_type: QUERY_TYPE, index: UINT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .BeginQuery(@ptrCast(self), query, query_type, index);
            }
            pub inline fn EndQuery(self: *T, query: *IQueryHeap, query_type: QUERY_TYPE, index: UINT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .EndQuery(@ptrCast(self), query, query_type, index);
            }
            pub inline fn ResolveQueryData(
                self: *T,
                query: *IQueryHeap,
                query_type: QUERY_TYPE,
                start_index: UINT,
                num_queries: UINT,
                dst_resource: *IResource,
                buffer_offset: UINT64,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ResolveQueryData(
                    @ptrCast(self),
                    query,
                    query_type,
                    start_index,
                    num_queries,
                    dst_resource,
                    buffer_offset,
                );
            }
            pub inline fn SetPredication(
                self: *T,
                buffer: ?*IResource,
                buffer_offset: UINT64,
                operation: PREDICATION_OP,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).SetPredication(
                    @ptrCast(self),
                    buffer,
                    buffer_offset,
                    operation,
                );
            }
            pub inline fn SetMarker(self: *T, metadata: UINT, data: ?*const anyopaque, size: UINT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .SetMarker(@ptrCast(self), metadata, data, size);
            }
            pub inline fn BeginEvent(self: *T, metadata: UINT, data: ?*const anyopaque, size: UINT) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v))
                    .BeginEvent(@ptrCast(self), metadata, data, size);
            }
            pub inline fn EndEvent(self: *T) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).EndEvent(@ptrCast(self));
            }
            pub inline fn ExecuteIndirect(
                self: *T,
                command_signature: *ICommandSignature,
                max_command_count: UINT,
                arg_buffer: *IResource,
                arg_buffer_offset: UINT64,
                count_buffer: ?*IResource,
                count_buffer_offset: UINT64,
            ) void {
                @as(*const IGraphicsCommandList.VTable, @ptrCast(self.__v)).ExecuteIndirect(
                    @ptrCast(self),
                    command_signature,
                    max_command_count,
                    arg_buffer,
                    arg_buffer_offset,
                    count_buffer,
                    count_buffer_offset,
                );
            }
        };
    }

    pub const VTable = extern struct {
        const T = IGraphicsCommandList;
        base: ICommandList.VTable,
        Close: *const fn (*T) callconv(.C) HRESULT,
        Reset: *const fn (*T, *ICommandAllocator, ?*IPipelineState) callconv(WINAPI) HRESULT,
        ClearState: *const fn (*T, ?*IPipelineState) callconv(WINAPI) void,
        DrawInstanced: *const fn (*T, UINT, UINT, UINT, UINT) callconv(WINAPI) void,
        DrawIndexedInstanced: *const fn (*T, UINT, UINT, UINT, INT, UINT) callconv(WINAPI) void,
        Dispatch: *const fn (*T, UINT, UINT, UINT) callconv(WINAPI) void,
        CopyBufferRegion: *const fn (*T, *IResource, UINT64, *IResource, UINT64, UINT64) callconv(WINAPI) void,
        CopyTextureRegion: *const fn (
            *T,
            *const TEXTURE_COPY_LOCATION,
            UINT,
            UINT,
            UINT,
            *const TEXTURE_COPY_LOCATION,
            ?*const BOX,
        ) callconv(WINAPI) void,
        CopyResource: *const fn (*T, *IResource, *IResource) callconv(WINAPI) void,
        CopyTiles: *const fn (
            *T,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *const TILE_REGION_SIZE,
            *IResource,
            buffer_start_offset_in_bytes: UINT64,
            TILE_COPY_FLAGS,
        ) callconv(WINAPI) void,
        ResolveSubresource: *const fn (*T, *IResource, UINT, *IResource, UINT, dxgi.FORMAT) callconv(WINAPI) void,
        IASetPrimitiveTopology: *const fn (*T, PRIMITIVE_TOPOLOGY) callconv(WINAPI) void,
        RSSetViewports: *const fn (*T, UINT, [*]const VIEWPORT) callconv(WINAPI) void,
        RSSetScissorRects: *const fn (*T, UINT, [*]const RECT) callconv(WINAPI) void,
        OMSetBlendFactor: *const fn (*T, *const [4]FLOAT) callconv(WINAPI) void,
        OMSetStencilRef: *const fn (*T, UINT) callconv(WINAPI) void,
        SetPipelineState: *const fn (*T, *IPipelineState) callconv(WINAPI) void,
        ResourceBarrier: *const fn (*T, UINT, [*]const RESOURCE_BARRIER) callconv(WINAPI) void,
        ExecuteBundle: *const fn (*T, *IGraphicsCommandList) callconv(WINAPI) void,
        SetDescriptorHeaps: *const fn (*T, UINT, [*]const *IDescriptorHeap) callconv(WINAPI) void,
        SetComputeRootSignature: *const fn (*T, ?*IRootSignature) callconv(WINAPI) void,
        SetGraphicsRootSignature: *const fn (*T, ?*IRootSignature) callconv(WINAPI) void,
        SetComputeRootDescriptorTable: *const fn (*T, UINT, GPU_DESCRIPTOR_HANDLE) callconv(WINAPI) void,
        SetGraphicsRootDescriptorTable: *const fn (*T, UINT, GPU_DESCRIPTOR_HANDLE) callconv(WINAPI) void,
        SetComputeRoot32BitConstant: *const fn (*T, UINT, UINT, UINT) callconv(WINAPI) void,
        SetGraphicsRoot32BitConstant: *const fn (*T, UINT, UINT, UINT) callconv(WINAPI) void,
        SetComputeRoot32BitConstants: *const fn (*T, UINT, UINT, *const anyopaque, UINT) callconv(WINAPI) void,
        SetGraphicsRoot32BitConstants: *const fn (*T, UINT, UINT, *const anyopaque, UINT) callconv(WINAPI) void,
        SetComputeRootConstantBufferView: *const fn (*T, UINT, GPU_VIRTUAL_ADDRESS) callconv(WINAPI) void,
        SetGraphicsRootConstantBufferView: *const fn (*T, UINT, GPU_VIRTUAL_ADDRESS) callconv(WINAPI) void,
        SetComputeRootShaderResourceView: *const fn (*T, UINT, GPU_VIRTUAL_ADDRESS) callconv(WINAPI) void,
        SetGraphicsRootShaderResourceView: *const fn (*T, UINT, GPU_VIRTUAL_ADDRESS) callconv(WINAPI) void,
        SetComputeRootUnorderedAccessView: *const fn (*T, UINT, GPU_VIRTUAL_ADDRESS) callconv(WINAPI) void,
        SetGraphicsRootUnorderedAccessView: *const fn (*T, UINT, GPU_VIRTUAL_ADDRESS) callconv(WINAPI) void,
        IASetIndexBuffer: *const fn (*T, ?*const INDEX_BUFFER_VIEW) callconv(WINAPI) void,
        IASetVertexBuffers: *const fn (*T, UINT, UINT, ?[*]const VERTEX_BUFFER_VIEW) callconv(WINAPI) void,
        SOSetTargets: *const fn (*T, UINT, UINT, ?[*]const STREAM_OUTPUT_BUFFER_VIEW) callconv(WINAPI) void,
        OMSetRenderTargets: *const fn (
            *T,
            UINT,
            ?[*]const CPU_DESCRIPTOR_HANDLE,
            BOOL,
            ?*const CPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) void,
        ClearDepthStencilView: *const fn (
            *T,
            CPU_DESCRIPTOR_HANDLE,
            CLEAR_FLAGS,
            FLOAT,
            UINT8,
            UINT,
            ?[*]const RECT,
        ) callconv(WINAPI) void,
        ClearRenderTargetView: *const fn (
            *T,
            CPU_DESCRIPTOR_HANDLE,
            *const [4]FLOAT,
            UINT,
            ?[*]const RECT,
        ) callconv(WINAPI) void,
        ClearUnorderedAccessViewUint: *const fn (
            *T,
            GPU_DESCRIPTOR_HANDLE,
            CPU_DESCRIPTOR_HANDLE,
            *IResource,
            *const [4]UINT,
            UINT,
            ?[*]const RECT,
        ) callconv(WINAPI) void,
        ClearUnorderedAccessViewFloat: *const fn (
            *T,
            GPU_DESCRIPTOR_HANDLE,
            CPU_DESCRIPTOR_HANDLE,
            *IResource,
            *const [4]FLOAT,
            UINT,
            ?[*]const RECT,
        ) callconv(WINAPI) void,
        DiscardResource: *const fn (*T, *IResource, ?*const DISCARD_REGION) callconv(WINAPI) void,
        BeginQuery: *const fn (*T, *IQueryHeap, QUERY_TYPE, UINT) callconv(WINAPI) void,
        EndQuery: *const fn (*T, *IQueryHeap, QUERY_TYPE, UINT) callconv(WINAPI) void,
        ResolveQueryData: *const fn (
            *T,
            *IQueryHeap,
            QUERY_TYPE,
            UINT,
            UINT,
            *IResource,
            UINT64,
        ) callconv(WINAPI) void,
        SetPredication: *const fn (*T, ?*IResource, UINT64, PREDICATION_OP) callconv(WINAPI) void,
        SetMarker: *const fn (*T, UINT, ?*const anyopaque, UINT) callconv(WINAPI) void,
        BeginEvent: *const fn (*T, UINT, ?*const anyopaque, UINT) callconv(WINAPI) void,
        EndEvent: *const fn (*T) callconv(WINAPI) void,
        ExecuteIndirect: *const fn (
            *T,
            *ICommandSignature,
            UINT,
            *IResource,
            UINT64,
            ?*IResource,
            UINT64,
        ) callconv(WINAPI) void,
    };
};

pub const RANGE_UINT64 = extern struct {
    Begin: UINT64,
    End: UINT64,
};

pub const SUBRESOURCE_RANGE_UINT64 = extern struct {
    Subresource: UINT,
    Range: RANGE_UINT64,
};

pub const SAMPLE_POSITION = extern struct {
    X: INT8,
    Y: INT8,
};

pub const RESOLVE_MODE = enum(UINT) {
    DECOMPRESS = 0,
    MIN = 1,
    MAX = 2,
    AVERAGE = 3,
    ENCODE_SAMPLER_FEEDBACK = 4,
    DECODE_SAMPLER_FEEDBACK = 5,
};

pub const IGraphicsCommandList1 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{553103fb-1fe7-4557-bb38-946d7d0e7ca7}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AtomicCopyBufferUINT(
                self: *T,
                dst_buffer: *IResource,
                dst_offset: UINT64,
                src_buffer: *IResource,
                src_offset: UINT64,
                dependencies: UINT,
                dependent_resources: [*]const *IResource,
                dependent_subresource_ranges: [*]const SUBRESOURCE_RANGE_UINT64,
            ) void {
                @as(*const IGraphicsCommandList1.VTable, @ptrCast(self.__v)).AtomicCopyBufferUINT(
                    @ptrCast(self),
                    dst_buffer,
                    dst_offset,
                    src_buffer,
                    src_offset,
                    dependencies,
                    dependent_resources,
                    dependent_subresource_ranges,
                );
            }
            pub inline fn AtomicCopyBufferUINT64(
                self: *T,
                dst_buffer: *IResource,
                dst_offset: UINT64,
                src_buffer: *IResource,
                src_offset: UINT64,
                dependencies: UINT,
                dependent_resources: [*]const *IResource,
                dependent_subresource_ranges: [*]const SUBRESOURCE_RANGE_UINT64,
            ) void {
                @as(*const IGraphicsCommandList1.VTable, @ptrCast(self.__v)).AtomicCopyBufferUINT64(
                    @ptrCast(self),
                    dst_buffer,
                    dst_offset,
                    src_buffer,
                    src_offset,
                    dependencies,
                    dependent_resources,
                    dependent_subresource_ranges,
                );
            }
            pub inline fn OMSetDepthBounds(self: *T, min: FLOAT, max: FLOAT) void {
                @as(*const IGraphicsCommandList1.VTable, @ptrCast(self.__v))
                    .OMSetDepthBounds(@ptrCast(self), min, max);
            }
            pub inline fn SetSamplePositions(
                self: *T,
                num_samples: UINT,
                num_pixels: UINT,
                sample_positions: *SAMPLE_POSITION,
            ) void {
                @as(*const IGraphicsCommandList1.VTable, @ptrCast(self.__v)).SetSamplePositions(
                    @ptrCast(self),
                    num_samples,
                    num_pixels,
                    sample_positions,
                );
            }
            pub inline fn ResolveSubresourceRegion(
                self: *T,
                dst_resource: *IResource,
                dst_subresource: UINT,
                dst_x: UINT,
                dst_y: UINT,
                src_resource: *IResource,
                src_subresource: UINT,
                src_rect: *RECT,
                format: dxgi.FORMAT,
                resolve_mode: RESOLVE_MODE,
            ) void {
                @as(*const IGraphicsCommandList1.VTable, @ptrCast(self.__v)).ResolveSubresourceRegion(
                    @ptrCast(self),
                    dst_resource,
                    dst_subresource,
                    dst_x,
                    dst_y,
                    src_resource,
                    src_subresource,
                    src_rect,
                    format,
                    resolve_mode,
                );
            }
            pub inline fn SetViewInstanceMask(self: *T, mask: UINT) void {
                @as(*const IGraphicsCommandList1.VTable, @ptrCast(self.__v))
                    .SetViewInstanceMask(@ptrCast(self), mask);
            }
        };
    }

    pub const VTable = extern struct {
        const T = IGraphicsCommandList1;
        base: IGraphicsCommandList.VTable,
        AtomicCopyBufferUINT: *const fn (
            *T,
            *IResource,
            UINT64,
            *IResource,
            UINT64,
            UINT,
            [*]const *IResource,
            [*]const SUBRESOURCE_RANGE_UINT64,
        ) callconv(WINAPI) void,
        AtomicCopyBufferUINT64: *const fn (
            *T,
            *IResource,
            UINT64,
            *IResource,
            UINT64,
            UINT,
            [*]const *IResource,
            [*]const SUBRESOURCE_RANGE_UINT64,
        ) callconv(WINAPI) void,
        OMSetDepthBounds: *const fn (*T, FLOAT, FLOAT) callconv(WINAPI) void,
        SetSamplePositions: *const fn (*T, UINT, UINT, *SAMPLE_POSITION) callconv(WINAPI) void,
        ResolveSubresourceRegion: *const fn (
            *T,
            *IResource,
            UINT,
            UINT,
            UINT,
            *IResource,
            UINT,
            *RECT,
            dxgi.FORMAT,
            RESOLVE_MODE,
        ) callconv(WINAPI) void,
        SetViewInstanceMask: *const fn (*T, UINT) callconv(WINAPI) void,
    };
};

pub const WRITEBUFFERIMMEDIATE_PARAMETER = extern struct {
    Dest: GPU_VIRTUAL_ADDRESS,
    Value: UINT32,
};

pub const WRITEBUFFERIMMEDIATE_MODE = enum(UINT) {
    DEFAULT = 0,
    MARKER_IN = 0x1,
    MARKER_OUT = 0x2,
};

pub const IGraphicsCommandList2 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{38C3E585-FF17-412C-9150-4FC6F9D72A28}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub const WriteBufferImmediate = IGraphicsCommandList2.Methods(@This()).WriteBufferImmediate;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn WriteBufferImmediate(
                self: *T,
                count: UINT,
                params: [*]const WRITEBUFFERIMMEDIATE_PARAMETER,
                modes: ?[*]const WRITEBUFFERIMMEDIATE_MODE,
            ) void {
                @as(*const IGraphicsCommandList2.VTable, @ptrCast(self.__v))
                    .WriteBufferImmediate(@ptrCast(self), count, params, modes);
            }
        };
    }

    pub const VTable = extern struct {
        base: IGraphicsCommandList1.VTable,
        WriteBufferImmediate: *const fn (
            *IGraphicsCommandList2,
            UINT,
            [*]const WRITEBUFFERIMMEDIATE_PARAMETER,
            ?[*]const WRITEBUFFERIMMEDIATE_MODE,
        ) callconv(WINAPI) void,
    };
};

pub const IGraphicsCommandList3 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{6FDA83A7-B84C-4E38-9AC8-C7BD22016B3D}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub const WriteBufferImmediate = IGraphicsCommandList2.Methods(@This()).WriteBufferImmediate;

    pub const SetProtectedResourceSession = IGraphicsCommandList3.Methods(@This()).SetProtectedResourceSession;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetProtectedResourceSession(self: *T, prsession: ?*IProtectedResourceSession) void {
                @as(*const IGraphicsCommandList3.VTable, @ptrCast(self.__v))
                    .SetProtectedResourceSession(@ptrCast(self), prsession);
            }
        };
    }

    pub const VTable = extern struct {
        base: IGraphicsCommandList2.VTable,
        SetProtectedResourceSession: *const fn (
            *IGraphicsCommandList3,
            ?*IProtectedResourceSession,
        ) callconv(WINAPI) void,
    };
};

pub const RENDER_PASS_BEGINNING_ACCESS_TYPE = enum(UINT) {
    DISCARD = 0,
    PRESERVE = 1,
    CLEAR = 2,
    NO_ACCESS = 3,
};

pub const RENDER_PASS_BEGINNING_ACCESS_CLEAR_PARAMETERS = extern struct {
    ClearValue: CLEAR_VALUE,
};

pub const RENDER_PASS_BEGINNING_ACCESS = extern struct {
    Type: RENDER_PASS_BEGINNING_ACCESS_TYPE,
    u: extern union {
        Clear: RENDER_PASS_BEGINNING_ACCESS_CLEAR_PARAMETERS,
    },
};

pub const RENDER_PASS_ENDING_ACCESS_TYPE = enum(UINT) {
    DISCARD = 0,
    PRESERVE = 1,
    RESOLVE = 2,
    NO_ACCESS = 3,
};

pub const RENDER_PASS_ENDING_ACCESS_RESOLVE_SUBRESOURCE_PARAMETERS = extern struct {
    SrcSubresource: UINT,
    DstSubresource: UINT,
    DstX: UINT,
    DstY: UINT,
    SrcRect: RECT,
};

pub const RENDER_PASS_ENDING_ACCESS_RESOLVE_PARAMETERS = extern struct {
    pSrcResource: *IResource,
    pDstResource: *IResource,
    SubresourceCount: UINT,
    pSubresourceParameters: [*]const RENDER_PASS_ENDING_ACCESS_RESOLVE_SUBRESOURCE_PARAMETERS,
    Format: dxgi.FORMAT,
    ResolveMode: RESOLVE_MODE,
    PreserveResolveSource: BOOL,
};

pub const RENDER_PASS_ENDING_ACCESS = extern struct {
    Type: RENDER_PASS_ENDING_ACCESS_TYPE,
    u: extern union {
        Resolve: RENDER_PASS_ENDING_ACCESS_RESOLVE_PARAMETERS,
    },
};

pub const RENDER_PASS_RENDER_TARGET_DESC = extern struct {
    cpuDescriptor: CPU_DESCRIPTOR_HANDLE,
    BeginningAccess: RENDER_PASS_BEGINNING_ACCESS,
    EndingAccess: RENDER_PASS_ENDING_ACCESS,
};

pub const RENDER_PASS_DEPTH_STENCIL_DESC = extern struct {
    cpuDescriptor: CPU_DESCRIPTOR_HANDLE,
    DepthBeginningAccess: RENDER_PASS_BEGINNING_ACCESS,
    StencilBeginningAccess: RENDER_PASS_BEGINNING_ACCESS,
    DepthEndingAccess: RENDER_PASS_ENDING_ACCESS,
    StencilEndingAccess: RENDER_PASS_ENDING_ACCESS,
};

pub const RENDER_PASS_FLAGS = packed struct(UINT) {
    ALLOW_UAV_WRITES: bool = false,
    SUSPENDING_PASS: bool = false,
    RESUMING_PASS: bool = false,
    __unused: u29 = 0,
};

pub const META_COMMAND_PARAMETER_TYPE = enum(UINT) {
    FLOAT = 0,
    UINT64 = 1,
    GPU_VIRTUAL_ADDRESS = 2,
    CPU_DESCRIPTOR_HANDLE_HEAP_TYPE_CBV_SRV_UAV = 3,
    GPU_DESCRIPTOR_HANDLE_HEAP_TYPE_CBV_SRV_UAV = 4,
};

pub const META_COMMAND_PARAMETER_FLAGS = packed struct(UINT) {
    INPUT: bool = false,
    OUTPUT: bool = false,
    __unused: u30 = 0,
};

pub const META_COMMAND_PARAMETER_STAGE = enum(UINT) {
    CREATION = 0,
    INITIALIZATION = 1,
    EXECUTION = 2,
};

pub const META_COMMAND_PARAMETER_DESC = extern struct {
    Name: LPCWSTR,
    Type: META_COMMAND_PARAMETER_TYPE,
    Flags: META_COMMAND_PARAMETER_FLAGS,
    RequiredResourceState: RESOURCE_STATES,
    StructureOffset: UINT,
};

pub const GRAPHICS_STATES = packed struct(UINT) {
    IA_VERTEX_BUFFERS: bool = false,
    IA_INDEX_BUFFER: bool = false,
    IA_PRIMITIVE_TOPOLOGY: bool = false,
    DESCRIPTOR_HEAP: bool = false,
    GRAPHICS_ROOT_SIGNATURE: bool = false,
    COMPUTE_ROOT_SIGNATURE: bool = false,
    RS_VIEWPORTS: bool = false,
    RS_SCISSOR_RECTS: bool = false,
    PREDICATION: bool = false,
    OM_RENDER_TARGETS: bool = false,
    OM_STENCIL_REF: bool = false,
    OM_BLEND_FACTOR: bool = false,
    PIPELINE_STATE: bool = false,
    SO_TARGETS: bool = false,
    OM_DEPTH_BOUNDS: bool = false,
    SAMPLE_POSITIONS: bool = false,
    VIEW_INSTANCE_MASK: bool = false,
    __unused: u15 = 0,
};

pub const META_COMMAND_DESC = extern struct {
    Id: GUID,
    Name: LPCWSTR,
    InitializationDirtyState: GRAPHICS_STATES,
    ExecutionDirtyState: GRAPHICS_STATES,
};

pub const IMetaCommand = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetRequiredParameterResourceSize = IMetaCommand.Methods(@This()).GetRequiredParameterResourceSize;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetRequiredParameterResourceSize(
                self: *T,
                stage: META_COMMAND_PARAMETER_STAGE,
                param_index: UINT,
            ) UINT64 {
                return @as(*const IMetaCommand.VTable, @ptrCast(self.__v))
                    .GetRequiredParameterResourceSize(@ptrCast(self), stage, param_index);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDeviceChild.VTable,
        GetRequiredParameterResourceSize: *const fn (
            *IMetaCommand,
            META_COMMAND_PARAMETER_STAGE,
            UINT,
        ) callconv(WINAPI) UINT64,
    };
};

pub const STATE_SUBOBJECT_TYPE = enum(UINT) {
    STATE_OBJECT_CONFIG = 0,
    GLOBAL_ROOT_SIGNATURE = 1,
    LOCAL_ROOT_SIGNATURE = 2,
    NODE_MASK = 3,
    DXIL_LIBRARY = 5,
    EXISTING_COLLECTION = 6,
    SUBOBJECT_TO_EXPORTS_ASSOCIATION = 7,
    DXIL_SUBOBJECT_TO_EXPORTS_ASSOCIATION = 8,
    RAYTRACING_SHADER_CONFIG = 9,
    RAYTRACING_PIPELINE_CONFIG = 10,
    HIT_GROUP = 11,
    RAYTRACING_PIPELINE_CONFIG1 = 12,
    MAX_VALID,
};

pub const STATE_SUBOBJECT = extern struct {
    Type: STATE_SUBOBJECT_TYPE,
    pDesc: *const anyopaque,
};

pub const STATE_OBJECT_FLAGS = packed struct(UINT) {
    ALLOW_LOCAL_DEPENDENCIES_ON_EXTERNAL_DEFINITIONS: bool = false,
    ALLOW_EXTERNAL_DEPENDENCIES_ON_LOCAL_DEFINITIONS: bool = false,
    ALLOW_STATE_OBJECT_ADDITIONS: bool = false,
    __unused: u29 = 0,
};

pub const STATE_OBJECT_CONFIG = extern struct {
    Flags: STATE_OBJECT_FLAGS,
};

pub const GLOBAL_ROOT_SIGNATURE = extern struct {
    pGlobalRootSignature: *IRootSignature,
};

pub const LOCAL_ROOT_SIGNATURE = extern struct {
    pLocalRootSignature: *IRootSignature,
};

pub const NODE_MASK = extern struct {
    NodeMask: UINT,
};

pub const EXPORT_FLAGS = packed struct(UINT) {
    __unused: u32 = 0,
};

pub const EXPORT_DESC = extern struct {
    Name: LPCWSTR,
    ExportToRename: LPCWSTR,
    Flags: EXPORT_FLAGS,
};

pub const DXIL_LIBRARY_DESC = extern struct {
    DXILLibrary: SHADER_BYTECODE,
    NumExports: UINT,
    pExports: ?[*]EXPORT_DESC,
};

pub const EXISTING_COLLECTION_DESC = extern struct {
    pExistingCollection: *IStateObject,
    NumExports: UINT,
    pExports: [*]EXPORT_DESC,
};

pub const SUBOBJECT_TO_EXPORTS_ASSOCIATION = extern struct {
    pSubobjectToAssociate: *const STATE_SUBOBJECT,
    NumExports: UINT,
    pExports: [*]LPCWSTR,
};

pub const DXIL_SUBOBJECT_TO_EXPORTS_ASSOCIATION = extern struct {
    SubobjectToAssociate: LPCWSTR,
    NumExports: UINT,
    pExports: [*]LPCWSTR,
};

pub const HIT_GROUP_TYPE = enum(UINT) {
    TRIANGLES = 0,
    PROCEDURAL_PRIMITIVE = 0x1,
};

pub const HIT_GROUP_DESC = extern struct {
    HitGroupExport: LPCWSTR,
    Type: HIT_GROUP_TYPE,
    AnyHitShaderImport: LPCWSTR,
    ClosestHitShaderImport: LPCWSTR,
    IntersectionShaderImport: LPCWSTR,
};

pub const RAYTRACING_SHADER_CONFIG = extern struct {
    MaxPayloadSizeInBytes: UINT,
    MaxAttributeSizeInBytes: UINT,
};

pub const RAYTRACING_PIPELINE_CONFIG = extern struct {
    MaxTraceRecursionDepth: UINT,
};

pub const RAYTRACING_PIPELINE_FLAGS = packed struct(UINT) {
    __unused0: bool = false, // 0x1
    __unused1: bool = false,
    __unused2: bool = false,
    __unused3: bool = false,
    __unused4: bool = false, // 0x10
    __unused5: bool = false,
    __unused6: bool = false,
    __unused7: bool = false,
    SKIP_TRIANGLES: bool = false, // 0x100
    SKIP_PROCEDURAL_PRIMITIVES: bool = false,
    __unused: u22 = 0,
};

pub const RAYTRACING_PIPELINE_CONFIG1 = extern struct {
    MaxTraceRecursionDepth: UINT,
    Flags: RAYTRACING_PIPELINE_FLAGS,
};

pub const STATE_OBJECT_TYPE = enum(UINT) {
    COLLECTION = 0,
    RAYTRACING_PIPELINE = 3,
};

pub const STATE_OBJECT_DESC = extern struct {
    Type: STATE_OBJECT_TYPE,
    NumSubobjects: UINT,
    pSubobjects: [*]const STATE_SUBOBJECT,
};

pub const RAYTRACING_GEOMETRY_FLAGS = packed struct(UINT) {
    OPAQUE: bool = false,
    NO_DUPLICATE_ANYHIT_INVOCATION: bool = false,
    __unused: u30 = 0,
};

pub const RAYTRACING_GEOMETRY_TYPE = enum(UINT) {
    TRIANGLES = 0,
    PROCEDURAL_PRIMITIVE_AABBS = 1,
};

pub const RAYTRACING_INSTANCE_FLAGS = packed struct(UINT) {
    TRIANGLE_CULL_DISABLE: bool = false,
    TRIANGLE_FRONT_COUNTERCLOCKWISE: bool = false,
    FORCE_OPAQUE: bool = false,
    FORCE_NON_OPAQUE: bool = false,
    __unused: u28 = 0,
};

pub const GPU_VIRTUAL_ADDRESS_AND_STRIDE = extern struct {
    StartAddress: GPU_VIRTUAL_ADDRESS,
    StrideInBytes: UINT64,
};

pub const GPU_VIRTUAL_ADDRESS_RANGE = extern struct {
    StartAddress: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT64,
};

pub const GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE = extern struct {
    StartAddress: GPU_VIRTUAL_ADDRESS,
    SizeInBytes: UINT64,
    StrideInBytes: UINT64,
};

pub const RAYTRACING_GEOMETRY_TRIANGLES_DESC = extern struct {
    Transform3x4: GPU_VIRTUAL_ADDRESS,
    IndexFormat: dxgi.FORMAT,
    VertexFormat: dxgi.FORMAT,
    IndexCount: UINT,
    VertexCount: UINT,
    IndexBuffer: GPU_VIRTUAL_ADDRESS,
    VertexBuffer: GPU_VIRTUAL_ADDRESS_AND_STRIDE,
};

pub const RAYTRACING_AABB = extern struct {
    MinX: FLOAT,
    MinY: FLOAT,
    MinZ: FLOAT,
    MaxX: FLOAT,
    MaxY: FLOAT,
    MaxZ: FLOAT,
};

pub const RAYTRACING_GEOMETRY_AABBS_DESC = extern struct {
    AABBCount: UINT64,
    AABBs: GPU_VIRTUAL_ADDRESS_AND_STRIDE,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAGS = packed struct(UINT) {
    ALLOW_UPDATE: bool = false,
    ALLOW_COMPACTION: bool = false,
    PREFER_FAST_TRACE: bool = false,
    PREFER_FAST_BUILD: bool = false,
    MINIMIZE_MEMORY: bool = false,
    PERFORM_UPDATE: bool = false,
    __unused: u26 = 0,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE = enum(UINT) {
    CLONE = 0,
    COMPACT = 0x1,
    VISUALIZATION_DECODE_FOR_TOOLS = 0x2,
    SERIALIZE = 0x3,
    DESERIALIZE = 0x4,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_TYPE = enum(UINT) {
    TOP_LEVEL = 0,
    BOTTOM_LEVEL = 0x1,
};

pub const ELEMENTS_LAYOUT = enum(UINT) {
    ARRAY = 0,
    ARRAY_OF_POINTERS = 0x1,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TYPE = enum(UINT) {
    COMPACTED_SIZE = 0,
    TOOLS_VISUALIZATION = 0x1,
    SERIALIZATION = 0x2,
    CURRENT_SIZE = 0x3,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_DESC = extern struct {
    DestBuffer: GPU_VIRTUAL_ADDRESS,
    InfoType: RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TYPE,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_COMPACTED_SIZE_DESC = extern struct {
    CompactedSizeInBytes: UINT64,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_TOOLS_VISUALIZATION_DESC = extern struct {
    DecodedSizeInBytes: UINT64,
};

pub const BUILD_RAYTRACING_ACCELERATION_STRUCTURE_TOOLS_VISUALIZATION_HEADER = extern struct {
    Type: RAYTRACING_ACCELERATION_STRUCTURE_TYPE,
    NumDescs: UINT,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_SERIALIZATION_DESC = extern struct {
    SerializedSizeInBytes: UINT64,
    NumBottomLevelAccelerationStructurePointers: UINT64,
};

pub const SERIALIZED_DATA_DRIVER_MATCHING_IDENTIFIER = extern struct {
    DriverOpaqueGUID: GUID,
    DriverOpaqueVersioningData: [16]BYTE,
};

pub const SERIALIZED_DATA_TYPE = enum(UINT) {
    RAYTRACING_ACCELERATION_STRUCTURE = 0,
};

pub const DRIVER_MATCHING_IDENTIFIER_STATUS = enum(UINT) {
    COMPATIBLE_WITH_DEVICE = 0,
    UNSUPPORTED_TYPE = 0x1,
    UNRECOGNIZED = 0x2,
    INCOMPATIBLE_VERSION = 0x3,
    INCOMPATIBLE_TYPE = 0x4,
};

pub const SERIALIZED_RAYTRACING_ACCELERATION_STRUCTURE_HEADER = extern struct {
    DriverMatchingIdentifier: SERIALIZED_DATA_DRIVER_MATCHING_IDENTIFIER,
    SerializedSizeInBytesIncludingHeader: UINT64,
    DeserializedSizeInBytes: UINT64,
    NumBottomLevelAccelerationStructurePointersAfterHeader: UINT64,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_CURRENT_SIZE_DESC = extern struct {
    CurrentSizeInBytes: UINT64,
};

pub const RAYTRACING_INSTANCE_DESC = extern struct {
    Transform: [3][4]FLOAT align(16),
    p: packed struct(u64) {
        InstanceID: u24,
        InstanceMask: u8,
        InstanceContributionToHitGroupIndex: u24,
        Flags: u8,
    },
    AccelerationStructure: GPU_VIRTUAL_ADDRESS,
};
comptime {
    std.debug.assert(@sizeOf(RAYTRACING_INSTANCE_DESC) == 64);
    std.debug.assert(@alignOf(RAYTRACING_INSTANCE_DESC) == 16);
}

pub const RAYTRACING_GEOMETRY_DESC = extern struct {
    Type: RAYTRACING_GEOMETRY_TYPE,
    Flags: RAYTRACING_GEOMETRY_FLAGS,
    u: extern union {
        Triangles: RAYTRACING_GEOMETRY_TRIANGLES_DESC,
        AABBs: RAYTRACING_GEOMETRY_AABBS_DESC,
    },
};

pub const BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS = extern struct {
    Type: RAYTRACING_ACCELERATION_STRUCTURE_TYPE,
    Flags: RAYTRACING_ACCELERATION_STRUCTURE_BUILD_FLAGS,
    NumDescs: UINT,
    DescsLayout: ELEMENTS_LAYOUT,
    u: extern union {
        InstanceDescs: GPU_VIRTUAL_ADDRESS,
        pGeometryDescs: [*]const RAYTRACING_GEOMETRY_DESC,
        ppGeometryDescs: [*]const *RAYTRACING_GEOMETRY_DESC,
    },
};

pub const BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC = extern struct {
    DestAccelerationStructureData: GPU_VIRTUAL_ADDRESS,
    Inputs: BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS,
    SourceAccelerationStructureData: GPU_VIRTUAL_ADDRESS,
    ScratchAccelerationStructureData: GPU_VIRTUAL_ADDRESS,
};

pub const RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO = extern struct {
    ResultDataMaxSizeInBytes: UINT64,
    ScratchDataSizeInBytes: UINT64,
    UpdateScratchDataSizeInBytes: UINT64,
};

pub const IStateObject = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{47016943-fca8-4594-93ea-af258b55346d}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const VTable = extern struct {
        base: IDeviceChild.VTable,
    };
};

pub const IStateObjectProperties = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{de5fa827-9bf9-4f26-89ff-d7f56fde3860}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetShaderIdentifier = IStateObjectProperties.Methods(@This()).GetShaderIdentifier;
    pub const GetShaderStackSize = IStateObjectProperties.Methods(@This()).GetShaderStackSize;
    pub const GetPipelineStackSize = IStateObjectProperties.Methods(@This()).GetPipelineStackSize;
    pub const SetPipelineStackSize = IStateObjectProperties.Methods(@This()).SetPipelineStackSize;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetShaderIdentifier(self: *T, export_name: LPCWSTR) *anyopaque {
                return @as(*const IStateObjectProperties.VTable, @ptrCast(self.__v))
                    .GetShaderIdentifier(@ptrCast(self), export_name);
            }
            pub inline fn GetShaderStackSize(self: *T, export_name: LPCWSTR) UINT64 {
                return @as(*const IStateObjectProperties.VTable, @ptrCast(self.__v))
                    .GetShaderStackSize(@ptrCast(self), export_name);
            }
            pub inline fn GetPipelineStackSize(self: *T) UINT64 {
                return @as(*const IStateObjectProperties.VTable, @ptrCast(self.__v))
                    .GetPipelineStackSize(@ptrCast(self));
            }
            pub inline fn SetPipelineStackSize(self: *T, stack_size: UINT64) void {
                @as(*const IStateObjectProperties.VTable, @ptrCast(self.__v))
                    .SetPipelineStackSize(@ptrCast(self), stack_size);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        GetShaderIdentifier: *const fn (*IStateObjectProperties, LPCWSTR) callconv(WINAPI) *anyopaque,
        GetShaderStackSize: *const fn (*IStateObjectProperties, LPCWSTR) callconv(WINAPI) UINT64,
        GetPipelineStackSize: *const fn (*IStateObjectProperties) callconv(WINAPI) UINT64,
        SetPipelineStackSize: *const fn (*IStateObjectProperties, UINT64) callconv(WINAPI) void,
    };
};

pub const DISPATCH_RAYS_DESC = extern struct {
    RayGenerationShaderRecord: GPU_VIRTUAL_ADDRESS_RANGE,
    MissShaderTable: GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE,
    HitGroupTable: GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE,
    CallableShaderTable: GPU_VIRTUAL_ADDRESS_RANGE_AND_STRIDE,
    Width: UINT,
    Height: UINT,
    Depth: UINT,
};

pub const IGraphicsCommandList4 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{8754318e-d3a9-4541-98cf-645b50dc4874}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub const WriteBufferImmediate = IGraphicsCommandList2.Methods(@This()).WriteBufferImmediate;

    pub const SetProtectedResourceSession = IGraphicsCommandList3.Methods(@This()).SetProtectedResourceSession;

    pub const BeginRenderPass = IGraphicsCommandList4.Methods(@This()).BeginRenderPass;
    pub const EndRenderPass = IGraphicsCommandList4.Methods(@This()).EndRenderPass;
    pub const InitializeMetaCommand = IGraphicsCommandList4.Methods(@This()).InitializeMetaCommand;
    pub const ExecuteMetaCommand = IGraphicsCommandList4.Methods(@This()).ExecuteMetaCommand;
    pub const BuildRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).BuildRaytracingAccelerationStructure;
    pub const EmitRaytracingAccelerationStructurePostbuildInfo = IGraphicsCommandList4.Methods(@This()).EmitRaytracingAccelerationStructurePostbuildInfo;
    pub const CopyRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).CopyRaytracingAccelerationStructure;
    pub const SetPipelineState1 = IGraphicsCommandList4.Methods(@This()).SetPipelineState1;
    pub const DispatchRays = IGraphicsCommandList4.Methods(@This()).DispatchRays;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn BeginRenderPass(
                self: *T,
                num_render_targets: UINT,
                render_targets: ?[*]const RENDER_PASS_RENDER_TARGET_DESC,
                depth_stencil: ?*const RENDER_PASS_DEPTH_STENCIL_DESC,
                flags: RENDER_PASS_FLAGS,
            ) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v)).BeginRenderPass(
                    @ptrCast(self),
                    num_render_targets,
                    render_targets,
                    depth_stencil,
                    flags,
                );
            }
            pub inline fn EndRenderPass(self: *T) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v)).EndRenderPass(@ptrCast(self));
            }
            pub inline fn InitializeMetaCommand(
                self: *T,
                meta_cmd: *IMetaCommand,
                init_param_data: ?*const anyopaque,
                data_size: SIZE_T,
            ) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v)).InitializeMetaCommand(
                    @ptrCast(self),
                    meta_cmd,
                    init_param_data,
                    data_size,
                );
            }
            pub inline fn ExecuteMetaCommand(
                self: *T,
                meta_cmd: *IMetaCommand,
                exe_param_data: ?*const anyopaque,
                data_size: SIZE_T,
            ) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v)).InitializeMetaCommand(
                    @ptrCast(self),
                    meta_cmd,
                    exe_param_data,
                    data_size,
                );
            }
            pub inline fn BuildRaytracingAccelerationStructure(
                self: *T,
                desc: *const BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC,
                num_post_build_descs: UINT,
                post_build_descs: ?[*]const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_DESC,
            ) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v)).BuildRaytracingAccelerationStructure(
                    @ptrCast(self),
                    desc,
                    num_post_build_descs,
                    post_build_descs,
                );
            }
            pub inline fn EmitRaytracingAccelerationStructurePostbuildInfo(
                self: *T,
                desc: *const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_DESC,
                num_src_accel_structs: UINT,
                src_accel_struct_data: [*]const GPU_VIRTUAL_ADDRESS,
            ) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v))
                    .EmitRaytracingAccelerationStructurePostbuildInfo(
                    @ptrCast(self),
                    desc,
                    num_src_accel_structs,
                    src_accel_struct_data,
                );
            }
            pub inline fn CopyRaytracingAccelerationStructure(
                self: *T,
                dst_data: GPU_VIRTUAL_ADDRESS,
                src_data: GPU_VIRTUAL_ADDRESS,
                mode: RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE,
            ) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v)).CopyRaytracingAccelerationStructure(
                    @ptrCast(self),
                    dst_data,
                    src_data,
                    mode,
                );
            }
            pub inline fn SetPipelineState1(self: *T, state_obj: *IStateObject) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v))
                    .SetPipelineState1(@ptrCast(self), state_obj);
            }
            pub inline fn DispatchRays(self: *T, desc: *const DISPATCH_RAYS_DESC) void {
                @as(*const IGraphicsCommandList4.VTable, @ptrCast(self.__v)).DispatchRays(@ptrCast(self), desc);
            }
        };
    }

    pub const VTable = extern struct {
        const T = IGraphicsCommandList4;
        base: IGraphicsCommandList3.VTable,
        BeginRenderPass: *const fn (
            *T,
            UINT,
            ?[*]const RENDER_PASS_RENDER_TARGET_DESC,
            ?*const RENDER_PASS_DEPTH_STENCIL_DESC,
            RENDER_PASS_FLAGS,
        ) callconv(WINAPI) void,
        EndRenderPass: *const fn (*T) callconv(WINAPI) void,
        InitializeMetaCommand: *const fn (*T, *IMetaCommand, ?*const anyopaque, SIZE_T) callconv(WINAPI) void,
        ExecuteMetaCommand: *const fn (*T, *IMetaCommand, ?*const anyopaque, SIZE_T) callconv(WINAPI) void,
        BuildRaytracingAccelerationStructure: *const fn (
            *T,
            *const BUILD_RAYTRACING_ACCELERATION_STRUCTURE_DESC,
            UINT,
            ?[*]const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_DESC,
        ) callconv(WINAPI) void,
        EmitRaytracingAccelerationStructurePostbuildInfo: *const fn (
            *T,
            *const RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO_DESC,
            UINT,
            [*]const GPU_VIRTUAL_ADDRESS,
        ) callconv(WINAPI) void,
        CopyRaytracingAccelerationStructure: *const fn (
            *T,
            GPU_VIRTUAL_ADDRESS,
            GPU_VIRTUAL_ADDRESS,
            RAYTRACING_ACCELERATION_STRUCTURE_COPY_MODE,
        ) callconv(WINAPI) void,
        SetPipelineState1: *const fn (*T, *IStateObject) callconv(WINAPI) void,
        DispatchRays: *const fn (*T, *const DISPATCH_RAYS_DESC) callconv(WINAPI) void,
    };
};

pub const RS_SET_SHADING_RATE_COMBINER_COUNT = 2;

pub const SHADING_RATE = enum(UINT) {
    @"1X1" = 0,
    @"1X2" = 0x1,
    @"2X1" = 0x4,
    @"2X2" = 0x5,
    @"2X4" = 0x6,
    @"4X2" = 0x9,
    @"4X4" = 0xa,
};

pub const SHADING_RATE_COMBINER = enum(UINT) {
    PASSTHROUGH = 0,
    OVERRIDE = 1,
    COMBINER_MIN = 2,
    COMBINER_MAX = 3,
    COMBINER_SUM = 4,
};

pub const IGraphicsCommandList5 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{55050859-4024-474c-87f5-6472eaee44ea}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub const WriteBufferImmediate = IGraphicsCommandList2.Methods(@This()).WriteBufferImmediate;

    pub const SetProtectedResourceSession = IGraphicsCommandList3.Methods(@This()).SetProtectedResourceSession;

    pub const BeginRenderPass = IGraphicsCommandList4.Methods(@This()).BeginRenderPass;
    pub const EndRenderPass = IGraphicsCommandList4.Methods(@This()).EndRenderPass;
    pub const InitializeMetaCommand = IGraphicsCommandList4.Methods(@This()).InitializeMetaCommand;
    pub const ExecuteMetaCommand = IGraphicsCommandList4.Methods(@This()).ExecuteMetaCommand;
    pub const BuildRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).BuildRaytracingAccelerationStructure;
    pub const EmitRaytracingAccelerationStructurePostbuildInfo = IGraphicsCommandList4.Methods(@This()).EmitRaytracingAccelerationStructurePostbuildInfo;
    pub const CopyRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).CopyRaytracingAccelerationStructure;
    pub const SetPipelineState1 = IGraphicsCommandList4.Methods(@This()).SetPipelineState1;
    pub const DispatchRays = IGraphicsCommandList4.Methods(@This()).DispatchRays;

    pub const RSSetShadingRate = IGraphicsCommandList5.Methods(@This()).RSSetShadingRate;
    pub const RSSetShadingRateImage = IGraphicsCommandList5.Methods(@This()).RSSetShadingRateImage;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn RSSetShadingRate(
                self: *T,
                base_shading_rate: SHADING_RATE,
                combiners: ?*const [RS_SET_SHADING_RATE_COMBINER_COUNT]SHADING_RATE_COMBINER,
            ) void {
                @as(*const IGraphicsCommandList5.VTable, @ptrCast(self.__v))
                    .RSSetShadingRate(@ptrCast(self), base_shading_rate, combiners);
            }
            pub inline fn RSSetShadingRateImage(self: *T, shading_rate_img: ?*IResource) void {
                @as(*const IGraphicsCommandList5.VTable, @ptrCast(self.__v))
                    .RSSetShadingRateImage(@ptrCast(self), shading_rate_img);
            }
        };
    }

    pub const VTable = extern struct {
        base: IGraphicsCommandList4.VTable,
        RSSetShadingRate: *const fn (
            *IGraphicsCommandList5,
            SHADING_RATE,
            ?*const [RS_SET_SHADING_RATE_COMBINER_COUNT]SHADING_RATE_COMBINER,
        ) callconv(WINAPI) void,
        RSSetShadingRateImage: *const fn (*IGraphicsCommandList5, ?*IResource) callconv(WINAPI) void,
    };
};

pub const IGraphicsCommandList6 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{c3827890-e548-4cfa-96cf-5689a9370f80}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub const WriteBufferImmediate = IGraphicsCommandList2.Methods(@This()).WriteBufferImmediate;

    pub const SetProtectedResourceSession = IGraphicsCommandList3.Methods(@This()).SetProtectedResourceSession;

    pub const BeginRenderPass = IGraphicsCommandList4.Methods(@This()).BeginRenderPass;
    pub const EndRenderPass = IGraphicsCommandList4.Methods(@This()).EndRenderPass;
    pub const InitializeMetaCommand = IGraphicsCommandList4.Methods(@This()).InitializeMetaCommand;
    pub const ExecuteMetaCommand = IGraphicsCommandList4.Methods(@This()).ExecuteMetaCommand;
    pub const BuildRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).BuildRaytracingAccelerationStructure;
    pub const EmitRaytracingAccelerationStructurePostbuildInfo = IGraphicsCommandList4.Methods(@This()).EmitRaytracingAccelerationStructurePostbuildInfo;
    pub const CopyRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).CopyRaytracingAccelerationStructure;
    pub const SetPipelineState1 = IGraphicsCommandList4.Methods(@This()).SetPipelineState1;
    pub const DispatchRays = IGraphicsCommandList4.Methods(@This()).DispatchRays;

    pub const RSSetShadingRate = IGraphicsCommandList5.Methods(@This()).RSSetShadingRate;
    pub const RSSetShadingRateImage = IGraphicsCommandList5.Methods(@This()).RSSetShadingRateImage;

    pub const DispatchMesh = IGraphicsCommandList6.Methods(@This()).DispatchMesh;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn DispatchMesh(
                self: *T,
                thread_group_count_x: UINT,
                thread_group_count_y: UINT,
                thread_group_count_z: UINT,
            ) void {
                @as(*const IGraphicsCommandList6.VTable, @ptrCast(self.__v)).DispatchMesh(
                    @ptrCast(self),
                    thread_group_count_x,
                    thread_group_count_y,
                    thread_group_count_z,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IGraphicsCommandList5.VTable,
        DispatchMesh: *const fn (*IGraphicsCommandList6, UINT, UINT, UINT) callconv(WINAPI) void,
    };
};

pub const IGraphicsCommandList7 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{dd171223-8b61-4769-90e3-160ccde4e2c1}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub const WriteBufferImmediate = IGraphicsCommandList2.Methods(@This()).WriteBufferImmediate;

    pub const SetProtectedResourceSession = IGraphicsCommandList3.Methods(@This()).SetProtectedResourceSession;

    pub const BeginRenderPass = IGraphicsCommandList4.Methods(@This()).BeginRenderPass;
    pub const EndRenderPass = IGraphicsCommandList4.Methods(@This()).EndRenderPass;
    pub const InitializeMetaCommand = IGraphicsCommandList4.Methods(@This()).InitializeMetaCommand;
    pub const ExecuteMetaCommand = IGraphicsCommandList4.Methods(@This()).ExecuteMetaCommand;
    pub const BuildRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).BuildRaytracingAccelerationStructure;
    pub const EmitRaytracingAccelerationStructurePostbuildInfo = IGraphicsCommandList4.Methods(@This()).EmitRaytracingAccelerationStructurePostbuildInfo;
    pub const CopyRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).CopyRaytracingAccelerationStructure;
    pub const SetPipelineState1 = IGraphicsCommandList4.Methods(@This()).SetPipelineState1;
    pub const DispatchRays = IGraphicsCommandList4.Methods(@This()).DispatchRays;

    pub const RSSetShadingRate = IGraphicsCommandList5.Methods(@This()).RSSetShadingRate;
    pub const RSSetShadingRateImage = IGraphicsCommandList5.Methods(@This()).RSSetShadingRateImage;

    pub const DispatchMesh = IGraphicsCommandList6.Methods(@This()).DispatchMesh;

    pub const Barrier = IGraphicsCommandList7.Methods(@This()).Barrier;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Barrier(
                self: *T,
                num_barrier_groups: UINT32,
                barrier_groups: [*]const BARRIER_GROUP,
            ) void {
                @as(*const IGraphicsCommandList7.VTable, @ptrCast(self.__v)).Barrier(
                    @ptrCast(self),
                    num_barrier_groups,
                    barrier_groups,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IGraphicsCommandList6.VTable,
        Barrier: *const fn (*IGraphicsCommandList7, UINT32, [*]const BARRIER_GROUP) callconv(WINAPI) void,
    };
};

pub const IGraphicsCommandList8 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{ee936ef9-599d-4d28-938e-23c4ad05ce51}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub const WriteBufferImmediate = IGraphicsCommandList2.Methods(@This()).WriteBufferImmediate;

    pub const SetProtectedResourceSession = IGraphicsCommandList3.Methods(@This()).SetProtectedResourceSession;

    pub const BeginRenderPass = IGraphicsCommandList4.Methods(@This()).BeginRenderPass;
    pub const EndRenderPass = IGraphicsCommandList4.Methods(@This()).EndRenderPass;
    pub const InitializeMetaCommand = IGraphicsCommandList4.Methods(@This()).InitializeMetaCommand;
    pub const ExecuteMetaCommand = IGraphicsCommandList4.Methods(@This()).ExecuteMetaCommand;
    pub const BuildRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).BuildRaytracingAccelerationStructure;
    pub const EmitRaytracingAccelerationStructurePostbuildInfo = IGraphicsCommandList4.Methods(@This()).EmitRaytracingAccelerationStructurePostbuildInfo;
    pub const CopyRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).CopyRaytracingAccelerationStructure;
    pub const SetPipelineState1 = IGraphicsCommandList4.Methods(@This()).SetPipelineState1;
    pub const DispatchRays = IGraphicsCommandList4.Methods(@This()).DispatchRays;

    pub const RSSetShadingRate = IGraphicsCommandList5.Methods(@This()).RSSetShadingRate;
    pub const RSSetShadingRateImage = IGraphicsCommandList5.Methods(@This()).RSSetShadingRateImage;

    pub const DispatchMesh = IGraphicsCommandList6.Methods(@This()).DispatchMesh;

    pub const Barrier = IGraphicsCommandList7.Methods(@This()).Barrier;

    pub const OMSetFrontAndBackStencilRef = IGraphicsCommandList8.Methods(@This()).OMSetFrontAndBackStencilRef;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn OMSetFrontAndBackStencilRef(
                self: *T,
                front_stencil_ref: UINT,
                back_stencil_ref: UINT,
            ) void {
                @as(*const IGraphicsCommandList8.VTable, @ptrCast(self.__v)).OMSetFrontAndBackStencilRef(
                    @ptrCast(self),
                    front_stencil_ref,
                    back_stencil_ref,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IGraphicsCommandList7.VTable,
        Barrier: *const fn (*IGraphicsCommandList8, UINT, UINT) callconv(WINAPI) void,
    };
};

pub const IGraphicsCommandList9 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{34ed2808-ffe6-4c2b-b11a-cabd2b0c59e1}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const GetType = ICommandList.Methods(@This()).GetType;

    pub const Close = IGraphicsCommandList.Methods(@This()).Close;
    pub const Reset = IGraphicsCommandList.Methods(@This()).Reset;
    pub const ClearState = IGraphicsCommandList.Methods(@This()).ClearState;
    pub const DrawInstanced = IGraphicsCommandList.Methods(@This()).DrawInstanced;
    pub const DrawIndexedInstanced = IGraphicsCommandList.Methods(@This()).DrawIndexedInstanced;
    pub const Dispatch = IGraphicsCommandList.Methods(@This()).Dispatch;
    pub const CopyBufferRegion = IGraphicsCommandList.Methods(@This()).CopyBufferRegion;
    pub const CopyTextureRegion = IGraphicsCommandList.Methods(@This()).CopyTextureRegion;
    pub const CopyResource = IGraphicsCommandList.Methods(@This()).CopyResource;
    pub const CopyTiles = IGraphicsCommandList.Methods(@This()).CopyTiles;
    pub const ResolveSubresource = IGraphicsCommandList.Methods(@This()).ResolveSubresource;
    pub const IASetPrimitiveTopology = IGraphicsCommandList.Methods(@This()).IASetPrimitiveTopology;
    pub const RSSetViewports = IGraphicsCommandList.Methods(@This()).RSSetViewports;
    pub const RSSetScissorRects = IGraphicsCommandList.Methods(@This()).RSSetScissorRects;
    pub const OMSetBlendFactor = IGraphicsCommandList.Methods(@This()).OMSetBlendFactor;
    pub const OMSetStencilRef = IGraphicsCommandList.Methods(@This()).OMSetStencilRef;
    pub const SetPipelineState = IGraphicsCommandList.Methods(@This()).SetPipelineState;
    pub const ResourceBarrier = IGraphicsCommandList.Methods(@This()).ResourceBarrier;
    pub const ExecuteBundle = IGraphicsCommandList.Methods(@This()).ExecuteBundle;
    pub const SetDescriptorHeaps = IGraphicsCommandList.Methods(@This()).SetDescriptorHeaps;
    pub const SetComputeRootSignature = IGraphicsCommandList.Methods(@This()).SetComputeRootSignature;
    pub const SetGraphicsRootSignature = IGraphicsCommandList.Methods(@This()).SetGraphicsRootSignature;
    pub const SetComputeRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetComputeRootDescriptorTable;
    pub const SetGraphicsRootDescriptorTable = IGraphicsCommandList.Methods(@This()).SetGraphicsRootDescriptorTable;
    pub const SetComputeRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstant;
    pub const SetGraphicsRoot32BitConstant = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstant;
    pub const SetComputeRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetComputeRoot32BitConstants;
    pub const SetGraphicsRoot32BitConstants = IGraphicsCommandList.Methods(@This()).SetGraphicsRoot32BitConstants;
    pub const SetComputeRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetComputeRootConstantBufferView;
    pub const SetGraphicsRootConstantBufferView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootConstantBufferView;
    pub const SetComputeRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetComputeRootShaderResourceView;
    pub const SetGraphicsRootShaderResourceView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootShaderResourceView;
    pub const SetComputeRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetComputeRootUnorderedAccessView;
    pub const SetGraphicsRootUnorderedAccessView = IGraphicsCommandList.Methods(@This()).SetGraphicsRootUnorderedAccessView;
    pub const IASetIndexBuffer = IGraphicsCommandList.Methods(@This()).IASetIndexBuffer;
    pub const IASetVertexBuffers = IGraphicsCommandList.Methods(@This()).IASetVertexBuffers;
    pub const SOSetTargets = IGraphicsCommandList.Methods(@This()).SOSetTargets;
    pub const OMSetRenderTargets = IGraphicsCommandList.Methods(@This()).OMSetRenderTargets;
    pub const ClearDepthStencilView = IGraphicsCommandList.Methods(@This()).ClearDepthStencilView;
    pub const ClearRenderTargetView = IGraphicsCommandList.Methods(@This()).ClearRenderTargetView;
    pub const ClearUnorderedAccessViewUint = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewUint;
    pub const ClearUnorderedAccessViewFloat = IGraphicsCommandList.Methods(@This()).ClearUnorderedAccessViewFloat;
    pub const DiscardResource = IGraphicsCommandList.Methods(@This()).DiscardResource;
    pub const BeginQuery = IGraphicsCommandList.Methods(@This()).BeginQuery;
    pub const EndQuery = IGraphicsCommandList.Methods(@This()).EndQuery;
    pub const ResolveQueryData = IGraphicsCommandList.Methods(@This()).ResolveQueryData;
    pub const SetPredication = IGraphicsCommandList.Methods(@This()).SetPredication;
    pub const SetMarker = IGraphicsCommandList.Methods(@This()).SetMarker;
    pub const BeginEvent = IGraphicsCommandList.Methods(@This()).BeginEvent;
    pub const EndEvent = IGraphicsCommandList.Methods(@This()).EndEvent;
    pub const ExecuteIndirect = IGraphicsCommandList.Methods(@This()).ExecuteIndirect;

    pub const AtomicCopyBufferUINT = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT;
    pub const AtomicCopyBufferUINT64 = IGraphicsCommandList1.Methods(@This()).AtomicCopyBufferUINT64;
    pub const OMSetDepthBounds = IGraphicsCommandList1.Methods(@This()).OMSetDepthBounds;
    pub const SetSamplePositions = IGraphicsCommandList1.Methods(@This()).SetSamplePositions;
    pub const ResolveSubresourceRegion = IGraphicsCommandList1.Methods(@This()).ResolveSubresourceRegion;
    pub const SetViewInstanceMask = IGraphicsCommandList1.Methods(@This()).SetViewInstanceMask;

    pub const WriteBufferImmediate = IGraphicsCommandList2.Methods(@This()).WriteBufferImmediate;

    pub const SetProtectedResourceSession = IGraphicsCommandList3.Methods(@This()).SetProtectedResourceSession;

    pub const BeginRenderPass = IGraphicsCommandList4.Methods(@This()).BeginRenderPass;
    pub const EndRenderPass = IGraphicsCommandList4.Methods(@This()).EndRenderPass;
    pub const InitializeMetaCommand = IGraphicsCommandList4.Methods(@This()).InitializeMetaCommand;
    pub const ExecuteMetaCommand = IGraphicsCommandList4.Methods(@This()).ExecuteMetaCommand;
    pub const BuildRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).BuildRaytracingAccelerationStructure;
    pub const EmitRaytracingAccelerationStructurePostbuildInfo = IGraphicsCommandList4.Methods(@This()).EmitRaytracingAccelerationStructurePostbuildInfo;
    pub const CopyRaytracingAccelerationStructure = IGraphicsCommandList4.Methods(@This()).CopyRaytracingAccelerationStructure;
    pub const SetPipelineState1 = IGraphicsCommandList4.Methods(@This()).SetPipelineState1;
    pub const DispatchRays = IGraphicsCommandList4.Methods(@This()).DispatchRays;

    pub const RSSetShadingRate = IGraphicsCommandList5.Methods(@This()).RSSetShadingRate;
    pub const RSSetShadingRateImage = IGraphicsCommandList5.Methods(@This()).RSSetShadingRateImage;

    pub const DispatchMesh = IGraphicsCommandList6.Methods(@This()).DispatchMesh;

    pub const Barrier = IGraphicsCommandList7.Methods(@This()).Barrier;

    pub const OMSetFrontAndBackStencilRef = IGraphicsCommandList8.Methods(@This()).OMSetFrontAndBackStencilRef;

    pub const RSSetDepthBias = IGraphicsCommandList9.Methods(@This()).RSSetDepthBias;
    pub const IASetIndexBufferStripCutValue = IGraphicsCommandList9.Methods(@This()).IASetIndexBufferStripCutValue;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn RSSetDepthBias(
                self: *T,
                depth_bias: FLOAT,
                depth_bias_clamp: FLOAT,
                slope_scaled_depth_bias: FLOAT,
            ) void {
                @as(*const IGraphicsCommandList9.VTable, @ptrCast(self.__v)).RSSetDepthBias(
                    @ptrCast(self),
                    depth_bias,
                    depth_bias_clamp,
                    slope_scaled_depth_bias,
                );
            }
            pub inline fn IASetIndexBufferStripCutValue(
                self: *T,
                cut_value: INDEX_BUFFER_STRIP_CUT_VALUE,
            ) void {
                @as(*const IGraphicsCommandList9.VTable, @ptrCast(self.__v)).IASetIndexBufferStripCutValue(
                    @ptrCast(self),
                    cut_value,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IGraphicsCommandList8.VTable,
        RSSetDepthBias: *const fn (*IGraphicsCommandList9, FLOAT, FLOAT, FLOAT) callconv(WINAPI) void,
        IASetIndexBufferStripCutValue: *const fn (
            *IGraphicsCommandList9,
            INDEX_BUFFER_STRIP_CUT_VALUE,
        ) callconv(WINAPI) void,
    };
};

pub const ICommandQueue = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{0ec870a6-5d7e-4c22-8cfc-5baae07616ed}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetDevice = IDeviceChild.Methods(@This()).GetDevice;

    pub const UpdateTileMappings = ICommandQueue.Methods(@This()).UpdateTileMappings;
    pub const CopyTileMappings = ICommandQueue.Methods(@This()).CopyTileMappings;
    pub const ExecuteCommandLists = ICommandQueue.Methods(@This()).ExecuteCommandLists;
    pub const SetMarker = ICommandQueue.Methods(@This()).SetMarker;
    pub const BeginEvent = ICommandQueue.Methods(@This()).BeginEvent;
    pub const EndEvent = ICommandQueue.Methods(@This()).EndEvent;
    pub const Signal = ICommandQueue.Methods(@This()).Signal;
    pub const Wait = ICommandQueue.Methods(@This()).Wait;
    pub const GetTimestampFrequency = ICommandQueue.Methods(@This()).GetTimestampFrequency;
    pub const GetClockCalibration = ICommandQueue.Methods(@This()).GetClockCalibration;
    pub const GetDesc = ICommandQueue.Methods(@This()).GetDesc;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn UpdateTileMappings(
                self: *T,
                resource: *IResource,
                num_resource_regions: UINT,
                resource_region_start_coordinates: ?[*]const TILED_RESOURCE_COORDINATE,
                resource_region_sizes: ?[*]const TILE_REGION_SIZE,
                heap: ?*IHeap,
                num_ranges: UINT,
                range_flags: ?[*]const TILE_RANGE_FLAGS,
                heap_range_start_offsets: ?[*]const UINT,
                range_tile_counts: ?[*]const UINT,
                flags: TILE_MAPPING_FLAGS,
            ) void {
                @as(*const ICommandQueue.VTable, @ptrCast(self.__v)).UpdateTileMappings(
                    @ptrCast(self),
                    resource,
                    num_resource_regions,
                    resource_region_start_coordinates,
                    resource_region_sizes,
                    heap,
                    num_ranges,
                    range_flags,
                    heap_range_start_offsets,
                    range_tile_counts,
                    flags,
                );
            }
            pub inline fn CopyTileMappings(
                self: *T,
                dst_resource: *IResource,
                dst_region_start_coordinate: *const TILED_RESOURCE_COORDINATE,
                src_resource: *IResource,
                src_region_start_coordinate: *const TILED_RESOURCE_COORDINATE,
                region_size: *const TILE_REGION_SIZE,
                flags: TILE_MAPPING_FLAGS,
            ) void {
                @as(*const ICommandQueue.VTable, @ptrCast(self.__v)).CopyTileMappings(
                    @ptrCast(self),
                    dst_resource,
                    dst_region_start_coordinate,
                    src_resource,
                    src_region_start_coordinate,
                    region_size,
                    flags,
                );
            }
            pub inline fn ExecuteCommandLists(self: *T, num: UINT, cmdlists: [*]const *ICommandList) void {
                @as(*const ICommandQueue.VTable, @ptrCast(self.__v))
                    .ExecuteCommandLists(@ptrCast(self), num, cmdlists);
            }
            pub inline fn SetMarker(self: *T, metadata: UINT, data: ?*const anyopaque, size: UINT) void {
                @as(*const ICommandQueue.VTable, @ptrCast(self.__v)).SetMarker(@ptrCast(self), metadata, data, size);
            }
            pub inline fn BeginEvent(self: *T, metadata: UINT, data: ?*const anyopaque, size: UINT) void {
                @as(*const ICommandQueue.VTable, @ptrCast(self.__v)).BeginEvent(@ptrCast(self), metadata, data, size);
            }
            pub inline fn EndEvent(self: *T) void {
                @as(*const ICommandQueue.VTable, @ptrCast(self.__v)).EndEvent(@ptrCast(self));
            }
            pub inline fn Signal(self: *T, fence: *IFence, value: UINT64) HRESULT {
                return @as(*const ICommandQueue.VTable, @ptrCast(self.__v)).Signal(@ptrCast(self), fence, value);
            }
            pub inline fn Wait(self: *T, fence: *IFence, value: UINT64) HRESULT {
                return @as(*const ICommandQueue.VTable, @ptrCast(self.__v)).Wait(@ptrCast(self), fence, value);
            }
            pub inline fn GetTimestampFrequency(self: *T, frequency: *UINT64) HRESULT {
                return @as(*const ICommandQueue.VTable, @ptrCast(self.__v))
                    .GetTimestampFrequency(@ptrCast(self), frequency);
            }
            pub inline fn GetClockCalibration(self: *T, gpu_timestamp: *UINT64, cpu_timestamp: *UINT64) HRESULT {
                return @as(*const ICommandQueue.VTable, @ptrCast(self.__v))
                    .GetClockCalibration(@ptrCast(self), gpu_timestamp, cpu_timestamp);
            }
            pub inline fn GetDesc(self: *T) COMMAND_QUEUE_DESC {
                var desc: COMMAND_QUEUE_DESC = undefined;
                _ = @as(*const ICommandQueue.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), &desc);
                return desc;
            }
        };
    }

    pub const VTable = extern struct {
        const T = ICommandQueue;
        base: IPageable.VTable,
        UpdateTileMappings: *const fn (
            *T,
            *IResource,
            UINT,
            ?[*]const TILED_RESOURCE_COORDINATE,
            ?[*]const TILE_REGION_SIZE,
            *IHeap,
            UINT,
            ?[*]const TILE_RANGE_FLAGS,
            ?[*]const UINT,
            ?[*]const UINT,
            TILE_MAPPING_FLAGS,
        ) callconv(WINAPI) void,
        CopyTileMappings: *const fn (
            *T,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *IResource,
            *const TILED_RESOURCE_COORDINATE,
            *const TILE_REGION_SIZE,
            TILE_MAPPING_FLAGS,
        ) callconv(WINAPI) void,
        ExecuteCommandLists: *const fn (*T, UINT, [*]const *ICommandList) callconv(WINAPI) void,
        SetMarker: *const fn (*T, UINT, ?*const anyopaque, UINT) callconv(WINAPI) void,
        BeginEvent: *const fn (*T, UINT, ?*const anyopaque, UINT) callconv(WINAPI) void,
        EndEvent: *const fn (*T) callconv(WINAPI) void,
        Signal: *const fn (*T, *IFence, UINT64) callconv(WINAPI) HRESULT,
        Wait: *const fn (*T, *IFence, UINT64) callconv(WINAPI) HRESULT,
        GetTimestampFrequency: *const fn (*T, *UINT64) callconv(WINAPI) HRESULT,
        GetClockCalibration: *const fn (*T, *UINT64, *UINT64) callconv(WINAPI) HRESULT,
        GetDesc: *const fn (*T, *COMMAND_QUEUE_DESC) callconv(WINAPI) *COMMAND_QUEUE_DESC,
    };
};

pub const IDevice = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{189819f1-1db6-4b57-be54-1821339b85f7}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetNodeCount(self: *T) UINT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).GetNodeCount(@ptrCast(self));
            }
            pub inline fn CreateCommandQueue(
                self: *T,
                desc: *const COMMAND_QUEUE_DESC,
                guid: *const GUID,
                obj: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateCommandQueue(@ptrCast(self), desc, guid, obj);
            }
            pub inline fn CreateCommandAllocator(
                self: *T,
                cmdlist_type: COMMAND_LIST_TYPE,
                guid: *const GUID,
                obj: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateCommandAllocator(@ptrCast(self), cmdlist_type, guid, obj);
            }
            pub inline fn CreateGraphicsPipelineState(
                self: *T,
                desc: *const GRAPHICS_PIPELINE_STATE_DESC,
                guid: *const GUID,
                pso: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateGraphicsPipelineState(@ptrCast(self), desc, guid, pso);
            }
            pub inline fn CreateComputePipelineState(
                self: *T,
                desc: *const COMPUTE_PIPELINE_STATE_DESC,
                guid: *const GUID,
                pso: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateComputePipelineState(@ptrCast(self), desc, guid, pso);
            }
            pub inline fn CreateCommandList(
                self: *T,
                node_mask: UINT,
                cmdlist_type: COMMAND_LIST_TYPE,
                cmdalloc: *ICommandAllocator,
                initial_state: ?*IPipelineState,
                guid: *const GUID,
                cmdlist: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).CreateCommandList(
                    @ptrCast(self),
                    node_mask,
                    cmdlist_type,
                    cmdalloc,
                    initial_state,
                    guid,
                    cmdlist,
                );
            }
            pub inline fn CheckFeatureSupport(
                self: *T,
                feature: FEATURE,
                data: *anyopaque,
                data_size: UINT,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CheckFeatureSupport(@ptrCast(self), feature, data, data_size);
            }
            pub inline fn CreateDescriptorHeap(
                self: *T,
                desc: *const DESCRIPTOR_HEAP_DESC,
                guid: *const GUID,
                heap: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateDescriptorHeap(@ptrCast(self), desc, guid, heap);
            }
            pub inline fn GetDescriptorHandleIncrementSize(self: *T, heap_type: DESCRIPTOR_HEAP_TYPE) UINT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .GetDescriptorHandleIncrementSize(@ptrCast(self), heap_type);
            }
            pub inline fn CreateRootSignature(
                self: *T,
                node_mask: UINT,
                blob: *const anyopaque,
                blob_size: UINT64,
                guid: *const GUID,
                signature: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateRootSignature(@ptrCast(self), node_mask, blob, blob_size, guid, signature);
            }
            pub inline fn CreateConstantBufferView(
                self: *T,
                desc: ?*const CONSTANT_BUFFER_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateConstantBufferView(@ptrCast(self), desc, dst_descriptor);
            }
            pub inline fn CreateShaderResourceView(
                self: *T,
                resource: ?*IResource,
                desc: ?*const SHADER_RESOURCE_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateShaderResourceView(@ptrCast(self), resource, desc, dst_descriptor);
            }
            pub inline fn CreateUnorderedAccessView(
                self: *T,
                resource: ?*IResource,
                counter_resource: ?*IResource,
                desc: ?*const UNORDERED_ACCESS_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v)).CreateUnorderedAccessView(
                    @ptrCast(self),
                    resource,
                    counter_resource,
                    desc,
                    dst_descriptor,
                );
            }
            pub inline fn CreateRenderTargetView(
                self: *T,
                resource: ?*IResource,
                desc: ?*const RENDER_TARGET_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateRenderTargetView(@ptrCast(self), resource, desc, dst_descriptor);
            }
            pub inline fn CreateDepthStencilView(
                self: *T,
                resource: ?*IResource,
                desc: ?*const DEPTH_STENCIL_VIEW_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateDepthStencilView(@ptrCast(self), resource, desc, dst_descriptor);
            }
            pub inline fn CreateSampler(
                self: *T,
                desc: *const SAMPLER_DESC,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v)).CreateSampler(@ptrCast(self), desc, dst_descriptor);
            }
            pub inline fn CopyDescriptors(
                self: *T,
                num_dst_ranges: UINT,
                dst_range_starts: [*]const CPU_DESCRIPTOR_HANDLE,
                dst_range_sizes: ?[*]const UINT,
                num_src_ranges: UINT,
                src_range_starts: [*]const CPU_DESCRIPTOR_HANDLE,
                src_range_sizes: ?[*]const UINT,
                heap_type: DESCRIPTOR_HEAP_TYPE,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v)).CopyDescriptors(
                    @ptrCast(self),
                    num_dst_ranges,
                    dst_range_starts,
                    dst_range_sizes,
                    num_src_ranges,
                    src_range_starts,
                    src_range_sizes,
                    heap_type,
                );
            }
            pub inline fn CopyDescriptorsSimple(
                self: *T,
                num: UINT,
                dst_range_start: CPU_DESCRIPTOR_HANDLE,
                src_range_start: CPU_DESCRIPTOR_HANDLE,
                heap_type: DESCRIPTOR_HEAP_TYPE,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v)).CopyDescriptorsSimple(
                    @ptrCast(self),
                    num,
                    dst_range_start,
                    src_range_start,
                    heap_type,
                );
            }
            pub inline fn GetResourceAllocationInfo(
                self: *T,
                visible_mask: UINT,
                num_descs: UINT,
                descs: [*]const RESOURCE_DESC,
            ) RESOURCE_ALLOCATION_INFO {
                var info: RESOURCE_ALLOCATION_INFO = undefined;
                _ = @as(*const IDevice.VTable, @ptrCast(self.__v)).GetResourceAllocationInfo(
                    @ptrCast(self),
                    &info,
                    visible_mask,
                    num_descs,
                    descs,
                );
                return info;
            }
            pub inline fn GetCustomHeapProperties(
                self: *T,
                node_mask: UINT,
                heap_type: HEAP_TYPE,
            ) HEAP_PROPERTIES {
                var props: HEAP_PROPERTIES = undefined;
                @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .GetCustomHeapProperties(@ptrCast(self), &props, node_mask, heap_type);
                return props;
            }
            pub inline fn CreateCommittedResource(
                self: *T,
                heap_props: *const HEAP_PROPERTIES,
                heap_flags: HEAP_FLAGS,
                desc: *const RESOURCE_DESC,
                state: RESOURCE_STATES,
                clear_value: ?*const CLEAR_VALUE,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).CreateCommittedResource(
                    @ptrCast(self),
                    heap_props,
                    heap_flags,
                    desc,
                    state,
                    clear_value,
                    guid,
                    resource,
                );
            }
            pub inline fn CreateHeap(
                self: *T,
                desc: *const HEAP_DESC,
                guid: *const GUID,
                heap: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).CreateHeap(@ptrCast(self), desc, guid, heap);
            }
            pub inline fn CreatePlacedResource(
                self: *T,
                heap: *IHeap,
                heap_offset: UINT64,
                desc: *const RESOURCE_DESC,
                state: RESOURCE_STATES,
                clear_value: ?*const CLEAR_VALUE,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).CreatePlacedResource(
                    @ptrCast(self),
                    heap,
                    heap_offset,
                    desc,
                    state,
                    clear_value,
                    guid,
                    resource,
                );
            }
            pub inline fn CreateReservedResource(
                self: *T,
                desc: *const RESOURCE_DESC,
                state: RESOURCE_STATES,
                clear_value: ?*const CLEAR_VALUE,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateReservedResource(@ptrCast(self), desc, state, clear_value, guid, resource);
            }
            pub inline fn CreateSharedHandle(
                self: *T,
                object: *IDeviceChild,
                attributes: ?*const SECURITY_ATTRIBUTES,
                access: DWORD,
                name: ?LPCWSTR,
                handle: ?*HANDLE,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateSharedHandle(@ptrCast(self), object, attributes, access, name, handle);
            }
            pub inline fn OpenSharedHandle(
                self: *T,
                handle: HANDLE,
                guid: *const GUID,
                object: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .OpenSharedHandle(@ptrCast(self), handle, guid, object);
            }
            pub inline fn OpenSharedHandleByName(self: *T, name: LPCWSTR, access: DWORD, handle: ?*HANDLE) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .OpenSharedHandleByName(@ptrCast(self), name, access, handle);
            }
            pub inline fn MakeResident(self: *T, num: UINT, objects: [*]const *IPageable) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).MakeResident(@ptrCast(self), num, objects);
            }
            pub inline fn Evict(self: *T, num: UINT, objects: [*]const *IPageable) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).Evict(@ptrCast(self), num, objects);
            }
            pub inline fn CreateFence(
                self: *T,
                initial_value: UINT64,
                flags: FENCE_FLAGS,
                guid: *const GUID,
                fence: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateFence(@ptrCast(self), initial_value, flags, guid, fence);
            }
            pub inline fn GetDeviceRemovedReason(self: *T) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).GetDeviceRemovedReason(@ptrCast(self));
            }
            pub inline fn GetCopyableFootprints(
                self: *T,
                desc: *const RESOURCE_DESC,
                first_subresource: UINT,
                num_subresources: UINT,
                base_offset: UINT64,
                layouts: ?[*]PLACED_SUBRESOURCE_FOOTPRINT,
                num_rows: ?[*]UINT,
                row_size: ?[*]UINT64,
                total_sizie: ?*UINT64,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v)).GetCopyableFootprints(
                    @ptrCast(self),
                    desc,
                    first_subresource,
                    num_subresources,
                    base_offset,
                    layouts,
                    num_rows,
                    row_size,
                    total_sizie,
                );
            }
            pub inline fn CreateQueryHeap(
                self: *T,
                desc: *const QUERY_HEAP_DESC,
                guid: *const GUID,
                query_heap: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateQueryHeap(@ptrCast(self), desc, guid, query_heap);
            }
            pub inline fn SetStablePowerState(self: *T, enable: BOOL) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v)).SetStablePowerState(@ptrCast(self), enable);
            }
            pub inline fn CreateCommandSignature(
                self: *T,
                desc: *const COMMAND_SIGNATURE_DESC,
                root_signature: ?*IRootSignature,
                guid: *const GUID,
                cmd_signature: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice.VTable, @ptrCast(self.__v))
                    .CreateCommandSignature(@ptrCast(self), desc, root_signature, guid, cmd_signature);
            }
            pub inline fn GetResourceTiling(
                self: *T,
                resource: *IResource,
                num_resource_tiles: ?*UINT,
                packed_mip_desc: ?*PACKED_MIP_INFO,
                std_tile_shape_non_packed_mips: ?*TILE_SHAPE,
                num_subresource_tilings: ?*UINT,
                first_subresource: UINT,
                subresource_tiling_for_non_packed_mips: [*]SUBRESOURCE_TILING,
            ) void {
                @as(*const IDevice.VTable, @ptrCast(self.__v)).GetResourceTiling(
                    @ptrCast(self),
                    resource,
                    num_resource_tiles,
                    packed_mip_desc,
                    std_tile_shape_non_packed_mips,
                    num_subresource_tilings,
                    first_subresource,
                    subresource_tiling_for_non_packed_mips,
                );
            }
            pub inline fn GetAdapterLuid(self: *T) LUID {
                var luid: LUID = undefined;
                @as(*const IDevice.VTable, @ptrCast(self.__v)).GetAdapterLuid(@ptrCast(self), &luid);
                return luid;
            }
        };
    }

    pub const VTable = extern struct {
        const T = IDevice;
        base: IObject.VTable,
        GetNodeCount: *const fn (*T) callconv(WINAPI) UINT,
        CreateCommandQueue: *const fn (
            *T,
            *const COMMAND_QUEUE_DESC,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateCommandAllocator: *const fn (
            *T,
            COMMAND_LIST_TYPE,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateGraphicsPipelineState: *const fn (
            *T,
            *const GRAPHICS_PIPELINE_STATE_DESC,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateComputePipelineState: *const fn (
            *T,
            *const COMPUTE_PIPELINE_STATE_DESC,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateCommandList: *const fn (
            *T,
            UINT,
            COMMAND_LIST_TYPE,
            *ICommandAllocator,
            ?*IPipelineState,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CheckFeatureSupport: *const fn (*T, FEATURE, *anyopaque, UINT) callconv(WINAPI) HRESULT,
        CreateDescriptorHeap: *const fn (
            *T,
            *const DESCRIPTOR_HEAP_DESC,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        GetDescriptorHandleIncrementSize: *const fn (*T, DESCRIPTOR_HEAP_TYPE) callconv(WINAPI) UINT,
        CreateRootSignature: *const fn (
            *T,
            UINT,
            *const anyopaque,
            UINT64,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateConstantBufferView: *const fn (
            *T,
            ?*const CONSTANT_BUFFER_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) void,
        CreateShaderResourceView: *const fn (
            *T,
            ?*IResource,
            ?*const SHADER_RESOURCE_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) void,
        CreateUnorderedAccessView: *const fn (
            *T,
            ?*IResource,
            ?*IResource,
            ?*const UNORDERED_ACCESS_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) void,
        CreateRenderTargetView: *const fn (
            *T,
            ?*IResource,
            ?*const RENDER_TARGET_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) void,
        CreateDepthStencilView: *const fn (
            *T,
            ?*IResource,
            ?*const DEPTH_STENCIL_VIEW_DESC,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) void,
        CreateSampler: *const fn (*T, *const SAMPLER_DESC, CPU_DESCRIPTOR_HANDLE) callconv(WINAPI) void,
        CopyDescriptors: *const fn (
            *T,
            UINT,
            [*]const CPU_DESCRIPTOR_HANDLE,
            ?[*]const UINT,
            UINT,
            [*]const CPU_DESCRIPTOR_HANDLE,
            ?[*]const UINT,
            DESCRIPTOR_HEAP_TYPE,
        ) callconv(WINAPI) void,
        CopyDescriptorsSimple: *const fn (
            *T,
            UINT,
            CPU_DESCRIPTOR_HANDLE,
            CPU_DESCRIPTOR_HANDLE,
            DESCRIPTOR_HEAP_TYPE,
        ) callconv(WINAPI) void,
        GetResourceAllocationInfo: *const fn (
            *T,
            *RESOURCE_ALLOCATION_INFO,
            UINT,
            UINT,
            [*]const RESOURCE_DESC,
        ) callconv(WINAPI) *RESOURCE_ALLOCATION_INFO,
        GetCustomHeapProperties: *const fn (
            *T,
            *HEAP_PROPERTIES,
            UINT,
            HEAP_TYPE,
        ) callconv(WINAPI) *HEAP_PROPERTIES,
        CreateCommittedResource: *const fn (
            *T,
            *const HEAP_PROPERTIES,
            HEAP_FLAGS,
            *const RESOURCE_DESC,
            RESOURCE_STATES,
            ?*const CLEAR_VALUE,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateHeap: *const fn (*T, *const HEAP_DESC, *const GUID, ?*?*anyopaque) callconv(WINAPI) HRESULT,
        CreatePlacedResource: *const fn (
            *T,
            *IHeap,
            UINT64,
            *const RESOURCE_DESC,
            RESOURCE_STATES,
            ?*const CLEAR_VALUE,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateReservedResource: *const fn (
            *T,
            *const RESOURCE_DESC,
            RESOURCE_STATES,
            ?*const CLEAR_VALUE,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateSharedHandle: *const fn (
            *T,
            *IDeviceChild,
            ?*const SECURITY_ATTRIBUTES,
            DWORD,
            ?LPCWSTR,
            ?*HANDLE,
        ) callconv(WINAPI) HRESULT,
        OpenSharedHandle: *const fn (*T, HANDLE, *const GUID, ?*?*anyopaque) callconv(WINAPI) HRESULT,
        OpenSharedHandleByName: *const fn (*T, LPCWSTR, DWORD, ?*HANDLE) callconv(WINAPI) HRESULT,
        MakeResident: *const fn (*T, UINT, [*]const *IPageable) callconv(WINAPI) HRESULT,
        Evict: *const fn (*T, UINT, [*]const *IPageable) callconv(WINAPI) HRESULT,
        CreateFence: *const fn (*T, UINT64, FENCE_FLAGS, *const GUID, *?*anyopaque) callconv(WINAPI) HRESULT,
        GetDeviceRemovedReason: *const fn (*T) callconv(WINAPI) HRESULT,
        GetCopyableFootprints: *const fn (
            *T,
            *const RESOURCE_DESC,
            UINT,
            UINT,
            UINT64,
            ?[*]PLACED_SUBRESOURCE_FOOTPRINT,
            ?[*]UINT,
            ?[*]UINT64,
            ?*UINT64,
        ) callconv(WINAPI) void,
        CreateQueryHeap: *const fn (*T, *const QUERY_HEAP_DESC, *const GUID, ?*?*anyopaque) callconv(WINAPI) HRESULT,
        SetStablePowerState: *const fn (*T, BOOL) callconv(WINAPI) HRESULT,
        CreateCommandSignature: *const fn (
            *T,
            *const COMMAND_SIGNATURE_DESC,
            ?*IRootSignature,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        GetResourceTiling: *const fn (
            *T,
            *IResource,
            ?*UINT,
            ?*PACKED_MIP_INFO,
            ?*TILE_SHAPE,
            ?*UINT,
            UINT,
            [*]SUBRESOURCE_TILING,
        ) callconv(WINAPI) void,
        GetAdapterLuid: *const fn (*T, *LUID) callconv(WINAPI) *LUID,
    };
};

pub const MULTIPLE_FENCE_WAIT_FLAGS = enum(UINT) {
    ALL = 0,
    ANY = 1,
};

pub const RESIDENCY_PRIORITY = enum(UINT) {
    MINIMUM = 0x28000000,
    LOW = 0x50000000,
    NORMAL = 0x78000000,
    HIGH = 0xa0010000,
    MAXIMUM = 0xc8000000,
};

pub const IDevice1 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{77acce80-638e-4e65-8895-c1f23386863e}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreatePipelineLibrary(
                self: *T,
                blob: *const anyopaque,
                blob_length: SIZE_T,
                guid: *const GUID,
                library: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice1.VTable, @ptrCast(self.__v))
                    .CreatePipelineLibrary(@ptrCast(self), blob, blob_length, guid, library);
            }
            pub inline fn SetEventOnMultipleFenceCompletion(
                self: *T,
                fences: [*]const *IFence,
                fence_values: [*]const UINT64,
                num_fences: UINT,
                flags: MULTIPLE_FENCE_WAIT_FLAGS,
                event: HANDLE,
            ) HRESULT {
                return @as(*const IDevice1.VTable, @ptrCast(self.__v)).SetEventOnMultipleFenceCompletion(
                    @ptrCast(self),
                    fences,
                    fence_values,
                    num_fences,
                    flags,
                    event,
                );
            }
            pub inline fn SetResidencyPriority(
                self: *T,
                num_objects: UINT,
                objects: [*]const *IPageable,
                priorities: [*]const RESIDENCY_PRIORITY,
            ) HRESULT {
                return @as(*const IDevice1.VTable, @ptrCast(self.__v))
                    .SetResidencyPriority(@ptrCast(self), num_objects, objects, priorities);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice.VTable,
        CreatePipelineLibrary: *const fn (
            *IDevice1,
            *const anyopaque,
            SIZE_T,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        SetEventOnMultipleFenceCompletion: *const fn (
            *IDevice1,
            [*]const *IFence,
            [*]const UINT64,
            UINT,
            MULTIPLE_FENCE_WAIT_FLAGS,
            HANDLE,
        ) callconv(WINAPI) HRESULT,
        SetResidencyPriority: *const fn (
            *IDevice1,
            UINT,
            [*]const *IPageable,
            [*]const RESIDENCY_PRIORITY,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const PIPELINE_STATE_SUBOBJECT_TYPE = enum(UINT) {
    ROOT_SIGNATURE = 0,
    VS = 1,
    PS = 2,
    DS = 3,
    HS = 4,
    GS = 5,
    CS = 6,
    STREAM_OUTPUT = 7,
    BLEND = 8,
    SAMPLE_MASK = 9,
    RASTERIZER = 10,
    DEPTH_STENCIL = 11,
    INPUT_LAYOUT = 12,
    IB_STRIP_CUT_VALUE = 13,
    PRIMITIVE_TOPOLOGY = 14,
    RENDER_TARGET_FORMATS = 15,
    DEPTH_STENCIL_FORMAT = 16,
    SAMPLE_DESC = 17,
    NODE_MASK = 18,
    CACHED_PSO = 19,
    FLAGS = 20,
    DEPTH_STENCIL1 = 21,
    VIEW_INSTANCING = 22,
    AS = 24,
    MS = 25,
    MAX_VALID,
};

pub const RT_FORMAT_ARRAY = extern struct {
    RTFormats: [8]dxgi.FORMAT,
    NumRenderTargets: UINT,
};

pub const PIPELINE_STATE_STREAM_DESC = extern struct {
    SizeInBytes: SIZE_T,
    pPipelineStateSubobjectStream: *anyopaque,
};

// NOTE(mziulek): Helper structures for defining Mesh Shaders.
pub const MESH_SHADER_PIPELINE_STATE_DESC = extern struct {
    pRootSignature: ?*IRootSignature,
    AS: SHADER_BYTECODE,
    MS: SHADER_BYTECODE,
    PS: SHADER_BYTECODE,
    BlendState: BLEND_DESC,
    SampleMask: UINT,
    RasterizerState: RASTERIZER_DESC,
    DepthStencilState: DEPTH_STENCIL_DESC1,
    PrimitiveTopologyType: PRIMITIVE_TOPOLOGY_TYPE,
    NumRenderTargets: UINT,
    RTVFormats: [8]dxgi.FORMAT,
    DSVFormat: dxgi.FORMAT,
    SampleDesc: dxgi.SAMPLE_DESC,
    NodeMask: UINT,
    CachedPSO: CACHED_PIPELINE_STATE,
    Flags: PIPELINE_STATE_FLAGS,

    pub fn init_default() MESH_SHADER_PIPELINE_STATE_DESC {
        var v = std.mem.zeroes(@This());
        v = .{
            .pRootSignature = null,
            .AS = SHADER_BYTECODE.init_zero(),
            .MS = SHADER_BYTECODE.init_zero(),
            .PS = SHADER_BYTECODE.init_zero(),
            .BlendState = BLEND_DESC.init_default(),
            .SampleMask = 0xffff_ffff,
            .RasterizerState = RASTERIZER_DESC.init_default(),
            .DepthStencilState = DEPTH_STENCIL_DESC1.init_default(),
            .PrimitiveTopologyType = .UNDEFINED,
            .NumRenderTargets = 0,
            .RTVFormats = [_]dxgi.FORMAT{.UNKNOWN} ** 8,
            .DSVFormat = .UNKNOWN,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .NodeMask = 0,
            .CachedPSO = CACHED_PIPELINE_STATE.init_zero(),
            .Flags = .{},
        };
        return v;
    }
};

pub const PIPELINE_MESH_STATE_STREAM = extern struct {
    Flags_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .FLAGS,
    Flags: PIPELINE_STATE_FLAGS,
    NodeMask_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .NODE_MASK,
    NodeMask: UINT,
    pRootSignature_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .ROOT_SIGNATURE,
    pRootSignature: ?*IRootSignature,
    PS_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .PS,
    PS: SHADER_BYTECODE,
    AS_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .AS,
    AS: SHADER_BYTECODE,
    MS_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .MS,
    MS: SHADER_BYTECODE,
    BlendState_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .BLEND,
    BlendState: BLEND_DESC,
    DepthStencilState_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .DEPTH_STENCIL1,
    DepthStencilState: DEPTH_STENCIL_DESC1,
    DSVFormat_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .DEPTH_STENCIL_FORMAT,
    DSVFormat: dxgi.FORMAT,
    RasterizerState_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .RASTERIZER,
    RasterizerState: RASTERIZER_DESC,
    RTVFormats_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .RENDER_TARGET_FORMATS,
    RTVFormats: RT_FORMAT_ARRAY,
    SampleDesc_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .SAMPLE_DESC,
    SampleDesc: dxgi.SAMPLE_DESC,
    SampleMask_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .SAMPLE_MASK,
    SampleMask: UINT,
    CachedPSO_type: PIPELINE_STATE_SUBOBJECT_TYPE align(8) = .CACHED_PSO,
    CachedPSO: CACHED_PIPELINE_STATE,

    pub fn init(desc: MESH_SHADER_PIPELINE_STATE_DESC) PIPELINE_MESH_STATE_STREAM {
        const stream = PIPELINE_MESH_STATE_STREAM{
            .Flags = desc.Flags,
            .NodeMask = desc.NodeMask,
            .pRootSignature = desc.pRootSignature,
            .PS = desc.PS,
            .AS = desc.AS,
            .MS = desc.MS,
            .BlendState = desc.BlendState,
            .DepthStencilState = desc.DepthStencilState,
            .DSVFormat = desc.DSVFormat,
            .RasterizerState = desc.RasterizerState,
            .RTVFormats = .{ .RTFormats = desc.RTVFormats, .NumRenderTargets = desc.NumRenderTargets },
            .SampleDesc = desc.SampleDesc,
            .SampleMask = desc.SampleMask,
            .CachedPSO = desc.CachedPSO,
        };
        return stream;
    }
};

pub const IDevice2 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{30baa41e-b15b-475c-a0bb-1af5c5b64328}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreatePipelineState(
                self: *T,
                desc: *const PIPELINE_STATE_STREAM_DESC,
                guid: *const GUID,
                pso: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice2.VTable, @ptrCast(self.__v))
                    .CreatePipelineState(@ptrCast(self), desc, guid, pso);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice1.VTable,
        CreatePipelineState: *const fn (
            *IDevice2,
            *const PIPELINE_STATE_STREAM_DESC,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const RESIDENCY_FLAGS = packed struct(UINT) {
    DENY_OVERBUDGET: bool = false,
    __unused: u31 = 0,
};

pub const IDevice3 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{81dadc15-2bad-4392-93c5-101345c4aa98}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn OpenExistingHeapFromAddress(
                self: *T,
                address: *const anyopaque,
                guid: *const GUID,
                heap: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice3.VTable, @ptrCast(self.__v))
                    .OpenExistingHeapFromAddress(@ptrCast(self), address, guid, heap);
            }
            pub inline fn OpenExistingHeapFromFileMapping(
                self: *T,
                file_mapping: HANDLE,
                guid: *const GUID,
                heap: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice3.VTable, @ptrCast(self.__v))
                    .OpenExistingHeapFromFileMapping(@ptrCast(self), file_mapping, guid, heap);
            }
            pub inline fn EnqueueMakeResident(
                self: *T,
                flags: RESIDENCY_FLAGS,
                num_objects: UINT,
                objects: [*]const *IPageable,
                fence_to_signal: *IFence,
                fence_value_to_signal: UINT64,
            ) HRESULT {
                return @as(*const IDevice3.VTable, @ptrCast(self.__v)).EnqueueMakeResident(
                    @ptrCast(self),
                    flags,
                    num_objects,
                    objects,
                    fence_to_signal,
                    fence_value_to_signal,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice2.VTable,
        OpenExistingHeapFromAddress: *const fn (
            *IDevice3,
            *const anyopaque,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        OpenExistingHeapFromFileMapping: *const fn (
            *IDevice3,
            HANDLE,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        EnqueueMakeResident: *const fn (
            *IDevice3,
            RESIDENCY_FLAGS,
            UINT,
            [*]const *IPageable,
            *IFence,
            UINT64,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const COMMAND_LIST_FLAGS = packed struct(UINT) {
    __unused: u32 = 0,
};

pub const RESOURCE_ALLOCATION_INFO1 = extern struct {
    Offset: UINT64,
    Alignment: UINT64,
    SizeInBytes: UINT64,
};

pub const IDevice4 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{e865df17-a9ee-46f9-a463-3098315aa2e5}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub const CreateCommandList1 = IDevice4.Methods(@This()).CreateCommandList1;
    pub const CreateProtectedResourceSession = IDevice4.Methods(@This()).CreateProtectedResourceSession;
    pub const CreateCommittedResource1 = IDevice4.Methods(@This()).CreateCommittedResource1;
    pub const CreateHeap1 = IDevice4.Methods(@This()).CreateHeap1;
    pub const CreateReservedResource1 = IDevice4.Methods(@This()).CreateReservedResource1;
    pub const GetResourceAllocationInfo1 = IDevice4.Methods(@This()).GetResourceAllocationInfo1;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateCommandList1(
                self: *T,
                node_mask: UINT,
                cmdlist_type: COMMAND_LIST_TYPE,
                flags: COMMAND_LIST_FLAGS,
                guid: *const GUID,
                cmdlist: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice4.VTable, @ptrCast(self.__v))
                    .CreateCommandList1(@ptrCast(self), node_mask, cmdlist_type, flags, guid, cmdlist);
            }
            pub inline fn CreateProtectedResourceSession(
                self: *T,
                desc: *const PROTECTED_RESOURCE_SESSION_DESC,
                guid: *const GUID,
                session: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice4.VTable, @ptrCast(self.__v))
                    .CreateProtectedResourceSession(@ptrCast(self), desc, guid, session);
            }
            pub inline fn CreateCommittedResource1(
                self: *T,
                heap_properties: *const HEAP_PROPERTIES,
                heap_flags: HEAP_FLAGS,
                desc: *const RESOURCE_DESC,
                initial_state: RESOURCE_STATES,
                clear_value: ?*const CLEAR_VALUE,
                psession: ?*IProtectedResourceSession,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice4.VTable, @ptrCast(self.__v)).CreateCommittedResource1(
                    @ptrCast(self),
                    heap_properties,
                    heap_flags,
                    desc,
                    initial_state,
                    clear_value,
                    psession,
                    guid,
                    resource,
                );
            }
            pub inline fn CreateHeap1(
                self: *T,
                desc: *const HEAP_DESC,
                psession: ?*IProtectedResourceSession,
                guid: *const GUID,
                heap: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice4.VTable, @ptrCast(self.__v))
                    .CreateHeap1(@ptrCast(self), desc, psession, guid, heap);
            }
            pub inline fn CreateReservedResource1(
                self: *T,
                desc: *const RESOURCE_DESC,
                initial_state: RESOURCE_STATES,
                clear_value: ?*const CLEAR_VALUE,
                psession: ?*IProtectedResourceSession,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice4.VTable, @ptrCast(self.__v)).CreateReservedResource1(
                    @ptrCast(self),
                    desc,
                    initial_state,
                    clear_value,
                    psession,
                    guid,
                    resource,
                );
            }
            pub inline fn GetResourceAllocationInfo1(
                self: *T,
                visible_mask: UINT,
                num_resource_descs: UINT,
                resource_descs: [*]const RESOURCE_DESC,
                alloc_info: ?[*]RESOURCE_ALLOCATION_INFO1,
            ) RESOURCE_ALLOCATION_INFO {
                var desc: RESOURCE_ALLOCATION_INFO = undefined;
                @as(*const IDevice4.VTable, @ptrCast(self.__v)).GetResourceAllocationInfo1(
                    @ptrCast(self),
                    &desc,
                    visible_mask,
                    num_resource_descs,
                    resource_descs,
                    alloc_info,
                );
                return desc;
            }
        };
    }

    pub const VTable = extern struct {
        const T = IDevice4;
        base: IDevice3.VTable,
        CreateCommandList1: *const fn (
            *T,
            UINT,
            COMMAND_LIST_TYPE,
            COMMAND_LIST_FLAGS,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateProtectedResourceSession: *const fn (
            *T,
            *const PROTECTED_RESOURCE_SESSION_DESC,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateCommittedResource1: *const fn (
            *T,
            *const HEAP_PROPERTIES,
            HEAP_FLAGS,
            *const RESOURCE_DESC,
            RESOURCE_STATES,
            ?*const CLEAR_VALUE,
            ?*IProtectedResourceSession,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateHeap1: *const fn (
            *T,
            *const HEAP_DESC,
            ?*IProtectedResourceSession,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateReservedResource1: *const fn (
            *T,
            *const RESOURCE_DESC,
            RESOURCE_STATES,
            ?*const CLEAR_VALUE,
            ?*IProtectedResourceSession,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        GetResourceAllocationInfo1: *const fn (
            *T,
            *RESOURCE_ALLOCATION_INFO,
            UINT,
            UINT,
            [*]const RESOURCE_DESC,
            ?[*]RESOURCE_ALLOCATION_INFO1,
        ) callconv(WINAPI) *RESOURCE_ALLOCATION_INFO,
    };
};

pub const LIFETIME_STATE = enum(UINT) {
    IN_USE = 0,
    NOT_IN_USE = 1,
};

pub const ILifetimeOwner = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const LifetimeStateUpdated = ILifetimeOwner.Methods(@This()).LifetimeStateUpdated;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn LifetimeStateUpdated(self: *T, new_state: LIFETIME_STATE) void {
                @as(*const ILifetimeOwner.VTable, @ptrCast(self.__v)).LifetimeStateUpdated(@ptrCast(self), new_state);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        LifetimeStateUpdated: *const fn (*ILifetimeOwner, LIFETIME_STATE) callconv(WINAPI) void,
    };
};

pub const IDevice5 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{8b4f173b-2fea-4b80-8f58-4307191ab95d}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub const CreateCommandList1 = IDevice4.Methods(@This()).CreateCommandList1;
    pub const CreateProtectedResourceSession = IDevice4.Methods(@This()).CreateProtectedResourceSession;
    pub const CreateCommittedResource1 = IDevice4.Methods(@This()).CreateCommittedResource1;
    pub const CreateHeap1 = IDevice4.Methods(@This()).CreateHeap1;
    pub const CreateReservedResource1 = IDevice4.Methods(@This()).CreateReservedResource1;
    pub const GetResourceAllocationInfo1 = IDevice4.Methods(@This()).GetResourceAllocationInfo1;

    pub const CreateLifetimeTracker = IDevice5.Methods(@This()).CreateLifetimeTracker;
    pub const RemoveDevice = IDevice5.Methods(@This()).RemoveDevice;
    pub const EnumerateMetaCommands = IDevice5.Methods(@This()).EnumerateMetaCommands;
    pub const EnumerateMetaCommandParameters = IDevice5.Methods(@This()).EnumerateMetaCommandParameters;
    pub const CreateMetaCommand = IDevice5.Methods(@This()).CreateMetaCommand;
    pub const CreateStateObject = IDevice5.Methods(@This()).CreateStateObject;
    pub const GetRaytracingAccelerationStructurePrebuildInfo = IDevice5.Methods(@This()).GetRaytracingAccelerationStructurePrebuildInfo;
    pub const CheckDriverMatchingIdentifier = IDevice5.Methods(@This()).CheckDriverMatchingIdentifier;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateLifetimeTracker(
                self: *T,
                owner: *ILifetimeOwner,
                guid: *const GUID,
                tracker: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice5.VTable, @ptrCast(self.__v))
                    .CreateLifetimeTracker(@ptrCast(self), owner, guid, tracker);
            }
            pub inline fn RemoveDevice(self: *T) void {
                @as(*const IDevice5.VTable, @ptrCast(self.__v)).RemoveDevice(@ptrCast(self));
            }
            pub inline fn EnumerateMetaCommands(
                self: *T,
                num_meta_cmds: *UINT,
                descs: ?[*]META_COMMAND_DESC,
            ) HRESULT {
                return @as(*const IDevice5.VTable, @ptrCast(self.__v))
                    .EnumerateMetaCommands(@ptrCast(self), num_meta_cmds, descs);
            }
            pub inline fn EnumerateMetaCommandParameters(
                self: *T,
                cmd_id: *const GUID,
                stage: META_COMMAND_PARAMETER_STAGE,
                total_size: ?*UINT,
                param_count: *UINT,
                param_descs: ?[*]META_COMMAND_PARAMETER_DESC,
            ) HRESULT {
                return @as(*const IDevice5.VTable, @ptrCast(self.__v)).EnumerateMetaCommandParameters(
                    @ptrCast(self),
                    cmd_id,
                    stage,
                    total_size,
                    param_count,
                    param_descs,
                );
            }
            pub inline fn CreateMetaCommand(
                self: *T,
                cmd_id: *const GUID,
                node_mask: UINT,
                creation_param_data: ?*const anyopaque,
                creation_param_data_size: SIZE_T,
                guid: *const GUID,
                meta_cmd: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice5.VTable, @ptrCast(self.__v)).CreateMetaCommand(
                    @ptrCast(self),
                    cmd_id,
                    node_mask,
                    creation_param_data,
                    creation_param_data_size,
                    guid,
                    meta_cmd,
                );
            }
            pub inline fn CreateStateObject(
                self: *T,
                desc: *const STATE_OBJECT_DESC,
                guid: *const GUID,
                state_object: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice5.VTable, @ptrCast(self.__v))
                    .CreateStateObject(@ptrCast(self), desc, guid, state_object);
            }
            pub inline fn GetRaytracingAccelerationStructurePrebuildInfo(
                self: *T,
                desc: *const BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS,
                info: *RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO,
            ) void {
                @as(*const IDevice5.VTable, @ptrCast(self.__v))
                    .GetRaytracingAccelerationStructurePrebuildInfo(@ptrCast(self), desc, info);
            }
            pub inline fn CheckDriverMatchingIdentifier(
                self: *T,
                serialized_data_type: SERIALIZED_DATA_TYPE,
                identifier_to_check: *const SERIALIZED_DATA_DRIVER_MATCHING_IDENTIFIER,
            ) DRIVER_MATCHING_IDENTIFIER_STATUS {
                return @as(*const IDevice5.VTable, @ptrCast(self.__v)).CheckDriverMatchingIdentifier(
                    @ptrCast(self),
                    serialized_data_type,
                    identifier_to_check,
                );
            }
        };
    }

    pub const VTable = extern struct {
        const T = IDevice5;
        base: IDevice4.VTable,
        CreateLifetimeTracker: *const fn (
            *T,
            *ILifetimeOwner,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        RemoveDevice: *const fn (self: *T) callconv(WINAPI) void,
        EnumerateMetaCommands: *const fn (*T, *UINT, ?[*]META_COMMAND_DESC) callconv(WINAPI) HRESULT,
        EnumerateMetaCommandParameters: *const fn (
            *T,
            *const GUID,
            META_COMMAND_PARAMETER_STAGE,
            ?*UINT,
            *UINT,
            ?[*]META_COMMAND_PARAMETER_DESC,
        ) callconv(WINAPI) HRESULT,
        CreateMetaCommand: *const fn (
            *T,
            *const GUID,
            UINT,
            ?*const anyopaque,
            SIZE_T,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateStateObject: *const fn (
            *T,
            *const STATE_OBJECT_DESC,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        GetRaytracingAccelerationStructurePrebuildInfo: *const fn (
            *T,
            *const BUILD_RAYTRACING_ACCELERATION_STRUCTURE_INPUTS,
            *RAYTRACING_ACCELERATION_STRUCTURE_PREBUILD_INFO,
        ) callconv(WINAPI) void,
        CheckDriverMatchingIdentifier: *const fn (
            *T,
            SERIALIZED_DATA_TYPE,
            *const SERIALIZED_DATA_DRIVER_MATCHING_IDENTIFIER,
        ) callconv(WINAPI) DRIVER_MATCHING_IDENTIFIER_STATUS,
    };
};

pub const BACKGROUND_PROCESSING_MODE = enum(UINT) {
    ALLOWED = 0,
    ALLOW_INTRUSIVE_MEASUREMENTS = 1,
    DISABLE_BACKGROUND_WORK = 2,
    DISABLE_PROFILING_BY_SYSTEM = 3,
};

pub const MEASUREMENTS_ACTION = enum(UINT) {
    KEEP_ALL = 0,
    COMMIT_RESULTS = 1,
    COMMIT_RESULTS_HIGH_PRIORITY = 2,
    DISCARD_PREVIOUS = 3,
};

pub const IDevice6 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{c70b221b-40e4-4a17-89af-025a0727a6dc}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub const CreateCommandList1 = IDevice4.Methods(@This()).CreateCommandList1;
    pub const CreateProtectedResourceSession = IDevice4.Methods(@This()).CreateProtectedResourceSession;
    pub const CreateCommittedResource1 = IDevice4.Methods(@This()).CreateCommittedResource1;
    pub const CreateHeap1 = IDevice4.Methods(@This()).CreateHeap1;
    pub const CreateReservedResource1 = IDevice4.Methods(@This()).CreateReservedResource1;
    pub const GetResourceAllocationInfo1 = IDevice4.Methods(@This()).GetResourceAllocationInfo1;

    pub const CreateLifetimeTracker = IDevice5.Methods(@This()).CreateLifetimeTracker;
    pub const RemoveDevice = IDevice5.Methods(@This()).RemoveDevice;
    pub const EnumerateMetaCommands = IDevice5.Methods(@This()).EnumerateMetaCommands;
    pub const EnumerateMetaCommandParameters = IDevice5.Methods(@This()).EnumerateMetaCommandParameters;
    pub const CreateMetaCommand = IDevice5.Methods(@This()).CreateMetaCommand;
    pub const CreateStateObject = IDevice5.Methods(@This()).CreateStateObject;
    pub const GetRaytracingAccelerationStructurePrebuildInfo = IDevice5.Methods(@This()).GetRaytracingAccelerationStructurePrebuildInfo;
    pub const CheckDriverMatchingIdentifier = IDevice5.Methods(@This()).CheckDriverMatchingIdentifier;

    pub const SetBackgroundProcessingMode = IDevice6.Methods(@This()).SetBackgroundProcessingMode;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetBackgroundProcessingMode(
                self: *T,
                mode: BACKGROUND_PROCESSING_MODE,
                measurements_action: MEASUREMENTS_ACTION,
                event_to_signal_upon_completion: ?HANDLE,
                further_measurements_desired: ?*BOOL,
            ) HRESULT {
                return @as(*const IDevice6.VTable, @ptrCast(self.__v)).SetBackgroundProcessingMode(
                    @ptrCast(self),
                    mode,
                    measurements_action,
                    event_to_signal_upon_completion,
                    further_measurements_desired,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice5.VTable,
        SetBackgroundProcessingMode: *const fn (
            *IDevice6,
            BACKGROUND_PROCESSING_MODE,
            MEASUREMENTS_ACTION,
            ?HANDLE,
            ?*BOOL,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const PROTECTED_RESOURCE_SESSION_DESC1 = extern struct {
    NodeMask: UINT,
    Flags: PROTECTED_RESOURCE_SESSION_FLAGS,
    ProtectionType: GUID,
};

pub const IDevice7 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{5c014b53-68a1-4b9b-8bd1-dd6046b9358b}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub const CreateCommandList1 = IDevice4.Methods(@This()).CreateCommandList1;
    pub const CreateProtectedResourceSession = IDevice4.Methods(@This()).CreateProtectedResourceSession;
    pub const CreateCommittedResource1 = IDevice4.Methods(@This()).CreateCommittedResource1;
    pub const CreateHeap1 = IDevice4.Methods(@This()).CreateHeap1;
    pub const CreateReservedResource1 = IDevice4.Methods(@This()).CreateReservedResource1;
    pub const GetResourceAllocationInfo1 = IDevice4.Methods(@This()).GetResourceAllocationInfo1;

    pub const CreateLifetimeTracker = IDevice5.Methods(@This()).CreateLifetimeTracker;
    pub const RemoveDevice = IDevice5.Methods(@This()).RemoveDevice;
    pub const EnumerateMetaCommands = IDevice5.Methods(@This()).EnumerateMetaCommands;
    pub const EnumerateMetaCommandParameters = IDevice5.Methods(@This()).EnumerateMetaCommandParameters;
    pub const CreateMetaCommand = IDevice5.Methods(@This()).CreateMetaCommand;
    pub const CreateStateObject = IDevice5.Methods(@This()).CreateStateObject;
    pub const GetRaytracingAccelerationStructurePrebuildInfo = IDevice5.Methods(@This()).GetRaytracingAccelerationStructurePrebuildInfo;
    pub const CheckDriverMatchingIdentifier = IDevice5.Methods(@This()).CheckDriverMatchingIdentifier;

    pub const SetBackgroundProcessingMode = IDevice6.Methods(@This()).SetBackgroundProcessingMode;

    pub const AddToStateObject = IDevice7.Methods(@This()).AddToStateObject;
    pub const CreateProtectedResourceSession1 = IDevice7.Methods(@This()).CreateProtectedResourceSession1;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AddToStateObject(
                self: *T,
                addition: *const STATE_OBJECT_DESC,
                state_object: *IStateObject,
                guid: *const GUID,
                new_state_object: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice7.VTable, @ptrCast(self.__v))
                    .AddToStateObject(@ptrCast(self), addition, state_object, guid, new_state_object);
            }
            pub inline fn CreateProtectedResourceSession1(
                self: *T,
                desc: *const PROTECTED_RESOURCE_SESSION_DESC1,
                guid: *const GUID,
                session: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice7.VTable, @ptrCast(self.__v))
                    .CreateProtectedResourceSession1(@ptrCast(self), desc, guid, session);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice6.VTable,
        AddToStateObject: *const fn (
            *IDevice7,
            *const STATE_OBJECT_DESC,
            *IStateObject,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateProtectedResourceSession1: *const fn (
            *IDevice7,
            *const PROTECTED_RESOURCE_SESSION_DESC1,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const MIP_REGION = extern struct {
    Width: UINT,
    Height: UINT,
    Depth: UINT,
};

pub const RESOURCE_DESC1 = extern struct {
    Dimension: RESOURCE_DIMENSION,
    Alignment: UINT64,
    Width: UINT64,
    Height: UINT,
    DepthOrArraySize: UINT16,
    MipLevels: UINT16,
    Format: dxgi.FORMAT,
    SampleDesc: dxgi.SAMPLE_DESC,
    Layout: TEXTURE_LAYOUT,
    Flags: RESOURCE_FLAGS,
    SamplerFeedbackMipRegion: MIP_REGION,
};

pub const IDevice8 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{9218E6BB-F944-4F7E-A75C-B1B2C7B701F3}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub const CreateCommandList1 = IDevice4.Methods(@This()).CreateCommandList1;
    pub const CreateProtectedResourceSession = IDevice4.Methods(@This()).CreateProtectedResourceSession;
    pub const CreateCommittedResource1 = IDevice4.Methods(@This()).CreateCommittedResource1;
    pub const CreateHeap1 = IDevice4.Methods(@This()).CreateHeap1;
    pub const CreateReservedResource1 = IDevice4.Methods(@This()).CreateReservedResource1;
    pub const GetResourceAllocationInfo1 = IDevice4.Methods(@This()).GetResourceAllocationInfo1;

    pub const CreateLifetimeTracker = IDevice5.Methods(@This()).CreateLifetimeTracker;
    pub const RemoveDevice = IDevice5.Methods(@This()).RemoveDevice;
    pub const EnumerateMetaCommands = IDevice5.Methods(@This()).EnumerateMetaCommands;
    pub const EnumerateMetaCommandParameters = IDevice5.Methods(@This()).EnumerateMetaCommandParameters;
    pub const CreateMetaCommand = IDevice5.Methods(@This()).CreateMetaCommand;
    pub const CreateStateObject = IDevice5.Methods(@This()).CreateStateObject;
    pub const GetRaytracingAccelerationStructurePrebuildInfo = IDevice5.Methods(@This()).GetRaytracingAccelerationStructurePrebuildInfo;
    pub const CheckDriverMatchingIdentifier = IDevice5.Methods(@This()).CheckDriverMatchingIdentifier;

    pub const SetBackgroundProcessingMode = IDevice6.Methods(@This()).SetBackgroundProcessingMode;

    pub const AddToStateObject = IDevice7.Methods(@This()).AddToStateObject;
    pub const CreateProtectedResourceSession1 = IDevice7.Methods(@This()).CreateProtectedResourceSession1;

    pub const GetResourceAllocationInfo2 = IDevice8.Methods(@This()).GetResourceAllocationInfo2;
    pub const CreateCommittedResource2 = IDevice8.Methods(@This()).CreateCommittedResource2;
    pub const CreatePlacedResource1 = IDevice8.Methods(@This()).CreatePlacedResource1;
    pub const CreateSamplerFeedbackUnorderedAccessView = IDevice8.Methods(@This()).CreateSamplerFeedbackUnorderedAccessView;
    pub const GetCopyableFootprints1 = IDevice8.Methods(@This()).GetCopyableFootprints1;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetResourceAllocationInfo2(
                self: *T,
                visible_mask: UINT,
                num_resource_descs: UINT,
                resource_descs: *const RESOURCE_DESC1,
                alloc_info: ?[*]RESOURCE_ALLOCATION_INFO1,
            ) RESOURCE_ALLOCATION_INFO {
                var desc: RESOURCE_ALLOCATION_INFO = undefined;
                @as(*const IDevice8.VTable, @ptrCast(self.__v)).GetResourceAllocationInfo2(
                    @ptrCast(self),
                    &desc,
                    visible_mask,
                    num_resource_descs,
                    resource_descs,
                    alloc_info,
                );
                return desc;
            }
            pub inline fn CreateCommittedResource2(
                self: *T,
                heap_properties: *const HEAP_PROPERTIES,
                heap_flags: HEAP_FLAGS,
                desc: *const RESOURCE_DESC1,
                initial_state: RESOURCE_STATES,
                clear_value: ?*const CLEAR_VALUE,
                prsession: ?*IProtectedResourceSession,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice8.VTable, @ptrCast(self.__v)).CreateCommittedResource2(
                    @ptrCast(self),
                    heap_properties,
                    heap_flags,
                    desc,
                    initial_state,
                    clear_value,
                    prsession,
                    guid,
                    resource,
                );
            }
            pub inline fn CreatePlacedResource1(
                self: *T,
                heap: *IHeap,
                heap_offset: UINT64,
                desc: *const RESOURCE_DESC1,
                initial_state: RESOURCE_STATES,
                clear_value: ?*const CLEAR_VALUE,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice8.VTable, @ptrCast(self.__v)).CreatePlacedResource1(
                    @ptrCast(self),
                    heap,
                    heap_offset,
                    desc,
                    initial_state,
                    clear_value,
                    guid,
                    resource,
                );
            }
            pub inline fn CreateSamplerFeedbackUnorderedAccessView(
                self: *T,
                targeted_resource: ?*IResource,
                feedback_resource: ?*IResource,
                dest_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IDevice8.VTable, @ptrCast(self.__v)).CreateSamplerFeedbackUnorderedAccessView(
                    @ptrCast(self),
                    targeted_resource,
                    feedback_resource,
                    dest_descriptor,
                );
            }
            pub inline fn GetCopyableFootprints1(
                self: *T,
                desc: *const RESOURCE_DESC1,
                first_subresource: UINT,
                num_subresources: UINT,
                base_offset: UINT64,
                layouts: ?[*]PLACED_SUBRESOURCE_FOOTPRINT,
                num_rows: ?[*]UINT,
                row_size_in_bytes: ?[*]UINT64,
                total_bytes: ?*UINT64,
            ) void {
                @as(*const IDevice8.VTable, @ptrCast(self.__v)).GetCopyableFootprints1(
                    @ptrCast(self),
                    desc,
                    first_subresource,
                    num_subresources,
                    base_offset,
                    layouts,
                    num_rows,
                    row_size_in_bytes,
                    total_bytes,
                );
            }
        };
    }

    pub const VTable = extern struct {
        const T = IDevice8;
        base: IDevice7.VTable,
        GetResourceAllocationInfo2: *const fn (
            *T,
            UINT,
            UINT,
            *const RESOURCE_DESC1,
            ?[*]RESOURCE_ALLOCATION_INFO1,
        ) callconv(WINAPI) RESOURCE_ALLOCATION_INFO,
        CreateCommittedResource2: *const fn (
            *T,
            *const HEAP_PROPERTIES,
            HEAP_FLAGS,
            *const RESOURCE_DESC1,
            RESOURCE_STATES,
            ?*const CLEAR_VALUE,
            ?*IProtectedResourceSession,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreatePlacedResource1: *const fn (
            *T,
            *IHeap,
            UINT64,
            *const RESOURCE_DESC1,
            RESOURCE_STATES,
            ?*const CLEAR_VALUE,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateSamplerFeedbackUnorderedAccessView: *const fn (
            *T,
            ?*IResource,
            ?*IResource,
            CPU_DESCRIPTOR_HANDLE,
        ) callconv(WINAPI) void,
        GetCopyableFootprints1: *const fn (
            *T,
            *const RESOURCE_DESC1,
            UINT,
            UINT,
            UINT64,
            ?[*]PLACED_SUBRESOURCE_FOOTPRINT,
            ?[*]UINT,
            ?[*]UINT64,
            ?*UINT64,
        ) callconv(WINAPI) void,
    };
};

pub const SHADER_CACHE_KIND_FLAGS = packed struct(UINT) {
    IMPLICIT_D3D_CACHE_FOR_DRIVER: bool = false,
    IMPLICIT_D3D_CONVERSIONS: bool = false,
    IMPLICIT_DRIVER_MANAGED: bool = false,
    APPLICATION_MANAGED: bool = false,
    __unused: u28 = 0,
};

pub const SHADER_CACHE_CONTROL_FLAGS = packed struct(UINT) {
    DISABLE: bool = false,
    ENABLE: bool = false,
    CLEAR: bool = false,
    __unused: u29 = 0,
};

pub const SHADER_CACHE_MODE = enum(UINT) {
    MEMORY = 0,
    DISK = 1,
};

pub const SHADER_CACHE_FLAGS = packed struct(UINT) {
    DRIVER_VERSIONED: bool = false,
    USE_WORKING_DIR: bool = false,
    __unused: u30 = 0,
};

pub const SHADER_CACHE_SESSION_DESC = extern struct {
    Identifier: GUID,
    Mode: SHADER_CACHE_MODE,
    Flags: SHADER_CACHE_FLAGS,
    MaximumInMemoryCacheSizeBytes: UINT,
    MaximumInMemoryCacheEntries: UINT,
    MaximumValueFileSizeBytes: UINT,
    Version: UINT64,
};

pub const IDevice9 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{4c80e962-f032-4f60-bc9e-ebc2cfa1d83c}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub const CreateCommandList1 = IDevice4.Methods(@This()).CreateCommandList1;
    pub const CreateProtectedResourceSession = IDevice4.Methods(@This()).CreateProtectedResourceSession;
    pub const CreateCommittedResource1 = IDevice4.Methods(@This()).CreateCommittedResource1;
    pub const CreateHeap1 = IDevice4.Methods(@This()).CreateHeap1;
    pub const CreateReservedResource1 = IDevice4.Methods(@This()).CreateReservedResource1;
    pub const GetResourceAllocationInfo1 = IDevice4.Methods(@This()).GetResourceAllocationInfo1;

    pub const CreateLifetimeTracker = IDevice5.Methods(@This()).CreateLifetimeTracker;
    pub const RemoveDevice = IDevice5.Methods(@This()).RemoveDevice;
    pub const EnumerateMetaCommands = IDevice5.Methods(@This()).EnumerateMetaCommands;
    pub const EnumerateMetaCommandParameters = IDevice5.Methods(@This()).EnumerateMetaCommandParameters;
    pub const CreateMetaCommand = IDevice5.Methods(@This()).CreateMetaCommand;
    pub const CreateStateObject = IDevice5.Methods(@This()).CreateStateObject;
    pub const GetRaytracingAccelerationStructurePrebuildInfo = IDevice5.Methods(@This()).GetRaytracingAccelerationStructurePrebuildInfo;
    pub const CheckDriverMatchingIdentifier = IDevice5.Methods(@This()).CheckDriverMatchingIdentifier;

    pub const SetBackgroundProcessingMode = IDevice6.Methods(@This()).SetBackgroundProcessingMode;

    pub const AddToStateObject = IDevice7.Methods(@This()).AddToStateObject;
    pub const CreateProtectedResourceSession1 = IDevice7.Methods(@This()).CreateProtectedResourceSession1;

    pub const GetResourceAllocationInfo2 = IDevice8.Methods(@This()).GetResourceAllocationInfo2;
    pub const CreateCommittedResource2 = IDevice8.Methods(@This()).CreateCommittedResource2;
    pub const CreatePlacedResource1 = IDevice8.Methods(@This()).CreatePlacedResource1;
    pub const CreateSamplerFeedbackUnorderedAccessView = IDevice8.Methods(@This()).CreateSamplerFeedbackUnorderedAccessView;
    pub const GetCopyableFootprints1 = IDevice8.Methods(@This()).GetCopyableFootprints1;

    pub const CreateShaderCacheSession = IDevice9.Methods(@This()).CreateShaderCacheSession;
    pub const ShaderCacheControl = IDevice9.Methods(@This()).ShaderCacheControl;
    pub const CreateCommandQueue1 = IDevice9.Methods(@This()).CreateCommandQueue1;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateShaderCacheSession(
                self: *T,
                desc: *const SHADER_CACHE_SESSION_DESC,
                guid: *const GUID,
                session: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice9.VTable, @ptrCast(self.__v))
                    .CreateShaderCacheSession(@ptrCast(self), desc, guid, session);
            }
            pub inline fn ShaderCacheControl(
                self: *T,
                kinds: SHADER_CACHE_KIND_FLAGS,
                control: SHADER_CACHE_CONTROL_FLAGS,
            ) HRESULT {
                return @as(*const IDevice9.VTable, @ptrCast(self.__v))
                    .ShaderCacheControl(@ptrCast(self), kinds, control);
            }
            pub inline fn CreateCommandQueue1(
                self: *T,
                desc: *const COMMAND_QUEUE_DESC,
                creator_id: *const GUID,
                guid: *const GUID,
                cmdqueue: *?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice9.VTable, @ptrCast(self.__v))
                    .CreateCommandQueue1(@ptrCast(self), desc, creator_id, guid, cmdqueue);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice8.VTable,
        CreateShaderCacheSession: *const fn (
            *IDevice9,
            *const SHADER_CACHE_SESSION_DESC,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        ShaderCacheControl: *const fn (
            *IDevice9,
            SHADER_CACHE_KIND_FLAGS,
            SHADER_CACHE_CONTROL_FLAGS,
        ) callconv(WINAPI) HRESULT,
        CreateCommandQueue1: *const fn (
            *IDevice9,
            *const COMMAND_QUEUE_DESC,
            *const GUID,
            *const GUID,
            *?*anyopaque,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const BARRIER_LAYOUT = enum(UINT) {
    PRESENT,
    GENERIC_READ,
    RENDER_TARGET,
    UNORDERED_ACCESS,
    DEPTH_STENCIL_WRITE,
    DEPTH_STENCIL_READ,
    SHADER_RESOURCE,
    COPY_SOURCE,
    COPY_DEST,
    RESOLVE_SOURCE,
    RESOLVE_DEST,
    SHADING_RATE_SOURCE,
    VIDEO_DECODE_READ,
    VIDEO_DECODE_WRITE,
    VIDEO_PROCESS_READ,
    VIDEO_PROCESS_WRITE,
    VIDEO_ENCODE_READ,
    VIDEO_ENCODE_WRITE,
    DIRECT_QUEUE_COMMON,
    DIRECT_QUEUE_GENERIC_READ,
    DIRECT_QUEUE_UNORDERED_ACCESS,
    DIRECT_QUEUE_SHADER_RESOURCE,
    DIRECT_QUEUE_COPY_SOURCE,
    DIRECT_QUEUE_COPY_DEST,
    COMPUTE_QUEUE_COMMON,
    COMPUTE_QUEUE_GENERIC_READ,
    COMPUTE_QUEUE_UNORDERED_ACCESS,
    COMPUTE_QUEUE_SHADER_RESOURCE,
    COMPUTE_QUEUE_COPY_SOURCE,
    COMPUTE_QUEUE_COPY_DEST,
    VIDEO_QUEUE_COMMON,
    UNDEFINED = 0xffffffff,

    pub const COMMON = .PRESENT;
};

pub const BARRIER_SYNC = packed struct(UINT) {
    ALL: bool = false, // 0x1
    DRAW: bool = false,
    INDEX_INPUT: bool = false,
    VERTEX_SHADING: bool = false,
    PIXEL_SHADING: bool = false, // 0x10
    DEPTH_STENCIL: bool = false,
    RENDER_TARGET: bool = false,
    COMPUTE_SHADING: bool = false,
    RAYTRACING: bool = false, // 0x100
    COPY: bool = false,
    RESOLVE: bool = false,
    EXECUTE_INDIRECT_OR_PREDICATION: bool = false,
    ALL_SHADING: bool = false, // 0x1000
    NON_PIXEL_SHADING: bool = false,
    EMIT_RAYTRACING_ACCELERATION_STRUCTURE_POSTBUILD_INFO: bool = false,
    CLEAR_UNORDERED_ACCESS_VIEW: bool = false,
    __unused16: bool = false, // 0x10000
    __unused17: bool = false,
    __unused18: bool = false,
    __unused19: bool = false,
    VIDEO_DECODE: bool = false, // 0x100000
    VIDEO_PROCESS: bool = false,
    VIDEO_ENCODE: bool = false,
    BUILD_RAYTRACING_ACCELERATION_STRUCTURE: bool = false,
    COPY_RAYTRACING_ACCELERATION_STRUCTURE: bool = false, // 0x1000000
    __unused25: bool = false,
    __unused26: bool = false,
    __unused27: bool = false,
    __unused28: bool = false, // 0x10000000
    __unused29: bool = false,
    __unused30: bool = false,
    SPLIT: bool = false,
};

pub const BARRIER_ACCESS = packed struct(UINT) {
    VERTEX_BUFFER: bool = false,
    CONSTANT_BUFFER: bool = false,
    INDEX_BUFFER: bool = false,
    RENDER_TARGET: bool = false,
    UNORDERED_ACCESS: bool = false,
    DEPTH_STENCIL_WRITE: bool = false,
    DEPTH_STENCIL_READ: bool = false,
    SHADER_RESOURCE: bool = false,
    STREAM_OUTPUT: bool = false,
    INDIRECT_ARGUMENT_OR_PREDICATION: bool = false,
    COPY_DEST: bool = false,
    COPY_SOURCE: bool = false,
    RESOLVE_DEST: bool = false,
    RESOLVE_SOURCE: bool = false,
    RAYTRACING_ACCELERATION_STRUCTURE_READ: bool = false,
    RAYTRACING_ACCELERATION_STRUCTURE_WRITE: bool = false,
    SHADING_RATE_SOURCE: bool = false,
    VIDEO_DECODE_READ: bool = false,
    VIDEO_DECODE_WRITE: bool = false,
    VIDEO_PROCESS_READ: bool = false,
    VIDEO_PROCESS_WRITE: bool = false,
    VIDEO_ENCODE_READ: bool = false,
    VIDEO_ENCODE_WRITE: bool = false,
    __unused23: bool = false,
    __unused24: bool = false,
    __unused25: bool = false,
    __unused26: bool = false,
    __unused27: bool = false,
    __unused28: bool = false,
    __unused29: bool = false,
    __unused30: bool = false,
    NO_ACCESS: bool = false,

    pub const COMMON = BARRIER_ACCESS{};
};

pub const BARRIER_TYPE = enum(UINT) {
    GLOBAL,
    TEXTURE,
    BUFFER,
};

pub const TEXTURE_BARRIER_FLAGS = packed struct(UINT) {
    DISCARD: bool = false,
    __unused: u31 = 0,
};

pub const BARRIER_SUBRESOURCE_RANGE = extern struct {
    IndexOrFirstMipLevel: UINT,
    NumMipLevels: UINT = 0,
    FirstArraySlice: UINT = 0,
    NumArraySlices: UINT = 0,
    FirstPlane: UINT = 0,
    NumPlanes: UINT = 0,
};

pub const GLOBAL_BARRIER = extern struct {
    SyncBefore: BARRIER_SYNC,
    SyncAfter: BARRIER_SYNC,
    AccessBefore: BARRIER_ACCESS,
    AccessAfter: BARRIER_ACCESS,
};

pub const TEXTURE_BARRIER = extern struct {
    SyncBefore: BARRIER_SYNC,
    SyncAfter: BARRIER_SYNC,
    AccessBefore: BARRIER_ACCESS,
    AccessAfter: BARRIER_ACCESS,
    LayoutBefore: BARRIER_LAYOUT,
    LayoutAfter: BARRIER_LAYOUT,
    pResource: *IResource,
    Subresources: BARRIER_SUBRESOURCE_RANGE,
    Flags: TEXTURE_BARRIER_FLAGS,
};

pub const BUFFER_BARRIER = extern struct {
    SyncBefore: BARRIER_SYNC,
    SyncAfter: BARRIER_SYNC,
    AccessBefore: BARRIER_ACCESS,
    AccessAfter: BARRIER_ACCESS,
    pResource: *IResource,
    Offset: UINT64,
    Size: UINT64,
};

pub const BARRIER_GROUP = extern struct {
    Type: BARRIER_TYPE,
    NumBarriers: UINT32,
    u: extern union {
        pGlobalBarriers: [*]const GLOBAL_BARRIER,
        pTextureBarriers: [*]const TEXTURE_BARRIER,
        pBufferBarriers: [*]const BUFFER_BARRIER,
    },
};

pub const IDevice10 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{517f8718-aa66-49f9-b02b-a7ab89c06031}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub const CreateCommandList1 = IDevice4.Methods(@This()).CreateCommandList1;
    pub const CreateProtectedResourceSession = IDevice4.Methods(@This()).CreateProtectedResourceSession;
    pub const CreateCommittedResource1 = IDevice4.Methods(@This()).CreateCommittedResource1;
    pub const CreateHeap1 = IDevice4.Methods(@This()).CreateHeap1;
    pub const CreateReservedResource1 = IDevice4.Methods(@This()).CreateReservedResource1;
    pub const GetResourceAllocationInfo1 = IDevice4.Methods(@This()).GetResourceAllocationInfo1;

    pub const CreateLifetimeTracker = IDevice5.Methods(@This()).CreateLifetimeTracker;
    pub const RemoveDevice = IDevice5.Methods(@This()).RemoveDevice;
    pub const EnumerateMetaCommands = IDevice5.Methods(@This()).EnumerateMetaCommands;
    pub const EnumerateMetaCommandParameters = IDevice5.Methods(@This()).EnumerateMetaCommandParameters;
    pub const CreateMetaCommand = IDevice5.Methods(@This()).CreateMetaCommand;
    pub const CreateStateObject = IDevice5.Methods(@This()).CreateStateObject;
    pub const GetRaytracingAccelerationStructurePrebuildInfo = IDevice5.Methods(@This()).GetRaytracingAccelerationStructurePrebuildInfo;
    pub const CheckDriverMatchingIdentifier = IDevice5.Methods(@This()).CheckDriverMatchingIdentifier;

    pub const SetBackgroundProcessingMode = IDevice6.Methods(@This()).SetBackgroundProcessingMode;

    pub const AddToStateObject = IDevice7.Methods(@This()).AddToStateObject;
    pub const CreateProtectedResourceSession1 = IDevice7.Methods(@This()).CreateProtectedResourceSession1;

    pub const GetResourceAllocationInfo2 = IDevice8.Methods(@This()).GetResourceAllocationInfo2;
    pub const CreateCommittedResource2 = IDevice8.Methods(@This()).CreateCommittedResource2;
    pub const CreatePlacedResource1 = IDevice8.Methods(@This()).CreatePlacedResource1;
    pub const CreateSamplerFeedbackUnorderedAccessView = IDevice8.Methods(@This()).CreateSamplerFeedbackUnorderedAccessView;
    pub const GetCopyableFootprints1 = IDevice8.Methods(@This()).GetCopyableFootprints1;

    pub const CreateShaderCacheSession = IDevice9.Methods(@This()).CreateShaderCacheSession;
    pub const ShaderCacheControl = IDevice9.Methods(@This()).ShaderCacheControl;
    pub const CreateCommandQueue1 = IDevice9.Methods(@This()).CreateCommandQueue1;

    pub const CreateCommittedResource3 = IDevice10.Methods(@This()).CreateCommittedResource3;
    pub const CreatePlacedResource2 = IDevice10.Methods(@This()).CreatePlacedResource2;
    pub const CreateReservedResource2 = IDevice10.Methods(@This()).CreateReservedResource2;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateCommittedResource3(
                self: *T,
                heap_properties: *const HEAP_PROPERTIES,
                heap_flags: HEAP_FLAGS,
                desc: *const RESOURCE_DESC1,
                initial_layout: BARRIER_LAYOUT,
                clear_value: ?*const CLEAR_VALUE,
                prsession: ?*IProtectedResourceSession,
                num_castable_formats: UINT32,
                castable_formats: ?[*]dxgi.FORMAT,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice10.VTable, @ptrCast(self.__v)).CreateCommittedResource3(
                    @ptrCast(self),
                    heap_properties,
                    heap_flags,
                    desc,
                    initial_layout,
                    clear_value,
                    prsession,
                    num_castable_formats,
                    castable_formats,
                    guid,
                    resource,
                );
            }
            pub inline fn CreatePlacedResource2(
                self: *T,
                heap: *IHeap,
                heap_offset: UINT64,
                desc: *const RESOURCE_DESC1,
                initial_layout: BARRIER_LAYOUT,
                clear_value: ?*const CLEAR_VALUE,
                num_castable_formats: UINT32,
                castable_formats: ?[*]dxgi.FORMAT,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice10.VTable, @ptrCast(self.__v)).CreatePlacedResource2(
                    @ptrCast(self),
                    heap,
                    heap_offset,
                    desc,
                    initial_layout,
                    clear_value,
                    num_castable_formats,
                    castable_formats,
                    guid,
                    resource,
                );
            }
            pub inline fn CreateReservedResource2(
                self: *T,
                desc: *const RESOURCE_DESC,
                initial_layout: BARRIER_LAYOUT,
                clear_value: ?*const CLEAR_VALUE,
                psession: ?*IProtectedResourceSession,
                num_castable_formats: UINT32,
                castable_formats: ?[*]dxgi.FORMAT,
                guid: *const GUID,
                resource: ?*?*anyopaque,
            ) HRESULT {
                return @as(*const IDevice10.VTable, @ptrCast(self.__v)).CreateReservedResource2(
                    @ptrCast(self),
                    desc,
                    initial_layout,
                    clear_value,
                    psession,
                    num_castable_formats,
                    castable_formats,
                    guid,
                    resource,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice9.VTable,
        CreateCommittedResource3: *const fn (
            *IDevice10,
            *const HEAP_PROPERTIES,
            HEAP_FLAGS,
            *const RESOURCE_DESC1,
            BARRIER_LAYOUT,
            ?*const CLEAR_VALUE,
            ?*IProtectedResourceSession,
            UINT32,
            ?[*]dxgi.FORMAT,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreatePlacedResource2: *const fn (
            *IDevice10,
            *IHeap,
            UINT64,
            *const RESOURCE_DESC1,
            BARRIER_LAYOUT,
            ?*const CLEAR_VALUE,
            UINT32,
            ?[*]dxgi.FORMAT,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
        CreateReservedResource2: *const fn (
            *IDevice10,
            *const RESOURCE_DESC,
            BARRIER_LAYOUT,
            ?*const CLEAR_VALUE,
            ?*IProtectedResourceSession,
            UINT32,
            ?[*]dxgi.FORMAT,
            *const GUID,
            ?*?*anyopaque,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const SAMPLER_FLAGS = packed struct(UINT) {
    UINT_BORDER_COLOR: bool = false,
    __unused: u31 = 0,
};

pub const SAMPLER_DESC2 = extern struct {
    Filter: FILTER,
    AddressU: TEXTURE_ADDRESS_MODE,
    AddressV: TEXTURE_ADDRESS_MODE,
    AddressW: TEXTURE_ADDRESS_MODE,
    MipLODBias: FLOAT,
    MaxAnisotropy: UINT,
    ComparisonFunc: COMPARISON_FUNC,
    u: extern union {
        FloatBorderColor: [4]FLOAT,
        UintBorderColor: [4]UINT,
    },
    MinLOD: FLOAT,
    MaxLOD: FLOAT,
    Flags: SAMPLER_FLAGS,
};

pub const IDevice11 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{5405c344-d457-444e-b4dd-2366e45aee39}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetNodeCount = IDevice.Methods(@This()).GetNodeCount;
    pub const CreateCommandQueue = IDevice.Methods(@This()).CreateCommandQueue;
    pub const CreateCommandAllocator = IDevice.Methods(@This()).CreateCommandAllocator;
    pub const CreateGraphicsPipelineState = IDevice.Methods(@This()).CreateGraphicsPipelineState;
    pub const CreateComputePipelineState = IDevice.Methods(@This()).CreateComputePipelineState;
    pub const CreateCommandList = IDevice.Methods(@This()).CreateCommandList;
    pub const CheckFeatureSupport = IDevice.Methods(@This()).CheckFeatureSupport;
    pub const CreateDescriptorHeap = IDevice.Methods(@This()).CreateDescriptorHeap;
    pub const GetDescriptorHandleIncrementSize = IDevice.Methods(@This()).GetDescriptorHandleIncrementSize;
    pub const CreateRootSignature = IDevice.Methods(@This()).CreateRootSignature;
    pub const CreateConstantBufferView = IDevice.Methods(@This()).CreateConstantBufferView;
    pub const CreateShaderResourceView = IDevice.Methods(@This()).CreateShaderResourceView;
    pub const CreateUnorderedAccessView = IDevice.Methods(@This()).CreateUnorderedAccessView;
    pub const CreateRenderTargetView = IDevice.Methods(@This()).CreateRenderTargetView;
    pub const CreateDepthStencilView = IDevice.Methods(@This()).CreateDepthStencilView;
    pub const CreateSampler = IDevice.Methods(@This()).CreateSampler;
    pub const CopyDescriptors = IDevice.Methods(@This()).CopyDescriptors;
    pub const CopyDescriptorsSimple = IDevice.Methods(@This()).CopyDescriptorsSimple;
    pub const GetResourceAllocationInfo = IDevice.Methods(@This()).GetResourceAllocationInfo;
    pub const GetCustomHeapProperties = IDevice.Methods(@This()).GetCustomHeapProperties;
    pub const CreateCommittedResource = IDevice.Methods(@This()).CreateCommittedResource;
    pub const CreateHeap = IDevice.Methods(@This()).CreateHeap;
    pub const CreatePlacedResource = IDevice.Methods(@This()).CreatePlacedResource;
    pub const CreateReservedResource = IDevice.Methods(@This()).CreateReservedResource;
    pub const CreateSharedHandle = IDevice.Methods(@This()).CreateSharedHandle;
    pub const OpenSharedHandle = IDevice.Methods(@This()).OpenSharedHandle;
    pub const OpenSharedHandleByName = IDevice.Methods(@This()).OpenSharedHandleByName;
    pub const MakeResident = IDevice.Methods(@This()).MakeResident;
    pub const Evict = IDevice.Methods(@This()).Evict;
    pub const CreateFence = IDevice.Methods(@This()).CreateFence;
    pub const GetDeviceRemovedReason = IDevice.Methods(@This()).GetDeviceRemovedReason;
    pub const GetCopyableFootprints = IDevice.Methods(@This()).GetCopyableFootprints;
    pub const CreateQueryHeap = IDevice.Methods(@This()).CreateQueryHeap;
    pub const SetStablePowerState = IDevice.Methods(@This()).SetStablePowerState;
    pub const CreateCommandSignature = IDevice.Methods(@This()).CreateCommandSignature;
    pub const GetResourceTiling = IDevice.Methods(@This()).GetResourceTiling;
    pub const GetAdapterLuid = IDevice.Methods(@This()).GetAdapterLuid;

    pub const CreatePipelineLibrary = IDevice1.Methods(@This()).CreatePipelineLibrary;
    pub const SetEventOnMultipleFenceCompletion = IDevice1.Methods(@This()).SetEventOnMultipleFenceCompletion;
    pub const SetResidencyPriority = IDevice1.Methods(@This()).SetResidencyPriority;

    pub const CreatePipelineState = IDevice2.Methods(@This()).CreatePipelineState;

    pub const OpenExistingHeapFromAddress = IDevice3.Methods(@This()).OpenExistingHeapFromAddress;
    pub const OpenExistingHeapFromFileMapping = IDevice3.Methods(@This()).OpenExistingHeapFromFileMapping;
    pub const EnqueueMakeResident = IDevice3.Methods(@This()).EnqueueMakeResident;

    pub const CreateCommandList1 = IDevice4.Methods(@This()).CreateCommandList1;
    pub const CreateProtectedResourceSession = IDevice4.Methods(@This()).CreateProtectedResourceSession;
    pub const CreateCommittedResource1 = IDevice4.Methods(@This()).CreateCommittedResource1;
    pub const CreateHeap1 = IDevice4.Methods(@This()).CreateHeap1;
    pub const CreateReservedResource1 = IDevice4.Methods(@This()).CreateReservedResource1;
    pub const GetResourceAllocationInfo1 = IDevice4.Methods(@This()).GetResourceAllocationInfo1;

    pub const CreateLifetimeTracker = IDevice5.Methods(@This()).CreateLifetimeTracker;
    pub const RemoveDevice = IDevice5.Methods(@This()).RemoveDevice;
    pub const EnumerateMetaCommands = IDevice5.Methods(@This()).EnumerateMetaCommands;
    pub const EnumerateMetaCommandParameters = IDevice5.Methods(@This()).EnumerateMetaCommandParameters;
    pub const CreateMetaCommand = IDevice5.Methods(@This()).CreateMetaCommand;
    pub const CreateStateObject = IDevice5.Methods(@This()).CreateStateObject;
    pub const GetRaytracingAccelerationStructurePrebuildInfo = IDevice5.Methods(@This()).GetRaytracingAccelerationStructurePrebuildInfo;
    pub const CheckDriverMatchingIdentifier = IDevice5.Methods(@This()).CheckDriverMatchingIdentifier;

    pub const SetBackgroundProcessingMode = IDevice6.Methods(@This()).SetBackgroundProcessingMode;

    pub const AddToStateObject = IDevice7.Methods(@This()).AddToStateObject;
    pub const CreateProtectedResourceSession1 = IDevice7.Methods(@This()).CreateProtectedResourceSession1;

    pub const GetResourceAllocationInfo2 = IDevice8.Methods(@This()).GetResourceAllocationInfo2;
    pub const CreateCommittedResource2 = IDevice8.Methods(@This()).CreateCommittedResource2;
    pub const CreatePlacedResource1 = IDevice8.Methods(@This()).CreatePlacedResource1;
    pub const CreateSamplerFeedbackUnorderedAccessView = IDevice8.Methods(@This()).CreateSamplerFeedbackUnorderedAccessView;
    pub const GetCopyableFootprints1 = IDevice8.Methods(@This()).GetCopyableFootprints1;

    pub const CreateShaderCacheSession = IDevice9.Methods(@This()).CreateShaderCacheSession;
    pub const ShaderCacheControl = IDevice9.Methods(@This()).ShaderCacheControl;
    pub const CreateCommandQueue1 = IDevice9.Methods(@This()).CreateCommandQueue1;

    pub const CreateCommittedResource3 = IDevice10.Methods(@This()).CreateCommittedResource3;
    pub const CreatePlacedResource2 = IDevice10.Methods(@This()).CreatePlacedResource2;
    pub const CreateReservedResource2 = IDevice10.Methods(@This()).CreateReservedResource2;

    pub const CreateSampler2 = IDevice11.Methods(@This()).CreateSampler2;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateSampler2(
                self: *T,
                desc: *const SAMPLER_DESC2,
                dst_descriptor: CPU_DESCRIPTOR_HANDLE,
            ) void {
                @as(*const IDevice11.VTable, @ptrCast(self.__v))
                    .CreateSampler2(@ptrCast(self), desc, dst_descriptor);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDevice10.VTable,
        CreateSampler2: *const fn (*IDevice11, *const SAMPLER_DESC2, CPU_DESCRIPTOR_HANDLE) callconv(WINAPI) void,
    };
};

pub const PROTECTED_SESSION_STATUS = enum(UINT) {
    OK = 0,
    INVALID = 1,
};

pub const IProtectedSession = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetStatusFence = IProtectedSession.Methods(@This()).GetStatusFence;
    pub const GetSessionStatus = IProtectedSession.Methods(@This()).GetSessionStatus;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetStatusFence(self: *T, guid: *const GUID, fence: ?*?*anyopaque) HRESULT {
                return @as(*const IProtectedSession.VTable, @ptrCast(self.__v))
                    .GetStatusFence(@ptrCast(self), guid, fence);
            }
            pub inline fn GetSessionStatus(self: *T) PROTECTED_SESSION_STATUS {
                return @as(*const IProtectedSession.VTable, @ptrCast(self.__v)).GetSessionStatus(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IDeviceChild.VTable,
        GetStatusFence: *const fn (*IProtectedSession, *const GUID, ?*?*anyopaque) callconv(WINAPI) HRESULT,
        GetSessionStatus: *const fn (*IProtectedSession) callconv(WINAPI) PROTECTED_SESSION_STATUS,
    };
};

pub const PROTECTED_RESOURCE_SESSION_FLAGS = packed struct(UINT) {
    __unused: u32 = 0,
};

pub const PROTECTED_RESOURCE_SESSION_DESC = extern struct {
    NodeMask: UINT,
    Flags: PROTECTED_RESOURCE_SESSION_FLAGS,
};

pub const IProtectedResourceSession = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetPrivateData = IObject.Methods(@This()).GetPrivateData;
    pub const SetPrivateData = IObject.Methods(@This()).SetPrivateData;
    pub const SetPrivateDataInterface = IObject.Methods(@This()).SetPrivateDataInterface;
    pub const SetName = IObject.Methods(@This()).SetName;

    pub const GetStatusFence = IProtectedSession.Methods(@This()).GetStatusFence;
    pub const GetSessionStatus = IProtectedSession.Methods(@This()).GetSessionStatus;

    pub const GetDesc = IProtectedResourceSession.Methods(@This()).GetDesc;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetDesc(self: *T) PROTECTED_RESOURCE_SESSION_DESC {
                var desc: PROTECTED_RESOURCE_SESSION_DESC = undefined;
                _ = @as(*const IProtectedResourceSession.VTable, @ptrCast(self.__v)).GetDesc(@ptrCast(self), &desc);
                return desc;
            }
        };
    }

    pub const VTable = extern struct {
        base: IProtectedSession.VTable,
        GetDesc: *const fn (
            *IProtectedResourceSession,
            *PROTECTED_RESOURCE_SESSION_DESC,
        ) callconv(WINAPI) *PROTECTED_RESOURCE_SESSION_DESC,
    };
};

extern "d3d12" fn D3D12GetDebugInterface(*const GUID, ?*?*anyopaque) callconv(WINAPI) HRESULT;

extern "d3d12" fn D3D12CreateDevice(
    ?*IUnknown,
    d3d.FEATURE_LEVEL,
    *const GUID,
    ?*?*anyopaque,
) callconv(WINAPI) HRESULT;

extern "d3d12" fn D3D12SerializeVersionedRootSignature(
    *const VERSIONED_ROOT_SIGNATURE_DESC,
    ?*?*d3d.IBlob,
    ?*?*d3d.IBlob,
) callconv(WINAPI) HRESULT;

pub const CreateDevice = D3D12CreateDevice;
pub const GetDebugInterface = D3D12GetDebugInterface;
pub const SerializeVersionedRootSignature = D3D12SerializeVersionedRootSignature;

pub const DEBUG_FEATURE = packed struct(UINT) {
    ALLOW_BEHAVIOR_CHANGING_DEBUG_AIDS: bool = false,
    CONSERVATIVE_RESOURCE_STATE_TRACKING: bool = false,
    DISABLE_VIRTUALIZED_BUNDLES_VALIDATION: bool = false,
    EMULATE_WINDOWS7: bool = false,
    __unused: u28 = 0,
};

pub const RLDO_FLAGS = packed struct(UINT) {
    SUMMARY: bool = false,
    DETAIL: bool = false,
    IGNORE_INTERNAL: bool = false,
    ALL: bool = false,
    __unused: u28 = 0,
};

pub const IDebugDevice = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{3febd6dd-4973-4787-8194-e45f9e28923e}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const SetFeatureMask = IDebugDevice.Methods(@This()).SetFeatureMask;
    pub const GetFeatureMask = IDebugDevice.Methods(@This()).GetFeatureMask;
    pub const ReportLiveDeviceObjects = IDebugDevice.Methods(@This()).ReportLiveDeviceObjects;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetFeatureMask(self: *T, mask: DEBUG_FEATURE) HRESULT {
                return @as(*const IDebugDevice.VTable, @ptrCast(self.__v))
                    .SetFeatureMask(@ptrCast(self), mask);
            }
            pub inline fn GetFeatureMask(self: *T) DEBUG_FEATURE {
                return @as(*const IDebugDevice.VTable, @ptrCast(self.__v)).GetFeatureMask(@ptrCast(self));
            }
            pub inline fn ReportLiveDeviceObjects(self: *T, flags: RLDO_FLAGS) HRESULT {
                return @as(*const IDebugDevice.VTable, @ptrCast(self.__v))
                    .ReportLiveDeviceObjects(@ptrCast(self), flags);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetFeatureMask: *const fn (*IDebugDevice, DEBUG_FEATURE) callconv(WINAPI) HRESULT,
        GetFeatureMask: *const fn (*IDebugDevice) callconv(WINAPI) DEBUG_FEATURE,
        ReportLiveDeviceObjects: *const fn (*IDebugDevice, RLDO_FLAGS) callconv(WINAPI) HRESULT,
    };
};

// https://docs.microsoft.com/en-us/windows/win32/direct3d12/d3d12-graphics-reference-returnvalues
pub const ERROR_ADAPTER_NOT_FOUND = @as(HRESULT, @bitCast(@as(c_ulong, 0x887E0001)));
pub const ERROR_DRIVER_VERSION_MISMATCH = @as(HRESULT, @bitCast(@as(c_ulong, 0x887E0002)));
