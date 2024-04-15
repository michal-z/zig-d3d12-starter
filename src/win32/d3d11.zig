const w32 = @import("win32.zig");
const IUnknown = w32.IUnknown;
const UINT = w32.UINT;
const WINAPI = w32.WINAPI;
const GUID = w32.GUID;
const HRESULT = w32.HRESULT;
const HMODULE = w32.HMODULE;
const SIZE_T = w32.SIZE_T;
const LPCSTR = w32.LPCSTR;
const FLOAT = w32.FLOAT;
const BOOL = w32.BOOL;
const TRUE = w32.TRUE;
const FALSE = w32.FALSE;
const INT = w32.INT;
const UINT8 = w32.UINT8;

const d3dcommon = @import("d3dcommon.zig");
const FEATURE_LEVEL = d3dcommon.FEATURE_LEVEL;
const DRIVER_TYPE = d3dcommon.DRIVER_TYPE;

const dxgi = @import("dxgi.zig");

pub const CREATE_DEVICE_FLAG = packed struct(UINT) {
    SINGLETHREADED: bool = false,
    DEBUG: bool = false,
    SWITCH_TO_REF: bool = false,
    PREVENT_INTERNAL_THREADING_OPTIMIZATIONS: bool = false,
    __unused4: bool = false,
    BGRA_SUPPORT: bool = false,
    DEBUGGABLE: bool = false,
    PREVENT_ALTERING_LAYER_SETTINGS_FROM_REGISTRY: bool = false,
    DISABLE_GPU_TIMEOUT: bool = false,
    __unused9: bool = false,
    __unused10: bool = false,
    VIDEO_SUPPORT: bool = false,
    __unused: u20 = 0,
};

pub const SDK_VERSION = 7;

pub const IDevice = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        CreateBuffer: *anyopaque,
        CreateTexture1D: *anyopaque,
        CreateTexture2D: *anyopaque,
        CreateTexture3D: *anyopaque,
        CreateShaderResourceView: *anyopaque,
        CreateUnorderedAccessView: *anyopaque,
        CreateRenderTargetView: *anyopaque,
        CreateDepthStencilView: *anyopaque,
        CreateInputLayout: *anyopaque,
        CreateVertexShader: *anyopaque,
        CreateGeometryShader: *anyopaque,
        CreateGeometryShaderWithStreamOutput: *anyopaque,
        CreatePixelShader: *anyopaque,
        CreateHullShader: *anyopaque,
        CreateDomainShader: *anyopaque,
        CreateComputeShader: *anyopaque,
        CreateClassLinkage: *anyopaque,
        CreateBlendState: *anyopaque,
        CreateDepthStencilState: *anyopaque,
        CreateRasterizerState: *anyopaque,
        CreateSamplerState: *anyopaque,
        CreateQuery: *anyopaque,
        CreatePredicate: *anyopaque,
        CreateCounter: *anyopaque,
        CreateDeferredContext: *anyopaque,
        OpenSharedResource: *anyopaque,
        CheckFormatSupport: *anyopaque,
        CheckMultisampleQualityLevels: *anyopaque,
        CheckCounterInfo: *anyopaque,
        CheckCounter: *anyopaque,
        CheckFeatureSupport: *anyopaque,
        GetPrivateData: *anyopaque,
        SetPrivateData: *anyopaque,
        SetPrivateDataInterface: *anyopaque,
        GetFeatureLevel: *anyopaque,
        GetCreationFlags: *anyopaque,
        GetDeviceRemovedReason: *anyopaque,
        GetImmediateContext: *anyopaque,
        SetExceptionMode: *anyopaque,
        GetExceptionMode: *anyopaque,
    };
};

pub const IDevice1 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{a04bfb29-08ef-43d6-a49c-a9bdbdcbe686}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IDevice.VTable,
        GetImmediateContext1: *anyopaque,
        CreateDeferredContext1: *anyopaque,
        CreateBlendState1: *anyopaque,
        CreateRasterizerState1: *anyopaque,
        CreateDeviceContextState: *anyopaque,
        OpenSharedResource1: *anyopaque,
        OpenSharedResourceByName: *anyopaque,
    };
};

pub const CreateDevice = D3D11CreateDevice;
extern "d3d11" fn D3D11CreateDevice(
    pAdapter: ?*dxgi.IAdapter,
    DriverType: DRIVER_TYPE,
    Software: ?HMODULE,
    Flags: CREATE_DEVICE_FLAG,
    pFeatureLevels: ?[*]const FEATURE_LEVEL,
    FeatureLevels: UINT,
    SDKVersion: UINT,
    ppDevice: ?*?*IDevice,
    pFeatureLevel: ?*FEATURE_LEVEL,
    ppImmediateContext: ?*?*anyopaque,
) callconv(WINAPI) HRESULT;
