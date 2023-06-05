//! Zig version of: https://www.raylib.com/examples/core/loader.html?name=core_input_gamepad

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

// NOTE: Gamepad name ID depends on drivers and OS
const XBOX360_LEGACY_NAME_ID = "Xbox Controller";
const XBOX360_NAME_ID = "Xbox 360 Controller";
const PS3_NAME_ID = "PLAYSTATION(R)3 Controller";

var texPs3Pad: raylib.Texture2D = undefined;
var texXboxPad: raylib.Texture2D = undefined;

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [core] example - input gamepad");
    raylib.SetTargetFPS(60);
    raylib.SetConfigFlags(.{ .FLAG_MSAA_4X_HINT = true });

    texPs3Pad = raylib.LoadTexture("assets/ps3.png");
    texXboxPad = raylib.LoadTexture("assets/xbox.png");
}

fn update(_: f32) !void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);

    raylib.ClearBackground(raylib.RAYWHITE);
    if (raylib.IsGamepadAvailable(0)) {
        const gamepadName = raylib.GetGamepadName(0);
        raylib.DrawText(try raylib.TextFormat(
            fba.allocator(),
            "GP1: {s}",
            .{gamepadName},
        ), 10, 10, 10, raylib.BLACK);

        if (raylib.TextIsEqual(gamepadName, XBOX360_LEGACY_NAME_ID) or raylib.TextIsEqual(gamepadName, XBOX360_NAME_ID)) {
            raylib.DrawTexture(texXboxPad, 0, 0, raylib.DARKGRAY);

            // Draw buttons: xbox home
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_MIDDLE)) raylib.DrawCircle(394, 89, 19, raylib.RED);

            // Draw buttons: basic
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_MIDDLE_RIGHT)) raylib.DrawCircle(436, 150, 9, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_MIDDLE_LEFT)) raylib.DrawCircle(352, 150, 9, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) raylib.DrawCircle(501, 151, 15, raylib.BLUE);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) raylib.DrawCircle(536, 187, 15, raylib.LIME);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) raylib.DrawCircle(572, 151, 15, raylib.MAROON);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_FACE_UP)) raylib.DrawCircle(536, 115, 15, raylib.GOLD);

            // Draw buttons: d-pad
            raylib.DrawRectangle(317, 202, 19, 71, raylib.BLACK);
            raylib.DrawRectangle(293, 228, 69, 19, raylib.BLACK);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_UP)) raylib.DrawRectangle(317, 202, 19, 26, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_DOWN)) raylib.DrawRectangle(317, 202 + 45, 19, 26, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_LEFT)) raylib.DrawRectangle(292, 228, 25, 19, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) raylib.DrawRectangle(292 + 44, 228, 26, 19, raylib.RED);

            // Draw buttons: left-right back
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_TRIGGER_1)) raylib.DrawCircle(259, 61, 20, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) raylib.DrawCircle(536, 61, 20, raylib.RED);

            // Draw axis: left joystick
            raylib.DrawCircle(259, 152, 39, raylib.BLACK);
            raylib.DrawCircle(259, 152, 34, raylib.LIGHTGRAY);
            raylib.DrawCircle(259 + @floatToInt(i32, raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_X) * 20), 152 + @floatToInt(i32, raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_Y) * 20), 25, raylib.BLACK);

            // Draw axis: right joystick
            raylib.DrawCircle(461, 237, 38, raylib.BLACK);
            raylib.DrawCircle(461, 237, 33, raylib.LIGHTGRAY);
            raylib.DrawCircle(461 + @floatToInt(i32, raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_RIGHT_X) * 20), 237 + @floatToInt(i32, raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_RIGHT_Y) * 20), 25, raylib.BLACK);

            // Draw axis: left-right triggers
            raylib.DrawRectangle(170, 30, 15, 70, raylib.GRAY);
            raylib.DrawRectangle(604, 30, 15, 70, raylib.GRAY);
            raylib.DrawRectangle(170, 30, 15, @floatToInt(i32, ((1 + raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_TRIGGER)) / 2) * 70), raylib.RED);
            raylib.DrawRectangle(604, 30, 15, @floatToInt(i32, ((1 + raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_RIGHT_TRIGGER)) / 2) * 70), raylib.RED);

            //DrawText(TextFormat("Xbox axis LT: %02.02f", GetGamepadAxisMovement(0, GAMEPAD_AXIS_LEFT_TRIGGER)), 10, 40, 10, BLACK);
            //DrawText(TextFormat("Xbox axis RT: %02.02f", GetGamepadAxisMovement(0, GAMEPAD_AXIS_RIGHT_TRIGGER)), 10, 60, 10, BLACK);
        } else if (raylib.TextIsEqual(gamepadName, PS3_NAME_ID)) {
            raylib.DrawTexture(texPs3Pad, 0, 0, raylib.DARKGRAY);

            // Draw buttons: ps
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_MIDDLE)) raylib.DrawCircle(396, 222, 13, raylib.RED);

            // Draw buttons: basic
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_MIDDLE_LEFT)) raylib.DrawRectangle(328, 170, 32, 13, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_MIDDLE_RIGHT)) raylib.DrawTriangle(.{ .x = 436, .y = 168 }, .{ .x = 436, .y = 185 }, .{ .x = 464, .y = 177 }, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_FACE_UP)) raylib.DrawCircle(557, 144, 13, raylib.LIME);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_FACE_RIGHT)) raylib.DrawCircle(586, 173, 13, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_FACE_DOWN)) raylib.DrawCircle(557, 203, 13, raylib.VIOLET);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_FACE_LEFT)) raylib.DrawCircle(527, 173, 13, raylib.PINK);

            // Draw buttons: d-pad
            raylib.DrawRectangle(225, 132, 24, 84, raylib.BLACK);
            raylib.DrawRectangle(195, 161, 84, 25, raylib.BLACK);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_UP)) raylib.DrawRectangle(225, 132, 24, 29, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_DOWN)) raylib.DrawRectangle(225, 132 + 54, 24, 30, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_LEFT)) raylib.DrawRectangle(195, 161, 30, 25, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_FACE_RIGHT)) raylib.DrawRectangle(195 + 54, 161, 30, 25, raylib.RED);

            // Draw buttons: left-right back buttons
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_LEFT_TRIGGER_1)) raylib.DrawCircle(239, 82, 20, raylib.RED);
            if (raylib.IsGamepadButtonDown(0, .GAMEPAD_BUTTON_RIGHT_TRIGGER_1)) raylib.DrawCircle(557, 82, 20, raylib.RED);

            // Draw axis: left joystick
            raylib.DrawCircle(319, 255, 35, raylib.BLACK);
            raylib.DrawCircle(319, 255, 31, raylib.LIGHTGRAY);
            raylib.DrawCircle(319 + @floatToInt(i32, raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_X) * 20), 255 + @floatToInt(i32, raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_Y) * 20), 25, raylib.BLACK);

            // Draw axis: right joystick
            raylib.DrawCircle(475, 255, 35, raylib.BLACK);
            raylib.DrawCircle(475, 255, 31, raylib.LIGHTGRAY);
            raylib.DrawCircle(475 + @floatToInt(i32, raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_RIGHT_X) * 20), 255 + @floatToInt(i32, raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_RIGHT_Y) * 20), 25, raylib.BLACK);

            // Draw axis: left-right triggers
            raylib.DrawRectangle(169, 48, 15, 70, raylib.GRAY);
            raylib.DrawRectangle(611, 48, 15, 70, raylib.GRAY);
            raylib.DrawRectangle(169, 48, 15, ((@floatToInt(i32, 1 - raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_LEFT_TRIGGER) / 2)) * 70), raylib.RED);
            raylib.DrawRectangle(611, 48, 15, ((@floatToInt(i32, 1 - raylib.GetGamepadAxisMovement(0, .GAMEPAD_AXIS_RIGHT_TRIGGER) / 2)) * 70), raylib.RED);
        } else {
            raylib.DrawText("- GENERIC GAMEPAD -", 280, 180, 20, raylib.GRAY);
        }

        raylib.DrawText(try raylib.TextFormat(fba.allocator(), "DETECTED AXIS [{d}]:", .{raylib.GetGamepadAxisCount(0)}), 10, 50, 10, raylib.MAROON);

        var i: i32 = 0;
        while (i < raylib.GetGamepadAxisCount(0)) : (i += 1) {
            raylib.DrawText(try raylib.TextFormat(fba.allocator(), "AXIS {d}: {d}", .{ i, raylib.GetGamepadAxisMovement(0, @intToEnum(raylib.GamepadAxis, i)) }), 20, 70 + 20 * i, 10, raylib.DARKGRAY);
        }

        if (raylib.GetGamepadButtonPressed()) |button| {
            raylib.DrawText(try raylib.TextFormat(fba.allocator(), "DETECTED BUTTON: {any}", .{button}), 10, 430, 10, raylib.RED);
        } else {
            raylib.DrawText("DETECTED BUTTON: NONE", 10, 430, 10, raylib.GRAY);
        }
    } else {
        raylib.DrawText("GP1: NOT DETECTED", 10, 10, 10, raylib.GRAY);

        raylib.DrawTexture(texXboxPad, 0, 0, raylib.LIGHTGRAY);
    }
}

fn deinit() void {
    raylib.UnloadTexture(texPs3Pad);
    raylib.UnloadTexture(texXboxPad);
    raylib.CloseWindow();
}
