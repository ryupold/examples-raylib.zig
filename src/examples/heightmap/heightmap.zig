//! Zig version of: https://www.raylib.com/examples/models/loader.html?name=models_heightmap

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

var camera = raylib.Camera3D{
    .position = .{ .x = 18, .y = 18, .z = 18 },
    .target = .{},
    .up = .{ .y = 1 },
    .fovy = 45,
    .projection = .CAMERA_PERSPECTIVE,
};

var image: raylib.Image = undefined;
var texture: raylib.Texture2D = undefined;
var mesh: raylib.Mesh = undefined;
var model: raylib.Model = undefined;
const mapPosition: raylib.Vector3 = .{ .x = -8, .y = 0, .z = -8 };

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [models] example - heightmap loading and drawing");

    image = raylib.LoadImage("assets/heightmap.png");
    defer raylib.UnloadImage(image);

    texture = raylib.LoadTextureFromImage(image);

    mesh = raylib.GenMeshHeightmap(image, .{ .x = 16, .y = 8, .z = 16 });
    model = raylib.LoadModelFromMesh(mesh);
    model.materials[0].maps[raylib.MATERIAL_MAP_DIFFUSE].texture = texture;

    raylib.SetCameraMode(camera, .CAMERA_ORBITAL);
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    //Update
    raylib.UpdateCamera(&camera);

    //Draw
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        {
            raylib.BeginMode3D(camera);
            defer raylib.EndMode3D();

            raylib.DrawModel(model, mapPosition, 1, raylib.RED);
            raylib.DrawGrid(20, 1);
        }

        raylib.DrawTexture(texture, screenWidth - texture.width - 20, 20, raylib.WHITE);
        raylib.DrawRectangleLines(screenWidth - texture.width - 20, 20, texture.width, texture.height, raylib.GREEN);

        raylib.DrawFPS(10, 10);
    }
}

fn deinit() void {
    raylib.UnloadTexture(texture);
    raylib.UnloadModel(model);

    raylib.CloseWindow();
}
