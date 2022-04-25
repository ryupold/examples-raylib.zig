//! Zig version of: https://www.raylib.com/examples/textures/loader.html?name=textures_bunnymark

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("../../raylib/raylib.zig");

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const maxBunnies: usize = 50_000;
const maxBatchElements: usize = 8192;
const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

const Bunny = struct {
    position: raylib.Vector2,
    speed: raylib.Vector2,
    color: raylib.Color,
};

var texBunny: raylib.Texture2D = undefined;
var bunnies: std.ArrayList(Bunny) = undefined;

fn init(allocator: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark");

    texBunny = raylib.LoadTexture("assets/wabbit_alpha.png");
    bunnies = std.ArrayList(Bunny).init(allocator);

    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    // Update
    if (raylib.IsMouseButtonDown(@enumToInt(raylib.MouseButton.MOUSE_BUTTON_LEFT))) {
        // Create more bunnies
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            if (bunnies.items.len < maxBunnies) {
                try bunnies.append(.{
                    .position = raylib.GetMousePosition(),
                    .speed = .{
                        .x = @intToFloat(f32, raylib.GetRandomValue(-250, 250)) / 60,
                        .y = @intToFloat(f32, raylib.GetRandomValue(-250, 250)) / 60,
                    },
                    .color = .{
                        .r = @truncate(u8, @intCast(u32, raylib.GetRandomValue(50, 240))),
                        .g = @truncate(u8, @intCast(u32, raylib.GetRandomValue(80, 240))),
                        .b = @truncate(u8, @intCast(u32, raylib.GetRandomValue(100, 240))),
                        .a = 255,
                    },
                });
            }
        }
    }

    for (bunnies.items) |*bunny| {
        bunny.position = bunny.position.add(bunny.speed);
        if (((bunny.position.x + @intToFloat(f32, texBunny.width) / 2) > @intToFloat(f32, raylib.GetScreenWidth())) or
            ((bunny.position.x + @intToFloat(f32, texBunny.width) / 2) < 0)) bunny.speed.x *= -1;
        if (((bunny.position.y + @intToFloat(f32, texBunny.height) / 2) > @intToFloat(f32, raylib.GetScreenHeight())) or
            ((bunny.position.y + @intToFloat(f32, texBunny.height) / 2 - 40) < 0)) bunny.speed.y *= -1;
    }

    // Draw
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        for (bunnies.items) |bunny| {
            raylib.DrawTexture(texBunny, @floatToInt(i32, bunny.position.x), @floatToInt(i32, bunny.position.y), bunny.color);
        }

        raylib.DrawRectangle(0, 0, screenWidth, 40, raylib.BLACK);
        var buf: [64]u8 = undefined;

        raylib.DrawText(try std.fmt.bufPrintZ(&buf, "bunnies: {d}", .{bunnies.items.len}), 120, 10, 20, raylib.GREEN);
        raylib.DrawText(try std.fmt.bufPrintZ(&buf, "batched draw calls: {d}", .{1 + bunnies.items.len / maxBatchElements}), 320, 10, 20, raylib.MAROON);

        raylib.DrawFPS(10, 10);
    }
}

fn deinit() void {
    bunnies.deinit();
    raylib.CloseWindow();
}
