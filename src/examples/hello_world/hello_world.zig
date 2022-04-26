const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("../../raylib/raylib.zig");

pub const example = Example{
    .initFn = init,
    .updateFn = update,
};

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(800, 800, "hello world!");

    raylib.SetConfigFlags(.FLAG_WINDOW_RESIZABLE);
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();
        
        raylib.ClearBackground(raylib.BLACK);
        raylib.DrawFPS(10, 10);

        raylib.DrawText("hello world!", 100, 100, 20, raylib.YELLOW);
}