const std = @import("std");
const log = @import("./log.zig");
const Example = @import("examples/example.zig").Example;
const ZecsiAllocator = @import("allocator.zig").ZecsiAllocator;

const examples = @import("examples.zig").examples;

var zalloc = ZecsiAllocator{};
var currentExample: Example = undefined;

pub fn start(example: []const u8) !void {
    if (examples.get(example)) |e| {
        currentExample = e;
        var allo = zalloc.allocator();
        try currentExample.initFn(allo);
    }
}

pub fn stop() void {
    currentExample.deinitFn();

    if (zalloc.deinit()) {
        log.err("memory leaks detected!", .{});
    }
}

pub fn loop(dt: f32) void {
    currentExample.updateFn(dt) catch |err| log.err("ERROR: {?}", .{err});
}
