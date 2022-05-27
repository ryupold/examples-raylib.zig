//! Zig version of: https://www.raylib.com/examples/core/loader.html?name=core_3d_picking

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

var camera: raylib.Camera3D = .{
    .position = .{ .x = 10, .y = 10, .z = 10 },
    .target = .{ .x = 0, .y = 0, .z = 0 },
    .up = .{ .y = 1 },
    .fovy = 45,
    .projection = .CAMERA_PERSPECTIVE,
};
var cubePosition = raylib.Vector3{ .y = 1 };
var cubeSize = raylib.Vector3{ .x = 2, .y = 2, .z = 2 };
var ray = std.mem.zeroes(raylib.Ray);
var collision = std.mem.zeroes(raylib.RayCollision);

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d picking");
    raylib.SetCameraMode(camera, .CAMERA_FREE);
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    // Update
    raylib.UpdateCamera(&camera);

    if (raylib.IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) {
        if (!collision.hit) {
            ray = raylib.GetMouseRay(raylib.GetMousePosition(), camera);

            // Check collision between ray and box
            collision = raylib.GetRayCollisionBox(ray, .{
                .min = .{
                    .x = cubePosition.x - cubeSize.x / 2,
                    .y = cubePosition.y - cubeSize.y / 2,
                    .z = cubePosition.z - cubeSize.z / 2,
                },
                .max = .{
                    .x = cubePosition.x + cubeSize.x / 2,
                    .y = cubePosition.y + cubeSize.y / 2,
                    .z = cubePosition.z + cubeSize.z / 2,
                },
            });
        } else {
            collision.hit = false;
        }
    }

    // Draw
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        {
            raylib.BeginMode3D(camera);
            defer raylib.EndMode3D();

            if (collision.hit) {
                raylib.DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, raylib.RED);
                raylib.DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, raylib.MAROON);

                raylib.DrawCubeWires(
                    cubePosition,
                    cubeSize.x + 0.2,
                    cubeSize.y + 0.2,
                    cubeSize.z + 0.2,
                    raylib.GREEN,
                );
            } else {
                raylib.DrawCube(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, raylib.GRAY);
                raylib.DrawCubeWires(cubePosition, cubeSize.x, cubeSize.y, cubeSize.z, raylib.DARKGRAY);
            }

            raylib.DrawRay(ray, raylib.MAROON);
            raylib.DrawGrid(10, 1.0);

            raylib.DrawText("Try selecting the box with mouse!", 240, 10, 20, raylib.DARKGRAY);

            if (collision.hit) raylib.DrawText(
                "BOX SELECTED",
                @divTrunc((screenWidth - raylib.MeasureText("BOX SELECTED", 30)), 2),
                @floatToInt(i32, @intToFloat(f32, screenHeight) * 0.1),
                30,
                raylib.GREEN,
            );
        }

        raylib.DrawFPS(10, 10);
    }
}

fn deinit() void {
    raylib.CloseWindow();
}
