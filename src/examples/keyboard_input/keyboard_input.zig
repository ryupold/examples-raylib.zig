// Zig version of: https://www.raylib.com/examples/core/loader.html?name=core_input_keys
const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("../../raylib/raylib.zig");
const IsKeyDown = raylib.IsKeyDown;
const Keys = raylib.KeyboardKey;

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

var ballPosition: raylib.Vector2 = .{
    .x = @intToFloat(f32, screenWidth) / 2.0,
    .y = @intToFloat(f32, screenHeight) / 2.0,
};

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - keyboard input");
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    if (IsKeyDown(@enumToInt(Keys.KEY_RIGHT))) ballPosition.x += 2.0;
    if (IsKeyDown(@enumToInt(Keys.KEY_LEFT))) ballPosition.x -= 2.0;
    if (IsKeyDown(@enumToInt(Keys.KEY_UP))) ballPosition.y -= 2.0;
    if (IsKeyDown(@enumToInt(Keys.KEY_DOWN))) ballPosition.y += 2.0;

    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.RAYWHITE);
    raylib.DrawText("move the ball with arrow keys", 10, 10, 20, raylib.DARKGRAY);
    raylib.DrawCircleV(ballPosition, 50, raylib.MAROON);
}

fn deinit() void {
    raylib.CloseWindow();
}
