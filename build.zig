const std = @import("std");
const fs = std.fs;

pub const APP_NAME = "raylib-zig-examples";

const raylibSrc = "src/raylib/raylib/src/";
const emscriptenSrc = "src/raylib/emscripten/";
const marshalSrc = "src/raylib/marshal/";
const webOutdir = "zig-out/web/";

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    switch (target.getOsTag()) {
        .wasi, .emscripten => {
            std.log.info("building for emscripten\n", .{});
            if (b.sysroot == null) {
                // std.log.err("Please build with 'zig build -Dtarget=wasm32-emscripten --sysroot [path/to/emsdk]/upstream/emscripten/cache/sysroot", .{});
                std.log.err("Please build with 'zig build -Dtarget=wasm32-wasi --sysroot \"$EMSDK/upstream/emscripten\"", .{});
                @panic("error.SysRootExpected");
            }
            const lib = b.addStaticLibrary(APP_NAME, "src/web.zig");
            lib.addIncludeDir(raylibSrc);

            const outdir = webOutdir;

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

            // fs.cwd().deleteTree(outdir) catch {};
            fs.cwd().makePath(outdir) catch {};

            const warnings = ""; //-Wall

            const rcoreO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rcore.c", "-o", outdir ++ "rcore.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const rshapesO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rshapes.c", "-o", outdir ++ "rshapes.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const rtexturesO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rtextures.c", "-o", outdir ++ "rtextures.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const rtextO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rtext.c", "-o", outdir ++ "rtext.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const rmodelsO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "rmodels.c", "-o", outdir ++ "rmodels.o", "-Os", warnings, "-DPLATFORM_WEB", "-DGRAPHICS_API_OPENGL_ES2" });
            const utilsO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "utils.c", "-o", outdir ++ "utils.o", "-Os", warnings, "-DPLATFORM_WEB" });
            const raudioO = b.addSystemCommand(&.{ emcc_path, "-Os", warnings, "-c", raylibSrc ++ "raudio.c", "-o", outdir ++ "raudio.o", "-Os", warnings, "-DPLATFORM_WEB" });
            const libraylibA = b.addSystemCommand(&.{
                emar_path,
                "rcs",
                outdir ++ "libraylib.a",
                outdir ++ "rcore.o",
                outdir ++ "rshapes.o",
                outdir ++ "rtextures.o",
                outdir ++ "rtext.o",
                outdir ++ "rmodels.o",
                outdir ++ "utils.o",
                outdir ++ "raudio.o",
            });
            const emranlib = b.addSystemCommand(&.{
                emranlib_path,
                outdir ++ "libraylib.a",
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
            _ = fs.cwd().statFile(outdir ++ "libraylib.a") catch {
                lib.step.dependOn(&emranlib.step);
            };

            //--- from:  https://github.com/floooh/pacman.zig/blob/main/build.zig -----------------
            // var wasm32 = target;
            // wasm32.os_tag = .emscripten;
            lib.setTarget(target);
            lib.setBuildMode(mode);
            lib.defineCMacro("__EMSCRIPTEN__", "1");
            std.log.info("emscripten include path: {s}", .{include_path});
            lib.addIncludeDir(include_path);
            lib.addIncludeDir(emscriptenSrc);
            lib.addIncludeDir(marshalSrc);
            lib.addIncludeDir(raylibSrc);
            lib.addIncludeDir(raylibSrc ++ "extras/");

            lib.setOutputDir(outdir);
            lib.install();

            const shell = switch (mode) {
                .Debug => emscriptenSrc ++ "shell.html",
                else => emscriptenSrc ++ "minshell.html",
            };

            const emcc = b.addSystemCommand(&.{
                emcc_path,
                "-o",
                outdir ++ "game.html",
                emscriptenSrc ++ "entry.c",
                // marshalSrc ++ "raylib_marshall.c",
                // marshalSrc ++ "raylib_marshall_gen.c",
                // outdir ++ "libraylib.a",
                outdir ++ "lib" ++ APP_NAME ++ ".a",
                "-I.",
                "-I" ++ raylibSrc,
                "-I" ++ emscriptenSrc,
                // "-I" ++ marshalSrc,
                "-L.",
                "-L" ++ outdir,
                "-lraylib",
                "-l" ++ APP_NAME,
                "--shell-file",
                shell,
                "-DPLATFORM_WEB",
                "-sUSE_GLFW=3",
                // "-sWASM=0",
                "-sALLOW_MEMORY_GROWTH=1",
                //"-sTOTAL_MEMORY=1024MB",
                "-sASYNCIFY",
                "-sFORCE_FILESYSTEM=1",
                "-sASSERTIONS=1",
                "--memory-init-file",
                "0",
                "--preload-file",
                "assets",
                "--source-map-base",
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
        },
        else => {
            std.log.info("building for desktop\n", .{});
            const exe = b.addExecutable(APP_NAME, "src/desktop.zig");
            exe.setTarget(target);
            exe.setBuildMode(mode);

            const rayBuild = @import("src/raylib/raylib/src/build.zig");
            const raylib = rayBuild.addRaylib(b, target);
            exe.linkLibrary(raylib);
            exe.addIncludeDir(raylibSrc);
            exe.addIncludeDir(raylibSrc ++ "extras/");
            // exe.addIncludeDir(marshalSrc);
            // exe.addCSourceFile(marshalSrc ++ "raylib_marshall.c", &.{});
            // exe.addCSourceFile(marshalSrc ++ "raylib_marshall_gen.c", &.{});

            switch (raylib.target.getOsTag()) {
                //dunno why but macos target needs sometimes 2 tries to build
                .macos => {
                    exe.linkFramework("Foundation");
                    exe.linkFramework("Cocoa");
                    exe.linkFramework("OpenGL");
                    exe.linkFramework("CoreAudio");
                    exe.linkFramework("CoreVideo");
                    exe.linkFramework("IOKit");
                },
                else => {},
            }

            exe.linkLibC();
            exe.install();

            const run_cmd = exe.run();
            run_cmd.step.dependOn(b.getInstallStep());
            if (b.args) |args| {
                run_cmd.addArgs(args);
            }

            const run_step = b.step("run", "Run the app");
            run_step.dependOn(&run_cmd.step);
        },
    }

    const exe_tests = b.addTest("src/desktop.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
