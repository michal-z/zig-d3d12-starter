# zig-d3d12-starter

```
git clone https://github.com/michal-z/zig-d3d12-starter.git
cd zig-d3d12-starter
zig build run
```
* Simple game written from scratch
* No dependency except [Zig compiler (master)](https://ziglang.org/download/)
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
