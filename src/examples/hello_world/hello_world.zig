const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("raylib");

pub const example = Example{
    .initFn = init,
    .updateFn = update,
};

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(800, 800, "hello world!");

    raylib.SetConfigFlags(.{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.BLACK);
    raylib.DrawFPS(10, 10);

    raylib.DrawText(
        "hello world!",
        100,
        100,
        30,
        raylib.YELLOW,
    );
    var buf: [1024]u8 = undefined;

    const raylibVersion = try std.fmt.bufPrintZ(&buf, "raylib {s}", .{raylib.RAYLIB_VERSION});
    raylib.DrawText(
        raylibVersion,
        100,
        150,
        20,
        raylib.YELLOW,
    );

    const rlGlVersion = try std.fmt.bufPrintZ(&buf, "rlgl {s}", .{raylib.RLGL_VERSION});
    raylib.DrawText(
        rlGlVersion,
        100,
        180,
        20,
        raylib.YELLOW,
    );

    const glslVersion = try std.fmt.bufPrintZ(&buf, "GL_SHADING_LANGUAGE_VERSION {d}", .{raylib.GL_SHADING_LANGUAGE_VERSION});
    raylib.DrawText(
        glslVersion,
        100,
        210,
        20,
        raylib.YELLOW,
    );

    raylib.DrawText("zig build --help\n\nto see a list of examples", 100, 300, 18, raylib.BLUE);
    raylib.DrawText("zig build run -Dexample=6\n\nto run a specific example", 400, 400, 18, raylib.ORANGE);
}
