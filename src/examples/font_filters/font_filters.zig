//! Zig version of: https://www.raylib.com/examples/text/loader.html?name=text_font_filters

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("raylib");

const Camera3D = raylib.Camera3D;
const Vector3 = raylib.Vector3;

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

var font: raylib.Font = undefined;
var fontSize: f32 = undefined;
var fontPosition: raylib.Vector2 = undefined;
var textSize = raylib.Vector2{ .x = 0, .y = 0 };
var currentFontFilter: i32 = 0;
var msg: [50]u8 = undefined;

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [text] example - font filter");
    raylib.SetTargetFPS(60);

    std.mem.copyForwards(u8, &msg, "Loaded Font");

    font = raylib.LoadFont("assets/KAISG.ttf");

    raylib.GenTextureMipmaps(&font.texture);
    fontSize = @as(f32, @floatFromInt(font.baseSize));
    fontPosition = raylib.Vector2{ .x = 40, .y = @as(f32, @floatFromInt(screenHeight)) / 2.0 - 80.0 };

    raylib.SetTextureFilter(font.texture, @intFromEnum(raylib.TextureFilter.TEXTURE_FILTER_POINT));
}

fn update(_: f32) !void {
    var buf: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);

    fontSize += raylib.GetMouseWheelMove() * 4.0;

    if (raylib.IsKeyPressed(.KEY_ONE)) {
        raylib.SetTextureFilter(font.texture, @intFromEnum(raylib.TextureFilter.TEXTURE_FILTER_POINT));
        currentFontFilter = 0;
    } else if (raylib.IsKeyPressed(.KEY_TWO)) {
        raylib.SetTextureFilter(font.texture, @intFromEnum(raylib.TextureFilter.TEXTURE_FILTER_BILINEAR));
        currentFontFilter = 1;
    } else if (raylib.IsKeyPressed(.KEY_THREE)) {
        // NOTE: Trilinear filter won't be noticed on 2D drawing
        raylib.SetTextureFilter(font.texture, @intFromEnum(raylib.TextureFilter.TEXTURE_FILTER_TRILINEAR));
        currentFontFilter = 2;
    }

    textSize = raylib.MeasureTextEx(font, @as([*:0]const u8, @ptrCast(&msg)), fontSize, 0);

    if (raylib.IsKeyDown(.KEY_LEFT)) {
        fontPosition.x -= 10;
    } else if (raylib.IsKeyDown(.KEY_RIGHT)) {
        fontPosition.x += 10;
    }

    if (raylib.IsFileDropped()) {
        const droppedFiles = raylib.LoadDroppedFiles();

        // NOTE: We only support first ttf file dropped
        if (raylib.IsFileExtension(droppedFiles.paths[0], ".ttf")) {
            raylib.UnloadFont(font);
            font = raylib.LoadFontEx(
                droppedFiles.paths[0],
                @as(i32, @intFromFloat(fontSize)),
                null,
                0,
            );
        }

        raylib.UnloadDroppedFiles(droppedFiles); // Unload filepaths from memory
    }

    //DRAW
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        raylib.DrawText("Use mouse wheel to change font size", 20, 20, 10, raylib.GRAY);
        raylib.DrawText("Use KEY_RIGHT and KEY_LEFT to move text", 20, 40, 10, raylib.GRAY);
        raylib.DrawText("Use 1, 2, 3 to change texture filter", 20, 60, 10, raylib.GRAY);
        raylib.DrawText("Drop a new TTF font for dynamic loading", 20, 80, 10, raylib.DARKGRAY);

        raylib.DrawTextEx(font, @as([*:0]const u8, @ptrCast(&msg)), fontPosition, fontSize, 0, raylib.BLACK);

        // TODO: It seems texSize measurement is not accurate due to chars offsets...
        //DrawRectangleLines(fontPosition.x, fontPosition.y, textSize.x, textSize.y, RED);

        raylib.DrawRectangle(0, screenHeight - 80, screenWidth, 80, raylib.LIGHTGRAY);
        raylib.DrawText(try raylib.TextFormat(fba.allocator(), "Font size: {d}", .{fontSize}), 20, screenHeight - 50, 10, raylib.DARKGRAY);
        raylib.DrawText(try raylib.TextFormat(fba.allocator(), "Text size: [{d}, {d}]", .{ textSize.x, textSize.y }), 20, screenHeight - 30, 10, raylib.DARKGRAY);
        raylib.DrawText("CURRENT TEXTURE FILTER:", 250, 400, 20, raylib.GRAY);

        if (currentFontFilter == 0) {
            raylib.DrawText("POINT", 570, 400, 20, raylib.BLACK);
        } else if (currentFontFilter == 1) {
            raylib.DrawText("BILINEAR", 570, 400, 20, raylib.BLACK);
        } else if (currentFontFilter == 2) {
            raylib.DrawText("TRILINEAR", 570, 400, 20, raylib.BLACK);
        }
    }
}

fn deinit() void {
    raylib.UnloadFont(font);

    raylib.CloseWindow();
}
