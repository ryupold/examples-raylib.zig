//! Zig version of: https://www.raylib.com/examples/shaders/loader.html?name=shaders_basic_lighting

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("../../raylib/raylib.zig");

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const maxLights = 4;
const screenWidth: i32 = 800;
const screenHeight: i32 = 450;
const glslVersion = 330;

// #if defined(PLATFORM_DESKTOP)
//     #define GLSL_VERSION            330
// #else   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
//     #define GLSL_VERSION            100
// #endif

var camera: raylib.Camera3D = undefined;
var model: raylib.Model = undefined;
var cube: raylib.Model = undefined;
var shader: raylib.Shader = undefined;
var ambientLoc: i32 = undefined;
var lights: [maxLights]Light = undefined;
var lightLocations: [maxLights]LightLocation = undefined;

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [shaders] example - basic lighting");
    raylib.SetTargetFPS(60);

    camera.position = .{ .x = 2.0, .y = 4.0, .z = 6.0 };
    camera.target = .{ .x = 0.0, .y = 0.5, .z = 0.0 };
    camera.up = .{ .x = 0.0, .y = 1.0, .z = 0.0 };
    camera.fovy = 45.0;
    camera.projection = .CAMERA_PERSPECTIVE;

    model = raylib.LoadModelFromMesh(raylib.GenMeshPlane(10.0, 10.0, 3, 3));
    cube = raylib.LoadModelFromMesh(raylib.GenMeshCube(2.0, 4.0, 2));

    var buf: [4096]u8 = undefined;
    shader = raylib.LoadShader(
        try std.fmt.bufPrintZ(&buf, "assets/shaders/glsl{d}/lighting.vs", .{glslVersion}),
        try std.fmt.bufPrintZ(&buf, "assets/shaders/glsl{d}/lighting.fs", .{glslVersion}),
    );
    shader.locs.?[@enumToInt(raylib.ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW)] = raylib.GetShaderLocation(shader, "viewPos");
    ambientLoc = raylib.GetShaderLocation(shader, "ambient");
    var newAmbientLoc = [4]f32{ 0.1, 0.1, 0.1, 1.0 };
    raylib.SetShaderValue(
        shader,
        ambientLoc,
        &newAmbientLoc,
        .SHADER_UNIFORM_VEC4,
    );

    model.materials.?[0].shader = shader;
    cube.materials.?[0].shader = shader;

    lights = [maxLights]Light{
        try createLight(LightType.LIGHT_POINT, .{ .x = -2, .y = 1, .z = -2 }, .{}, raylib.YELLOW, shader),
        try createLight(LightType.LIGHT_POINT, .{ .x = 2, .y = 1, .z = 2 }, .{}, raylib.RED, shader),
        try createLight(LightType.LIGHT_POINT, .{ .x = -2, .y = 1, .z = 2 }, .{}, raylib.GREEN, shader),
        try createLight(LightType.LIGHT_POINT, .{ .x = 2, .y = 1, .z = -2 }, .{}, raylib.BLUE, shader),
    };
}

fn update(_: f32) !void {
    // Update
    {
        raylib.UpdateCamera(&camera, .CAMERA_ORBITAL);

        // Update the shader with the camera view vector (points towards { 0.0f, 0.0f, 0.0f })
        var cameraPos: [3]f32 = .{ camera.position.x, camera.position.y, camera.position.z };
        raylib.SetShaderValue(
            shader,
            shader.locs.?[@enumToInt(raylib.ShaderLocationIndex.SHADER_LOC_VECTOR_VIEW)],
            &cameraPos,
            .SHADER_UNIFORM_VEC3,
        );

        // Check key inputs to enable/disable lights
        if (raylib.IsKeyPressed(.KEY_Y)) {
            lights[0].enabled = !lights[0].enabled;
        }
        if (raylib.IsKeyPressed(.KEY_R)) {
            lights[1].enabled = !lights[1].enabled;
        }
        if (raylib.IsKeyPressed(.KEY_G)) {
            lights[2].enabled = !lights[2].enabled;
        }
        if (raylib.IsKeyPressed(.KEY_B)) {
            lights[3].enabled = !lights[3].enabled;
        }

        // Update light values (actually, only enable/disable them)
        for (0..maxLights) |i| updateLightValues(shader, lights[i], lightLocations[i]);
        //----------------------------------------------------------------------------------
    }

    // Draw
    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);

        {
            raylib.BeginMode3D(camera);
            defer raylib.EndMode3D();

            raylib.DrawModel(model, .{ .x = 0.0, .y = 0.0, .z = 0.0 }, 1.0, raylib.WHITE);
            raylib.DrawModel(cube, .{ .x = 0.0, .y = 0.0, .z = 0.0 }, 1.0, raylib.WHITE);

            for (0..maxLights) |i| {
                if (lights[i].enabled) {
                    raylib.DrawSphereEx(lights[i].position, 0.2, 8, 8, raylib.ColorAlpha(lights[i].color, 0.3));
                } else {
                    raylib.DrawSphereEx(lights[i].position, 0.2, 8, 8, raylib.ColorAlpha(raylib.GRAY, 0.3));
                }
            }

            raylib.DrawGrid(10, 1.0);
        }

        raylib.DrawFPS(10, 10);
        raylib.DrawText("Use keys [Y][R][G][B] to toggle lights", 10, 40, 20, raylib.DARKGRAY);
    }
}

fn deinit() void {
    raylib.UnloadModel(model); // Unload the model
    raylib.UnloadModel(cube); // Unload the model
    raylib.UnloadShader(shader); // Unload shader

    raylib.CloseWindow();
}

var lightsCount: i32 = 0;

/// Create a light and get shader locations
fn createLight(typ: LightType, position: raylib.Vector3, target: raylib.Vector3, color: raylib.Color, shadr: raylib.Shader) !Light {
    std.debug.assert(lightsCount < maxLights);

    var light: Light = Light{
        .enabled = true,
        .type = typ,
        .position = position,
        .target = target,
        .color = color,
        // .attenuation = 0,

        // NOTE: Lighting shader naming must be the provided ones
       
    };

    var buf: [4096]u8 = undefined;
    var lightLocation = LightLocation {
         .enabledLoc = raylib.GetShaderLocation(shadr, try std.fmt.bufPrintZ(&buf, "lights[{d}].enabled", .{lightsCount})),
        .typeLoc = raylib.GetShaderLocation(shadr, try std.fmt.bufPrintZ(&buf, "lights[{d}].type", .{lightsCount})),
        .positionLoc = raylib.GetShaderLocation(shadr, try std.fmt.bufPrintZ(&buf, "lights[{d}].position", .{lightsCount})),
        .targetLoc = raylib.GetShaderLocation(shadr, try std.fmt.bufPrintZ(&buf, "lights[{d}].target", .{lightsCount})),
        .colorLoc = raylib.GetShaderLocation(shadr, try std.fmt.bufPrintZ(&buf, "lights[{d}].color", .{lightsCount})),
        // .attenuationLoc = raylib.GetShaderLocation(shadr, try std.fmt.bufPrintZ(&buf, "lights[{d}].attenuation", .{lightsCount})),
    };

    updateLightValues(shadr, light, lightLocation);

    lightsCount += 1;

    return light;
}

/// Send light properties to shader
/// NOTE: Light shader locations should be available
fn updateLightValues(shadr: raylib.Shader, light: Light, lightLocation: LightLocation) void {
    // Send to shader light enabled state and type
    var le: u8 = if (light.enabled) 1 else 0;
    raylib.SetShaderValue(shadr, lightLocation.enabledLoc, &le, .SHADER_UNIFORM_INT);
    raylib.SetShaderValue(shadr, lightLocation.typeLoc, &light.type, .SHADER_UNIFORM_INT);

    // Send to shader light position values
    var position: [3]f32 = .{ light.position.x, light.position.y, light.position.z };
    raylib.SetShaderValue(shadr, lightLocation.positionLoc, &position, .SHADER_UNIFORM_VEC3);

    // Send to shader light target position values
    var target: [3]f32 = .{ light.target.x, light.target.y, light.target.z };
    raylib.SetShaderValue(shadr, lightLocation.targetLoc, &target, .SHADER_UNIFORM_VEC3);

    // Send to shader light color values
    var color: [4]f32 = .{ @intToFloat(f32, light.color.r) / 255.0, @intToFloat(f32, light.color.g) / 255, @intToFloat(f32, light.color.b) / 255, @intToFloat(f32, light.color.a) / 255 };
    raylib.SetShaderValue(shadr, lightLocation.colorLoc, &color, .SHADER_UNIFORM_VEC4);
}

/// Light data
const Light = extern struct {
    enabled: bool,
    type: LightType,
    position: raylib.Vector3,
    target: raylib.Vector3,
    color: raylib.Color,
};

const LightLocation = extern struct {
    // attenuation: f32,

    // Shader locations
    enabledLoc: i32,
    typeLoc: i32,
    positionLoc: i32,
    targetLoc: i32,
    colorLoc: i32,
    // attenuationLoc: i32,
};

const LightType = enum(i32) {
    LIGHT_DIRECTIONAL = 0,
    LIGHT_POINT = 1,
};
