const std = @import("std");
const Allocator = std.mem.Allocator;
const fmt = std.fmt;
const log = @import("log.zig");
const game = @import("game.zig");
const raylib = @import("raylib/raylib.zig");

pub fn main() anyerror!void {
    try game.start(@import("load_example.zig").name);
    defer game.stop();

    while (!raylib.WindowShouldClose()) {
        game.loop(raylib.GetFrameTime()) catch |err| {
            if(err == error.Exit) break;
            log.err("ERROR: {?}", .{err});
        };
    }
}
