const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d12 = @import("win32/d3d12.zig");
const d2d1 = @import("win32/d2d1.zig");
const cpu_gpu = @cImport(@cInclude("cpu_gpu_shared.h"));
const gen_mesh = @import("gen_mesh.zig");

const GpuContext = @import("GpuContext.zig");
const vhr = GpuContext.vhr;
const Mesh = gen_mesh.Mesh;

pub const map_size_x = 1400.0;
pub const map_size_y = 1050.0;
pub const player_start_x = -600.0;
pub const player_start_y = 20.0;

pub const LevelName = enum(u8) {
    star,
    strange_star_and_wall,
    rotating_arm_and_gear,
    long_rotating_blocks,
    spiral,

    pub fn next_level(level: LevelName) !LevelName {
        const i = @intFromEnum(level);
        if (i == @typeInfo(LevelName).Enum.fields.len - 1)
            return error.LastLevel;
        return @enumFromInt(i + 1);
    }
};

pub const LevelState = struct {
    objects_cpu: std.ArrayList(cpu_gpu.Object),
    objects_gpu: *d3d12.IResource,
    num_food_objects: u32,

    pub fn deinit(level: *LevelState) void {
        level.objects_cpu.deinit();
        _ = level.objects_gpu.Release();
        level.* = undefined;
    }
};

fn add_food(objects: *std.ArrayList(cpu_gpu.Object), num_food_objects: *u32, x: f32, y: f32) void {
    const fc = 0xff_00_00_00;
    objects.append(.{
        .flags = cpu_gpu.obj_flag_is_food | cpu_gpu.obj_flag_no_shadow,
        .colors = .{ fc, 0 },
        .mesh_indices = .{ Mesh.food_stroke, Mesh.invalid },
        .x = x,
        .y = y,
    }) catch unreachable;
    num_food_objects.* += 1;
}

pub fn define_and_upload_level(
    allocator: std.mem.Allocator,
    gc: *GpuContext,
    level_name: LevelName,
) !LevelState {
    var objects = std.ArrayList(cpu_gpu.Object).init(allocator);
    var num_food_objects: u32 = 0;

    // Index 0 is invalid object.
    try objects.append(.{
        .colors = .{ 0, 0 },
        .mesh_indices = .{ Mesh.invalid, Mesh.invalid },
        .flags = cpu_gpu.obj_flag_is_dead,
    });

    switch (level_name) {
        .rotating_arm_and_gear => {
            add_food(&objects, &num_food_objects, 325.0, map_size_y / 2 + 25.0);
            add_food(&objects, &num_food_objects, -325.0, map_size_y / 2 - 25.0);
            add_food(&objects, &num_food_objects, 25.0, map_size_y / 2 + 325.0);
            add_food(&objects, &num_food_objects, -25.0, map_size_y / 2 - 325.0);

            add_food(&objects, &num_food_objects, -475.0, map_size_y / 2 - 125.0);
            add_food(&objects, &num_food_objects, -475.0, map_size_y / 2 - 75.0);
            add_food(&objects, &num_food_objects, 475.0, map_size_y / 2 + 75.0);
            add_food(&objects, &num_food_objects, 525.0, map_size_y / 2 + 175.0);

            try objects.append(.{
                .colors = .{ 0x22_ff_ff_ff, 0xaa_ff_ff_ff },
                .mesh_indices = .{ Mesh.gear_12_150, Mesh.gear_12_150_stroke },
                .x = 0.0,
                .y = map_size_y / 2,
                .rotation_speed = 0.001,
                .flags = cpu_gpu.obj_flag_no_shadow,
            });
            try objects.append(.{
                .colors = .{ 0xaa_ff_ff_ff, 0 },
                .mesh_indices = .{ Mesh.circle_150_stroke, Mesh.invalid },
                .x = 0.0,
                .y = map_size_y / 2,
                .flags = cpu_gpu.obj_flag_no_shadow,
            });
            try objects.append(.{
                .colors = .{ 0x55_ff_ff_ff, 0xaa_ff_ff_ff },
                .mesh_indices = .{ Mesh.circle_40, Mesh.circle_40_stroke },
                .x = 0.0,
                .y = map_size_y / 2,
                .flags = cpu_gpu.obj_flag_no_shadow,
            });

            {
                const parent_index: u32 = @intCast(objects.items.len);
                try objects.append(.{
                    .colors = .{ 0x55_ff_ff_ff, 0xaa_ff_ff_ff },
                    .mesh_indices = .{ Mesh.arm_450, Mesh.arm_450_stroke },
                    .x = 0.0,
                    .y = map_size_y / 2,
                    .rotation_speed = -0.01,
                    .flags = cpu_gpu.obj_flag_no_shadow,
                });
                try objects.append(.{
                    .colors = .{ 0x55_ff_ff_ff, 0xaa_ff_ff_ff },
                    .mesh_indices = .{ Mesh.arm_300, Mesh.arm_300_stroke },
                    .x = 450.0,
                    .rotation_speed = -0.015,
                    .parent = parent_index,
                    .flags = cpu_gpu.obj_flag_no_shadow,
                });
                try objects.append(.{
                    .colors = .{ 0x55_ff_ff_ff, 0xaa_ff_ff_ff },
                    .mesh_indices = .{ Mesh.circle_40, Mesh.circle_40_stroke },
                    .parent = parent_index,
                    .flags = cpu_gpu.obj_flag_no_shadow,
                });
                try objects.append(.{
                    .colors = .{ 0x55_ff_ff_ff, 0xaa_ff_ff_ff },
                    .mesh_indices = .{ Mesh.circle_40, Mesh.circle_40_stroke },
                    .parent = parent_index,
                    .x = 450.0,
                    .flags = cpu_gpu.obj_flag_no_shadow,
                });
            }
        },
        .star => {
            try objects.append(.{
                .colors = .{ 0xff_22_44_99, 0xff_00_00_00 },
                .mesh_indices = .{ Mesh.star, Mesh.star_stroke },
            });
            add_food(&objects, &num_food_objects, -197.0, 352.0);
            add_food(&objects, &num_food_objects, 232.0, 364.0);
            add_food(&objects, &num_food_objects, 100.0, 802.0);
            add_food(&objects, &num_food_objects, -160.0, 800.0);
        },
        .long_rotating_blocks => {
            const num = 10;
            for (0..num) |i| {
                const f = std.math.tau * @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(num));
                const r = 300.0;
                add_food(&objects, &num_food_objects, r * @cos(f), map_size_y / 2 + r * @sin(f));
                add_food(&objects, &num_food_objects, r * 1.45 * @sin(f), map_size_y / 2 + r * 1.45 * @cos(f));
            }
            try objects.append(.{
                .colors = .{ 0xff_22_44_99, 0xff_00_00_00 },
                .mesh_indices = .{ Mesh.round_rect_900_50, Mesh.round_rect_900_50_stroke },
                .x = 0.0,
                .y = map_size_y / 2,
                .rotation_speed = 0.01,
            });
            try objects.append(.{
                .colors = .{ 0xff_22_44_99, 0xff_00_00_00 },
                .mesh_indices = .{
                    Mesh.round_rect_900_50,
                    Mesh.round_rect_900_50_stroke,
                },
                .x = 0.0,
                .y = map_size_y / 2,
                .rotation_speed = -0.01,
            });
            try objects.append(.{
                .colors = .{ 0xff_22_44_99, 0xff_00_00_00 },
                .mesh_indices = .{ Mesh.circle_40, Mesh.circle_40_stroke },
                .x = 0.0,
                .y = map_size_y / 2,
            });
        },
        .spiral => {
            try objects.append(.{
                .colors = .{ 0xff_00_00_00, 0 },
                .mesh_indices = .{ Mesh.spiral, Mesh.invalid },
            });
            add_food(&objects, &num_food_objects, -17.0, 533.0);
            add_food(&objects, &num_food_objects, 313.0, 544.0);
            add_food(&objects, &num_food_objects, -106.0, 530.0);
            add_food(&objects, &num_food_objects, 261.0, 380.0);
            add_food(&objects, &num_food_objects, 295.0, 456.0);
            add_food(&objects, &num_food_objects, 67.0, 778.0);
            add_food(&objects, &num_food_objects, -133.0, 719.0);
            add_food(&objects, &num_food_objects, 398.0, 596.0);
            add_food(&objects, &num_food_objects, 412.0, 477.0);
            add_food(&objects, &num_food_objects, -415.0, 442.0);
            add_food(&objects, &num_food_objects, -424.0, 562.0);
            add_food(&objects, &num_food_objects, -396.0, 680.0);
            add_food(&objects, &num_food_objects, -327.0, 643.0);
            add_food(&objects, &num_food_objects, -39.0, 215.0);
            add_food(&objects, &num_food_objects, -72.0, 333.0);
        },
        .strange_star_and_wall => {
            try objects.append(.{
                .colors = .{ 0xff_22_44_99, 0xff_00_00_00 },
                .mesh_indices = .{
                    Mesh.strange_star_and_wall,
                    Mesh.strange_star_and_wall_stroke,
                },
            });
            add_food(&objects, &num_food_objects, -197.0, 352.0);
            add_food(&objects, &num_food_objects, -5.0, 274.0);
            add_food(&objects, &num_food_objects, -296.0, 605.0);
            add_food(&objects, &num_food_objects, 232.0, 364.0);
            add_food(&objects, &num_food_objects, 252.0, 581.0);
            add_food(&objects, &num_food_objects, 100.0, 802.0);
            add_food(&objects, &num_food_objects, -160.0, 800.0);
        },
    }

    // Player MUST be the last object.
    try objects.append(.{
        .colors = .{ 0xff_bb_00_00, 0xff_00_00_00 },
        .mesh_indices = .{ Mesh.player_body, Mesh.player_detail },
        .x = player_start_x,
        .y = player_start_y,
        .move_speed = 250.0,
        .rotation_speed = 5.0,
        .flags = cpu_gpu.obj_flag_no_shadow,
    });

    var object_buffer: *d3d12.IResource = undefined;
    vhr(gc.device.CreateCommittedResource3(
        &.{ .Type = .DEFAULT },
        d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
        &.{
            .Dimension = .BUFFER,
            .Width = objects.items.len * @sizeOf(cpu_gpu.Object),
            .Layout = .ROW_MAJOR,
        },
        .UNDEFINED,
        null,
        null,
        0,
        null,
        &d3d12.IResource.IID,
        @ptrCast(&object_buffer),
    ));

    gc.device.CreateShaderResourceView(
        object_buffer,
        &d3d12.SHADER_RESOURCE_VIEW_DESC.init_structured_buffer(
            0,
            @intCast(objects.items.len),
            @sizeOf(cpu_gpu.Object),
        ),
        .{ .ptr = gc.shader_dheap_start_cpu.ptr +
            @as(u32, @intCast(cpu_gpu.rdh_object_buffer)) *
            gc.shader_dheap_descriptor_size },
    );

    vhr(gc.command_allocators[0].Reset());
    vhr(gc.command_list.Reset(gc.command_allocators[0], null));

    const upload_mem, const buffer, const offset =
        gc.allocate_upload_buffer_region(cpu_gpu.Object, @intCast(objects.items.len));

    for (objects.items, 0..) |object, i| upload_mem[i] = object;

    gc.command_list.CopyBufferRegion(
        object_buffer,
        0,
        buffer,
        offset,
        upload_mem.len * @sizeOf(@TypeOf(upload_mem[0])),
    );

    vhr(gc.command_list.Close());
    gc.command_queue.ExecuteCommandLists(1, &.{@ptrCast(gc.command_list)});
    gc.finish_gpu_commands();

    return .{
        .objects_cpu = objects,
        .objects_gpu = object_buffer,
        .num_food_objects = @intCast(num_food_objects),
    };
}
