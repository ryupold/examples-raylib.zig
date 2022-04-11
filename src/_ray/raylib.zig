const std = @import("std");
const assert = std.debug.assert;

const r = @cImport({
    @cInclude("raylib_marshall.h");
    @cInclude("extras/raygui.h");
});

pub usingnamespace @import("types.zig");
pub usingnamespace @import("enums.zig");
pub usingnamespace @import("core.zig");
pub usingnamespace @import("gen.zig");
