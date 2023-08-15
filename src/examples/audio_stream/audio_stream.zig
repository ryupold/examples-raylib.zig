const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("raylib");

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

var music: raylib.Music = undefined;
var framesCounter: u32 = 0;

fn callback(bufferData: ?*anyopaque, frames: u32) void {
    _ = bufferData;
    framesCounter = frames;
}

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "audio stream example");
    raylib.SetTargetFPS(60);

    raylib.InitAudioDevice();

    music = raylib.LoadMusicStream("assets/music/file_example_MP3_1MG.mp3");
    raylib.PlayMusicStream(music);
    raylib.AttachAudioStreamProcessor(music.stream, callback);
}

fn update(_: f32) !void {
    raylib.UpdateMusicStream(music);

    if (raylib.IsKeyPressed(raylib.KeyboardKey.KEY_SPACE)) {
        if (raylib.IsMusicStreamPlaying(music)) {
            raylib.PauseMusicStream(music);
        } else {
            raylib.ResumeMusicStream(music);
        }
    }

    raylib.BeginDrawing();
    defer raylib.EndDrawing();
    raylib.ClearBackground(raylib.BLACK);
    var buf: [1024]u8 = undefined;
    raylib.DrawText(try std.fmt.bufPrintZ(&buf, "Frames per stream processor callback: {d}", .{framesCounter}), 20, 100, 30, raylib.WHITE);

    raylib.DrawFPS(10, 10);
}

fn deinit() void {
    raylib.UnloadMusicStream(music);

    raylib.CloseWindow();
}
