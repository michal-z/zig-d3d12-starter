const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d12 = @import("win32/d3d12.zig");
const d3d12d = @import("win32/d3d12sdklayers.zig");
const dxgi = @import("win32/dxgi.zig");
const d2d1 = @import("win32/d2d1.zig");
const xa2 = @import("win32/xaudio2.zig");
const cgen = @import("content_generation.zig");
const cpu_gpu = @cImport(@cInclude("cpu_gpu_shared.h"));

pub const std_options = .{
    .log_level = .info,
};

// IDEAS:
// Level with rotating planets
// Level with neurons
// Level with PCB paths
// Level with logic gates

export const D3D12SDKVersion: u32 = 613;
export const D3D12SDKPath: [*:0]const u8 = ".\\d3d12\\";

const window_name = "zig-d3d12-starter";

const GpuContext = @import("GpuContext.zig");
const AudioContext = @import("AudioContext.zig");
const vhr = GpuContext.vhr;
const window_clear_color: [4]f32 = .{ 1, 1, 1, 0 };
const ds_target_format: dxgi.FORMAT = .D32_FLOAT;
var random_state = std.Random.DefaultPrng.init(0);
const random = random_state.random();

const pso_color = 0;
const pso_shadow = 1;

pub fn main() !void {
    _ = w32.SetProcessDPIAware();

    _ = w32.CoInitializeEx(null, w32.COINIT_MULTITHREADED);
    defer w32.CoUninitialize();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var game = try GameState.init(allocator);
    defer game.deinit();

    while (true) {
        var message = std.mem.zeroes(w32.MSG);
        if (w32.PeekMessageA(&message, null, 0, 0, w32.PM_REMOVE) == .TRUE) {
            _ = w32.TranslateMessage(&message);
            _ = w32.DispatchMessageA(&message);
            if (message.message == w32.WM_QUIT) break;
        }

        if (game.update())
            game.draw();
    }
}

const GameState = struct {
    allocator: std.mem.Allocator,

    gpu_context: GpuContext,
    audio_context: AudioContext,

    vertex_buffer: *d3d12.IResource,
    frame_state_buffer: *d3d12.IResource,

    pso: [2]*d3d12.IPipelineState,
    pso_rs: *d3d12.IRootSignature,

    d2d_factory: *d2d1.IFactory,

    meshes: std.ArrayList(cgen.Mesh),

    player_is_dead: f32 = 0.0,
    player_to_next_level: f32 = 0.0,

    current_level_name: cgen.LevelName,
    current_level: cgen.LevelState,

    eat_sounds: [2]AudioContext.SoundHandle,

    fn init(allocator: std.mem.Allocator) !GameState {
        var gpu_context = GpuContext.init(
            create_window(
                w32.GetSystemMetrics(w32.SM_CXSCREEN),
                w32.GetSystemMetrics(w32.SM_CYSCREEN),
            ),
            .{
                .color_target_clear_color = window_clear_color,
                .ds_target_format = .D32_FLOAT,
            },
        );

        // If `AudioContext` initialization fails we will use "empty" context that does nothing
        // (game will still run but without sound).
        var audio_context = AudioContext.init(allocator) catch AudioContext{};

        const eat_sounds = .{
            audio_context.create_sound_from_file("data/sounds/tabla_tas1.flac") catch unreachable,
            audio_context.create_sound_from_file("data/sounds/drum_bass_hard.flac") catch unreachable,
        };

        const pso, const pso_rs = create_pso(gpu_context.device);

        var frame_state_buffer: *d3d12.IResource = undefined;
        vhr(gpu_context.device.CreateCommittedResource3(
            &.{ .Type = .DEFAULT },
            d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
            &.{
                .Dimension = .BUFFER,
                .Width = @sizeOf(cpu_gpu.FrameState),
                .Layout = .ROW_MAJOR,
            },
            .UNDEFINED,
            null,
            null,
            0,
            null,
            &d3d12.IResource.IID,
            @ptrCast(&frame_state_buffer),
        ));

        gpu_context.device.CreateConstantBufferView(
            &.{
                .BufferLocation = frame_state_buffer.GetGPUVirtualAddress(),
                .SizeInBytes = @sizeOf(cpu_gpu.FrameState),
            },
            .{ .ptr = gpu_context.shader_dheap_start_cpu.ptr +
                @as(u32, @intCast(cpu_gpu.rdh_frame_state_buffer)) *
                gpu_context.shader_dheap_descriptor_size },
        );

        var d2d_factory: *d2d1.IFactory = undefined;
        vhr(d2d1.CreateFactory(
            .SINGLE_THREADED,
            &d2d1.IFactory.IID,
            if (GpuContext.d3d12_debug) &.{ .debugLevel = .INFORMATION } else &.{ .debugLevel = .NONE },
            @ptrCast(&d2d_factory),
        ));

        const meshes, const vertex_buffer = try cgen.define_and_upload_meshes(allocator, &gpu_context, d2d_factory);

        const current_level_name = .rotating_arm;
        //const current_level_name = .strange_star_and_wall;
        const current_level = try cgen.define_and_upload_level(allocator, &gpu_context, current_level_name);

        return .{
            .allocator = allocator,
            .gpu_context = gpu_context,
            .audio_context = audio_context,
            .vertex_buffer = vertex_buffer,
            .frame_state_buffer = frame_state_buffer,
            .pso = pso,
            .pso_rs = pso_rs,
            .meshes = meshes,
            .d2d_factory = d2d_factory,
            .current_level = current_level,
            .current_level_name = current_level_name,
            .eat_sounds = eat_sounds,
        };
    }

    fn deinit(game: *GameState) void {
        game.gpu_context.finish_gpu_commands();

        game.audio_context.deinit();

        for (game.meshes.items) |mesh| {
            if (mesh.geometry) |geometry| _ = geometry.Release();
        }
        game.meshes.deinit();
        game.current_level.deinit();

        _ = game.d2d_factory.Release();
        for (game.pso) |pso| _ = pso.Release();
        _ = game.pso_rs.Release();
        _ = game.vertex_buffer.Release();
        _ = game.frame_state_buffer.Release();

        game.gpu_context.deinit();

        game.* = undefined;
    }

    fn update(game: *GameState) bool {
        const status = game.gpu_context.handle_window_resize();
        if (status == .minimized) {
            w32.Sleep(10);
            return false;
        }

        _, const delta_time = update_frame_stats(game.gpu_context.window, window_name);

        if (game.player_is_dead > 0.0) {
            game.player_is_dead -= delta_time;

            if (game.player_is_dead <= 0.0) {
                game.player_is_dead = 0.0;

                game.gpu_context.finish_gpu_commands();

                game.current_level.deinit();
                game.current_level = cgen.define_and_upload_level(
                    game.allocator,
                    &game.gpu_context,
                    game.current_level_name,
                ) catch unreachable;
            }
            return true;
        }

        if (game.player_to_next_level > 0.0) {
            game.player_to_next_level -= delta_time;

            if (game.player_to_next_level <= 0.0) {
                game.player_to_next_level = 0.0;

                // Advance to the next level.
                game.current_level_name = game.current_level_name.next_level() catch {
                    _ = w32.MessageBoxA(
                        game.gpu_context.window,
                        "Y O U  H A V E  C O M P L E T E D  T H E  G A M E !!!",
                        "CONGRATULATIONS",
                        w32.MB_OK,
                    );
                    w32.PostQuitMessage(0);
                    return true;
                };

                game.gpu_context.finish_gpu_commands();

                game.current_level.deinit();
                game.current_level = cgen.define_and_upload_level(
                    game.allocator,
                    &game.gpu_context,
                    game.current_level_name,
                ) catch unreachable;
            }
            return true;
        }

        const level = &game.current_level;
        const player = &level.objects_cpu.items[level.objects_cpu.items.len - 1];

        const window_width: f32 = @floatFromInt(game.gpu_context.window_width);
        const window_height: f32 = @floatFromInt(game.gpu_context.window_height);
        const window_aspect = window_width / window_height;

        if (is_key_down(w32.VK_RIGHT) or is_key_down('D')) {
            player.rotation += player.rotation_speed * delta_time;
        } else if (is_key_down(w32.VK_LEFT) or is_key_down('A')) {
            player.rotation -= player.rotation_speed * delta_time;
        }

        player.x += @cos(player.rotation) * player.move_speed * delta_time;
        player.y += @sin(player.rotation) * player.move_speed * delta_time;

        for (level.objects_cpu.items) |*object| {
            if (object == player) continue;
            if (object.flags & cpu_gpu.obj_flag_is_dead != 0) continue;

            object.rotation += object.rotation_speed;

            if (object.move_speed != 0.0) {
                object.x += @cos(object.move_direction) * object.move_speed * delta_time;
                object.y += @sin(object.move_direction) * object.move_speed * delta_time;

                if (object.x < -0.5 * cgen.map_size_y * window_aspect or
                    object.x > 0.5 * cgen.map_size_y * window_aspect or
                    object.y < 0.0 or
                    object.y > cgen.map_size_y)
                {
                    object.move_direction += std.math.pi;
                }
            }
        }

        if (player.x < -0.5 * cgen.map_size_y * window_aspect) {
            player.x = 0.5 * cgen.map_size_y * window_aspect;
        } else if (player.x > 0.5 * cgen.map_size_y * window_aspect) {
            player.x = -0.5 * cgen.map_size_y * window_aspect;
        }

        if (player.y < 0.0) {
            player.y = cgen.map_size_y;
        } else if (player.y > cgen.map_size_y) {
            player.y = 0.0;
        }

        for (level.objects_cpu.items) |*object| {
            if (object == player) continue;
            if (object.flags & cpu_gpu.obj_flag_is_dead != 0) continue;

            const parent = level.objects_cpu.items[object.parent];

            for (0..object.mesh_indices.len) |submesh| {
                if (object.mesh_indices[submesh] == cgen.Mesh.invalid) continue;

                if (game.meshes.items[object.mesh_indices[submesh]].geometry) |geometry| {
                    var contains: w32.BOOL = .FALSE;
                    vhr(geometry.FillContainsPoint(
                        .{ .x = player.x, .y = player.y },
                        &d2d1.MATRIX_3X2_F.mul(
                            d2d1.MATRIX_3X2_F.rotation_translation(object.rotation, object.x, object.y),
                            d2d1.MATRIX_3X2_F.rotation_translation(parent.rotation, parent.x, parent.y),
                        ),
                        d2d1.DEFAULT_FLATTENING_TOLERANCE,
                        &contains,
                    ));

                    if (contains == .TRUE) {
                        if (object.flags & cpu_gpu.obj_flag_is_food != 0) {
                            object.flags |= cpu_gpu.obj_flag_is_dead;
                            object.flags &= @bitCast(~cpu_gpu.obj_flag_is_food);

                            const idx = random.uintLessThan(u32, game.eat_sounds.len);
                            game.audio_context.play_sound(game.eat_sounds[idx], .{});

                            level.num_food_objects -= 1;
                            if (level.num_food_objects == 0) {
                                game.player_to_next_level = 1.0;
                                return true;
                            }
                        } else {
                            game.player_is_dead = 1.0;
                            return true;
                        }
                        break;
                    }
                }
            }
        }

        return true;
    }

    fn draw(game: *GameState) void {
        const level = &game.current_level;
        const gc = &game.gpu_context;

        gc.begin_command_list();

        gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
            .Type = .BUFFER,
            .NumBarriers = 2,
            .u = .{ .pBufferBarriers = &[_]d3d12.BUFFER_BARRIER{ .{
                .SyncBefore = .{},
                .SyncAfter = .{ .COPY = true },
                .AccessBefore = .{ .NO_ACCESS = true },
                .AccessAfter = .{ .COPY_DEST = true },
                .pResource = game.frame_state_buffer,
            }, .{
                .SyncBefore = .{},
                .SyncAfter = .{ .COPY = true },
                .AccessBefore = .{ .NO_ACCESS = true },
                .AccessAfter = .{ .COPY_DEST = true },
                .pResource = level.objects_gpu,
            } } },
        }});

        {
            const proj = proj: {
                const width: f32 = @floatFromInt(gc.window_width);
                const height: f32 = @floatFromInt(gc.window_height);
                const aspect = width / height;

                break :proj orthographic_off_center(
                    -0.5 * cgen.map_size_y * aspect,
                    0.5 * cgen.map_size_y * aspect,
                    0.0,
                    cgen.map_size_y,
                    0.0,
                    1.0,
                );
            };

            const upload_mem, const buffer, const offset = gc.allocate_upload_buffer_region(cpu_gpu.FrameState, 1);

            upload_mem[0] = .{
                .proj = transpose(proj),
            };

            gc.command_list.CopyBufferRegion(
                game.frame_state_buffer,
                0,
                buffer,
                offset,
                upload_mem.len * @sizeOf(@TypeOf(upload_mem[0])),
            );
        }

        {
            const upload_mem, const buffer, const offset = gc.allocate_upload_buffer_region(
                cpu_gpu.Object,
                @intCast(level.objects_cpu.items.len),
            );

            for (level.objects_cpu.items, 0..) |object, i| upload_mem[i] = object;

            gc.command_list.CopyBufferRegion(
                level.objects_gpu,
                0,
                buffer,
                offset,
                upload_mem.len * @sizeOf(@TypeOf(upload_mem[0])),
            );
        }

        gc.command_list.Barrier(1, &[_]d3d12.BARRIER_GROUP{.{
            .Type = .BUFFER,
            .NumBarriers = 2,
            .u = .{ .pBufferBarriers = &[_]d3d12.BUFFER_BARRIER{ .{
                .SyncBefore = .{ .COPY = true },
                .SyncAfter = .{ .DRAW = true },
                .AccessBefore = .{ .COPY_DEST = true },
                .AccessAfter = .{ .CONSTANT_BUFFER = true },
                .pResource = game.frame_state_buffer,
            }, .{
                .SyncBefore = .{ .COPY = true },
                .SyncAfter = .{ .DRAW = true },
                .AccessBefore = .{ .COPY_DEST = true },
                .AccessAfter = .{ .SHADER_RESOURCE = true },
                .pResource = level.objects_gpu,
            } } },
        }});

        gc.command_list.OMSetRenderTargets(
            1,
            &[_]d3d12.CPU_DESCRIPTOR_HANDLE{gc.display_target_descriptor()},
            .TRUE,
            &gc.dsv_dheap_start,
        );
        gc.command_list.ClearRenderTargetView(gc.display_target_descriptor(), &window_clear_color, 0, null);
        gc.command_list.ClearDepthStencilView(gc.dsv_dheap_start, .{ .DEPTH = true }, 1.0, 0, 0, null);

        gc.command_list.IASetPrimitiveTopology(.TRIANGLELIST);
        gc.command_list.SetGraphicsRootSignature(game.pso_rs);

        gc.command_list.SetPipelineState(game.pso[pso_color]);

        const objects = level.objects_cpu.items[0..level.objects_cpu.items.len];

        // Draw objects that don't cast shadows (background)
        for (objects, 0..) |object, object_id| {
            if (object.flags & cpu_gpu.obj_flag_is_dead != 0) continue;
            if (object.flags & cpu_gpu.obj_flag_no_shadow == 0) continue;

            for (0..object.mesh_indices.len) |submesh| {
                if (object.mesh_indices[submesh] == cgen.Mesh.invalid) continue;

                const mesh = &game.meshes.items[object.mesh_indices[submesh]];

                gc.command_list.SetGraphicsRoot32BitConstants(
                    0,
                    3,
                    &[_]u32{ mesh.first_vertex, @intCast(object_id), @intCast(submesh) },
                    0,
                );
                gc.command_list.DrawInstanced(mesh.num_vertices, 1, 0, 0);
            }
        }

        // Draw shadows
        gc.command_list.SetPipelineState(game.pso[pso_shadow]);

        for (objects, 0..) |object, object_id| {
            if (object.flags & cpu_gpu.obj_flag_is_dead != 0) continue;
            if (object.flags & cpu_gpu.obj_flag_no_shadow != 0) continue;

            for (0..object.mesh_indices.len) |submesh| {
                if (object.mesh_indices[submesh] == cgen.Mesh.invalid) continue;

                const mesh = &game.meshes.items[object.mesh_indices[submesh]];

                gc.command_list.SetGraphicsRoot32BitConstants(
                    0,
                    3,
                    &[_]u32{ mesh.first_vertex, @intCast(object_id), @intCast(submesh) },
                    0,
                );
                gc.command_list.DrawInstanced(mesh.num_vertices, 1, 0, 0);
            }
        }

        // Draw objects that do cast shadows
        gc.command_list.SetPipelineState(game.pso[pso_color]);

        for (objects, 0..) |object, object_id| {
            if (object.flags & cpu_gpu.obj_flag_is_dead != 0) continue;
            if (object.flags & cpu_gpu.obj_flag_no_shadow != 0) continue;

            for (0..object.mesh_indices.len) |submesh| {
                if (object.mesh_indices[submesh] == cgen.Mesh.invalid) continue;

                const mesh = &game.meshes.items[object.mesh_indices[submesh]];

                gc.command_list.SetGraphicsRoot32BitConstants(
                    0,
                    3,
                    &[_]u32{ mesh.first_vertex, @intCast(object_id), @intCast(submesh) },
                    0,
                );
                gc.command_list.DrawInstanced(mesh.num_vertices, 1, 0, 0);
            }
        }

        gc.end_command_list();

        gc.command_queue.ExecuteCommandLists(1, &[_]*d3d12.ICommandList{@ptrCast(gc.command_list)});
        gc.present_frame();
    }
};

fn create_pso(device: *GpuContext.IDevice) struct { [2]*d3d12.IPipelineState, *d3d12.IRootSignature } {
    const s00_vs = @embedFile("cso/s00.vs.cso");
    const s00_ps = @embedFile("cso/s00.ps.cso");
    const s00_shadow_vs = @embedFile("cso/s00_shadow.vs.cso");
    const s00_shadow_ps = @embedFile("cso/s00_shadow.ps.cso");

    var pso_rs: *d3d12.IRootSignature = undefined;
    vhr(device.CreateRootSignature(
        0,
        s00_vs,
        s00_vs.len,
        &d3d12.IRootSignature.IID,
        @ptrCast(&pso_rs),
    ));

    var pso: [2]*d3d12.IPipelineState = undefined;
    vhr(device.CreateGraphicsPipelineState(
        &.{
            .DepthStencilState = .{
                .DepthEnable = .FALSE,
                .DepthFunc = .LESS_EQUAL,
            },
            .DSVFormat = ds_target_format,
            .RTVFormats = .{GpuContext.display_target_format} ++ .{.UNKNOWN} ** 7,
            .NumRenderTargets = 1,
            .BlendState = .{
                .RenderTarget = .{.{
                    .RenderTargetWriteMask = 0x0f,
                    .BlendEnable = .TRUE,
                    .SrcBlend = .SRC_ALPHA,
                    .DestBlend = .INV_SRC_ALPHA,
                }} ++ .{.{}} ** 7,
            },
            .RasterizerState = .{ .CullMode = .NONE },
            .PrimitiveTopologyType = .TRIANGLE,
            .VS = .{ .pShaderBytecode = s00_vs, .BytecodeLength = s00_vs.len },
            .PS = .{ .pShaderBytecode = s00_ps, .BytecodeLength = s00_ps.len },
            .SampleDesc = .{ .Count = GpuContext.display_target_num_samples },
        },
        &d3d12.IPipelineState.IID,
        @ptrCast(&pso[pso_color]),
    ));

    vhr(device.CreateGraphicsPipelineState(
        &.{
            .DepthStencilState = .{ .DepthEnable = .TRUE },
            .DSVFormat = ds_target_format,
            .RTVFormats = .{GpuContext.display_target_format} ++ .{.UNKNOWN} ** 7,
            .NumRenderTargets = 1,
            .BlendState = .{
                .RenderTarget = .{.{
                    .RenderTargetWriteMask = 0x0f,
                    .BlendEnable = .TRUE,
                    .SrcBlend = .SRC_ALPHA,
                    .DestBlend = .INV_SRC_ALPHA,
                }} ++ .{.{}} ** 7,
            },
            .RasterizerState = .{ .CullMode = .NONE },
            .PrimitiveTopologyType = .TRIANGLE,
            .VS = .{ .pShaderBytecode = s00_shadow_vs, .BytecodeLength = s00_shadow_vs.len },
            .PS = .{ .pShaderBytecode = s00_shadow_ps, .BytecodeLength = s00_shadow_ps.len },
            .SampleDesc = .{ .Count = GpuContext.display_target_num_samples },
        },
        &d3d12.IPipelineState.IID,
        @ptrCast(&pso[pso_shadow]),
    ));

    return .{ pso, pso_rs };
}

fn process_window_message(
    window: w32.HWND,
    message: w32.UINT,
    wparam: w32.WPARAM,
    lparam: w32.LPARAM,
) callconv(w32.WINAPI) w32.LRESULT {
    switch (message) {
        w32.WM_KEYDOWN => {
            if (wparam == w32.VK_ESCAPE) {
                w32.PostQuitMessage(0);
                return 0;
            }
        },
        w32.WM_GETMINMAXINFO => {
            var info: *w32.MINMAXINFO = @ptrFromInt(@as(usize, @intCast(lparam)));
            info.ptMinTrackSize.x = 400;
            info.ptMinTrackSize.y = 400;
            return 0;
        },
        w32.WM_DESTROY => {
            w32.PostQuitMessage(0);
            return 0;
        },
        else => {},
    }
    return w32.DefWindowProcA(window, message, wparam, lparam);
}

fn create_window(width: i32, height: i32) w32.HWND {
    const winclass = w32.WNDCLASSEXA{
        .style = 0,
        .lpfnWndProc = process_window_message,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = @ptrCast(w32.GetModuleHandleA(null)),
        .hIcon = null,
        .hCursor = w32.LoadCursorA(null, @ptrFromInt(32512)),
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = window_name,
        .hIconSm = null,
    };
    _ = w32.RegisterClassExA(&winclass);

    const window = w32.CreateWindowExA(
        w32.WS_EX_TOPMOST,
        window_name,
        window_name,
        w32.WS_POPUP | w32.WS_VISIBLE,
        w32.CW_USEDEFAULT,
        w32.CW_USEDEFAULT,
        width,
        height,
        null,
        null,
        winclass.hInstance,
        null,
    ).?;

    _ = w32.ShowCursor(.FALSE);

    return window;
}

fn update_frame_stats(window: w32.HWND, name: [:0]const u8) struct { f64, f32 } {
    const state = struct {
        var timer: std.time.Timer = undefined;
        var previous_time_ns: u64 = 0;
        var header_refresh_time_ns: u64 = 0;
        var frame_count: u64 = ~@as(u64, 0);
    };

    if (state.frame_count == ~@as(u64, 0)) {
        state.timer = std.time.Timer.start() catch unreachable;
        state.previous_time_ns = 0;
        state.header_refresh_time_ns = 0;
        state.frame_count = 0;
    }

    const now_ns = state.timer.read();
    const time = @as(f64, @floatFromInt(now_ns)) / std.time.ns_per_s;
    const delta_time = @as(f32, @floatFromInt(now_ns - state.previous_time_ns)) / std.time.ns_per_s;
    state.previous_time_ns = now_ns;

    if ((now_ns - state.header_refresh_time_ns) >= std.time.ns_per_s) {
        const t = @as(f64, @floatFromInt(now_ns - state.header_refresh_time_ns)) / std.time.ns_per_s;
        const fps = @as(f64, @floatFromInt(state.frame_count)) / t;
        const ms = (1.0 / fps) * 1000.0;

        var buffer = [_]u8{0} ** 128;
        const buffer_slice = buffer[0 .. buffer.len - 1];
        const header = std.fmt.bufPrint(
            buffer_slice,
            "[{d:.1} fps  {d:.3} ms] {s}",
            .{ fps, ms, name },
        ) catch buffer_slice;

        _ = w32.SetWindowTextA(window, @ptrCast(header.ptr));

        state.header_refresh_time_ns = now_ns;
        state.frame_count = 0;
    }
    state.frame_count += 1;

    return .{ time, delta_time };
}

fn orthographic_off_center(l: f32, r: f32, t: f32, b: f32, n: f32, f: f32) [16]f32 {
    std.debug.assert(!std.math.approxEqAbs(f32, f, n, 0.001));

    const d = 1 / (f - n);
    return .{
        2 / (r - l),        0.0,                0.0,    0.0,
        0.0,                2 / (t - b),        0.0,    0.0,
        0.0,                0.0,                d,      0.0,
        -(r + l) / (r - l), -(t + b) / (t - b), -d * n, 1.0,
    };
}

fn transpose(m: [16]f32) [16]f32 {
    return .{
        m[0], m[4], m[8],  m[12],
        m[1], m[5], m[9],  m[13],
        m[2], m[6], m[10], m[14],
        m[3], m[7], m[11], m[15],
    };
}

fn is_key_down(vkey: c_int) bool {
    return (@as(w32.USHORT, @bitCast(w32.GetAsyncKeyState(vkey))) & 0x8000) != 0;
}
