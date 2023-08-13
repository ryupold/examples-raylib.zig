const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("raylib");

const screenWidth: i32 = 1024;
const screenHeight: i32 = 800;

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

var camera: raylib.Camera3D = .{
    .position = .{ .x = 10.0, .y = 20.0, .z = 10.0 },
    .target = .{ .x = 0.0, .y = 5.0, .z = 0.0 },
    .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
    .fovy = 45.0,
    .projection = .CAMERA_PERSPECTIVE,
};

var model: raylib.Model = undefined;
var texture: raylib.Texture2D = undefined;
var animFrameCounter: u64 = 0;
var animsCount: u32 = 0;
var anims: ?[*]raylib.ModelAnimation = undefined;

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - 3d camera free");
    raylib.SetTargetFPS(60);
    raylib.DisableCursor();

    model = raylib.LoadModel("assets/guy.iqm");
    texture = raylib.LoadTexture("assets/guytex.png");
    raylib.SetMaterialTexture(model.materials, raylib.MATERIAL_MAP_DIFFUSE, texture);

    anims = raylib.LoadModelAnimations("assets/guyanim.iqm", @as(?[*]u32, @ptrCast(&animsCount)));
}

fn update(_: f32) !void {
    raylib.UpdateCamera(&camera, .CAMERA_ORBITAL);

    if (raylib.IsKeyDown(.KEY_SPACE)) {
        animFrameCounter += 1;
        raylib.UpdateModelAnimation(model, anims.?[0], @as(i32, @intCast(animFrameCounter)));
        if (animFrameCounter >= anims.?[0].frameCount) animFrameCounter = 0;
    }

    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.RAYWHITE);

    raylib.BeginMode3D(camera);
    defer raylib.EndMode3D();

    raylib.DrawModelEx(
        model,
        raylib.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        raylib.Vector3{ .x = 1.0, .y = 0.0, .z = 0.0 },
        -90.0,
        raylib.Vector3{ .x = 1.0, .y = 1.0, .z = 1.0 },
        raylib.WHITE,
    );
    for (0..@as(usize, @intCast(model.boneCount))) |i| {
        raylib.DrawCube(anims.?[0].framePoses.?[@intCast(animFrameCounter)][i].translation, 0.2, 0.2, 0.2, raylib.RED);
    }

    raylib.DrawGrid(10, 1.0);
}

fn deinit() void {
    raylib.UnloadModel(model);
    raylib.UnloadTexture(texture);
    raylib.CloseWindow();
    raylib.UnloadModelAnimations(anims, animsCount);
}
