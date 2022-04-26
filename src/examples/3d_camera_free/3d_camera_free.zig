//! Zig version of: https://www.raylib.com/examples/core/loader.html?name=core_3d_camera_free

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("../../raylib/raylib.zig");

const Camera3D = raylib.Camera3D;
const Vector3 = raylib.Vector3;

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

var camera: Camera3D = .{
    .position = .{ .x = 10.0, .y = 10.0, .z = 10.0 },
    .target = .{ .x = 0, .y = 0, .z = 0 },
    .up = .{ .x = 0, .y = 1, .z = 0 },
    .fovy = 45.0,
    .projection = @enumToInt(raylib.CameraProjection.CAMERA_PERSPECTIVE),
};
var cubePosition: Vector3 = .{ .x = 0, .y = 0, .z = 0 };

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free");
    raylib.SetCameraMode(camera, @enumToInt(raylib.CameraMode.CAMERA_FREE));
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    if (raylib.IsKeyDown(.KEY_Z))
        camera.target = .{ .x = 0.0, .y = 0.0, .z = 0.0 };
    raylib.UpdateCamera(&camera);

    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.RAYWHITE);

    raylib.BeginMode3D(camera);
    raylib.DrawCube(cubePosition, 2.0, 2.0, 2.0, raylib.RED);
    raylib.DrawCubeWires(cubePosition, 2.0, 2.0, 2.0, raylib.MAROON);
    raylib.DrawGrid(10, 1);
    raylib.EndMode3D();

    raylib.DrawRectangle(10, 10, 320, 133, raylib.Fade(raylib.SKYBLUE, 0.5));
    raylib.DrawRectangleLines(10, 10, 320, 133, raylib.BLUE);

    raylib.DrawText("Free camera default controls:", 20, 20, 10, raylib.BLACK);
    raylib.DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, raylib.DARKGRAY);
    raylib.DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, raylib.DARKGRAY);
    raylib.DrawText("- Alt + Mouse Wheel Pressed to Rotate", 40, 80, 10, raylib.DARKGRAY);
    raylib.DrawText("- Alt + Ctrl + Mouse Wheel Pressed for Smooth Zoom", 40, 100, 10, raylib.DARKGRAY);
    raylib.DrawText("- Z to zoom to (0, 0, 0)", 40, 120, 10, raylib.DARKGRAY);
}

fn deinit() void {
    raylib.CloseWindow();
}

// #include "raylib.h"

// int main(void)
// {
//     // Initialization
//     //--------------------------------------------------------------------------------------
//     const int screenWidth = 800;
//     const int screenHeight = 450;

//     InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free");

//     // Define the camera to look into our 3d world
//     Camera3D camera = { 0 };
//     camera.position = (Vector3){ 10.0f, 10.0f, 10.0f }; // Camera position
//     camera.target = (Vector3){ 0.0f, 0.0f, 0.0f };      // Camera looking at point
//     camera.up = (Vector3){ 0.0f, 1.0f, 0.0f };          // Camera up vector (rotation towards target)
//     camera.fovy = 45.0f;                                // Camera field-of-view Y
//     camera.projection = CAMERA_PERSPECTIVE;                   // Camera mode type

//     Vector3 cubePosition = { 0.0f, 0.0f, 0.0f };

//     SetCameraMode(camera, CAMERA_FREE); // Set a free camera mode

//     SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
//     //--------------------------------------------------------------------------------------

//     // Main game loop
//     while (!WindowShouldClose())        // Detect window close button or ESC key
//     {
//         // Update
//         //----------------------------------------------------------------------------------
//         UpdateCamera(&camera);          // Update camera

//         if (IsKeyDown('Z')) camera.target = (Vector3){ 0.0f, 0.0f, 0.0f };
//         //----------------------------------------------------------------------------------

//         // Draw
//         //----------------------------------------------------------------------------------
//         BeginDrawing();

//             ClearBackground(RAYWHITE);

//             BeginMode3D(camera);

//                 DrawCube(cubePosition, 2.0f, 2.0f, 2.0f, RED);
//                 DrawCubeWires(cubePosition, 2.0f, 2.0f, 2.0f, MAROON);

//                 DrawGrid(10, 1.0f);

//             EndMode3D();

//             DrawRectangle( 10, 10, 320, 133, Fade(SKYBLUE, 0.5f));
//             DrawRectangleLines( 10, 10, 320, 133, BLUE);

//             DrawText("Free camera default controls:", 20, 20, 10, BLACK);
//             DrawText("- Mouse Wheel to Zoom in-out", 40, 40, 10, DARKGRAY);
//             DrawText("- Mouse Wheel Pressed to Pan", 40, 60, 10, DARKGRAY);
//             DrawText("- Alt + Mouse Wheel Pressed to Rotate", 40, 80, 10, DARKGRAY);
//             DrawText("- Alt + Ctrl + Mouse Wheel Pressed for Smooth Zoom", 40, 100, 10, DARKGRAY);
//             DrawText("- Z to zoom to (0, 0, 0)", 40, 120, 10, DARKGRAY);

//         EndDrawing();
//         //----------------------------------------------------------------------------------
//     }

//     // De-Initialization
//     //--------------------------------------------------------------------------------------
//     CloseWindow();        // Close window and OpenGL context
//     //--------------------------------------------------------------------------------------

//     return 0;
// }
