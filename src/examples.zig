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
    "controls_test_suite",
    "physics_demo",
    "heightmap",
};

pub const examples = std.ComptimeStringMap(Example, .{
    .{ "hello_world", @import("examples/hello_world/hello_world.zig").example },
    .{ "input_keys", @import("examples/input_keys/input_keys.zig").example },
    .{ "3d_camera_free", @import("examples/3d_camera_free/3d_camera_free.zig").example },
    .{ "smooth_pixel_perfect", @import("examples/smooth_pixel_perfect/smooth_pixel_perfect.zig").example },
    .{ "lines_bezier", @import("examples/lines_bezier/lines_bezier.zig").example },
    .{ "bunnymark", @import("examples/bunnymark/bunnymark.zig").example },
    .{ "input_box", @import("examples/input_box/input_box.zig").example },
    .{ "controls_test_suite", @import("examples/controls_test_suite/controls_test_suite.zig").example },
    .{ "physics_demo", @import("examples/physics_demo/physics_demo.zig").example },
    .{ "heightmap", @import("examples/heightmap/heightmap.zig").example },
});
