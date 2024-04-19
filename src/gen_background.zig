const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d11 = @import("win32/d3d11.zig");
const d3d12 = @import("win32/d3d12.zig");
const dxgi = @import("win32/dxgi.zig");
const d2d1 = @import("win32/d2d1.zig");
const wic = @import("win32/wincodec.zig");
const cpu_gpu = @cImport(@cInclude("cpu_gpu_shared.h"));
const gen_level = @import("gen_level.zig");
const gen_mesh = @import("gen_mesh.zig");

const GpuContext = @import("GpuContext.zig");
const vhr = GpuContext.vhr;

fn draw_level_background(
    level_name: gen_level.LevelName,
    d2d_device_context: *d2d1.IDeviceContext5,
    meshes: std.ArrayList(gen_mesh.Mesh),
) void {
    _ = meshes;

    d2d_device_context.BeginDraw();

    switch (level_name) {
        .rotating_arm_and_gear => {
            var brush: *d2d1.ISolidColorBrush = undefined;
            vhr(d2d_device_context.CreateSolidColorBrush(
                &d2d1.COLOR_F.init(.Red, 1.0),
                &.{
                    .opacity = 0.5,
                    .transform = d2d1.MATRIX_3X2_F.identity,
                },
                @ptrCast(&brush),
            ));
            defer _ = brush.Release();

            d2d_device_context.Clear(&d2d1.COLOR_F.init(.LightSkyBlue, 1.0));
            d2d_device_context.DrawLine(
                .{ .x = 10.0, .y = 10.0 },
                .{ .x = 500.0, .y = 500.0 },
                @ptrCast(brush),
                17.0,
                null,
            );
        },
        .star => {},
        .long_rotating_blocks => {},
        .spiral => {},
        .strange_star_and_wall => {},
    }

    vhr(d2d_device_context.EndDraw(null, null));
}

pub fn define_and_upload_background(
    gc: *GpuContext,
    level_name: gen_level.LevelName,
    d2d_device_context: *d2d1.IDeviceContext5,
    meshes: std.ArrayList(gen_mesh.Mesh),
) !*d3d12.IResource {
    const window_height: f32 = @floatFromInt(gc.window_height);
    const width: u32 = @intFromFloat(window_height * 1.333);
    const height: u32 = @intFromFloat(window_height);

    var background_texture: *d3d12.IResource = undefined;
    vhr(gc.device.CreateCommittedResource3(
        &.{ .Type = .DEFAULT },
        d3d12.HEAP_FLAGS.ALLOW_ALL_BUFFERS_AND_TEXTURES,
        &.{
            .Dimension = .TEXTURE2D,
            .Width = width,
            .Height = height,
            .Format = .B8G8R8A8_UNORM,
        },
        .COPY_DEST,
        null,
        null,
        0,
        null,
        &d3d12.IResource.IID,
        @ptrCast(&background_texture),
    ));

    const background_desc = background_texture.GetDesc();

    gc.device.CreateShaderResourceView(
        background_texture,
        null,
        .{ .ptr = gc.shader_dheap_start_cpu.ptr +
            @as(u32, @intCast(cpu_gpu.rdh_background_texture)) *
            gc.shader_dheap_descriptor_size },
    );

    var readback_bitmap: *d2d1.IBitmap1 = undefined;
    vhr(d2d_device_context.CreateBitmap1(
        .{ .width = width, .height = height },
        null,
        0,
        &.{
            .pixelFormat = .{
                .format = .B8G8R8A8_UNORM,
                .alphaMode = .IGNORE,
            },
            .dpiX = 96.0,
            .dpiY = 96.0,
            .bitmapOptions = .{ .CPU_READ = true, .CANNOT_DRAW = true },
            .colorContext = null,
        },
        @ptrCast(&readback_bitmap),
    ));
    defer _ = readback_bitmap.Release();

    var rt_bitmap: *d2d1.IBitmap1 = undefined;
    vhr(d2d_device_context.CreateBitmap1(
        .{ .width = width, .height = height },
        null,
        0,
        &.{
            .pixelFormat = .{
                .format = .B8G8R8A8_UNORM,
                .alphaMode = .IGNORE,
            },
            .dpiX = 96.0,
            .dpiY = 96.0,
            .bitmapOptions = .{ .TARGET = true },
            .colorContext = null,
        },
        @ptrCast(&rt_bitmap),
    ));
    defer _ = rt_bitmap.Release();

    d2d_device_context.SetTarget(@ptrCast(rt_bitmap));

    draw_level_background(level_name, d2d_device_context, meshes);

    vhr(readback_bitmap.CopyFromBitmap(null, @ptrCast(rt_bitmap), null));

    var readback_rect: d2d1.MAPPED_RECT = undefined;
    vhr(readback_bitmap.Map(.{ .READ = true }, &readback_rect));
    defer vhr(readback_bitmap.Unmap());

    var layout: [1]d3d12.PLACED_SUBRESOURCE_FOOTPRINT = undefined;
    var required_size: u64 = undefined;
    gc.device.GetCopyableFootprints(
        &background_desc,
        0,
        1,
        0,
        &layout,
        null,
        null,
        &required_size,
    );

    const upload_mem, const buffer, const offset =
        gc.allocate_upload_buffer_region(u8, @intCast(required_size));
    layout[0].Offset = offset;

    for (0..height) |y| {
        @memcpy(
            upload_mem[y * layout[0].Footprint.RowPitch ..][0 .. width * 4],
            readback_rect.bits[y * readback_rect.pitch ..][0 .. width * 4],
        );
    }

    vhr(gc.command_allocators[0].Reset());
    vhr(gc.command_list.Reset(gc.command_allocators[0], null));

    gc.command_list.CopyTextureRegion(&.{
        .pResource = background_texture,
        .Type = .SUBRESOURCE_INDEX,
        .u = .{ .SubresourceIndex = 0 },
    }, 0, 0, 0, &.{
        .pResource = buffer,
        .Type = .PLACED_FOOTPRINT,
        .u = .{ .PlacedFootprint = layout[0] },
    }, null);

    vhr(gc.command_list.Close());
    gc.command_queue.ExecuteCommandLists(1, &.{@ptrCast(gc.command_list)});
    gc.finish_gpu_commands();

    return background_texture;
}

fn write_bitmap_to_file(
    wic_factory: *wic.IImagingFactory2,
    d2d_device: *d2d1.IDevice5,
    bitmap: *d2d1.IBitmap1,
) void {
    var stream: *wic.IStream = undefined;
    vhr(wic_factory.CreateStream(@ptrCast(&stream)));
    defer _ = stream.Release();

    vhr(stream.InitializeFromFilename(
        std.unicode.utf8ToUtf16LeStringLiteral("image.png"),
        w32.GENERIC_WRITE,
    ));

    var encoder: *wic.IBitmapEncoder = undefined;
    vhr(wic_factory.CreateEncoder(&wic.GUID_ContainerFormatPng, null, @ptrCast(&encoder)));
    defer _ = encoder.Release();

    vhr(encoder.Initialize(@ptrCast(stream), .NoCache));

    var frame_encode: *wic.IBitmapFrameEncode = undefined;
    vhr(encoder.CreateNewFrame(@ptrCast(&frame_encode), null));
    defer _ = frame_encode.Release();

    vhr(frame_encode.Initialize(null));

    var image_encoder: *wic.IImageEncoder = undefined;
    vhr(wic_factory.CreateImageEncoder(@ptrCast(d2d_device), @ptrCast(&image_encoder)));
    defer _ = image_encoder.Release();

    vhr(image_encoder.WriteFrame(@ptrCast(bitmap), frame_encode, null));
    vhr(frame_encode.Commit());
    vhr(encoder.Commit());
}
