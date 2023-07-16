//! Zig version of: https://www.raylib.com/examples/text/loader.html?name=text_input_box

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("raylib");

const Camera3D = raylib.Camera3D;
const Vector3 = raylib.Vector3;

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 800;
const screenHeight: i32 = 450;
const maxInputChars: usize = 9;
var letterCount: usize = 0;
const textBox = raylib.Rectangle{ .x = screenWidth / 2 - 100, .y = 180, .width = 225, .height = 50 };
var mouseOnText = false;
var framesCounter: usize = 0;

var name = [_]u8{0} ** (maxInputChars + 1);

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raylib [text] example - input box");
    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    var buf: [4096]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    if (raylib.CheckCollisionPointRec(raylib.GetMousePosition(), textBox)) {
        mouseOnText = true;
    } else {
        mouseOnText = false;
    }

    if (mouseOnText) {
        // Set the window's cursor to the I-Beam
        raylib.SetMouseCursor(.MOUSE_CURSOR_IBEAM);

        // Get char pressed (unicode character) on the queue
        var key = raylib.GetCharPressed();

        // Check if more characters have been pressed on the same frame
        while (key > 0) {
            // NOTE: Only allow keys in range [32..125]
            if ((key >= 32) and (key <= 125) and (letterCount < maxInputChars)) {
                name[letterCount] = @as(u8, @intCast(key));
                name[letterCount + 1] = 0; // Add null terminator at the end of the string.
                letterCount += 1;
            }

            key = raylib.GetCharPressed(); // Check next character in the queue
        }

        if (raylib.IsKeyPressed(.KEY_BACKSPACE)) {
            if (letterCount > 0) {
                letterCount -= 1;
            }
            name[letterCount] = 0;
        }
    } else {
        raylib.SetMouseCursor(.MOUSE_CURSOR_DEFAULT);
    }

    if (mouseOnText) {
        framesCounter += 1;
    } else {
        framesCounter = 0;
    }

    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.RAYWHITE);
        raylib.DrawText("PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, raylib.GRAY);
        raylib.DrawRectangleRec(textBox, raylib.LIGHTGRAY);
        if (mouseOnText) {
            raylib.DrawRectangleLines(@as(i32, @intFromFloat(textBox.x)), @as(i32, @intFromFloat(textBox.y)), @as(i32, @intFromFloat(textBox.width)), @as(i32, @intFromFloat(textBox.height)), raylib.RED);
        } else {
            raylib.DrawRectangleLines(textBox.x, textBox.y, textBox.width, textBox.height, raylib.DARKGRAY);
        }

        raylib.DrawText(@as([*:0]u8, @ptrCast(&name)), @as(i32, @intFromFloat(textBox.x)) + 5, @as(i32, @intFromFloat(textBox.y)) + 8, 40, raylib.MAROON);
        raylib.DrawText(try raylib.TextFormat(fba.allocator(), "INPUT CHARS: {d}/{d}", .{ letterCount, maxInputChars }), 315, 250, 20, raylib.DARKGRAY);

        if (mouseOnText) {
            if (letterCount < maxInputChars) {
                // Draw blinking underscore char
                if (((framesCounter / 20) % 2) == 0) {
                    raylib.DrawText("_", @as(i32, @intFromFloat(textBox.x)) + 8 + raylib.MeasureText(@as([*:0]u8, @ptrCast(&name)), 40), textBox.y + 12, 40, raylib.MAROON);
                }
            } else {
                raylib.DrawText("Press BACKSPACE to delete chars...", 230, 300, 20, raylib.GRAY);
            }
        }
    }
}

fn deinit() void {
    raylib.CloseWindow();
}
