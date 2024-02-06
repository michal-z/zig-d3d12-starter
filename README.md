# zig-d3d12-starter

```
git clone https://github.com/michal-z/zig-d3d12-starter.git
cd zig-d3d12-starter
zig build run
```
* Minimal and ready to use project with no dependency except [Zig compiler (master)](https://ziglang.org/download/)
* DXC compiler included and integrated - Zig's caching mechanism nicely works with shader compilations
* D3D12 Agility SDK included and integrated
* D3D12 bindings with some helper functions
* D3D12 debug layer and GPU-based validation support
* No libc dependency
* Small output binary (~25 KB in `ReleaseFast` configuration)

Roadmap:
* Zig API for `PIX for Windows`
* XAudio2 bindings

Build options:

    -Doptimize=ReleaseFast (generate small and fast binary)
    -Dd3d12-debug=true (enable D3D12 debug layer)
    -Dd3d12-debug-gpu=true (enable D3D12 debug layer and GPU-based validation)

Example:

    zig build run -Doptimize=ReleaseFast -Dd3d12-debug=true

![image](screenshot.png)
