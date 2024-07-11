# zig-d3d12-starter

```
git clone https://github.com/michal-z/zig-d3d12-starter.git
cd zig-d3d12-starter
zig build run
```

Requires [Zig 0.13.0](https://ziglang.org/download/#release-0.13.0) to build.

* Simple game written from scratch
* Modern D3D12 for rendering (fully bindless, ehnanced barriers)
* Direct2D for 2D shape tessellation
* Audio support using XAudio2
* No dependency except [Zig compiler](https://ziglang.org/download/#release-0.13.0)
* DXC compiler included - Zig's caching mechanism integrated to support shader compilation
* Shaders embeded in the output binary
* D3D12 Agility SDK included and integrated
* D3D12 bindings with some helper functions
* D3D12 debug layer and GPU-based validation support
* No libc dependency

Build options:

    -Doptimize=ReleaseFast (generate small and fast binary)
    -Dd3d12-debug=true (enable D3D12 debug layer)
    -Dd3d12-debug-gpu=true (enable D3D12 debug layer and GPU-based validation)

Example:

    zig build run -Doptimize=ReleaseFast -Dd3d12-debug=true

![image](screenshot.png)
