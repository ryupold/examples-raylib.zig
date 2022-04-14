const std = @import("std");
const Allocator = std.mem.Allocator;
const fmt = std.fmt;
const emsdk = @cImport({
    @cDefine("__EMSCRIPTEN__", "1");
    @cInclude("emscripten/emscripten.h");
});
const r = @cImport({
    @cInclude("raylib.h");
});
const game = @import("./game.zig");
const log = @import("./log.zig");
const ZecsiAllocator = @import("allocator.zig").ZecsiAllocator;

////special entry point for Emscripten build, called from src/marshall/emscripten_entry.c
export fn emsc_main() callconv(.C) c_int {
    return safeMain() catch |err| {
        log.err("ERROR: {?}", .{err});
        return 1;
    };
}

export fn emsc_set_window_size(width: usize, height: usize) callconv(.C) void {
    game.setWindowSize(width, height);
}

fn safeMain() !c_int {
    var zalloc = ZecsiAllocator{};
    const allocator = zalloc.allocator();
    try log.infoAlloc(allocator, "starting da game  ...", .{});

    try game.start(allocator, .{.cwd = ""});
    defer game.stop(allocator);

    emsdk.emscripten_set_main_loop(gameLoop, 0, 1);
    log.info("after emscripten_set_main_loop", .{});

    log.info("CLEANUP", .{});
    if (zalloc.deinit()) {
        log.err("memory leaks detected!", .{});
        return 1;
    }
    return 0;
}

export fn gameLoop() callconv(.C) void {
    game.mainLoop() catch unreachable;
}
