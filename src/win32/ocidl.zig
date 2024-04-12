const w32 = @import("win32.zig");
const IUnknown = w32.IUnknown;
const WINAPI = w32.WINAPI;
const HRESULT = w32.HRESULT;
const GUID = w32.GUID;
const LPCWSTR = w32.LPCWSTR;
const DWORD = w32.DWORD;
const UINT = w32.UINT;
const INT = w32.INT;
const BYTE = w32.BYTE;

pub const IPropertyBag2 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        Read: *anyopaque,
        Write: *anyopaque,
        CountProperties: *anyopaque,
        GetPropertyInfo: *anyopaque,
        LoadObject: *anyopaque,
    };
};
