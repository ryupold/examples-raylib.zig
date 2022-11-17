const std = @import("std");
const fmt = std.fmt;
const emsdk = @cImport({
    @cDefine("__EMSCRIPTEN__", "1");
    @cDefine("PLATFORM_WEB", "1");
    @cInclude("emscripten/emscripten.h");
});
const log = @import("log.zig");
const game = @import("game.zig");
const ZecsiAllocator = @import("allocator.zig").ZecsiAllocator;
const raylib = @import("raylib/raylib.zig");

////special entry point for Emscripten build, called from src/marshall/emscripten_entry.c
export fn emsc_main() callconv(.C) c_int {
    return safeMain() catch |err| {
        log.err("ERROR: {?}", .{err});
        return 1;
    };
}

export fn emsc_set_window_size(width: c_int, height: c_int) callconv(.C) void {
    raylib.SetWindowSize(@intCast(i32, width), @intCast(i32, height));
}

fn safeMain() !c_int {
    try game.start(@import("load_example.zig").name);
    defer game.stop();

    emsdk.emscripten_set_main_loop(gameLoop, 0, 1);
    return 0;
}

export fn gameLoop() callconv(.C) void {
    game.loop(raylib.GetFrameTime()) catch |err| log.err("ERROR: {?}", .{err});
}
