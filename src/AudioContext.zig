const std = @import("std");
const w32 = @import("win32/win32.zig");
const xa2 = @import("win32/xaudio2.zig");
const mf = @import("win32/mf.zig");
const wasapi = @import("win32/wasapi.zig");

const HRESULT = w32.HRESULT;
const UINT32 = w32.UINT32;
const WINAPI = w32.WINAPI;

const xaudio2_debug = @import("build_options").audio_debug;

const WAVEFORMATEX = wasapi.WAVEFORMATEX;

const AudioContext = @This();

const log = std.log.scoped(.audio_context);

//allocator: std.mem.Allocator,
xaudio2: ?*xa2.IXAudio2 = null,
mastering_voice: *xa2.IMasteringVoice = undefined,
source_voices: std.ArrayList(*xa2.ISourceVoice) = undefined,

pub fn init(allocator: std.mem.Allocator) !AudioContext {
    var xaudio2: *xa2.IXAudio2 = undefined;
    if (xa2.create(@ptrCast(&xaudio2), .{ .DEBUG_ENGINE = xaudio2_debug }, 0) != w32.S_OK) {
        log.info("Failed to initialize audio subsystem (XAudio2Create()).", .{});
        return error.XAudio2CreateFailed;
    }
    errdefer _ = xaudio2.Release();

    log.info("XAudio2 root object created.", .{});

    if (mf.Startup(mf.VERSION, 0) != w32.S_OK) {
        log.info("Failed to initialize audio subsystem (MFStartup()).", .{});
        return error.MFStartupFailed;
    }
    errdefer _ = mf.Shutdown();

    log.info("Windows Media Foundation startup went fine.", .{});

    if (xaudio2_debug) {
        xaudio2.SetDebugConfiguration(&.{
            .TraceMask = .{ .ERRORS = true, .WARNINGS = true, .INFO = true },
            .BreakMask = .{},
            .LogThreadID = .TRUE,
            .LogFileline = .FALSE,
            .LogFunctionName = .FALSE,
            .LogTiming = .FALSE,
        }, null);
    }

    var mastering_voice: *xa2.IMasteringVoice = undefined;
    if (xaudio2.CreateMasteringVoice(
        @ptrCast(&mastering_voice),
        xa2.DEFAULT_CHANNELS,
        xa2.DEFAULT_SAMPLERATE,
        .{},
        null,
        null,
        .GameEffects,
    ) != w32.S_OK) {
        log.info("Failed to create mastering voice.", .{});
        return error.XAudio2Error;
    }
    errdefer mastering_voice.DestroyVoice();

    log.info("Mastering voice created.", .{});

    var source_voices = std.ArrayList(*xa2.ISourceVoice).init(allocator);
    {
        var i: u32 = 0;
        while (i < 32) : (i += 1) {
            var voice: *xa2.ISourceVoice = undefined;
            vhr(xaudio2.CreateSourceVoice(
                @ptrCast(&voice),
                &optimal_format,
                .{},
                xa2.DEFAULT_FREQ_RATIO,
                @ptrCast(&stop_on_buffer_end_cb),
                null,
                null,
            ));
            source_voices.append(voice) catch unreachable;
        }
        log.info("Source voices created.", .{});
    }

    return AudioContext{
        .xaudio2 = xaudio2,
        .mastering_voice = mastering_voice,
        .source_voices = source_voices,
    };
}

pub fn deinit(audctx: *AudioContext) void {
    if (audctx.xaudio2) |xaudio2| {
        xaudio2.StopEngine();
        _ = mf.Shutdown();
        for (audctx.source_voices.items) |voice| voice.DestroyVoice();
        audctx.source_voices.deinit();
        audctx.mastering_voice.DestroyVoice();
        _ = xaudio2.Release();
        audctx.* = AudioContext{};
    }
}

pub const SoundHandle = extern struct {
    index: u16 align(4) = 0,
    generation: u16 = 0,
};

const Sound = struct {
    data: ?[]const u8 = null,
};

const SoundPool = struct {
    const max_num_sounds = 1024;

    sounds: []Sound,
    generations: []u16,

    fn init(allocator: std.mem.Allocator) SoundPool {
        return .{
            .sounds = blk: {
                const sounds = allocator.alloc(Sound, max_num_sounds + 1) catch unreachable;
                for (sounds) |*sound| {
                    sound.* = .{};
                }
                break :blk sounds;
            },
            .generations = blk: {
                const generations = allocator.alloc(u16, max_num_sounds + 1) catch unreachable;
                @memset(generations, 0);
                break :blk generations;
            },
        };
    }

    fn deinit(pool: *SoundPool, allocator: std.mem.Allocator) void {
        for (pool.sounds) |sound| {
            if (sound.data) |data| allocator.free(data);
        }
        allocator.free(pool.sounds);
        allocator.free(pool.generations);
        pool.* = undefined;
    }

    fn add_sound(pool: SoundPool, data: []const u8) SoundHandle {
        var slot_idx: u32 = 1;
        while (slot_idx <= max_num_sounds) : (slot_idx += 1) {
            if (pool.sounds[slot_idx].data == null)
                break;
        }
        std.debug.assert(slot_idx <= max_num_sounds);

        pool.sounds[slot_idx] = .{ .data = data };
        return .{
            .index = @intCast(slot_idx),
            .generation = blk: {
                pool.generations[slot_idx] += 1;
                break :blk pool.generations[slot_idx];
            },
        };
    }

    fn destroy_sound(pool: SoundPool, allocator: std.mem.Allocator, handle: SoundHandle) void {
        if (pool.lookup_sound(handle)) |*sound| {
            allocator.free(sound.data.?);
            sound.* = .{};
        }
    }

    fn is_sound_valid(pool: SoundPool, handle: SoundHandle) bool {
        return handle.index > 0 and
            handle.index <= max_num_sounds and
            handle.generation > 0 and
            handle.generation == pool.generations[handle.index] and
            pool.sounds[handle.index].data != null;
    }

    fn lookup_sound(pool: SoundPool, handle: SoundHandle) ?*Sound {
        if (pool.is_sound_valid(handle)) {
            return &pool.sounds[handle.index];
        }
        return null;
    }
};

const StopOnBufferEndVoiceCallback = extern struct {
    __v: *const xa2.IVoiceCallback.VTable = &.{
        .OnVoiceProcessingPassStart = _on_voice_processing_pass_start,
        .OnVoiceProcessingPassEnd = _on_voice_processing_pass_end,
        .OnStreamEnd = _on_stream_end,
        .OnBufferStart = _on_buffer_start,
        .OnBufferEnd = _on_buffer_end,
        .OnLoopEnd = _on_loop_end,
        .OnVoiceError = _on_voice_error,
    },

    fn _on_buffer_end(_: *xa2.IVoiceCallback, context: ?*anyopaque) callconv(WINAPI) void {
        const voice = @as(*xa2.ISourceVoice, @ptrCast(@alignCast(context)));
        _ = voice.Stop(.{}, xa2.COMMIT_NOW);
    }

    fn _on_voice_processing_pass_start(_: *xa2.IVoiceCallback, _: UINT32) callconv(WINAPI) void {}
    fn _on_voice_processing_pass_end(_: *xa2.IVoiceCallback) callconv(WINAPI) void {}
    fn _on_stream_end(_: *xa2.IVoiceCallback) callconv(WINAPI) void {}
    fn _on_buffer_start(_: *xa2.IVoiceCallback, _: ?*anyopaque) callconv(WINAPI) void {}
    fn _on_loop_end(_: *xa2.IVoiceCallback, _: ?*anyopaque) callconv(WINAPI) void {}
    fn _on_voice_error(_: *xa2.IVoiceCallback, _: ?*anyopaque, _: HRESULT) callconv(WINAPI) void {}
};
var stop_on_buffer_end_cb: StopOnBufferEndVoiceCallback = .{};

fn vhr(hr: w32.HRESULT) void {
    if (hr != 0) @panic("HRESULT error!");
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
