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
    if (raylib.IsMouseButtonDown(.MOUSE_BUTTON_LEFT)) {
        // Create more bunnies
        var i: usize = 0;
        while (i < 100) : (i += 1) {
            if (bunnies.items.len < maxBunnies) {
                try bunnies.append(.{
                    .position = raylib.GetMousePosition(),
                    .speed = .{
                        .x = @as(f32, @floatFromInt(raylib.GetRandomValue(-250, 250))) / 60,
                        .y = @as(f32, @floatFromInt(raylib.GetRandomValue(-250, 250))) / 60,
                    },
                    .color = .{
                        .r = @as(u8, @truncate(@as(u32, @intCast(raylib.GetRandomValue(50, 240))))),
                        .g = @as(u8, @truncate(@as(u32, @intCast(raylib.GetRandomValue(80, 240))))),
                        .b = @as(u8, @truncate(@as(u32, @intCast(raylib.GetRandomValue(100, 240))))),
                        .a = 255,
                    },
                });
            }
        }
    }

    for (bunnies.items) |*bunny| {
        bunny.position = bunny.position.add(bunny.speed);
        if (((bunny.position.x + @as(f32, @floatFromInt(texBunny.width)) / 2) > @as(f32, @floatFromInt(raylib.GetScreenWidth()))) or
            ((bunny.position.x + @as(f32, @floatFromInt(texBunny.width)) / 2) < 0)) bunny.speed.x *= -1;
        if (((bunny.position.y + @as(f32, @floatFromInt(texBunny.height)) / 2) > @as(f32, @floatFromInt(raylib.GetScreenHeight()))) or
            ((bunny.position.y + @as(f32, @floatFromInt(texBunny.height)) / 2 - 40) < 0)) bunny.speed.y *= -1;
    }

    // Draw
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        for (bunnies.items) |bunny| {
            raylib.DrawTexture(texBunny, @as(i32, @intFromFloat(bunny.position.x)), @as(i32, @intFromFloat(bunny.position.y)), bunny.color);
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
