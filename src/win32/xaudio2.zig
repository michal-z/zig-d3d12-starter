const w32 = @import("win32.zig");
const IUnknown = w32.IUnknown;
const BYTE = w32.BYTE;
const UINT = w32.UINT;
const UINT32 = w32.UINT32;
const UINT64 = w32.UINT64;
const WINAPI = w32.WINAPI;
const LPCWSTR = w32.LPCWSTR;
const BOOL = w32.BOOL;
const DWORD = w32.DWORD;
const WORD = w32.WORD;
const GUID = w32.GUID;
const HRESULT = w32.HRESULT;
const WAVEFORMATEX = @import("wasapi.zig").WAVEFORMATEX;

// NOTE(mziulek):
// xaudio2redist.h uses tight field packing so we need align each field with `align(1)`
// in all non-interface structure definitions.

pub const COMMIT_NOW = 0;
pub const COMMIT_ALL = 0;
pub const INVALID_OPSET = 0xffff_ffff;
pub const NO_LOOP_REGION = 0;
pub const LOOP_INFINITE = 255;
pub const DEFAULT_CHANNELS = 0;
pub const DEFAULT_SAMPLERATE = 0;

pub const MAX_BUFFER_BYTES = 0x8000_0000;
pub const MAX_QUEUED_BUFFERS = 64;
pub const MAX_BUFFERS_SYSTEM = 2;
pub const MAX_AUDIO_CHANNELS = 64;
pub const MIN_SAMPLE_RATE = 1000;
pub const MAX_SAMPLE_RATE = 200000;
pub const MAX_VOLUME_LEVEL = 16777216.0;
pub const MIN_FREQ_RATIO = 1.0 / 1024.0;
pub const MAX_FREQ_RATIO = 1024.0;
pub const DEFAULT_FREQ_RATIO = 2.0;
pub const MAX_FILTER_ONEOVERQ = 1.5;
pub const MAX_FILTER_FREQUENCY = 1.0;
pub const MAX_LOOP_COUNT = 254;
pub const MAX_INSTANCES = 8;

pub const FLAGS = packed struct(UINT32) {
    DEBUG_ENGINE: bool = false,
    VOICE_NOPITCH: bool = false,
    VOICE_NOSRC: bool = false,
    VOICE_USEFILTER: bool = false,
    __unused4: bool = false,
    PLAY_TAILS: bool = false,
    END_OF_STREAM: bool = false,
    SEND_USEFILTER: bool = false,
    VOICE_NOSAMPLESPLAYED: bool = false,
    __unused9: bool = false,
    __unused10: bool = false,
    __unused11: bool = false,
    __unused12: bool = false,
    STOP_ENGINE_WHEN_IDLE: bool = false,
    __unused14: bool = false,
    @"1024_QUANTUM": bool = false,
    NO_VIRTUAL_AUDIO_CLIENT: bool = false,
    __unused: u15 = 0,
};

pub const VOICE_DETAILS = extern struct {
    CreationFlags: FLAGS align(1),
    ActiveFlags: FLAGS align(1),
    InputChannels: UINT32 align(1),
    InputSampleRate: UINT32 align(1),
};

pub const SEND_DESCRIPTOR = extern struct {
    Flags: FLAGS align(1),
    pOutputVoice: *IVoice align(1),
};

pub const VOICE_SENDS = extern struct {
    SendCount: UINT32 align(1),
    pSends: [*]SEND_DESCRIPTOR align(1),
};

pub const EFFECT_DESCRIPTOR = extern struct {
    pEffect: *IUnknown align(1),
    InitialState: BOOL align(1),
    OutputChannels: UINT32 align(1),
};

pub const EFFECT_CHAIN = extern struct {
    EffectCount: UINT32 align(1),
    pEffectDescriptors: [*]EFFECT_DESCRIPTOR align(1),
};

pub const FILTER_TYPE = enum(UINT32) {
    LowPassFilter,
    BandPassFilter,
    HighPassFilter,
    NotchFilter,
    LowPassOnePoleFilter,
    HighPassOnePoleFilter,
};

pub const AUDIO_STREAM_CATEGORY = enum(UINT32) {
    Other = 0,
    ForegroundOnlyMedia = 1,
    Communications = 3,
    Alerts = 4,
    SoundEffects = 5,
    GameEffects = 6,
    GameMedia = 7,
    GameChat = 8,
    Speech = 9,
    Movie = 10,
    Media = 11,
};

pub const FILTER_PARAMETERS = extern struct {
    Type: FILTER_TYPE align(1),
    Frequency: f32 align(1),
    OneOverQ: f32 align(1),
};

pub const BUFFER = extern struct {
    Flags: FLAGS align(1),
    AudioBytes: UINT32 align(1),
    pAudioData: [*]const BYTE align(1),
    PlayBegin: UINT32 align(1),
    PlayLength: UINT32 align(1),
    LoopBegin: UINT32 align(1),
    LoopLength: UINT32 align(1),
    LoopCount: UINT32 align(1),
    pContext: ?*anyopaque align(1),
};

pub const BUFFER_WMA = extern struct {
    pDecodedPacketCumulativeBytes: *const UINT32 align(1),
    PacketCount: UINT32 align(1),
};

pub const VOICE_STATE = extern struct {
    pCurrentBufferContext: ?*anyopaque align(1),
    BuffersQueued: UINT32 align(1),
    SamplesPlayed: UINT64 align(1),
};

pub const PERFORMANCE_DATA = extern struct {
    AudioCyclesSinceLastQuery: UINT64 align(1),
    TotalCyclesSinceLastQuery: UINT64 align(1),
    MinimumCyclesPerQuantum: UINT32 align(1),
    MaximumCyclesPerQuantum: UINT32 align(1),
    MemoryUsageInBytes: UINT32 align(1),
    CurrentLatencyInSamples: UINT32 align(1),
    GlitchesSinceEngineStarted: UINT32 align(1),
    ActiveSourceVoiceCount: UINT32 align(1),
    TotalSourceVoiceCount: UINT32 align(1),
    ActiveSubmixVoiceCount: UINT32 align(1),
    ActiveResamplerCount: UINT32 align(1),
    ActiveMatrixMixCount: UINT32 align(1),
    ActiveXmaSourceVoices: UINT32 align(1),
    ActiveXmaStreams: UINT32 align(1),
};

pub const LOG_FLAGS = packed struct(UINT32) {
    ERRORS: bool = false,
    WARNINGS: bool = false,
    INFO: bool = false,
    DETAIL: bool = false,
    API_CALLS: bool = false,
    FUNC_CALLS: bool = false,
    TIMING: bool = false,
    LOCKS: bool = false,
    MEMORY: bool = false,
    __unused9: bool = false,
    __unused10: bool = false,
    __unused11: bool = false,
    STREAMING: bool = false,
    __unused: u19 = 0,
};

pub const DEBUG_CONFIGURATION = extern struct {
    TraceMask: LOG_FLAGS align(1),
    BreakMask: LOG_FLAGS align(1),
    LogThreadID: BOOL align(1),
    LogFileline: BOOL align(1),
    LogFunctionName: BOOL align(1),
    LogTiming: BOOL align(1),
};

pub const IXAudio2 = extern struct {
    __v: *const VTable,

    pub const QueryInterface = IUnknown.Methods(@This()).QueryInterface;
    pub const AddRef = IUnknown.Methods(@This()).AddRef;
    pub const Release = IUnknown.Methods(@This()).Release;

    pub const RegisterForCallbacks = IXAudio2.Methods(@This()).RegisterForCallbacks;
    pub const UnregisterForCallbacks = IXAudio2.Methods(@This()).UnregisterForCallbacks;
    pub const CreateSourceVoice = IXAudio2.Methods(@This()).CreateSourceVoice;
    pub const CreateSubmixVoice = IXAudio2.Methods(@This()).CreateSubmixVoice;
    pub const CreateMasteringVoice = IXAudio2.Methods(@This()).CreateMasteringVoice;
    pub const StartEngine = IXAudio2.Methods(@This()).StartEngine;
    pub const StopEngine = IXAudio2.Methods(@This()).StopEngine;
    pub const CommitChanges = IXAudio2.Methods(@This()).CommitChanges;
    pub const GetPerformanceData = IXAudio2.Methods(@This()).GetPerformanceData;
    pub const SetDebugConfiguration = IXAudio2.Methods(@This()).SetDebugConfiguration;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn RegisterForCallbacks(self: *T, cb: *IEngineCallback) HRESULT {
                return @as(*const IXAudio2.VTable, @ptrCast(self.__v)).RegisterForCallbacks(@ptrCast(self), cb);
            }
            pub inline fn UnregisterForCallbacks(self: *T, cb: *IEngineCallback) void {
                @as(*const IXAudio2.VTable, @ptrCast(self.__v)).UnregisterForCallbacks(@ptrCast(self), cb);
            }
            pub inline fn CreateSourceVoice(
                self: *T,
                source_voice: *?*ISourceVoice,
                source_format: *const WAVEFORMATEX,
                flags: FLAGS,
                max_frequency_ratio: f32,
                callback: ?*IVoiceCallback,
                send_list: ?*const VOICE_SENDS,
                effect_chain: ?*const EFFECT_CHAIN,
            ) HRESULT {
                return @as(*const IXAudio2.VTable, @ptrCast(self.__v)).CreateSourceVoice(
                    @ptrCast(self),
                    source_voice,
                    source_format,
                    flags,
                    max_frequency_ratio,
                    callback,
                    send_list,
                    effect_chain,
                );
            }
            pub inline fn CreateSubmixVoice(
                self: *T,
                submix_voice: *?*ISubmixVoice,
                input_channels: UINT32,
                input_sample_rate: UINT32,
                flags: FLAGS,
                processing_stage: UINT32,
                send_list: ?*const VOICE_SENDS,
                effect_chain: ?*const EFFECT_CHAIN,
            ) HRESULT {
                return @as(*const IXAudio2.VTable, @ptrCast(self.__v)).CreateSubmixVoice(
                    @ptrCast(self),
                    submix_voice,
                    input_channels,
                    input_sample_rate,
                    flags,
                    processing_stage,
                    send_list,
                    effect_chain,
                );
            }
            pub inline fn CreateMasteringVoice(
                self: *T,
                mastering_voice: *?*IMasteringVoice,
                input_channels: UINT32,
                input_sample_rate: UINT32,
                flags: FLAGS,
                device_id: ?LPCWSTR,
                effect_chain: ?*const EFFECT_CHAIN,
                stream_category: AUDIO_STREAM_CATEGORY,
            ) HRESULT {
                return @as(*const IXAudio2.VTable, @ptrCast(self.__v)).CreateMasteringVoice(
                    @ptrCast(self),
                    mastering_voice,
                    input_channels,
                    input_sample_rate,
                    flags,
                    device_id,
                    effect_chain,
                    stream_category,
                );
            }
            pub inline fn StartEngine(self: *T) HRESULT {
                return @as(*const IXAudio2.VTable, @ptrCast(self.__v)).StartEngine(@ptrCast(self));
            }
            pub inline fn StopEngine(self: *T) void {
                @as(*const IXAudio2.VTable, @ptrCast(self.__v)).StopEngine(@ptrCast(self));
            }
            pub inline fn CommitChanges(self: *T, operation_set: UINT32) HRESULT {
                return @as(*const IXAudio2.VTable, @ptrCast(self.__v)).CommitChanges(@ptrCast(self), operation_set);
            }
            pub inline fn GetPerformanceData(self: *T, data: *PERFORMANCE_DATA) void {
                @as(*const IXAudio2.VTable, @ptrCast(self.__v)).GetPerformanceData(@ptrCast(self), data);
            }
            pub inline fn SetDebugConfiguration(
                self: *T,
                config: ?*const DEBUG_CONFIGURATION,
                reserved: ?*anyopaque,
            ) void {
                @as(*const IXAudio2.VTable, @ptrCast(self.__v)).SetDebugConfiguration(
                    @ptrCast(self),
                    config,
                    reserved,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IUnknown.VTable,
        RegisterForCallbacks: *const fn (*IXAudio2, *IEngineCallback) callconv(WINAPI) HRESULT,
        UnregisterForCallbacks: *const fn (*IXAudio2, *IEngineCallback) callconv(WINAPI) void,
        CreateSourceVoice: *const fn (
            *IXAudio2,
            *?*ISourceVoice,
            *const WAVEFORMATEX,
            FLAGS,
            f32,
            ?*IVoiceCallback,
            ?*const VOICE_SENDS,
            ?*const EFFECT_CHAIN,
        ) callconv(WINAPI) HRESULT,
        CreateSubmixVoice: *const fn (
            *IXAudio2,
            *?*ISubmixVoice,
            UINT32,
            UINT32,
            FLAGS,
            UINT32,
            ?*const VOICE_SENDS,
            ?*const EFFECT_CHAIN,
        ) callconv(WINAPI) HRESULT,
        CreateMasteringVoice: *const fn (
            *IXAudio2,
            *?*IMasteringVoice,
            UINT32,
            UINT32,
            FLAGS,
            ?LPCWSTR,
            ?*const EFFECT_CHAIN,
            AUDIO_STREAM_CATEGORY,
        ) callconv(WINAPI) HRESULT,
        StartEngine: *const fn (*IXAudio2) callconv(WINAPI) HRESULT,
        StopEngine: *const fn (*IXAudio2) callconv(WINAPI) void,
        CommitChanges: *const fn (*IXAudio2, UINT32) callconv(WINAPI) HRESULT,
        GetPerformanceData: *const fn (*IXAudio2, *PERFORMANCE_DATA) callconv(WINAPI) void,
        SetDebugConfiguration: *const fn (
            *IXAudio2,
            ?*const DEBUG_CONFIGURATION,
            ?*anyopaque,
        ) callconv(WINAPI) void,
    };
};

pub const IVoice = extern struct {
    __v: *const VTable,

    pub const GetVoiceDetails = IVoice.Methods(@This()).GetVoiceDetails;
    pub const SetOutputVoices = IVoice.Methods(@This()).SetOutputVoices;
    pub const SetEffectChain = IVoice.Methods(@This()).SetEffectChain;
    pub const EnableEffect = IVoice.Methods(@This()).EnableEffect;
    pub const DisableEffect = IVoice.Methods(@This()).DisableEffect;
    pub const GetEffectState = IVoice.Methods(@This()).GetEffectState;
    pub const SetEffectParameters = IVoice.Methods(@This()).SetEffectParameters;
    pub const GetEffectParameters = IVoice.Methods(@This()).GetEffectParameters;
    pub const SetFilterParameters = IVoice.Methods(@This()).SetFilterParameters;
    pub const GetFilterParameters = IVoice.Methods(@This()).GetFilterParameters;
    pub const SetOutputFilterParameters = IVoice.Methods(@This()).SetOutputFilterParameters;
    pub const GetOutputFilterParameters = IVoice.Methods(@This()).GetOutputFilterParameters;
    pub const SetVolume = IVoice.Methods(@This()).SetVolume;
    pub const GetVolume = IVoice.Methods(@This()).GetVolume;
    pub const SetChannelVolumes = IVoice.Methods(@This()).SetChannelVolumes;
    pub const GetChannelVolumes = IVoice.Methods(@This()).GetChannelVolumes;
    pub const DestroyVoice = IVoice.Methods(@This()).DestroyVoice;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetVoiceDetails(self: *T, details: *VOICE_DETAILS) void {
                @as(*const IVoice.VTable, @ptrCast(self.__v)).GetVoiceDetails(@ptrCast(self), details);
            }
            pub inline fn SetOutputVoices(self: *T, send_list: ?*const VOICE_SENDS) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).SetOutputVoices(@ptrCast(self), send_list);
            }
            pub inline fn SetEffectChain(self: *T, effect_chain: ?*const EFFECT_CHAIN) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).SetEffectChain(@ptrCast(self), effect_chain);
            }
            pub inline fn EnableEffect(self: *T, effect_index: UINT32, operation_set: UINT32) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).EnableEffect(
                    @ptrCast(self),
                    effect_index,
                    operation_set,
                );
            }
            pub inline fn DisableEffect(self: *T, effect_index: UINT32, operation_set: UINT32) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).DisableEffect(
                    @ptrCast(self),
                    effect_index,
                    operation_set,
                );
            }
            pub inline fn GetEffectState(self: *T, effect_index: UINT32, enabled: *BOOL) void {
                @as(*const IVoice.VTable, @ptrCast(self.__v)).GetEffectState(@ptrCast(self), effect_index, enabled);
            }
            pub inline fn SetEffectParameters(
                self: *T,
                effect_index: UINT32,
                params: *const anyopaque,
                params_size: UINT32,
                operation_set: UINT32,
            ) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).SetEffectParameters(
                    @ptrCast(self),
                    effect_index,
                    params,
                    params_size,
                    operation_set,
                );
            }
            pub inline fn GetEffectParameters(
                self: *T,
                effect_index: UINT32,
                params: *anyopaque,
                params_size: UINT32,
            ) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).GetEffectParameters(
                    @ptrCast(self),
                    effect_index,
                    params,
                    params_size,
                );
            }
            pub inline fn SetFilterParameters(
                self: *T,
                params: *const FILTER_PARAMETERS,
                operation_set: UINT32,
            ) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).SetFilterParameters(
                    @ptrCast(self),
                    params,
                    operation_set,
                );
            }
            pub inline fn GetFilterParameters(self: *T, params: *FILTER_PARAMETERS) void {
                @as(*const IVoice.VTable, @ptrCast(self.__v)).GetFilterParameters(@ptrCast(self), params);
            }
            pub inline fn SetOutputFilterParameters(
                self: *T,
                dst_voice: ?*IVoice,
                params: *const FILTER_PARAMETERS,
                operation_set: UINT32,
            ) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).SetOutputFilterParameters(
                    @ptrCast(self),
                    dst_voice,
                    params,
                    operation_set,
                );
            }
            pub inline fn GetOutputFilterParameters(
                self: *T,
                dst_voice: ?*IVoice,
                params: *FILTER_PARAMETERS,
            ) void {
                @as(*const IVoice.VTable, @ptrCast(self.__v)).GetOutputFilterParameters(
                    @ptrCast(self),
                    dst_voice,
                    params,
                );
            }
            pub inline fn SetVolume(self: *T, volume: f32) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).SetVolume(@ptrCast(self), volume);
            }
            pub inline fn GetVolume(self: *T, volume: *f32) void {
                @as(*const IVoice.VTable, @ptrCast(self.__v)).GetVolume(@ptrCast(self), volume);
            }
            pub inline fn SetChannelVolumes(
                self: *T,
                num_channels: UINT32,
                volumes: [*]const f32,
                operation_set: UINT32,
            ) HRESULT {
                return @as(*const IVoice.VTable, @ptrCast(self.__v)).SetChannelVolumes(
                    @ptrCast(self),
                    num_channels,
                    volumes,
                    operation_set,
                );
            }
            pub inline fn GetChannelVolumes(self: *T, num_channels: UINT32, volumes: [*]f32) void {
                @as(*const IVoice.VTable, @ptrCast(self.__v)).GetChannelVolumes(
                    @ptrCast(self),
                    num_channels,
                    volumes,
                );
            }
            pub inline fn DestroyVoice(self: *T) void {
                @as(*const IVoice.VTable, @ptrCast(self.__v)).DestroyVoice(@ptrCast(self));
            }
        };
    }

    pub const VTable = extern struct {
        GetVoiceDetails: *const fn (*IVoice, *VOICE_DETAILS) callconv(WINAPI) void,
        SetOutputVoices: *const fn (*IVoice, ?*const VOICE_SENDS) callconv(WINAPI) HRESULT,
        SetEffectChain: *const fn (*IVoice, ?*const EFFECT_CHAIN) callconv(WINAPI) HRESULT,
        EnableEffect: *const fn (*IVoice, UINT32, UINT32) callconv(WINAPI) HRESULT,
        DisableEffect: *const fn (*IVoice, UINT32, UINT32) callconv(WINAPI) HRESULT,
        GetEffectState: *const fn (*IVoice, UINT32, *BOOL) callconv(WINAPI) void,
        SetEffectParameters: *const fn (
            *IVoice,
            UINT32,
            *const anyopaque,
            UINT32,
            UINT32,
        ) callconv(WINAPI) HRESULT,
        GetEffectParameters: *const fn (*IVoice, UINT32, *anyopaque, UINT32) callconv(WINAPI) HRESULT,
        SetFilterParameters: *const fn (
            *IVoice,
            *const FILTER_PARAMETERS,
            UINT32,
        ) callconv(WINAPI) HRESULT,
        GetFilterParameters: *const fn (*IVoice, *FILTER_PARAMETERS) callconv(WINAPI) void,
        SetOutputFilterParameters: *const fn (
            *IVoice,
            ?*IVoice,
            *const FILTER_PARAMETERS,
            UINT32,
        ) callconv(WINAPI) HRESULT,
        GetOutputFilterParameters: *const fn (*IVoice, ?*IVoice, *FILTER_PARAMETERS) callconv(WINAPI) void,
        SetVolume: *const fn (*IVoice, f32) callconv(WINAPI) HRESULT,
        GetVolume: *const fn (*IVoice, *f32) callconv(WINAPI) void,
        SetChannelVolumes: *const fn (*IVoice, UINT32, [*]const f32, UINT32) callconv(WINAPI) HRESULT,
        GetChannelVolumes: *const fn (*IVoice, UINT32, [*]f32) callconv(WINAPI) void,
        SetOutputMatrix: *anyopaque,
        GetOutputMatrix: *anyopaque,
        DestroyVoice: *const fn (*IVoice) callconv(WINAPI) void,
    };
};

pub const ISourceVoice = extern struct {
    __v: *const VTable,

    pub const GetVoiceDetails = IVoice.Methods(@This()).GetVoiceDetails;
    pub const SetOutputVoices = IVoice.Methods(@This()).SetOutputVoices;
    pub const SetEffectChain = IVoice.Methods(@This()).SetEffectChain;
    pub const EnableEffect = IVoice.Methods(@This()).EnableEffect;
    pub const DisableEffect = IVoice.Methods(@This()).DisableEffect;
    pub const GetEffectState = IVoice.Methods(@This()).GetEffectState;
    pub const SetEffectParameters = IVoice.Methods(@This()).SetEffectParameters;
    pub const GetEffectParameters = IVoice.Methods(@This()).GetEffectParameters;
    pub const SetFilterParameters = IVoice.Methods(@This()).SetFilterParameters;
    pub const GetFilterParameters = IVoice.Methods(@This()).GetFilterParameters;
    pub const SetOutputFilterParameters = IVoice.Methods(@This()).SetOutputFilterParameters;
    pub const GetOutputFilterParameters = IVoice.Methods(@This()).GetOutputFilterParameters;
    pub const SetVolume = IVoice.Methods(@This()).SetVolume;
    pub const GetVolume = IVoice.Methods(@This()).GetVolume;
    pub const SetChannelVolumes = IVoice.Methods(@This()).SetChannelVolumes;
    pub const GetChannelVolumes = IVoice.Methods(@This()).GetChannelVolumes;
    pub const DestroyVoice = IVoice.Methods(@This()).DestroyVoice;

    pub const Start = ISourceVoice.Methods(@This()).Start;
    pub const Stop = ISourceVoice.Methods(@This()).Stop;
    pub const SubmitSourceBuffer = ISourceVoice.Methods(@This()).SubmitSourceBuffer;
    pub const FlushSourceBuffers = ISourceVoice.Methods(@This()).FlushSourceBuffers;
    pub const Discontinuity = ISourceVoice.Methods(@This()).Discontinuity;
    pub const ExitLoop = ISourceVoice.Methods(@This()).ExitLoop;
    pub const GetState = ISourceVoice.Methods(@This()).GetState;
    pub const SetFrequencyRatio = ISourceVoice.Methods(@This()).SetFrequencyRatio;
    pub const GetFrequencyRatio = ISourceVoice.Methods(@This()).GetFrequencyRatio;
    pub const SetSourceSampleRate = ISourceVoice.Methods(@This()).SetSourceSampleRate;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn Start(self: *T, flags: FLAGS, operation_set: UINT32) HRESULT {
                return @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).Start(
                    @ptrCast(self),
                    flags,
                    operation_set,
                );
            }
            pub inline fn Stop(self: *T, flags: FLAGS, operation_set: UINT32) HRESULT {
                return @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).Stop(
                    @ptrCast(self),
                    flags,
                    operation_set,
                );
            }
            pub inline fn SubmitSourceBuffer(
                self: *T,
                buffer: *const BUFFER,
                wmabuffer: ?*const BUFFER_WMA,
            ) HRESULT {
                return @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).SubmitSourceBuffer(
                    @ptrCast(self),
                    buffer,
                    wmabuffer,
                );
            }
            pub inline fn FlushSourceBuffers(self: *T) HRESULT {
                return @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).FlushSourceBuffers(@ptrCast(self));
            }
            pub inline fn Discontinuity(self: *T) HRESULT {
                return @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).Discontinuity(@ptrCast(self));
            }
            pub inline fn ExitLoop(self: *T, operation_set: UINT32) HRESULT {
                return @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).ExitLoop(@ptrCast(self), operation_set);
            }
            pub inline fn GetState(self: *T, state: *VOICE_STATE, flags: FLAGS) void {
                @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).GetState(@ptrCast(self), state, flags);
            }
            pub inline fn SetFrequencyRatio(self: *T, ratio: f32, operation_set: UINT32) HRESULT {
                return @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).SetFrequencyRatio(
                    @ptrCast(self),
                    ratio,
                    operation_set,
                );
            }
            pub inline fn GetFrequencyRatio(self: *T, ratio: *f32) void {
                @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).GetFrequencyRatio(@ptrCast(self), ratio);
            }
            pub inline fn SetSourceSampleRate(self: *T, sample_rate: UINT32) HRESULT {
                return @as(*const ISourceVoice.VTable, @ptrCast(self.__v)).SetSourceSampleRate(
                    @ptrCast(self),
                    sample_rate,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IVoice.VTable,
        Start: *const fn (*ISourceVoice, FLAGS, UINT32) callconv(WINAPI) HRESULT,
        Stop: *const fn (*ISourceVoice, FLAGS, UINT32) callconv(WINAPI) HRESULT,
        SubmitSourceBuffer: *const fn (
            *ISourceVoice,
            *const BUFFER,
            ?*const BUFFER_WMA,
        ) callconv(WINAPI) HRESULT,
        FlushSourceBuffers: *const fn (*ISourceVoice) callconv(WINAPI) HRESULT,
        Discontinuity: *const fn (*ISourceVoice) callconv(WINAPI) HRESULT,
        ExitLoop: *const fn (*ISourceVoice, UINT32) callconv(WINAPI) HRESULT,
        GetState: *const fn (*ISourceVoice, *VOICE_STATE, FLAGS) callconv(WINAPI) void,
        SetFrequencyRatio: *const fn (*ISourceVoice, f32, UINT32) callconv(WINAPI) HRESULT,
        GetFrequencyRatio: *const fn (*ISourceVoice, *f32) callconv(WINAPI) void,
        SetSourceSampleRate: *const fn (*ISourceVoice, UINT32) callconv(WINAPI) HRESULT,
    };
};

pub const ISubmixVoice = extern struct {
    __v: *const VTable,

    pub const GetVoiceDetails = IVoice.Methods(@This()).GetVoiceDetails;
    pub const SetOutputVoices = IVoice.Methods(@This()).SetOutputVoices;
    pub const SetEffectChain = IVoice.Methods(@This()).SetEffectChain;
    pub const EnableEffect = IVoice.Methods(@This()).EnableEffect;
    pub const DisableEffect = IVoice.Methods(@This()).DisableEffect;
    pub const GetEffectState = IVoice.Methods(@This()).GetEffectState;
    pub const SetEffectParameters = IVoice.Methods(@This()).SetEffectParameters;
    pub const GetEffectParameters = IVoice.Methods(@This()).GetEffectParameters;
    pub const SetFilterParameters = IVoice.Methods(@This()).SetFilterParameters;
    pub const GetFilterParameters = IVoice.Methods(@This()).GetFilterParameters;
    pub const SetOutputFilterParameters = IVoice.Methods(@This()).SetOutputFilterParameters;
    pub const GetOutputFilterParameters = IVoice.Methods(@This()).GetOutputFilterParameters;
    pub const SetVolume = IVoice.Methods(@This()).SetVolume;
    pub const GetVolume = IVoice.Methods(@This()).GetVolume;
    pub const SetChannelVolumes = IVoice.Methods(@This()).SetChannelVolumes;
    pub const GetChannelVolumes = IVoice.Methods(@This()).GetChannelVolumes;
    pub const DestroyVoice = IVoice.Methods(@This()).DestroyVoice;

    pub const VTable = extern struct {
        base: IVoice.VTable,
    };
};

pub const IMasteringVoice = extern struct {
    __v: *const VTable,

    pub const GetVoiceDetails = IVoice.Methods(@This()).GetVoiceDetails;
    pub const SetOutputVoices = IVoice.Methods(@This()).SetOutputVoices;
    pub const SetEffectChain = IVoice.Methods(@This()).SetEffectChain;
    pub const EnableEffect = IVoice.Methods(@This()).EnableEffect;
    pub const DisableEffect = IVoice.Methods(@This()).DisableEffect;
    pub const GetEffectState = IVoice.Methods(@This()).GetEffectState;
    pub const SetEffectParameters = IVoice.Methods(@This()).SetEffectParameters;
    pub const GetEffectParameters = IVoice.Methods(@This()).GetEffectParameters;
    pub const SetFilterParameters = IVoice.Methods(@This()).SetFilterParameters;
    pub const GetFilterParameters = IVoice.Methods(@This()).GetFilterParameters;
    pub const SetOutputFilterParameters = IVoice.Methods(@This()).SetOutputFilterParameters;
    pub const GetOutputFilterParameters = IVoice.Methods(@This()).GetOutputFilterParameters;
    pub const SetVolume = IVoice.Methods(@This()).SetVolume;
    pub const GetVolume = IVoice.Methods(@This()).GetVolume;
    pub const SetChannelVolumes = IVoice.Methods(@This()).SetChannelVolumes;
    pub const GetChannelVolumes = IVoice.Methods(@This()).GetChannelVolumes;
    pub const DestroyVoice = IVoice.Methods(@This()).DestroyVoice;

    pub const GetChannelMask = IMasteringVoice.Methods(@This()).GetChannelMask;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn GetChannelMask(self: *T, channel_mask: *DWORD) HRESULT {
                return @as(*const IMasteringVoice.VTable, @ptrCast(self.__v)).GetChannelMask(
                    @ptrCast(self),
                    channel_mask,
                );
            }
        };
    }

    pub const VTable = extern struct {
        base: IVoice.VTable,
        GetChannelMask: *const fn (*IMasteringVoice, *DWORD) callconv(WINAPI) HRESULT,
    };
};

pub const IEngineCallback = extern struct {
    __v: *const VTable,

    pub const OnProcessingPassStart = IEngineCallback.Methods(@This()).OnProcessingPassStart;
    pub const OnProcessingPassEnd = IEngineCallback.Methods(@This()).OnProcessingPassEnd;
    pub const OnCriticalError = IEngineCallback.Methods(@This()).OnCriticalError;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn OnProcessingPassStart(self: *T) void {
                @as(*const IEngineCallback.VTable, @ptrCast(self.__v)).OnProcessingPassStart(@ptrCast(self));
            }
            pub inline fn OnProcessingPassEnd(self: *T) void {
                @as(*const IEngineCallback.VTable, @ptrCast(self.__v)).OnProcessingPassEnd(@ptrCast(self));
            }
            pub inline fn OnCriticalError(self: *T, err: HRESULT) void {
                @as(*const IEngineCallback.VTable, @ptrCast(self.__v)).OnCriticalError(@ptrCast(self), err);
            }
        };
    }

    pub const VTable = extern struct {
        OnProcessingPassStart: *const fn (*IEngineCallback) callconv(WINAPI) void,
        OnProcessingPassEnd: *const fn (*IEngineCallback) callconv(WINAPI) void,
        OnCriticalError: *const fn (*IEngineCallback, HRESULT) callconv(WINAPI) void,
    };
};

pub const IVoiceCallback = extern struct {
    __v: *const VTable,

    pub const OnVoiceProcessingPassStart = IVoiceCallback.Methods(@This()).OnVoiceProcessingPassStart;
    pub const OnVoiceProcessingPassEnd = IVoiceCallback.Methods(@This()).OnVoiceProcessingPassEnd;
    pub const OnStreamEnd = IVoiceCallback.Methods(@This()).OnStreamEnd;
    pub const OnBufferStart = IVoiceCallback.Methods(@This()).OnBufferStart;
    pub const OnBufferEnd = IVoiceCallback.Methods(@This()).OnBufferEnd;
    pub const OnLoopEnd = IVoiceCallback.Methods(@This()).OnLoopEnd;
    pub const OnVoiceError = IVoiceCallback.Methods(@This()).OnVoiceError;

    pub fn Methods(comptime T: type) type {
        return extern struct {
            pub inline fn OnVoiceProcessingPassStart(self: *T, bytes_required: UINT32) void {
                @as(*const IVoiceCallback.VTable, @ptrCast(self.__v)).OnVoiceProcessingPassStart(
                    @ptrCast(self),
                    bytes_required,
                );
            }
            pub inline fn OnVoiceProcessingPassEnd(self: *T) void {
                @as(*const IVoiceCallback.VTable, @ptrCast(self.__v)).OnVoiceProcessingPassEnd(@ptrCast(self));
            }
            pub inline fn OnStreamEnd(self: *T) void {
                @as(*const IVoiceCallback.VTable, @ptrCast(self.__v)).OnStreamEnd(@ptrCast(self));
            }
            pub inline fn OnBufferStart(self: *T, context: ?*anyopaque) void {
                @as(*const IVoiceCallback.VTable, @ptrCast(self.__v)).OnBufferStart(@ptrCast(self), context);
            }
            pub inline fn OnBufferEnd(self: *T, context: ?*anyopaque) void {
                @as(*const IVoiceCallback.VTable, @ptrCast(self.__v)).OnBufferEnd(@ptrCast(self), context);
            }
            pub inline fn OnLoopEnd(self: *T, context: ?*anyopaque) void {
                @as(*const IVoiceCallback.VTable, @ptrCast(self.__v)).OnLoopEnd(@ptrCast(self), context);
            }
            pub inline fn OnVoiceError(self: *T, context: ?*anyopaque, err: HRESULT) void {
                @as(*const IVoiceCallback.VTable, @ptrCast(self.__v)).OnVoiceError(@ptrCast(self), context, err);
            }
        };
    }

    pub const VTable = extern struct {
        OnVoiceProcessingPassStart: *const fn (*IVoiceCallback, UINT32) callconv(WINAPI) void,
        OnVoiceProcessingPassEnd: *const fn (*IVoiceCallback) callconv(WINAPI) void,
        OnStreamEnd: *const fn (*IVoiceCallback) callconv(WINAPI) void,
        OnBufferStart: *const fn (*IVoiceCallback, ?*anyopaque) callconv(WINAPI) void,
        OnBufferEnd: *const fn (*IVoiceCallback, ?*anyopaque) callconv(WINAPI) void,
        OnLoopEnd: *const fn (*IVoiceCallback, ?*anyopaque) callconv(WINAPI) void,
        OnVoiceError: *const fn (*IVoiceCallback, ?*anyopaque, HRESULT) callconv(WINAPI) void,
    };
};

pub fn create(
    ppv: *?*IXAudio2,
    flags: FLAGS, // .{}
    processor: UINT32, // 0
) HRESULT {
    var xaudio2_dll = w32.GetModuleHandleA("xaudio2_9redist.dll");
    if (xaudio2_dll == null) {
        xaudio2_dll = w32.LoadLibraryA("xaudio2_9redist.dll");
        if (xaudio2_dll == null) return w32.E_FAIL;
    }

    const xaudio2_create: ?*const fn (*?*IXAudio2, FLAGS, UINT32) callconv(WINAPI) HRESULT =
        @ptrCast(w32.GetProcAddress(xaudio2_dll.?, "XAudio2Create"));

    if (xaudio2_create == null) return w32.E_FAIL;

    return xaudio2_create.?(ppv, flags, processor);
}
