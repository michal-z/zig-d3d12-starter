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
const ULONG = w32.ULONG;
const ULARGE_INTEGER = w32.ULARGE_INTEGER;

pub const ISequentialStream = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{0c733a30-2a1c-11ce-ade5-00aa0044773d}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        Read: *anyopaque,
        Write: *anyopaque,
    };
};

pub const IStream = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{0000000c-0000-0000-C000-000000000046}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: ISequentialStream.VTable,
        Seek: *anyopaque,
        SetSize: *anyopaque,
        CopyTo: *anyopaque,
        Commit: *anyopaque,
        Revert: *anyopaque,
        LockRegion: *anyopaque,
        UnlockRegion: *anyopaque,
        Stat: *anyopaque,
        Clone: *anyopaque,
    };
};
