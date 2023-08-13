const std = @import("std");
const fs = std.fs;
const exampleList = @import("src/examples.zig").exampleList;

pub const APP_NAME = "raylib-zig-examples";

const raylibSrc = "src/raylib/raylib/src/";
const rayguiSrc = "src/raygui/raygui/src/";
const raylibBindingSrc = "src/raylib/";
const rayguiBindingSrc = "src/raygui/";

pub fn build(b: *std.Build) !void {
    try promptExample();

    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardOptimizeOption(.{});

    switch (target.getOsTag()) {
        .wasi, .emscripten => {
            const emscriptenSrc = "src/raylib/emscripten/";
            const webCachedir = "zig-cache/web/";
            const webOutdir = "zig-out/web/";

            std.log.info("building for emscripten\n", .{});
            if (b.sysroot == null) {
                std.log.err("\n\nUSAGE: Please build with 'zig build -Doptimize=ReleaseSmall -Dtarget=wasm32-wasi --sysroot \"$EMSDK/upstream/emscripten\"'\n\n", .{});
                return error.SysRootExpected;
            }
            const lib = b.addStaticLibrary(.{
                .name = APP_NAME,
                .root_source_file = std.build.FileSource.relative("src/web.zig"),
                .optimize = mode,
                .target = target,
            });
            lib.addIncludePath(.{ .path = raylibSrc });
            lib.addIncludePath(.{ .path = rayguiSrc });

            const emcc_file = switch (b.host.target.os.tag) {
                .windows => "emcc.bat",
                else => "emcc",
            };
            const emar_file = switch (b.host.target.os.tag) {
                .windows => "emar.bat",
                else => "emar",
            };
            const emranlib_file = switch (b.host.target.os.tag) {
                .windows => "emranlib.bat",
                else => "emranlib",
            };

            const emcc_path = try fs.path.join(b.allocator, &.{ b.sysroot.?, emcc_file });
            defer b.allocator.free(emcc_path);
            const emranlib_path = try fs.path.join(b.allocator, &.{ b.sysroot.?, emranlib_file });
            defer b.allocator.free(emranlib_path);
            const emar_path = try fs.path.join(b.allocator, &.{ b.sysroot.?, emar_file });
            defer b.allocator.free(emar_path);
            const include_path = try fs.path.join(b.allocator, &.{ b.sysroot.?, "cache", "sysroot", "include" });
            defer b.allocator.free(include_path);

            fs.cwd().makePath(webCachedir) catch {};
            fs.cwd().makePath(webOutdir) catch {};

            const warnings = ""; //-Wall

            const rcoreO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rcore.c", "-o", webCachedir ++ "rcore.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const rshapesO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rshapes.c", "-o", webCachedir ++ "rshapes.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const rtexturesO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rtextures.c", "-o", webCachedir ++ "rtextures.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const rtextO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rtext.c", "-o", webCachedir ++ "rtext.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const rmodelsO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rmodels.c", "-o", webCachedir ++ "rmodels.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const utilsO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "utils.c", "-o", webCachedir ++ "utils.o", "-Os", warnings, "-DPLATFORM_WEB" });
            const raudioO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "raudio.c", "-o", webCachedir ++ "raudio.o", "-Os", warnings, "-DPLATFORM_WEB" });

            const libraylibA = b.addSystemCommand(&.{
                emar_path,
                "rcs",
                webCachedir ++ "libraylib.a",
                webCachedir ++ "rcore.o",
                webCachedir ++ "rshapes.o",
                webCachedir ++ "rtextures.o",
                webCachedir ++ "rtext.o",
                webCachedir ++ "rmodels.o",
                webCachedir ++ "utils.o",
                webCachedir ++ "raudio.o",
            });
            const emranlib = b.addSystemCommand(&.{
                emranlib_path,
                webCachedir ++ "libraylib.a",
            });

            libraylibA.step.dependOn(&rcoreO.step);
            libraylibA.step.dependOn(&rshapesO.step);
            libraylibA.step.dependOn(&rtexturesO.step);
            libraylibA.step.dependOn(&rtextO.step);
            libraylibA.step.dependOn(&rmodelsO.step);
            libraylibA.step.dependOn(&utilsO.step);
            libraylibA.step.dependOn(&raudioO.step);
            emranlib.step.dependOn(&libraylibA.step);

            //only build raylib if not already there
            _ = fs.cwd().statFile(webCachedir ++ "libraylib.a") catch {
                lib.step.dependOn(&emranlib.step);
            };

            lib.defineCMacro("__EMSCRIPTEN__", null);
            lib.defineCMacro("PLATFORM_WEB", null);
            std.log.info("emscripten include path: {s}", .{include_path});
            lib.addIncludePath(.{ .path = include_path });
            lib.addIncludePath(.{ .path = emscriptenSrc });
            lib.addIncludePath(.{ .path = raylibBindingSrc });
            lib.addIncludePath(.{ .path = rayguiBindingSrc });
            lib.addIncludePath(.{ .path = raylibSrc });
            lib.addIncludePath(.{ .path = rayguiSrc });
            lib.addIncludePath(.{ .path = raylibSrc ++ "extras/" });
            lib.addAnonymousModule("raylib", .{ .source_file = .{ .path = raylibBindingSrc ++ "raylib.zig" } });
            lib.addAnonymousModule("raygui", .{
                .source_file = .{ .path = rayguiBindingSrc ++ "raygui.zig" },
                .dependencies = &.{
                    .{ .name = "raylib", .module = lib.modules.get("raylib").? },
                },
            });

            const libraryOutputFolder = "zig-out/lib/";
            // this installs the lib (libraylib-zig-examples.a) to the `libraryOutputFolder` folder
            b.installArtifact(lib);

            const shell = switch (mode) {
                .Debug => emscriptenSrc ++ "shell.html",
                else => emscriptenSrc ++ "minshell.html",
            };

            const emcc = b.addSystemCommand(&.{
                emcc_path,
                "-o",
                webOutdir ++ "game.html",

                emscriptenSrc ++ "entry.c",
                raylibBindingSrc ++ "marshal.c",
                rayguiBindingSrc ++ "raygui_marshal.c",

                libraryOutputFolder ++ "lib" ++ APP_NAME ++ ".a",
                "-I.",
                "-I" ++ raylibSrc,
                "-I" ++ rayguiSrc,
                "-I" ++ emscriptenSrc,
                "-I" ++ raylibBindingSrc,
                "-I" ++ rayguiBindingSrc,
                "-L.",
                "-L" ++ webCachedir,
                "-L" ++ libraryOutputFolder,
                "-lraylib",
                "-l" ++ APP_NAME,
                "--shell-file",
                shell,
                "-DPLATFORM_WEB",
                "-DRAYGUI_IMPLEMENTATION",
                "-sUSE_GLFW=3",
                "-sWASM=1",
                "-sALLOW_MEMORY_GROWTH=1",
                "-sWASM_MEM_MAX=512MB", //going higher than that seems not to work on iOS browsers ¯\_(ツ)_/¯
                "-sTOTAL_MEMORY=512MB",
                "-sABORTING_MALLOC=0",
                "-sASYNCIFY",
                "-sFORCE_FILESYSTEM=1",
                "-sASSERTIONS=1",
                "--memory-init-file",
                "0",
                "--preload-file",
                "assets",
                "--source-map-base",
                "-O1",
                "-Os",
                // "-sLLD_REPORT_UNDEFINED",
                "-sERROR_ON_UNDEFINED_SYMBOLS=0",

                // optimizations
                "-O1",
                "-Os",

                // "-sUSE_PTHREADS=1",
                // "--profiling",
                // "-sTOTAL_STACK=128MB",
                // "-sMALLOC='emmalloc'",
                // "--no-entry",
                "-sEXPORTED_FUNCTIONS=['_malloc','_free','_main', '_emsc_main','_emsc_set_window_size']",
                "-sEXPORTED_RUNTIME_METHODS=ccall,cwrap",
            });

            emcc.step.dependOn(&lib.step);

            b.getInstallStep().dependOn(&emcc.step);
            //-------------------------------------------------------------------------------------

            std.log.info("\n\nOutput files will be in {s}\n---\ncd {s}\npython -m http.server\n---\n\nbuilding...", .{ webOutdir, webOutdir });
        },
        else => {
            std.log.info("building for desktop\n", .{});
            const exe = b.addExecutable(.{
                .name = APP_NAME,
                .root_source_file = std.build.FileSource.relative("src/desktop.zig"),
                .optimize = mode,
                .target = target,
            });

            const raylib = @import("src/raylib/build.zig");
            const raygui = @import("src/raygui/build.zig");
            raylib.addTo(b, exe, target, mode);
            raygui.addTo(b, exe, target, mode);

            switch (target.getOsTag()) {
                .macos => {
                    exe.linkFramework("Foundation");
                    exe.linkFramework("Cocoa");
                    exe.linkFramework("OpenGL");
                    exe.linkFramework("CoreAudio");
                    exe.linkFramework("CoreVideo");
                    exe.linkFramework("IOKit");
                },
                .linux => {
                    exe.addLibraryPath(.{ .path = "/usr/lib64/" });
                    exe.linkSystemLibrary("GL");
                    exe.linkSystemLibrary("rt");
                    exe.linkSystemLibrary("dl");
                    exe.linkSystemLibrary("m");
                    exe.linkSystemLibrary("X11");
                },
                else => {},
            }

            exe.linkLibC();
            b.installArtifact(exe);

            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(b.getInstallStep());
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            const run_step = b.step("run", "Run the app");
            run_step.dependOn(&run_cmd.step);
        },
    }
}

fn promptExample() !void {
    prompt: while (true) {
        var buf: [4069]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&buf);
        defer fba.reset();
        const output = std.io.getStdOut();
        var writer = output.writer();

        try writer.writeAll("\n\nExamples:\n--------------------------------------------------\n");
        for (exampleList, 0..) |example, i| {
            defer fba.reset();
            try writer.writeAll(try std.fmt.allocPrint(fba.allocator(), "{d}:\t{s}\n", .{ i + 1, example }));
        }
        try writer.writeAll("--------------------------------------------------\n\nSelect which example should be built: ");

        const input = std.io.getStdIn();
        var reader = input.reader();

        const option = reader.readUntilDelimiterOrEofAlloc(fba.allocator(), '\n', buf.len) catch continue;
        const nr = std.fmt.parseInt(usize, std.mem.trim(u8, option.?, " \t\n\r"), 10) catch |err| {
            std.log.err("{?} in input: {?s}", .{ err, option });
            continue;
        };
        fba.reset();

        for (exampleList, 1..) |example, i| {
            if (nr == i) {
                var load_example = try std.fs.cwd().createFile("src/load_example.zig", .{});
                defer load_example.close();
                try load_example.writeAll(try std.fmt.allocPrint(fba.allocator(), "pub const name = \"{s}\";\n", .{example}));
                break :prompt;
            }
        }
    }
}
