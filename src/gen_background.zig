const std = @import("std");
const w32 = @import("win32/win32.zig");
const d3d11 = @import("win32/d3d11.zig");
const d3d12 = @import("win32/d3d12.zig");
const dxgi = @import("win32/dxgi.zig");
const d2d1 = @import("win32/d2d1.zig");
const wic = @import("win32/wincodec.zig");
const dwrite = @import("win32/dwrite.zig");
const objidl = @import("win32/objidl.zig");
const cpu_gpu = @cImport(@cInclude("cpu_gpu_shared.h"));
const gen_level = @import("gen_level.zig");
const gen_mesh = @import("gen_mesh.zig");

const GpuContext = @import("GpuContext.zig");
const vhr = GpuContext.vhr;

const L = std.unicode.utf8ToUtf16LeStringLiteral;

fn draw_level_background(
    level_name: gen_level.LevelName,
    d2d_device_context: *d2d1.IDeviceContext5,
    d2d_factory: *d2d1.IFactory6,
    dwrite_factory: *dwrite.IFactory,
    meshes: std.ArrayList(gen_mesh.Mesh),
) void {
    d2d_device_context.BeginDraw();
    d2d_device_context.Clear(&d2d1.COLOR_F.init(.White, 1.0));

    var math_font: *dwrite.ITextFormat = undefined;
    vhr(dwrite_factory.CreateTextFormat(
        L("Cambria Math"),
        null,
        .NORMAL,
        .NORMAL,
        .NORMAL,
        64.0,
        L("en-us"),
        @ptrCast(&math_font),
    ));
    defer _ = math_font.Release();

    switch (level_name) {
        .rotating_arm_and_gear => {
            var brush: *d2d1.ISolidColorBrush = undefined;
            vhr(d2d_device_context.CreateSolidColorBrush(
                &d2d1.COLOR_F.init(.White, 1.0),
                &.{
                    .opacity = 0.15,
                    .transform = d2d1.MATRIX_3X2_F.identity,
                },
                @ptrCast(&brush),
            ));
            defer _ = brush.Release();

            d2d_device_context.Clear(&d2d1.COLOR_F.init(.RoyalBlue, 1.0));
            {
                var stream: *objidl.IStream = undefined;
                vhr(w32.SHCreateStreamOnFileEx(
                    L("data/svg/test.svg"),
                    w32.STGM_READ,
                    0,
                    .FALSE,
                    null,
                    &stream,
                ));
                defer _ = stream.Release();

                var svg_document: *d2d1.ISvgDocument = undefined;
                vhr(d2d_device_context.CreateSvgDocument(
                    stream,
                    .{ .width = gen_level.map_size_x, .height = gen_level.map_size_y },
                    &svg_document,
                ));
                defer _ = svg_document.Release();

                d2d_device_context.DrawSvgDocument(svg_document);
            }
            {
                const t = L("v = \u{03c9} \u{22c5} r");
                d2d_device_context.DrawText(
                    t,
                    t.len,
                    math_font,
                    &.{
                        .left = 0.0,
                        .top = 0.0,
                        .right = std.math.inf(f32),
                        .bottom = std.math.inf(f32),
                    },
                    @ptrCast(brush),
                    .{},
                    .NATURAL,
                );
            }
            {
                const t = L("\u{03c9}\u{2081} = \u{03c9}\u{2080} \u{22c5}  N\u{2080} \u{2215} N\u{2081}");
                d2d_device_context.DrawText(
                    t,
                    t.len,
                    math_font,
                    &.{
                        .left = 800.0,
                        .top = 0.0,
                        .right = std.math.inf(f32),
                        .bottom = std.math.inf(f32),
                    },
                    @ptrCast(brush),
                    .{},
                    .NATURAL,
                );
            }
            //
            // Grid
            //
            d2d_device_context.DrawLine(
                .{ .x = gen_level.map_size_x / 2, .y = 0.0 },
                .{ .x = gen_level.map_size_x / 2, .y = gen_level.map_size_y },
                @ptrCast(brush),
                3.0,
                null,
            );
            d2d_device_context.DrawLine(
                .{ .x = 0.0, .y = gen_level.map_size_y / 2 },
                .{ .x = gen_level.map_size_x, .y = gen_level.map_size_y / 2 },
                @ptrCast(brush),
                3.0,
                null,
            );
            {
                var x: f32 = 0.0;
                while (x <= gen_level.map_size_x) : (x += 50.0) {
                    d2d_device_context.DrawLine(
                        .{ .x = x, .y = 0.0 },
                        .{ .x = x, .y = gen_level.map_size_y },
                        @ptrCast(brush),
                        1.0,
                        null,
                    );
                }
            }
            {
                var y: f32 = 25.0;
                while (y <= gen_level.map_size_y) : (y += 50.0) {
                    d2d_device_context.DrawLine(
                        .{ .x = 0.0, .y = y },
                        .{ .x = gen_level.map_size_x, .y = y },
                        @ptrCast(brush),
                        1.0,
                        null,
                    );
                }
            }
            //
            // Shapes
            //
            d2d_device_context.DrawEllipse(
                &.{
                    .point = .{ .x = 700.0, .y = 75.0 },
                    .radiusX = 50.0,
                    .radiusY = 50.0,
                },
                @ptrCast(brush),
                3.0,
                null,
            );
            d2d_device_context.DrawRectangle(
                &.{
                    .left = 100.0,
                    .top = 825.0,
                    .right = 300.0,
                    .bottom = 925.0,
                },
                @ptrCast(brush),
                3.5,
                null,
            );
            //
            // Gear
            //
            if (false) {
                d2d_device_context.SetTransform(
                    &d2d1.MATRIX_3X2_F.mul(
                        d2d1.MATRIX_3X2_F.scaling(0.5, 0.5),
                        d2d1.MATRIX_3X2_F.translation(1200.0, 250.0),
                    ),
                );
                d2d_device_context.DrawGeometry(
                    meshes.items[gen_mesh.Mesh.gear_12_150].geometry.?,
                    @ptrCast(brush),
                    7.0,
                    null,
                );
                d2d_device_context.DrawEllipse(
                    &.{
                        .point = .{ .x = 0.0, .y = 0.0 },
                        .radiusX = 150.0,
                        .radiusY = 150.0,
                    },
                    @ptrCast(brush),
                    7.0,
                    null,
                );
            }
            //
            // Spiral
            //
            d2d_device_context.SetTransform(
                &d2d1.MATRIX_3X2_F.mul(
                    d2d1.MATRIX_3X2_F.scaling(0.25, 0.25),
                    d2d1.MATRIX_3X2_F.translation(200.0, 100.0),
                ),
            );
            d2d_device_context.FillGeometry(
                meshes.items[gen_mesh.Mesh.spiral].geometry.?,
                @ptrCast(brush),
                null,
            );
            d2d_device_context.SetTransform(&d2d1.MATRIX_3X2_F.identity);
            if (false) {
                var path_geo: *d2d1.IPathGeometry = undefined;
                vhr(d2d_factory.CreatePathGeometry(@ptrCast(&path_geo)));
                defer _ = path_geo.Release();
                {
                    var path_sink: *d2d1.IGeometrySink = undefined;
                    vhr(path_geo.Open(@ptrCast(&path_sink)));
                    defer {
                        vhr(path_sink.Close());
                        _ = path_sink.Release();
                    }

                    const p0 = d2d1.POINT_2F{ .x = 0.0, .y = 0.0 };
                    const a0 = std.math.pi * 0.3;
                    const r0 = 0.0;

                    const p1 = d2d1.POINT_2F{ .x = 100.0, .y = 100.0 };
                    const a1 = std.math.pi * 1.0;
                    const r1 = 100.0;

                    path_sink.BeginFigure(.{ .x = p0.x, .y = p0.y }, .HOLLOW);
                    path_sink.AddBezier(&.{
                        .point1 = .{ .x = p0.x + @cos(a0) * r0, .y = p0.y + @sin(a0) * r0 },
                        .point2 = .{ .x = p1.x, .y = p1.y },
                        .point3 = .{ .x = p1.x + @cos(a1) * r1, .y = p1.y + @sin(a1) * r1 },
                    });
                    path_sink.EndFigure(.OPEN);
                }

                d2d_device_context.SetTransform(&d2d1.MATRIX_3X2_F.translation(1000.0, 825.0));

                d2d_device_context.DrawGeometry(
                    @ptrCast(path_geo),
                    @ptrCast(brush),
                    7.0,
                    null,
                );
            }
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
    d2d_factory: *d2d1.IFactory6,
    dwrite_factory: *dwrite.IFactory,
    meshes: std.ArrayList(gen_mesh.Mesh),
) !*d3d12.IResource {
    const width: u32 = gen_level.map_size_x;
    const height: u32 = gen_level.map_size_y;

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

    draw_level_background(level_name, d2d_device_context, d2d_factory, dwrite_factory, meshes);

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

    gc.command_list.Barrier(1, &.{
        .{
            .Type = .TEXTURE,
            .NumBarriers = 1,
            .u = .{
                .pTextureBarriers = &.{
                    .{
                        .SyncBefore = .{ .COPY = true },
                        .SyncAfter = .{},
                        .AccessBefore = .{ .COPY_DEST = true },
                        .AccessAfter = .{ .NO_ACCESS = true },
                        .LayoutBefore = .COPY_DEST,
                        .LayoutAfter = .SHADER_RESOURCE,
                        .pResource = background_texture,
                    },
                },
            },
        },
    });

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
