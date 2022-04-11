const std = @import("std");
const mem = std.mem;
const builtin = @import("builtin");
const log = @import("log.zig");
const assert = std.debug.assert;

const Allocator = std.mem.Allocator;
var gpa = if (builtin.os.tag != .emscripten and builtin.os.tag != .wasi and builtin.mode != .ReleaseFast and builtin.mode != .ReleaseSmall) std.heap.GeneralPurposeAllocator(.{}){};

pub const ZecsiAllocator =
    struct {
    const Self = @This();
    pub fn allocator(_: *Self) Allocator {
        return switch (builtin.os.tag) {
            .emscripten, .wasi => Allocator{
                .ptr = undefined,
                .vtable = &e_allocator_vtable,
            },
            else => switch (builtin.mode) {
                .Debug, .ReleaseSafe => gpa.allocator(),
                else => std.heap.c_allocator,
            },
        };
    }

    pub fn deinit(_: *Self) bool {
        switch (builtin.os.tag) {
            .emscripten, .wasi => {
                log.info("deinit not implemented for EmscriptenAllocator", .{});
                return false;
            },
            else => {
                return if (builtin.mode != .ReleaseFast and builtin.mode != .ReleaseSmall)
                    gpa.deinit()
                else
                    false;
            },
        }
    }
};

const e_allocator_vtable = Allocator.VTable{
    .alloc = EmscriptenAllocator.alloc,
    .resize = EmscriptenAllocator.resize,
    .free = EmscriptenAllocator.free,
};

/// basically copied the std.heap.c_allocator and replaced with emscripten malloc & free
const EmscriptenAllocator = struct {
    const c = @cImport({
        @cDefine("__EMSCRIPTEN__", "1");
        @cInclude("emscripten/emscripten.h");
        @cInclude("stdlib.h");
    });

    usingnamespace if (@hasDecl(c, "malloc_size"))
        struct {
            pub const supports_malloc_size = true;
            pub const malloc_size = c.malloc_size;
        }
    else if (@hasDecl(c, "malloc_usable_size"))
        struct {
            pub const supports_malloc_size = true;
            pub const malloc_size = c.malloc_usable_size;
        }
    else if (@hasDecl(c, "_msize"))
        struct {
            pub const supports_malloc_size = true;
            pub const malloc_size = c._msize;
        }
    else
        struct {
            pub const supports_malloc_size = false;
        };

    pub const supports_posix_memalign = @hasDecl(c, "posix_memalign");

    fn getHeader(ptr: [*]u8) *[*]u8 {
        return @intToPtr(*[*]u8, @ptrToInt(ptr) - @sizeOf(usize));
    }

    fn alignedAlloc(len: usize, alignment: usize) ?[*]u8 {
        if (supports_posix_memalign) {
            // The posix_memalign only accepts alignment values that are a
            // multiple of the pointer size
            const eff_alignment = std.math.max(alignment, @sizeOf(usize));

            var aligned_ptr: ?*anyopaque = undefined;
            if (c.posix_memalign(&aligned_ptr, eff_alignment, len) != 0)
                return null;

            return @ptrCast([*]u8, aligned_ptr);
        }

        // Thin wrapper around regular malloc, overallocate to account for
        // alignment padding and store the orignal malloc()'ed pointer before
        // the aligned address.
        var unaligned_ptr = @ptrCast([*]u8, c.malloc(len + alignment - 1 + @sizeOf(usize)) orelse return null);
        const unaligned_addr = @ptrToInt(unaligned_ptr);
        const aligned_addr = mem.alignForward(unaligned_addr + @sizeOf(usize), alignment);
        var aligned_ptr = unaligned_ptr + (aligned_addr - unaligned_addr);
        getHeader(aligned_ptr).* = unaligned_ptr;

        return aligned_ptr;
    }

    fn alignedFree(ptr: [*]u8) void {
        if (supports_posix_memalign) {
            return c.free(ptr);
        }

        const unaligned_ptr = getHeader(ptr).*;
        c.free(unaligned_ptr);
    }

    fn alignedAllocSize(ptr: [*]u8) usize {
        if (supports_posix_memalign) {
            return EmscriptenAllocator.malloc_size(ptr);
        }

        const unaligned_ptr = getHeader(ptr).*;
        const delta = @ptrToInt(ptr) - @ptrToInt(unaligned_ptr);
        return EmscriptenAllocator.malloc_size(unaligned_ptr) - delta;
    }

    fn alloc(
        _: *anyopaque,
        len: usize,
        alignment: u29,
        len_align: u29,
        return_address: usize,
    ) error{OutOfMemory}![]u8 {
        _ = return_address;
        assert(len > 0);
        assert(std.math.isPowerOfTwo(alignment));

        var ptr = alignedAlloc(len, alignment) orelse return error.OutOfMemory;
        if (len_align == 0) {
            return ptr[0..len];
        }
        const full_len = init: {
            if (EmscriptenAllocator.supports_malloc_size) {
                const s = alignedAllocSize(ptr);
                assert(s >= len);
                break :init s;
            }
            break :init len;
        };
        return ptr[0..mem.alignBackwardAnyAlign(full_len, len_align)];
    }

    fn resize(
        _: *anyopaque,
        buf: []u8,
        buf_align: u29,
        new_len: usize,
        len_align: u29,
        return_address: usize,
    ) ?usize {
        _ = buf_align;
        _ = return_address;
        if (new_len <= buf.len) {
            return mem.alignAllocLen(buf.len, new_len, len_align);
        }
        if (EmscriptenAllocator.supports_malloc_size) {
            const full_len = alignedAllocSize(buf.ptr);
            if (new_len <= full_len) {
                return mem.alignAllocLen(full_len, new_len, len_align);
            }
        }
        return null;
    }

    fn free(
        _: *anyopaque,
        buf: []u8,
        buf_align: u29,
        return_address: usize,
    ) void {
        _ = buf_align;
        _ = return_address;
        alignedFree(buf.ptr);
    }
};
