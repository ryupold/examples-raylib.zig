//! apologies for the weird bindings.
//! i have to pass structs in&out as pointers otherwise the wasm32 build will crash at runtime
//! windows & macos works just fine passing structs directly

const std = @import("std");
const r = @cImport({
    @cInclude("raylib_marshall.h");
});
const t = @import("types.zig");
const e = @import("enums.zig");
const cPtr = t.asCPtr;
const log = @import("../log.zig");

//=== Window-related functions ====================================================================
// Setup init configuration flags
pub fn SetConfigFlags(flags: e.ConfigFlags) void {
    r.SetConfigFlags(@enumToInt(flags));
}

//=== Files System ================================================================================
pub fn LoadFileData(fileName: []const u8) ![]const u8 {
    var buf: [8096]u8 = undefined;
    var bytesRead: u32 = undefined;

    const result = r.mLoadFileData(std.fmt.bufPrintZ(&buf, "{s}", .{fileName}) catch |err| {
        log.err("ERROR in LoadFileData: {?}", .{err});
        unreachable;
    }, @ptrCast([*c]c_uint, &bytesRead));

    if(result == null) return error.FileNotFound;

    return result[0..bytesRead];
}

pub fn UnloadFileData(data: []const u8) void {
    var ptr = @intToPtr([*c]u8, @ptrToInt(data.ptr));
    r.mUnloadFileData(ptr);
}
