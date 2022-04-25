const std = @import("std");

pub const Example = struct {
    initFn: fn (std.mem.Allocator) anyerror!void = init,
    deinitFn: fn () void = deinit,
    updateFn: fn (f32) anyerror!void = update,
};

fn init(allocator: std.mem.Allocator) !void {
    _ = allocator;
}

fn update(dt: f32) !void {
    _ = dt;
}

fn deinit() void {}