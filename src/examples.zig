const std = @import("std");
const Example = @import("examples/example.zig").Example;

pub const exampleList: []const []const u8 = &.{
    "hello_world",
    "input_keys",
    "3d_camera_free",
    "smooth_pixel_perfect",
    "lines_bezier",
    "bunnymark",
    "input_box",
    "heightmap",
    "3d_picking",
    "rlgl_solar_system",
    "font_filters",
    "raygui",
};

pub const examples = std.ComptimeStringMap(Example, .{
    .{ "hello_world", @import("examples/hello_world/hello_world.zig").example },
    .{ "input_keys", @import("examples/input_keys/input_keys.zig").example },
    .{ "3d_camera_free", @import("examples/3d_camera_free/3d_camera_free.zig").example },
    .{ "smooth_pixel_perfect", @import("examples/smooth_pixel_perfect/smooth_pixel_perfect.zig").example },
    .{ "lines_bezier", @import("examples/lines_bezier/lines_bezier.zig").example },
    .{ "bunnymark", @import("examples/bunnymark/bunnymark.zig").example },
    .{ "input_box", @import("examples/input_box/input_box.zig").example },
    .{ "heightmap", @import("examples/heightmap/heightmap.zig").example },
    .{ "3d_picking", @import("examples/3d_picking/3d_picking.zig").example },
    .{ "rlgl_solar_system", @import("examples/rlgl_solar_system/rlgl_solar_system.zig").example },
    .{ "font_filters", @import("examples/font_filters/font_filters.zig").example },
    .{ "raygui", @import("examples/raygui/raygui.zig").example },
});
