const std = @import("std");

pub const min_zig_version = std.SemanticVersion{ .major = 0, .minor = 12, .patch = 0, .pre = "dev.2540" };

pub fn build(b: *std.Build) void {
    ensureZigVersion() catch return;

    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "zig-d3d12-starter",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = false,
    });
    exe.rdynamic = true;
    if (optimize == .ReleaseFast)
        exe.root_module.strip = true;

    const d3d12_debug = b.option(bool, "d3d12-debug", "Enable D3D12 debug layer") orelse false;
    const d3d12_debug_gpu = b.option(bool, "d3d12-debug-gpu", "Enable D3D12 GPU-based validation") orelse false;

    const build_options = b.addOptions();
    build_options.addOption(bool, "d3d12_debug", d3d12_debug);
    build_options.addOption(bool, "d3d12_debug_gpu", d3d12_debug_gpu);

    exe.root_module.addOptions("build_options", build_options);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const install_d3d12_step = b.addInstallDirectory(.{
        .source_dir = .{ .path = "bin/d3d12" },
        .install_dir = .bin,
        .install_subdir = "d3d12",
    });
    exe.step.dependOn(&install_d3d12_step.step);

    const dxc_step = buildShaders(b);
    exe.step.dependOn(dxc_step);
}

fn buildShaders(b: *std.Build) *std.Build.Step {
    const dxc_step = b.step("dxc", "Build HLSL shaders");

    makeDxcCmd(b, dxc_step, "src/main.hlsl", "vertex", "s00.vs.cso", "vs", "");
    makeDxcCmd(b, dxc_step, "src/main.hlsl", "pixel", "s00.ps.cso", "ps", "");

    return dxc_step;
}

fn makeDxcCmd(
    b: *std.Build,
    dxc_step: *std.Build.Step,
    comptime input_path: []const u8,
    comptime entry_point: []const u8,
    comptime output_filename: []const u8,
    comptime profile: []const u8,
    comptime define: []const u8,
) void {
    const shader_ver = "6_0";

    const dxc_command = [9][]const u8{
        "bin/dxc.exe",
        input_path,
        "/E " ++ entry_point,
        "/Fo " ++ "src/cso/" ++ output_filename,
        "/T " ++ profile ++ "_" ++ shader_ver,
        if (define.len == 0) "" else "/D " ++ define,
        "/WX",
        "/Ges",
        "/O3",
    };

    const cmd_step = b.addSystemCommand(&dxc_command);
    dxc_step.dependOn(&cmd_step.step);
}

fn ensureZigVersion() !void {
    var installed_ver = @import("builtin").zig_version;
    installed_ver.build = null;

    if (installed_ver.order(min_zig_version) == .lt) {
        std.log.err("\n" ++
            \\---------------------------------------------------------------------------
            \\
            \\Installed Zig compiler version is too old.
            \\
            \\Min. required version: {any}
            \\Installed version: {any}
            \\
            \\Please install newer version and try again.
            \\Latest version can be found here: https://ziglang.org/download/
            \\
            \\---------------------------------------------------------------------------
            \\
        , .{ min_zig_version, installed_ver });
        return error.ZigIsTooOld;
    }
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
