const std = @import("std");

pub fn build(b: *std.Build) void {
    ensure_zig_version() catch return;

    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const exe = b.addExecutable(.{
        .name = "zig-d3d12-starter",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .strip = if (optimize == .ReleaseFast) true else null,
    });
    exe.rdynamic = true;

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

    const dxc_step = build_shaders(b, optimize);
    exe.step.dependOn(dxc_step);
}

fn build_shaders(b: *std.Build, optimize: std.builtin.OptimizeMode) *std.Build.Step {
    const dxc_step = b.step("dxc", "Build HLSL shaders");

    make_dxc_cmd(b, optimize, dxc_step, "src/main.hlsl", "vertex", "s00.vs.cso", "vs", &.{""});
    make_dxc_cmd(b, optimize, dxc_step, "src/main.hlsl", "pixel", "s00.ps.cso", "ps", &.{""});

    return dxc_step;
}

fn make_dxc_cmd(
    b: *std.Build,
    optimize: std.builtin.OptimizeMode,
    dxc_step: *std.Build.Step,
    input_path: []const u8,
    comptime entry_point: []const u8,
    comptime output_filename: []const u8,
    comptime profile: []const u8,
    comptime defines: []const []const u8,
) void {
    const shader_ver = "6_0";

    const cmd_step = b.addSystemCommand(&.{"bin/dxc.exe"});
    cmd_step.addArgs(&.{
        "/WX",
        "/Ges",
        "/all_resources_bound",
        "/HV 2021",
        "/E " ++ entry_point,
        "/T " ++ profile ++ "_" ++ shader_ver,
    });
    if (optimize == .Debug)
        cmd_step.addArgs(&.{ "/Od", "/Zi", "/Qembed_debug" })
    else
        cmd_step.addArg("/O3");

    inline for (defines) |define| {
        if (define.len > 0) cmd_step.addArg("/D " ++ define);
    }

    cmd_step.addFileArg(.{ .path = input_path });
    const cso_path = cmd_step.addPrefixedOutputFileArg("/Fo ", output_filename);

    dxc_step.dependOn(&b.addInstallFile(cso_path, "../src/cso/" ++ output_filename).step);
}

fn ensure_zig_version() !void {
    var installed_ver = @import("builtin").zig_version;
    installed_ver.build = null;

    const min_zig_version = std.SemanticVersion{ .major = 0, .minor = 12, .patch = 0, .pre = "dev.2540" };

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
