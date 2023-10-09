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

var sampleCount: u32 = 0;
var samples: []f32 = &.{};
var points: []raylib.Vector2 = &.{};
var allocator: std.mem.Allocator = undefined;

fn callback(bufferData: ?*anyopaque, frames: u32) void {
    var data: [*]u8 = @ptrCast(bufferData);
    var i: usize = 0;
    if (samples.len != frames * music.stream.channels) {
        if (samples.len != 0) {
            allocator.free(samples);
            allocator.free(points);
        }
        samples = allocator.alloc(f32, frames * music.stream.channels) catch unreachable;
        points = allocator.alloc(raylib.Vector2, frames * music.stream.channels) catch unreachable;
    }
    //read the samples from the first channel
    while (i < frames * music.stream.channels) : (i += music.stream.channels) {
        var j: usize = 0;
        while (j < music.stream.channels) : (j += 1) {
            const start = (i * music.stream.sampleSize / 8) + (j * music.stream.sampleSize / 8);
            samples[i + j] = std.mem.bytesToValue(f32, @as(*[4]u8, @ptrCast(data[(start)..(start + 4)])));
            samples[i + j] = std.mem.bytesToValue(f32, @as(*[4]u8, @ptrCast(data[(start)..(start + 4)])));
        }
    }
    sampleCount = frames;
}

fn init(a: std.mem.Allocator) !void {
    allocator = a;
    raylib.InitWindow(screenWidth, screenHeight, "raylib - audio stream example");
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
    raylib.DrawText(try std.fmt.bufPrintZ(&buf, "{d} samples", .{sampleCount}), 40, 60, 16, raylib.WHITE);
    raylib.DrawText(try std.fmt.bufPrintZ(&buf, "{d} bit sample size", .{music.stream.sampleSize}), 40, 80, 16, raylib.WHITE);
    raylib.DrawText(try std.fmt.bufPrintZ(&buf, "{d} channels", .{music.stream.channels}), 40, 100, 16, raylib.WHITE);

    const soundwaves = raylib.Rectangle{
        .x = 20,
        .y = 150,
        .width = screenWidth - 40,
        .height = 250,
    };
    const channelGap = 5;
    for (0..music.stream.channels) |channel| {
        const channelRect = raylib.Rectangle{
            .x = soundwaves.x,
            .y = soundwaves.y + @as(f32, @floatFromInt(channel)) * (soundwaves.height / @as(f32, @floatFromInt(music.stream.channels)) + channelGap),
            .width = soundwaves.width,
            .height = soundwaves.height / @as(f32, @floatFromInt(music.stream.channels)) - @as(f32, @floatFromInt(music.stream.channels)) * channelGap,
        };
        raylib.DrawRectangleLinesEx(channelRect, 1, raylib.GRAY);

        for (0..sampleCount) |i| {
            const sampleLineSize = raylib.Vector2{
                .x = channelRect.width / @as(f32, @floatFromInt(sampleCount)),
                .y = 2,
            };
            const nextPoint = .{
                .x = @as(f32, @floatFromInt(i)) * sampleLineSize.x + channelRect.x,
                .y = channelRect.y + channelRect.height / 2 - (samples[i * music.stream.channels + channel] * channelRect.height),
            };
            raylib.DrawCircleV(nextPoint, 1, raylib.GREEN.lerp(
                raylib.RED,
                @abs(samples[i * music.stream.channels + channel]) * 5,
            ));
        }
    }

    raylib.DrawFPS(10, 10);
}

fn deinit() void {
    raylib.UnloadMusicStream(music);
    if (samples.len != 0) {
        allocator.free(samples);
        allocator.free(points);
    }

    raylib.CloseWindow();
}
