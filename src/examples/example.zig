const std = @import("std");

pub const Example = struct {
    initFn: *const fn (std.mem.Allocator) anyerror!void = init,
    deinitFn: *const fn () void = deinit,
    updateFn: *const fn (f32) anyerror!void = update,
};

fn init(allocator: std.mem.Allocator) !void {
    _ = allocator;
}

fn update(dt: f32) !void {
    _ = dt;
}

fn deinit() void {}
