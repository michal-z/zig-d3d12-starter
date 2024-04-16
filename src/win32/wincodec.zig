const w32 = @import("win32.zig");
const IUnknown = w32.IUnknown;
const WINAPI = w32.WINAPI;
const HRESULT = w32.HRESULT;
const GUID = w32.GUID;
const LPCWSTR = w32.LPCWSTR;
const DWORD = w32.DWORD;
const UINT = w32.UINT;
const UINT32 = w32.UINT32;
const INT = w32.INT;
const BYTE = w32.BYTE;
const FLOAT = w32.FLOAT;
const objidl = @import("objidl.zig");
const ocidl = @import("ocidl.zig");
const IPropertyBag2 = ocidl.IPropertyBag2;
const d2d1 = @import("d2d1.zig");

pub const PixelFormatGUID = w32.GUID;

pub const Rect = extern struct {
    X: INT,
    Y: INT,
    Width: INT,
    Height: INT,
};

pub const DecodeOptions = enum(UINT) {
    MetadataCacheOnDemand = 0,
    MetadataCacheOnLoad = 0x1,
};

pub const BitmapEncoderCacheOption = enum(UINT) {
    CacheInMemory = 0,
    CacheTempFile = 0x1,
    NoCache = 0x2,
};

pub const BitmapCreateCacheOption = enum(UINT) {
    NoCache = 0,
    CacheOnDemand = 0x1,
    CacheOnLoad = 0x2,
};

pub const BitmapPaletteType = enum(UINT) {
    Custom = 0,
    MedianCut = 0x1,
    FixedBW = 0x2,
    FixedHalftone8 = 0x3,
    FixedHalftone27 = 0x4,
    FixedHalftone64 = 0x5,
    FixedHalftone125 = 0x6,
    FixedHalftone216 = 0x7,
    FixedHalftone252 = 0x8,
    FixedHalftone256 = 0x9,
    FixedGray4 = 0xa,
    FixedGray16 = 0xb,
    FixedGray256 = 0xc,
};

pub const IPalette = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        InitializePredefined: *anyopaque,
        InitializeCustom: *anyopaque,
        InitializeFromBitmap: *anyopaque,
        InitializeFromPalette: *anyopaque,
        GetType: *anyopaque,
        GetColorCount: *anyopaque,
        GetColors: *anyopaque,
        IsBlackWhite: *anyopaque,
        IsGrayscale: *anyopaque,
        HasAlpha: *anyopaque,
    };
};

pub const IStream = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{135FF860-22B7-4ddf-B0F6-218F4F299A43}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const InitializeFromFilename = IStream.Methods(@This()).InitializeFromFilename;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn InitializeFromFilename(
                self: *T,
                filename: LPCWSTR,
                desired_access: DWORD,
            ) HRESULT {
                return @as(*const IStream.VTable, @ptrCast(self.__v)).InitializeFromFilename(
                    @ptrCast(self),
                    filename,
                    desired_access,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: objidl.IStream.VTable,
        InitializeFromIStream: *anyopaque,
        InitializeFromFilename: *const fn (*IStream, LPCWSTR, DWORD) callconv(WINAPI) HRESULT,
        InitializeFromMemory: *anyopaque,
        InitializeFromIStreamRegion: *anyopaque,
    };
};

pub const IBitmapDecoder = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetFrame = IBitmapDecoder.Methods(@This()).GetFrame;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetFrame(
                self: *T,
                index: UINT,
                frame: ?*?*IBitmapFrameDecode,
            ) HRESULT {
                return @as(*const IBitmapDecoder.VTable, @ptrCast(self.__v)).GetFrame(@ptrCast(self), index, frame);
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        QueryCapability: *anyopaque,
        Initialize: *anyopaque,
        GetContainerFormat: *anyopaque,
        GetDecoderInfo: *anyopaque,
        CopyPalette: *anyopaque,
        GetMetadataQueryReader: *anyopaque,
        GetPreview: *anyopaque,
        GetColorContexts: *anyopaque,
        GetThumbnail: *anyopaque,
        GetFrameCount: *anyopaque,
        GetFrame: *const fn (*IBitmapDecoder, UINT, ?*?*IBitmapFrameDecode) callconv(WINAPI) HRESULT,
    };
};

pub const IBitmapEncoder = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const Initialize = IBitmapEncoder.Methods(@This()).Initialize;
    pub const CreateNewFrame = IBitmapEncoder.Methods(@This()).CreateNewFrame;
    pub const Commit = IBitmapEncoder.Methods(@This()).Commit;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Initialize(self: *T, stream: ?*objidl.IStream, cache_option: BitmapEncoderCacheOption) HRESULT {
                return @as(*const IBitmapEncoder.VTable, @ptrCast(self.__v)).Initialize(
                    @ptrCast(self),
                    stream,
                    cache_option,
                );
            }
            pub inline fn CreateNewFrame(self: *T, frame: ?*?*IBitmapFrameEncode, encoder_options: ?*?*IPropertyBag2) HRESULT {
                return @as(*const IBitmapEncoder.VTable, @ptrCast(self.__v)).CreateNewFrame(
                    @ptrCast(self),
                    frame,
                    encoder_options,
                );
            }
            pub inline fn Commit(self: *T) HRESULT {
                return @as(*const IBitmapEncoder.VTable, @ptrCast(self.__v)).Commit(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        Initialize: *const fn (
            *IBitmapEncoder,
            ?*objidl.IStream,
            BitmapEncoderCacheOption,
        ) callconv(WINAPI) HRESULT,
        GetContainerFormat: *anyopaque,
        GetEncoderInfo: *anyopaque,
        SetColorContexts: *anyopaque,
        SetPalette: *anyopaque,
        SetThumbnail: *anyopaque,
        SetPreview: *anyopaque,
        CreateNewFrame: *const fn (
            *IBitmapEncoder,
            ?*?*IBitmapFrameEncode,
            ?*?*IPropertyBag2,
        ) callconv(WINAPI) HRESULT,
        Commit: *const fn (*IBitmapEncoder) callconv(WINAPI) HRESULT,
        GetMetadataQueryWriter: *anyopaque,
    };
};

pub const IBitmapSource = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetSize = IBitmapSource.Methods(@This()).GetSize;
    pub const GetPixelFormat = IBitmapSource.Methods(@This()).GetPixelFormat;
    pub const CopyPixels = IBitmapSource.Methods(@This()).CopyPixels;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetSize(self: *T, width: *UINT, height: *UINT) HRESULT {
                return @as(*const IBitmapSource.VTable, @ptrCast(self.__v)).GetSize(@ptrCast(self), width, height);
            }
            pub inline fn GetPixelFormat(self: *T, guid: *PixelFormatGUID) HRESULT {
                return @as(*const IBitmapSource.VTable, @ptrCast(self.__v)).GetPixelFormat(@ptrCast(self), guid);
            }
            pub inline fn CopyPixels(
                self: *T,
                rect: ?*const Rect,
                stride: UINT,
                size: UINT,
                buffer: [*]BYTE,
            ) HRESULT {
                return @as(*const IBitmapSource.VTable, @ptrCast(self.__v)).CopyPixels(
                    @ptrCast(self),
                    rect,
                    stride,
                    size,
                    buffer,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        GetSize: *const fn (*IBitmapSource, *UINT, *UINT) callconv(WINAPI) HRESULT,
        GetPixelFormat: *const fn (*IBitmapSource, *PixelFormatGUID) callconv(WINAPI) HRESULT,
        GetResolution: *anyopaque,
        CopyPalette: *anyopaque,
        CopyPixels: *const fn (*IBitmapSource, ?*const Rect, UINT, UINT, [*]BYTE) callconv(WINAPI) HRESULT,
    };
};

pub const IBitmapFrameDecode = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetSize = IBitmapSource.Methods(@This()).GetSize;
    pub const GetPixelFormat = IBitmapSource.Methods(@This()).GetPixelFormat;
    pub const CopyPixels = IBitmapSource.Methods(@This()).CopyPixels;

    pub const VTable = extern struct {
        base: IBitmapSource.VTable,
        GetMetadataQueryReader: *anyopaque,
        GetColorContexts: *anyopaque,
        GetThumbnail: *anyopaque,
    };
};

pub const IBitmapFrameEncode = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const WritePixels = IBitmapFrameEncode.Methods(@This()).WritePixels;
    pub const Commit = IBitmapFrameEncode.Methods(@This()).Commit;
    pub const SetSize = IBitmapFrameEncode.Methods(@This()).SetSize;
    pub const SetPixelFormat = IBitmapFrameEncode.Methods(@This()).SetPixelFormat;
    pub const Initialize = IBitmapFrameEncode.Methods(@This()).Initialize;
    pub const WriteSource = IBitmapFrameEncode.Methods(@This()).WriteSource;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn WritePixels(
                self: *T,
                line_count: UINT,
                stride: UINT,
                buffer_size: UINT,
                pixels: *BYTE,
            ) HRESULT {
                return @as(*const IBitmapFrameEncode.VTable, @ptrCast(self.__v)).WritePixels(
                    @ptrCast(self),
                    line_count,
                    stride,
                    buffer_size,
                    pixels,
                );
            }
            pub inline fn Commit(self: *T) HRESULT {
                return @as(*const IBitmapFrameEncode.VTable, @ptrCast(self.__v)).Commit(@ptrCast(self));
            }
            pub inline fn SetSize(self: *T, width: UINT, height: UINT) HRESULT {
                return @as(*const IBitmapFrameEncode.VTable, @ptrCast(self.__v)).SetSize(
                    @ptrCast(self),
                    width,
                    height,
                );
            }
            pub inline fn SetPixelFormat(self: *T, format: *PixelFormatGUID) HRESULT {
                return @as(*const IBitmapFrameEncode.VTable, @ptrCast(self.__v)).SetPixelFormat(
                    @ptrCast(self),
                    format,
                );
            }
            pub inline fn Initialize(self: *T, encoder_options: ?*IPropertyBag2) HRESULT {
                return @as(*const IBitmapFrameEncode.VTable, @ptrCast(self.__v)).Initialize(
                    @ptrCast(self),
                    encoder_options,
                );
            }
            pub inline fn WriteSource(self: *T, bitmap_source: ?*IBitmapSource, rect: ?*Rect) HRESULT {
                return @as(*const IBitmapFrameEncode.VTable, @ptrCast(self.__v)).WriteSource(
                    @ptrCast(self),
                    bitmap_source,
                    rect,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        Initialize: *const fn (*IBitmapFrameEncode, ?*IPropertyBag2) callconv(WINAPI) HRESULT,
        SetSize: *const fn (*IBitmapFrameEncode, UINT, UINT) callconv(WINAPI) HRESULT,
        SetResolution: *anyopaque,
        SetPixelFormat: *const fn (*IBitmapFrameEncode, *PixelFormatGUID) callconv(WINAPI) HRESULT,
        SetColorContexts: *anyopaque,
        SetPalette: *anyopaque,
        SetThumbnail: *anyopaque,
        WritePixels: *const fn (*IBitmapFrameEncode, UINT, UINT, UINT, *BYTE) callconv(WINAPI) HRESULT,
        WriteSource: *const fn (*IBitmapFrameEncode, ?*IBitmapSource, ?*Rect) callconv(WINAPI) HRESULT,
        Commit: *const fn (*IBitmapFrameEncode) callconv(WINAPI) HRESULT,
        GetMetadataQueryWriter: *anyopaque,
    };
};

pub const IBitmap = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetSize = IBitmapSource.Methods(@This()).GetSize;
    pub const GetPixelFormat = IBitmapSource.Methods(@This()).GetPixelFormat;
    pub const CopyPixels = IBitmapSource.Methods(@This()).CopyPixels;

    pub const VTable = extern struct {
        base: IBitmapSource.VTable,
        Lock: *anyopaque,
        SetPalette: *anyopaque,
        SetResolution: *anyopaque,
    };
};

pub const BitmapDitherType = enum(UINT) {
    None = 0,
    Ordered4x4 = 0x1,
    Ordered8x8 = 0x2,
    Ordered16x16 = 0x3,
    Spiral4x4 = 0x4,
    Spiral8x8 = 0x5,
    DualSpiral4x4 = 0x6,
    DualSpiral8x8 = 0x7,
    ErrorDiffusion = 0x8,
};

pub const IFormatConverter = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const GetSize = IBitmapSource.Methods(@This()).GetSize;
    pub const GetPixelFormat = IBitmapSource.Methods(@This()).GetPixelFormat;
    pub const CopyPixels = IBitmapSource.Methods(@This()).CopyPixels;

    pub const Initialize = IFormatConverter.Methods(@This()).Initialize;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Initialize(
                self: *T,
                source: ?*IBitmapSource,
                dest_format: *const PixelFormatGUID,
                dither: BitmapDitherType,
                palette: ?*IPalette,
                alpha_threshold_percent: f64,
                palette_translate: BitmapPaletteType,
            ) HRESULT {
                return @as(*const IFormatConverter.VTable, @ptrCast(self.__v)).Initialize(
                    @ptrCast(self),
                    source,
                    dest_format,
                    dither,
                    palette,
                    alpha_threshold_percent,
                    palette_translate,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IBitmapSource.VTable,
        Initialize: *const fn (
            *IFormatConverter,
            ?*IBitmapSource,
            *const PixelFormatGUID,
            BitmapDitherType,
            ?*IPalette,
            f64,
            BitmapPaletteType,
        ) callconv(WINAPI) HRESULT,
        CanConvert: *anyopaque,
    };
};

pub const IImagingFactory = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{ec5ec8a9-c395-4314-9c77-54d7a935ff70}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateDecoderFromFilename = IImagingFactory.Methods(@This()).CreateDecoderFromFilename;
    pub const CreateFormatConverter = IImagingFactory.Methods(@This()).CreateFormatConverter;
    pub const CreateBitmap = IImagingFactory.Methods(@This()).CreateBitmap;
    pub const CreateStream = IImagingFactory.Methods(@This()).CreateStream;
    pub const CreateEncoder = IImagingFactory.Methods(@This()).CreateEncoder;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateDecoderFromFilename(
                self: *T,
                filename: LPCWSTR,
                vendor: ?*const GUID,
                access: DWORD,
                metadata: DecodeOptions,
                decoder: ?*?*IBitmapDecoder,
            ) HRESULT {
                return @as(*const IImagingFactory.VTable, @ptrCast(self.__v)).CreateDecoderFromFilename(
                    @ptrCast(self),
                    filename,
                    vendor,
                    access,
                    metadata,
                    decoder,
                );
            }
            pub inline fn CreateFormatConverter(self: *T, converter: ?*?*IFormatConverter) HRESULT {
                return @as(*const IImagingFactory.VTable, @ptrCast(self.__v)).CreateFormatConverter(
                    @ptrCast(self),
                    converter,
                );
            }
            pub inline fn CreateBitmap(
                self: *T,
                width: UINT,
                height: UINT,
                format: *const PixelFormatGUID,
                cache_option: BitmapCreateCacheOption,
                bitmap: ?*?*IBitmap,
            ) HRESULT {
                return @as(*const IImagingFactory.VTable, @ptrCast(self.__v)).CreateBitmap(
                    @ptrCast(self),
                    width,
                    height,
                    format,
                    cache_option,
                    bitmap,
                );
            }
            pub inline fn CreateEncoder(
                self: *T,
                container_format: *const GUID,
                vendor: ?*const GUID,
                encoder: ?*?*IBitmapEncoder,
            ) HRESULT {
                return @as(*const IImagingFactory.VTable, @ptrCast(self.__v)).CreateEncoder(
                    @ptrCast(self),
                    container_format,
                    vendor,
                    encoder,
                );
            }
            pub inline fn CreateStream(self: *T, wic_stream: ?*?*IStream) HRESULT {
                return @as(*const IImagingFactory.VTable, @ptrCast(self.__v)).CreateStream(
                    @ptrCast(self),
                    wic_stream,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        CreateDecoderFromFilename: *const fn (
            *IImagingFactory,
            LPCWSTR,
            ?*const GUID,
            DWORD,
            DecodeOptions,
            ?*?*IBitmapDecoder,
        ) callconv(WINAPI) HRESULT,
        CreateDecoderFromStream: *anyopaque,
        CreateDecoderFromFileHandle: *anyopaque,
        CreateComponentInfo: *anyopaque,
        CreateDecoder: *anyopaque,
        CreateEncoder: *const fn (
            *IImagingFactory,
            *const GUID,
            ?*const GUID,
            ?*?*IBitmapEncoder,
        ) callconv(WINAPI) HRESULT,
        CreatePalette: *anyopaque,
        CreateFormatConverter: *const fn (*IImagingFactory, ?*?*IFormatConverter) callconv(WINAPI) HRESULT,
        CreateBitmapScaler: *anyopaque,
        CreateBitmapClipper: *anyopaque,
        CreateBitmapFlipRotator: *anyopaque,
        CreateStream: *const fn (*IImagingFactory, ?*?*IStream) callconv(WINAPI) HRESULT,
        CreateColorContext: *anyopaque,
        CreateColorTransformer: *anyopaque,
        CreateBitmap: *const fn (
            *IImagingFactory,
            UINT,
            UINT,
            *const PixelFormatGUID,
            BitmapCreateCacheOption,
            ?*?*IBitmap,
        ) callconv(WINAPI) HRESULT,
        CreateBitmapFromSource: *anyopaque,
        CreateBitmapFromSourceRect: *anyopaque,
        CreateBitmapFromMemory: *anyopaque,
        CreateBitmapFromHBITMAP: *anyopaque,
        CreateBitmapFromHICON: *anyopaque,
        CreateComponentEnumerator: *anyopaque,
        CreateFastMetadataEncoderFromDecoder: *anyopaque,
        CreateFastMetadataEncoderFromFrameDecode: *anyopaque,
        CreateQueryWriter: *anyopaque,
        CreateQueryWriterFromReader: *anyopaque,
    };
};

pub const ImageParameters = extern struct {
    PixelFormat: d2d1.PIXEL_FORMAT,
    DpiX: FLOAT,
    DpiY: FLOAT,
    Top: FLOAT,
    Left: FLOAT,
    PixelWidth: UINT32,
    PixelHeight: UINT32,
};

pub const IImageEncoder = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const WriteFrame = IImageEncoder.Methods(@This()).WriteFrame;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn WriteFrame(
                self: *T,
                d2d_image: *d2d1.IImage,
                frame_encode: *IBitmapFrameEncode,
                image_parameters: ?*const ImageParameters,
            ) HRESULT {
                return @as(*const IImageEncoder.VTable, @ptrCast(self.__v)).WriteFrame(
                    @ptrCast(self),
                    d2d_image,
                    frame_encode,
                    image_parameters,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        WriteFrame: *const fn (
            *IImageEncoder,
            *d2d1.IImage,
            *IBitmapFrameEncode,
            ?*const ImageParameters,
        ) callconv(WINAPI) HRESULT,
        WriteFrameThumbnail: *anyopaque,
        WriteThumbnail: *anyopaque,
    };
};

pub const IImagingFactory2 = extern struct {
    __v: *const VTable,

    pub const IID = GUID.parse("{7B816B45-1996-4476-B132-DE9E247C8AF0}");

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const CreateDecoderFromFilename = IImagingFactory.Methods(@This()).CreateDecoderFromFilename;
    pub const CreateFormatConverter = IImagingFactory.Methods(@This()).CreateFormatConverter;
    pub const CreateBitmap = IImagingFactory.Methods(@This()).CreateBitmap;
    pub const CreateStream = IImagingFactory.Methods(@This()).CreateStream;
    pub const CreateEncoder = IImagingFactory.Methods(@This()).CreateEncoder;

    pub const CreateImageEncoder = IImagingFactory2.Methods(@This()).CreateImageEncoder;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn CreateImageEncoder(
                self: *T,
                d2d_device: *d2d1.IDevice,
                image_encoder: ?*?*IImageEncoder,
            ) HRESULT {
                return @as(*const IImagingFactory2.VTable, @ptrCast(self.__v)).CreateImageEncoder(
                    @ptrCast(self),
                    d2d_device,
                    image_encoder,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IImagingFactory.VTable,
        CreateImageEncoder: *const fn (
            *IImagingFactory2,
            *d2d1.IDevice,
            ?*?*IImageEncoder,
        ) callconv(WINAPI) HRESULT,
    };
};

pub const CLSID_ImagingFactory = GUID{
    .Data1 = 0xcacaf262,
    .Data2 = 0x9370,
    .Data3 = 0x4615,
    .Data4 = .{ 0xa1, 0x3b, 0x9f, 0x55, 0x39, 0xda, 0x4c, 0xa },
};
pub const CLSID_ImagingFactory2 = GUID{
    .Data1 = 0x317d06e8,
    .Data2 = 0x5f24,
    .Data3 = 0x433d,
    .Data4 = .{ 0xbd, 0xf7, 0x79, 0xce, 0x68, 0xd8, 0xab, 0xc2 },
};

pub const GUID_PixelFormatDontCare = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x00 },
};
pub const GUID_PixelFormat2bppIndexed = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x02 },
};
pub const GUID_PixelFormat24bppRGB = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0d },
};
pub const GUID_PixelFormat32bppRGB = PixelFormatGUID{
    .Data1 = 0xd98c6b95,
    .Data2 = 0x3efe,
    .Data3 = 0x47d6,
    .Data4 = .{ 0xbb, 0x25, 0xeb, 0x17, 0x48, 0xab, 0x0c, 0xf1 },
};
pub const GUID_PixelFormat32bppRGBA = PixelFormatGUID{
    .Data1 = 0xf5c7ad2d,
    .Data2 = 0x6a8d,
    .Data3 = 0x43dd,
    .Data4 = .{ 0xa7, 0xa8, 0xa2, 0x99, 0x35, 0x26, 0x1a, 0xe9 },
};
pub const GUID_PixelFormat32bppPRGBA = PixelFormatGUID{
    .Data1 = 0x3cc4a650,
    .Data2 = 0xa527,
    .Data3 = 0x4d37,
    .Data4 = .{ 0xa9, 0x16, 0x31, 0x42, 0xc7, 0xeb, 0xed, 0xba },
};
pub const GUID_PixelFormat24bppBGR = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0c },
};
pub const GUID_PixelFormat32bppBGR = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0e },
};
pub const GUID_PixelFormat32bppBGRA = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x0f },
};
pub const GUID_PixelFormat32bppPBGRA = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x10 },
};
pub const GUID_PixelFormat64bppRGBA = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x16 },
};
pub const GUID_PixelFormat8bppGray = PixelFormatGUID{
    .Data1 = 0x6fddc324,
    .Data2 = 0x4e03,
    .Data3 = 0x4bfe,
    .Data4 = .{ 0xb1, 0x85, 0x3d, 0x77, 0x76, 0x8d, 0xc9, 0x08 },
};
pub const GUID_PixelFormat8bppAlpha = PixelFormatGUID{
    .Data1 = 0xe6cd0116,
    .Data2 = 0xeeba,
    .Data3 = 0x4161,
    .Data4 = .{ 0xaa, 0x85, 0x27, 0xdd, 0x9f, 0xb3, 0xa8, 0x95 },
};

pub const GUID_ContainerFormatPng = GUID{
    .Data1 = 0x1b7cfaf4,
    .Data2 = 0x713f,
    .Data3 = 0x473c,
    .Data4 = .{ 0xbb, 0xcd, 0x61, 0x37, 0x42, 0x5f, 0xae, 0xaf },
};
