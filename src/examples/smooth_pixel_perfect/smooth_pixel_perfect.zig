//! Zig version of: https://www.raylib.com/examples/core/loader.html?name=core_smooth_pixelperfect

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("raylib");

const Vector2 = raylib.Vector2;
const Rectangle = raylib.Rectangle;

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

const virtualScreenWidth: i32 = 160;
const virtualScreenHeight: i32 = 90;

const virtualRatio = @as(f32, @floatFromInt(screenWidth)) / @as(f32, @floatFromInt(virtualScreenWidth));
var worldSpaceCamera: raylib.Camera2D = .{
    .target = raylib.Vector2.zero(),
    .zoom = 1,
};
var screenSpaceCamera: raylib.Camera2D = .{
    .target = raylib.Vector2.zero(),
    .zoom = 1,
};

var rec01 = Rectangle{ .x = 70, .y = 35, .width = 20, .height = 20 };
var rec02 = Rectangle{ .x = 90, .y = 55, .width = 30, .height = 10 };
var rec03 = Rectangle{ .x = 80, .y = 65, .width = 15, .height = 25 };
var sourceRec: Rectangle = undefined;
var destRec = Rectangle{
    .x = -virtualRatio,
    .y = -virtualRatio,
    .width = @as(f32, @floatFromInt(screenWidth)) + (virtualRatio * 2),
    .height = @as(f32, @floatFromInt(screenHeight)) + (virtualRatio * 2),
};

var origin = Vector2{ .x = 0, .y = 0 };
var rotation: f32 = 0.0;
var cameraX: f32 = 0.0;
var cameraY: f32 = 0.0;

var target: raylib.RenderTexture2D = undefined;

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - smooth pixel-perfect camera");

    target = raylib.LoadRenderTexture(virtualScreenWidth, virtualScreenHeight);

    sourceRec = .{
        .x = 0,
        .y = 0,
        .width = @as(f32, @floatFromInt(target.texture.width)),
        .height = @as(f32, @floatFromInt(-target.texture.height)),
    };

    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    // bump allocator for std.fmt.allocPrintZ
    var buf: [16 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);

    // Make the camera move to demonstrate the effect
    rotation += 60.0 * raylib.GetFrameTime();
    cameraX = std.math.sin(@as(f32, @floatCast(raylib.GetTime()))) * 50 - 10;
    cameraY = std.math.cos(@as(f32, @floatCast(raylib.GetTime()))) * 30;

    // Set the camera's target to the values computed above
    screenSpaceCamera.target = .{ .x = cameraX, .y = cameraY };

    // Round worldSpace coordinates, keep decimals into screenSpace coordinates
    worldSpaceCamera.target.x = screenSpaceCamera.target.x;
    screenSpaceCamera.target.x -= worldSpaceCamera.target.x;
    screenSpaceCamera.target.x *= virtualRatio;

    worldSpaceCamera.target.y = screenSpaceCamera.target.y;
    screenSpaceCamera.target.y -= worldSpaceCamera.target.y;
    screenSpaceCamera.target.y *= virtualRatio;

    {
        raylib.BeginTextureMode(target);
        defer raylib.EndTextureMode();

        raylib.ClearBackground(raylib.RAYWHITE);
        {
            raylib.BeginMode2D(worldSpaceCamera);
            defer raylib.EndMode2D();
            raylib.DrawRectanglePro(rec01, origin, rotation, raylib.BLACK);
            raylib.DrawRectanglePro(rec02, origin, -rotation, raylib.RED);
            raylib.DrawRectanglePro(rec03, origin, rotation + 45.0, raylib.BLUE);
        }
    }

    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RED);

        {
            raylib.BeginMode2D(screenSpaceCamera);
            defer raylib.EndMode2D();

            raylib.DrawTexturePro(target.texture, sourceRec, destRec, origin, 0.0, raylib.WHITE);
        }

        raylib.DrawText(try raylib.TextFormat(fba.allocator(), "Screen resolution: {d}x{d}", .{ screenWidth, screenHeight }), 10, 10, 20, raylib.DARKBLUE);
        raylib.DrawText(try raylib.TextFormat(fba.allocator(), "World resolution: {d}x{d}", .{ virtualScreenWidth, virtualScreenHeight }), 10, 40, 20, raylib.DARKGREEN);
        raylib.DrawFPS(raylib.GetScreenWidth() - 95, 10);
    }
}

fn deinit() void {
    raylib.UnloadRenderTexture(target);
    raylib.CloseWindow();
}
