const w32 = @import("win32.zig");
const d3d12 = @import("d3d12.zig");
const IUnknown = w32.IUnknown;
const HRESULT = w32.HRESULT;
const WINAPI = w32.WINAPI;
const GUID = w32.GUID;
const UINT = w32.UINT;
const BOOL = w32.BOOL;

pub const GPU_BASED_VALIDATION_FLAGS = packed struct(UINT) {
    DISABLE_STATE_TRACKING: bool = false,
    __unused: u31 = 0,
};

pub const IDebug = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const EnableDebugLayer = IDebug.Methods(@This()).EnableDebugLayer;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn EnableDebugLayer(self: *T) void {
                @as(*const IDebug.VTable, @ptrCast(self.__v)).EnableDebugLayer(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        EnableDebugLayer: *const fn (*IDebug) callconv(WINAPI) void,
    };
};

pub const IDebug3 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const EnableDebugLayer = IDebug.Methods(@This()).EnableDebugLayer;

    pub const SetEnableGPUBasedValidation = IDebug3.Methods(@This()).SetEnableGPUBasedValidation;
    pub const SetEnableSynchronizedCommandQueueValidation = IDebug3.Methods(@This()).SetEnableSynchronizedCommandQueueValidation;
    pub const SetGPUBasedValidationFlags = IDebug3.Methods(@This()).SetGPUBasedValidationFlags;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetEnableGPUBasedValidation(self: *T, enable: BOOL) void {
                @as(*const IDebug3.VTable, @ptrCast(self.__v)).SetEnableGPUBasedValidation(@ptrCast(self), enable);
            }
            pub inline fn SetEnableSynchronizedCommandQueueValidation(self: *T, enable: BOOL) void {
                @as(*const IDebug3.VTable, @ptrCast(self.__v))
                    .SetEnableSynchronizedCommandQueueValidation(@ptrCast(self), enable);
            }
            pub inline fn SetGPUBasedValidationFlags(self: *T, flags: GPU_BASED_VALIDATION_FLAGS) void {
                @as(*const IDebug3.VTable, @ptrCast(self.__v)).SetGPUBasedValidationFlags(@ptrCast(self), flags);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDebug.VTable,
        SetEnableGPUBasedValidation: *const fn (*IDebug3, BOOL) callconv(WINAPI) void,
        SetEnableSynchronizedCommandQueueValidation: *const fn (*IDebug3, BOOL) callconv(WINAPI) void,
        SetGPUBasedValidationFlags: *const fn (*IDebug3, GPU_BASED_VALIDATION_FLAGS) callconv(WINAPI) void,
    };
};

pub const IDebug4 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const EnableDebugLayer = IDebug.Methods(@This()).EnableDebugLayer;

    pub const SetEnableGPUBasedValidation = IDebug3.Methods(@This()).SetEnableGPUBasedValidation;
    pub const SetEnableSynchronizedCommandQueueValidation = IDebug3.Methods(@This()).SetEnableSynchronizedCommandQueueValidation;
    pub const SetGPUBasedValidationFlags = IDebug3.Methods(@This()).SetGPUBasedValidationFlags;

    pub const DisableDebugLayer = IDebug4.Methods(@This()).DisableDebugLayer;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn DisableDebugLayer(self: *T) void {
                @as(*const IDebug4.VTable, @ptrCast(self.__v)).DisableDebugLayer(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IDebug3.VTable,
        DisableDebugLayer: *const fn (*IDebug4) callconv(WINAPI) void,
    };
};

pub const IDebug5 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{548d6b12-09fa-40e0-9069-5dcd589a52c9}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const EnableDebugLayer = IDebug.Methods(@This()).EnableDebugLayer;

    pub const SetEnableGPUBasedValidation = IDebug3.Methods(@This()).SetEnableGPUBasedValidation;
    pub const SetEnableSynchronizedCommandQueueValidation = IDebug3.Methods(@This()).SetEnableSynchronizedCommandQueueValidation;
    pub const SetGPUBasedValidationFlags = IDebug3.Methods(@This()).SetGPUBasedValidationFlags;

    pub const DisableDebugLayer = IDebug4.Methods(@This()).DisableDebugLayer;

    pub const SetEnableAutoName = IDebug5.Methods(@This()).SetEnableAutoName;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn SetEnableAutoName(self: *T, enable: BOOL) void {
                @as(*const IDebug5.VTable, @ptrCast(self.__v)).SetEnableAutoName(@ptrCast(self), enable);
            }
        };
    }

    pub const VTable = extern struct {
        base: IDebug4.VTable,
        SetEnableAutoName: *const fn (*IDebug5, BOOL) callconv(WINAPI) void,
    };
};

pub const MESSAGE_CATEGORY = enum(UINT) {
    APPLICATION_DEFINED = 0,
    MISCELLANEOUS = 1,
    INITIALIZATION = 2,
    CLEANUP = 3,
    COMPILATION = 4,
    STATE_CREATION = 5,
    STATE_SETTING = 6,
    STATE_GETTING = 7,
    RESOURCE_MANIPULATION = 8,
    EXECUTION = 9,
    SHADER = 10,
};

pub const MESSAGE_SEVERITY = enum(UINT) {
    CORRUPTION = 0,
    ERROR = 1,
    WARNING = 2,
    INFO = 3,
    MESSAGE = 4,
};

pub const MESSAGE_ID = enum(UINT) {
    CLEARRENDERTARGETVIEW_MISMATCHINGCLEARVALUE = 820,
    COMMAND_LIST_DRAW_VERTEX_BUFFER_STRIDE_TOO_SMALL = 209,
    CREATEGRAPHICSPIPELINESTATE_DEPTHSTENCILVIEW_NOT_SET = 680,
};

pub const INFO_QUEUE_FILTER_DESC = extern struct {
    NumCategories: u32,
    pCategoryList: ?[*]MESSAGE_CATEGORY,
    NumSeverities: u32,
    pSeverityList: ?[*]MESSAGE_SEVERITY,
    NumIDs: u32,
    pIDList: ?[*]MESSAGE_ID,
};

pub const INFO_QUEUE_FILTER = extern struct {
    AllowList: INFO_QUEUE_FILTER_DESC,
    DenyList: INFO_QUEUE_FILTER_DESC,
};

pub const IInfoQueue = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{0742a90b-c387-483f-b946-30a7e4e61458}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const AddStorageFilterEntries = IInfoQueue.Methods(@This()).AddStorageFilterEntries;
    pub const PushStorageFilter = IInfoQueue.Methods(@This()).PushStorageFilter;
    pub const PopStorageFilter = IInfoQueue.Methods(@This()).PopStorageFilter;
    pub const SetBreakOnSeverity = IInfoQueue.Methods(@This()).SetBreakOnSeverity;
    pub const SetMuteDebugOutput = IInfoQueue.Methods(@This()).SetMuteDebugOutput;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AddStorageFilterEntries(self: *T, filter: *INFO_QUEUE_FILTER) HRESULT {
                return @as(*const IInfoQueue.VTable, @ptrCast(self.__v))
                    .AddStorageFilterEntries(@ptrCast(self), filter);
            }
            pub inline fn PushStorageFilter(self: *T, filter: *INFO_QUEUE_FILTER) HRESULT {
                return @as(*const IInfoQueue.VTable, @ptrCast(self.__v)).PushStorageFilter(@ptrCast(self), filter);
            }
            pub inline fn PopStorageFilter(self: *T) void {
                @as(*const IInfoQueue.VTable, @ptrCast(self.__v)).PopStorageFilter(@ptrCast(self));
            }
            pub inline fn SetBreakOnSeverity(self: *T, severity: MESSAGE_SEVERITY, enable: BOOL) HRESULT {
                return @as(*const IInfoQueue.VTable, @ptrCast(self.__v)).SetBreakOnSeverity(
                    @ptrCast(self),
                    severity,
                    enable,
                );
            }
            pub inline fn SetMuteDebugOutput(self: *T, mute: BOOL) void {
                @as(*const IInfoQueue.VTable, @ptrCast(self.__v)).SetMuteDebugOutput(@ptrCast(self), mute);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        SetMessageCountLimit: *anyopaque,
        ClearStoredMessages: *anyopaque,
        GetMessage: *anyopaque,
        GetNumMessagesAllowedByStorageFilter: *anyopaque,
        GetNumMessagesDeniedByStorageFilter: *anyopaque,
        GetNumStoredMessages: *anyopaque,
        GetNumStoredMessagesAllowedByRetrievalFilter: *anyopaque,
        GetNumMessagesDiscardedByMessageCountLimit: *anyopaque,
        GetMessageCountLimit: *anyopaque,
        AddStorageFilterEntries: *const fn (*IInfoQueue, *INFO_QUEUE_FILTER) callconv(WINAPI) HRESULT,
        GetStorageFilter: *anyopaque,
        ClearStorageFilter: *anyopaque,
        PushEmptyStorageFilter: *anyopaque,
        PushCopyOfStorageFilter: *anyopaque,
        PushStorageFilter: *const fn (*IInfoQueue, *INFO_QUEUE_FILTER) callconv(WINAPI) HRESULT,
        PopStorageFilter: *const fn (*IInfoQueue) callconv(WINAPI) void,
        GetStorageFilterStackSize: *anyopaque,
        AddRetrievalFilterEntries: *anyopaque,
        GetRetrievalFilter: *anyopaque,
        ClearRetrievalFilter: *anyopaque,
        PushEmptyRetrievalFilter: *anyopaque,
        PushCopyOfRetrievalFilter: *anyopaque,
        PushRetrievalFilter: *anyopaque,
        PopRetrievalFilter: *anyopaque,
        GetRetrievalFilterStackSize: *anyopaque,
        AddMessage: *anyopaque,
        AddApplicationMessage: *anyopaque,
        SetBreakOnCategory: *anyopaque,
        SetBreakOnSeverity: *const fn (*IInfoQueue, MESSAGE_SEVERITY, BOOL) callconv(WINAPI) HRESULT,
        SetBreakOnID: *anyopaque,
        GetBreakOnCategory: *anyopaque,
        GetBreakOnSeverity: *anyopaque,
        GetBreakOnID: *anyopaque,
        SetMuteDebugOutput: *const fn (*IInfoQueue, BOOL) callconv(WINAPI) void,
        GetMuteDebugOutput: *anyopaque,
    };
};

pub const IDebugCommandQueue = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const AssertResourceState = IDebugCommandQueue.Methods(@This()).AssertResourceState;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AssertResourceState(
                self: *T,
                resource: *d3d12.IResource,
                subresource: UINT,
                state: d3d12.RESOURCE_STATES,
            ) BOOL {
                return @as(*const IDebugCommandQueue.VTable, @ptrCast(self.__v)).AssertResourceState(
                    @ptrCast(self),
                    resource,
                    subresource,
                    state,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        AssertResourceState: *const fn (
            *IDebugCommandQueue,
            *d3d12.IResource,
            UINT,
            d3d12.RESOURCE_STATES,
        ) callconv(WINAPI) BOOL,
    };
};

pub const IDebugCommandQueue1 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{16be35a2-bfd6-49f2-bcae-eaae4aff862d}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const AssertResourceState = IDebugCommandQueue.Methods(@This()).AssertResourceState;

    pub const AssertResourceAccess = IDebugCommandQueue1.Methods(@This()).AssertResourceAccess;
    pub const AssertTextureLayout = IDebugCommandQueue1.Methods(@This()).AssertTextureLayout;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AssertResourceAccess(
                self: *T,
                resource: *d3d12.IResource,
                subresource: UINT,
                access: d3d12.BARRIER_ACCESS,
            ) void {
                @as(*const IDebugCommandQueue1.VTable, @ptrCast(self.__v)).AssertResourceAccess(
                    @ptrCast(self),
                    resource,
                    subresource,
                    access,
                );
            }
            pub inline fn AssertTextureLayout(
                self: *T,
                resource: *d3d12.IResource,
                subresource: UINT,
                layout: d3d12.BARRIER_LAYOUT,
            ) void {
                @as(*const IDebugCommandQueue1.VTable, @ptrCast(self.__v)).AssertTextureLayout(
                    @ptrCast(self),
                    resource,
                    subresource,
                    layout,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IDebugCommandQueue.VTable,
        AssertResourceAccess: *const fn (
            *IDebugCommandQueue1,
            *d3d12.IResource,
            UINT,
            d3d12.BARRIER_ACCESS,
        ) callconv(WINAPI) void,
        AssertTextureLayout: *const fn (
            *IDebugCommandQueue1,
            *d3d12.IResource,
            UINT,
            d3d12.BARRIER_LAYOUT,
        ) callconv(WINAPI) void,
    };
};

pub const DEBUG_FEATURE = packed struct(UINT) {
    ALLOW_BEHAVIOR_CHANGING_DEBUG_AIDS: bool = false,
    CONSERVATIVE_RESOURCE_STATE_TRACKING: bool = false,
    DISABLE_VIRTUALIZED_BUNDLES_VALIDATION: bool = false,
    EMULATE_WINDOWS7: bool = false,
    __unused: u28 = 0,
};

pub const IDebugCommandList = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const AssertResourceState = IDebugCommandList.Methods(@This()).AssertResourceState;
    pub const SetFeatureMask = IDebugCommandList.Methods(@This()).SetFeatureMask;
    pub const GetFeatureMask = IDebugCommandList.Methods(@This()).GetFeatureMask;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AssertResourceState(
                self: *T,
                resource: *d3d12.IResource,
                subresource: UINT,
                state: d3d12.RESOURCE_STATES,
            ) BOOL {
                return @as(*const IDebugCommandList.VTable, @ptrCast(self.__v)).AssertResourceState(
                    @ptrCast(self),
                    resource,
                    subresource,
                    state,
                );
            }
            pub inline fn SetFeatureMask(self: *T, mask: DEBUG_FEATURE) HRESULT {
                return @as(*const IDebugCommandList.VTable, @ptrCast(self.__v)).SetFeatureMask(@ptrCast(self), mask);
            }
            pub inline fn GetFeatureMask(self: *T) DEBUG_FEATURE {
                return @as(*const IDebugCommandList.VTable, @ptrCast(self.__v)).GetFeatureMask(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        AssertResourceState: *const fn (
            *IDebugCommandList,
            *d3d12.IResource,
            UINT,
            d3d12.RESOURCE_STATES,
        ) callconv(WINAPI) BOOL,
        SetFeatureMask: *const fn (*IDebugCommandList, DEBUG_FEATURE) callconv(WINAPI) HRESULT,
        GetFeatureMask: *const fn (*IDebugCommandList) callconv(WINAPI) DEBUG_FEATURE,
    };
};

pub const IDebugCommandList2 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const AssertResourceState = IDebugCommandList.Methods(@This()).AssertResourceState;
    pub const SetFeatureMask = IDebugCommandList.Methods(@This()).SetFeatureMask;
    pub const GetFeatureMask = IDebugCommandList.Methods(@This()).GetFeatureMask;

    pub const VTable = extern struct {
        base: IDebugCommandList.VTable,
        SetDebugParameter: *anyopaque,
        GetDebugParameter: *anyopaque,
    };
};

pub const IDebugCommandList3 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{197d5e15-4d37-4d34-af78-724cd70fdb1f}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const AssertResourceState = IDebugCommandList.Methods(@This()).AssertResourceState;
    pub const SetFeatureMask = IDebugCommandList.Methods(@This()).SetFeatureMask;
    pub const GetFeatureMask = IDebugCommandList.Methods(@This()).GetFeatureMask;

    pub const AssertResourceAccess = IDebugCommandList3.Methods(@This()).AssertResourceAccess;
    pub const AssertTextureLayout = IDebugCommandList3.Methods(@This()).AssertTextureLayout;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn AssertResourceAccess(
                self: *T,
                resource: *d3d12.IResource,
                subresource: UINT,
                access: d3d12.BARRIER_ACCESS,
            ) void {
                @as(*const IDebugCommandList3.VTable, @ptrCast(self.__v)).AssertResourceAccess(
                    @ptrCast(self),
                    resource,
                    subresource,
                    access,
                );
            }
            pub inline fn AssertTextureLayout(
                self: *T,
                resource: *d3d12.IResource,
                subresource: UINT,
                layout: d3d12.BARRIER_LAYOUT,
            ) void {
                @as(*const IDebugCommandList3.VTable, @ptrCast(self.__v)).AssertTextureLayout(
                    @ptrCast(self),
                    resource,
                    subresource,
                    layout,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IDebugCommandList2.VTable,
        AssertResourceAccess: *const fn (
            *IDebugCommandList3,
            *d3d12.IResource,
            UINT,
            d3d12.BARRIER_ACCESS,
        ) callconv(WINAPI) void,
        AssertTextureLayout: *const fn (
            *IDebugCommandList3,
            *d3d12.IResource,
            UINT,
            d3d12.BARRIER_LAYOUT,
        ) callconv(WINAPI) void,
    };
};
