//! Zig version of: https://www.raylib.com/examples/textures/loader.html?name=textures_image_drawing

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
var cat: raylib.Image = undefined;
var parrots: raylib.Image = undefined;
var font: raylib.Font = undefined;
var texture: raylib.Texture2D = undefined;

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [textures] example - image drawing");
    raylib.SetTargetFPS(60);

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    cat = raylib.LoadImage("assets/cat.png"); // Loaded in CPU memory (RAM)
    defer raylib.UnloadImage(cat); // Unload CPU (RAM) image data after operations are done

    raylib.ImageCrop(&cat, .{ .x = 100, .y = 10, .width = 280, .height = 380 }); // Crop a piece of the image
    raylib.ImageFlipHorizontal(&cat); // Flip cropped piece horizontally
    raylib.ImageResize(&cat, 150, 200); // Resize cropped image to 150x200 pixels

    parrots = raylib.LoadImage("assets/parrots.png"); // Loaded in CPU memory (RAM)
    defer raylib.UnloadImage(parrots); // Unload CPU (RAM) image data after operations are done

    // Draw one image over the other with a scaling of 1.5f
    raylib.ImageDraw(
        &parrots,
        cat,
        .{ .x = 0, .y = 0, .width = @as(f32, @floatFromInt(cat.width)), .height = @as(f32, @floatFromInt(cat.height)) },
        .{ .x = 30, .y = 40, .width = @as(f32, @floatFromInt(cat.width)) * 1.5, .height = @as(f32, @floatFromInt(cat.height)) * 1.5 },
        raylib.WHITE,
    );
    raylib.ImageCrop(
        &parrots,
        .{ .x = 0, .y = 50, .width = @as(f32, @floatFromInt(parrots.width)), .height = @as(f32, @floatFromInt(parrots.height - 100)) },
    );

    // Draw on the image with a few image draw methods
    raylib.ImageDrawPixel(&parrots, 10, 10, raylib.RAYWHITE);
    raylib.ImageDrawCircleLines(&parrots, 10, 10, 5, raylib.RAYWHITE);
    raylib.ImageDrawRectangle(&parrots, 5, 20, 10, 10, raylib.RAYWHITE);

    // Load custom font for frawing on image
    font = raylib.LoadFont("assets/custom_jupiter_crash.png");
    defer raylib.UnloadFont(font);

    // Draw over image using custom font
    raylib.ImageDrawTextEx(&parrots, font, "PARROTS & CAT", .{ .x = 300, .y = 230 }, @as(f32, @floatFromInt(font.baseSize)), -2, raylib.WHITE);

    texture = raylib.LoadTextureFromImage(parrots); // Image converted to texture, uploaded to GPU memory (VRAM)
}

fn update(_: f32) !void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.RAYWHITE);

    raylib.DrawTexture(texture, screenWidth / 2 - @divFloor(texture.width, 2), screenHeight / 2 - @divFloor(texture.height, 2) - 40, raylib.WHITE);
    raylib.DrawRectangleLines(screenWidth / 2 - @divFloor(texture.width, 2), screenHeight / 2 - @divFloor(texture.height, 2) - 40, texture.width, texture.height, raylib.DARKGRAY);

    raylib.DrawText("We are drawing only one texture from various images composed!", 240, 350, 10, raylib.DARKGRAY);
    raylib.DrawText("Source images have been cropped, scaled, flipped and copied one over the other.", 190, 370, 10, raylib.DARKGRAY);
}

fn deinit() void {
    raylib.UnloadTexture(texture);
    raylib.CloseWindow();
}
