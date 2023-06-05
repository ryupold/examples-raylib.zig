//! Zig version of: https://www.raylib.com/examples/shapes/loader.html?name=shapes_lines_bezier

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("../../raylib/raylib.zig");

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

var start: raylib.Vector2 = .{ .x = 0, .y = 0 };
var end: raylib.Vector2 = .{ .x = @intToFloat(f32, screenWidth), .y = @intToFloat(f32, screenHeight) };

fn init(_: std.mem.Allocator) !void {
    raylib.SetConfigFlags(.{ .FLAG_MSAA_4X_HINT = true });
    raylib.InitWindow(screenWidth, screenHeight, "raylib [shapes] example - cubic-bezier lines");
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    // Update
    if (raylib.IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) {
        start = raylib.GetMousePosition();
    } else if (raylib.IsMouseButtonDown(.MOUSE_BUTTON_RIGHT)) {
        end = raylib.GetMousePosition();
    }

    // Draw
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);
        raylib.DrawText("USE MOUSE LEFT-RIGHT CLICK to DEFINE LINE START and END POINTS", 15, 20, 20, raylib.GRAY);

        raylib.DrawLineBezier(start, end, 2, raylib.RED);
    }
}

fn deinit() void {
    raylib.CloseWindow();
}
