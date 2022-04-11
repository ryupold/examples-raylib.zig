const std = @import("std");
const Allocator = std.mem.Allocator;
const fmt = std.fmt;
const game = @import("./game.zig");
const log = @import("./log.zig");

const r = @import("raylib/raylib.zig");
const ZecsiAllocator = @import("allocator.zig").ZecsiAllocator;

var zalloc = ZecsiAllocator{};

const updateWindowSizeEveryNthFrame = 30;

pub fn main() anyerror!void {
    //init allocator
    const allocator = zalloc.allocator();
    defer {
        log.info("free memory...", .{});
        if (zalloc.deinit()) {
            log.err("memory leaks detected!", .{});
        }
    }

    const exePath = try std.fs.selfExePathAlloc(allocator);
    const cwd = std.fs.path.dirname(exePath).?;
    defer allocator.free(exePath);
    log.info("current path: {s}", .{cwd});

    r.SetConfigFlags(.FLAG_WINDOW_RESIZABLE);
    var frame: usize = 0;
    var lastWindowSize : struct { w: u32 = 0, h: u32 = 0 } = .{};

    // game start/stop
    log.info("starting game...", .{});
    try game.start(allocator, .{ .cwd = cwd });
    defer {
        log.info("stopping game...", .{});
        game.stop(allocator);
    }

    r.SetTargetFPS(60);

    while (!r.WindowShouldClose()) {
        if (frame % updateWindowSizeEveryNthFrame == 0) {
            const newW = @intCast(u32, r.GetScreenWidth());
            const newH = @intCast(u32, r.GetScreenHeight());
            if (newW != lastWindowSize.w or newH != lastWindowSize.h) {
                log.debug("changed screen size {d}x{x}", .{newW, newH});
                game.setWindowSize(@intCast(usize, newW), @intCast(usize, newH));
                lastWindowSize.w = newW;
                lastWindowSize.h = newH;
            }
        }
        frame += 1;
        try game.mainLoop();
    }
}
