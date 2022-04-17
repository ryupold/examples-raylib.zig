const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const std = @import("std");

const LogLevel = enum { debug, info, warn, err };

const printBufferSize: usize = 1024 * 16;
pub fn info(comptime fmt: []const u8, args: anytype) void {
    var buf: [printBufferSize]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    infoAlloc(fba.allocator(), fmt, args) catch |err| {
        std.debug.print("Error when log.info: {?}\n(your message is probably to long, please use 'infoAlloc' instead)\n", .{err});
    };
}

pub fn warn(comptime fmt: []const u8, args: anytype) void {
    var buf: [printBufferSize]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    warnAlloc(fba.allocator(), fmt, args) catch |err| {
        std.debug.print("Error when log.warn: {?}\n(your message is probably to long, please use 'warnAlloc' instead)\n", .{err});
    };
}

pub fn err(comptime fmt: []const u8, args: anytype) void {
    var buf: [printBufferSize]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    errAlloc(fba.allocator(), fmt, args) catch |err| {
        std.debug.print("Error when log.err: {?}\n(your message is probably to long, please use 'errAlloc' instead)\n", .{err});
    };
}

pub fn debug(comptime fmt: []const u8, args: anytype) void {
    if (builtin.mode == .Debug) {
        var buf: [printBufferSize]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        debugAlloc(fba.allocator(), fmt, args) catch |err| {
            std.debug.print("Error when log.debug: {?}\n(your message is probably to long, please use 'debugAlloc' instead)\n", .{err});
        };
    }
}

pub fn infoAlloc(allocator: Allocator, comptime fmt: []const u8, args: anytype) !void {
    try printAlloc(allocator, .info, fmt, args);
}

pub fn warnAlloc(allocator: Allocator, comptime fmt: []const u8, args: anytype) !void {
    try printAlloc(allocator, .warn, fmt, args);
}

pub fn errAlloc(allocator: Allocator, comptime fmt: []const u8, args: anytype) !void {
    try printAlloc(allocator, .err, fmt, args);
}

pub fn debugAlloc(allocator: Allocator, comptime fmt: []const u8, args: anytype) !void {
    try printAlloc(allocator, .debug, fmt, args);
}

fn printAlloc(allocator: Allocator, comptime logLevel: LogLevel, comptime fmt: []const u8, args: anytype) !void {
    const s = try std.fmt.allocPrintZ(allocator, fmt++"\n", args);
    defer allocator.free(s);
    getPrintFn(logLevel)(s);
}

fn getPrintFn(comptime logLevel: LogLevel) fn ([:0]u8) void {
    switch (builtin.os.tag) {
        .wasi, .emscripten, .freestanding => {
            return emscriptenPrint(logLevel);
        },
        else => {
            return desktopPrint(logLevel);
        },
    }
}

fn emscriptenPrint(comptime logLevel: LogLevel) fn ([:0]u8) void {
    const emsdk = @cImport({
        @cDefine("__EMSCRIPTEN__", "1");
        @cInclude("emscripten/emscripten.h");
    });
    return (struct {
        pub fn print(s: [:0]u8) void {
            emsdk.emscripten_log(switch (logLevel) {
                .info => 1,
                .warn => 2,
                .err => 4,
                .debug => 256,
            }, @ptrCast([*c]const u8, s));
        }
    }).print;
}

fn desktopPrint(comptime logLevel: LogLevel) fn ([:0]u8) void {
    return (struct {
        pub fn print(s: [:0]u8) void {
            const printFn: fn (comptime format: []const u8, args: anytype) void =
                switch (logLevel) {
                .info => std.log.info,
                .warn => std.log.warn,
                .err => std.log.err,
                .debug => std.log.debug,
            };
            printFn("{s}", .{s});
        }
    }).print;
}
