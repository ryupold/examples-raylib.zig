const std = @import("std");
const Allocator = std.mem.Allocator;
const fmt = std.fmt;
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

    r.InitWindow(800, 800, "example");

    r.SetConfigFlags(@enumToInt(r.ConfigFlags.FLAG_WINDOW_RESIZABLE));
    r.SetTargetFPS(60);

    while (!r.WindowShouldClose()) {
        r.BeginDrawing();
        defer r.EndDrawing();
        
        r.ClearBackground(r.BLACK);
        r.DrawFPS(10, 10);

        r.DrawText("hello planet", 100, 100, 20, r.YELLOW);
    }
}
