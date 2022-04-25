const std = @import("std");
const Example = @import("examples/example.zig").Example;

pub const exampleList = std.ComptimeStringMap(void, .{
    .{"hello_world", {}},
    .{"keyboard_input", {}},
});

pub const examples = std.ComptimeStringMap(Example, .{
    .{ "hello_world", @import("examples/hello_world/hello_world.zig").example },
    .{ "keyboard_input", @import("examples/keyboard_input/keyboard_input.zig").example },
});
