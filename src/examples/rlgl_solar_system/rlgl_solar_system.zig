//! Zig version of: https://www.raylib.com/examples/models/loader.html?name=models_rlgl_solar_system

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

const sunRadius: f32 = 4.0;
const earthRadius: f32 = 0.6;
const earthOrbitRadius: f32 = 8.0;
const moonRadius: f32 = 0.16;
const moonOrbitRadius: f32 = 1.5;

var camera = raylib.Camera3D{
    .position = .{ .x = 16, .y = 16, .z = 16 },
    .target = .{},
    .up = .{ .y = 1 },
    .fovy = 45,
    .projection = .CAMERA_PERSPECTIVE,
};

var rotationSpeed: f32 = 0.2;
var earthRotation: f32 = 0;
var earthOrbitRotation: f32 = 0;
var moonRotation: f32 = 0;
var moonOrbitRotation: f32 = 0;

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [models] example - rlgl module usage with push/pop matrix transformations");

    raylib.SetCameraMode(camera, .CAMERA_FREE);
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    //Update
    raylib.UpdateCamera(&camera);

    earthRotation += (5 * rotationSpeed);
    earthOrbitRotation += (365.0 / 360.0 * (5 * rotationSpeed) * rotationSpeed);
    moonRotation += (2 * rotationSpeed);
    moonOrbitRotation += (8 * rotationSpeed);

    //Draw
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        // 3D
        {
            raylib.BeginMode3D(camera);
            defer raylib.EndMode3D();

            {
                raylib.rlPushMatrix();
                defer raylib.rlPopMatrix();

                raylib.rlScalef(sunRadius, sunRadius, sunRadius); // Scale Sun
                drawSphereBasic(raylib.GOLD); // Draw the Sun
            }

            {
                raylib.rlPushMatrix();
                defer raylib.rlPopMatrix();

                raylib.rlRotatef(earthOrbitRotation, 0.0, 1.0, 0.0); // Rotation for Earth orbit around Sun
                raylib.rlTranslatef(earthOrbitRadius, 0.0, 0.0); // Translation for Earth orbit

                {
                    raylib.rlPushMatrix();
                    defer raylib.rlPopMatrix();

                    raylib.rlRotatef(earthRotation, 0.25, 1.0, 0.0); // Rotation for Earth itself
                    raylib.rlScalef(earthRadius, earthRadius, earthRadius); // Scale Earth
                    drawSphereBasic(raylib.BLUE); // Draw the Earth
                }

                raylib.rlRotatef(moonOrbitRotation, 0.0, 1.0, 0.0); // Rotation for Moon orbit around Earth
                raylib.rlTranslatef(moonOrbitRadius, 0.0, 0.0); // Translation for Moon orbit
                raylib.rlRotatef(moonRotation, 0.0, 1.0, 0.0); // Rotation for Moon itself
                raylib.rlScalef(moonRadius, moonRadius, moonRadius); // Scale Moon
                drawSphereBasic(raylib.LIGHTGRAY); // Draw the Moon
            }

            // Some reference elements (not affected by previous matrix transformations)
            raylib.DrawCircle3D(.{}, earthOrbitRadius, .{ .x = 1 }, 90.0, raylib.Fade(raylib.RED, 0.5));
            raylib.DrawGrid(20, 1.0);
        }

        raylib.DrawText("EARTH ORBITING AROUND THE SUN!", 400, 10, 20, raylib.MAROON);
        raylib.DrawFPS(10, 10);
    }
}

fn deinit() void {
    raylib.CloseWindow();
}

// Draw sphere without any matrix transformation
// NOTE: Sphere is drawn in world position ( 0, 0, 0 ) with radius 1.0f
fn drawSphereBasic(color: raylib.Color) void {
    const rings: f32 = 16;
    const slices: f32 = 16;

    const cosf = std.math.cos;
    const sinf = std.math.sin;

    // Make sure there is enough space in the internal render batch
    // buffer to store all required vertex, batch is reseted if required
    _ = raylib.rlCheckRenderBatchLimit((rings + 2) * slices * 6);

    raylib.rlBegin(raylib.RL_TRIANGLES);
    defer raylib.rlEnd();

    raylib.rlColor4ub(color.r, color.g, color.b, color.a);
    var i: f32 = 0;
    while (i < (rings + 2)) : (i += 1) {
        var j: f32 = 0;
        while (j < slices) : (j += 1) {
            raylib.rlVertex3f(cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * i)) * sinf(raylib.DEG2RAD * (j * 360 / slices)), sinf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * i)), cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * i)) * cosf(raylib.DEG2RAD * (j * 360 / slices)));
            raylib.rlVertex3f(cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))) * sinf(raylib.DEG2RAD * ((j + 1) * 360 / slices)), sinf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))), cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))) * cosf(raylib.DEG2RAD * ((j + 1) * 360 / slices)));
            raylib.rlVertex3f(cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))) * sinf(raylib.DEG2RAD * (j * 360 / slices)), sinf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))), cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))) * cosf(raylib.DEG2RAD * (j * 360 / slices)));

            raylib.rlVertex3f(cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * i)) * sinf(raylib.DEG2RAD * (j * 360 / slices)), sinf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * i)), cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * i)) * cosf(raylib.DEG2RAD * (j * 360 / slices)));
            raylib.rlVertex3f(cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i))) * sinf(raylib.DEG2RAD * ((j + 1) * 360 / slices)), sinf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i))), cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i))) * cosf(raylib.DEG2RAD * ((j + 1) * 360 / slices)));
            raylib.rlVertex3f(cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))) * sinf(raylib.DEG2RAD * ((j + 1) * 360 / slices)), sinf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))), cosf(raylib.DEG2RAD * (270 + (180 / (rings + 1)) * (i + 1))) * cosf(raylib.DEG2RAD * ((j + 1) * 360 / slices)));
        }
    }
}
