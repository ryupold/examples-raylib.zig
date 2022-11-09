const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("../../raylib/raylib.zig");
const raygui = @import("../../raygui/raygui.zig");

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

var buttonPressed: usize = 0;

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raygui example");
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    var buf: [16 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        raylib.DrawText(try raylib.TextFormat(
            fba.allocator(),
            "button pressed {d} times",
            .{buttonPressed},
        ), 10, 10, 20, raylib.BLACK);

        if (raygui.GuiButton(.{ .x = 100, .y = 100, .width = 200, .height = 100 }, "press me!")) {
            buttonPressed += 1;
        }
        raylib.DrawFPS(raylib.GetScreenWidth() - 95, 10);
    }
}

fn deinit() void {
    raylib.CloseWindow();
}
