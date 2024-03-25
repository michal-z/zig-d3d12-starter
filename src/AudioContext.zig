const std = @import("std");
const w32 = @import("win32/win32.zig");
const xa2 = @import("win32/xaudio2.zig");
const mf = @import("win32/mf.zig");
const wasapi = @import("win32/wasapi.zig");

const xaudio2_debug = @import("build_options").audio_debug;

const WAVEFORMATEX = wasapi.WAVEFORMATEX;

const AudioContext = @This();

const log = std.log.scoped(.audio_context);

//allocator: std.mem.Allocator,
xaudio2: ?*xa2.IXAudio2 = null,
mastering_voice: *xa2.IMasteringVoice = undefined,
source_voices: std.ArrayList(*xa2.ISourceVoice) = undefined,

pub fn init(_: std.mem.Allocator) !AudioContext {
    var xaudio2: *xa2.IXAudio2 = undefined;
    if (xa2.create(@ptrCast(&xaudio2), .{ .DEBUG_ENGINE = xaudio2_debug }, 0) != w32.S_OK) {
        log.info("Failed to initialize audio subsystem (XAudio2Create()).", .{});
        return error.XAudio2CreateFailed;
    }
    errdefer _ = xaudio2.Release();

    log.info("XAudio2 root object created.", .{});

    if (mf.Startup(mf.VERSION, 0) != w32.S_OK) {
        log.info("Failed to initialize audio subsystem (XAudio2Create()).", .{});
        return error.MFStartupFailed;
    }
    errdefer _ = mf.Shutdown();

    log.info("Windows Media Foundation startup went fine.", .{});

    return AudioContext{
        .xaudio2 = xaudio2,
    };
}

pub fn deinit(audctx: *AudioContext) void {
    if (audctx.xaudio2) |xaudio2| {
        xaudio2.StopEngine();
        _ = mf.Shutdown();
        audctx.* = AudioContext{};
    }
}

const optimal_format = WAVEFORMATEX{
    .wFormatTag = wasapi.WAVE_FORMAT_PCM,
    .nChannels = 1,
    .nSamplesPerSec = 48_000,
    .nAvgBytesPerSec = 2 * 48_000,
    .nBlockAlign = 2,
    .wBitsPerSample = 16,
    .cbSize = @sizeOf(WAVEFORMATEX),
};
