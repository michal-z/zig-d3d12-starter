const w32 = @import("win32.zig");
const WORD = w32.WORD;
const DWORD = w32.DWORD;

pub const WAVE_FORMAT_PCM = 1;
pub const WAVE_FORMAT_IEEE_FLOAT = 0x0003;

pub const WAVEFORMATEX = extern struct {
    wFormatTag: WORD,
    nChannels: WORD,
    nSamplesPerSec: DWORD,
    nAvgBytesPerSec: DWORD,
    nBlockAlign: WORD,
    wBitsPerSample: WORD,
    cbSize: WORD,
};
