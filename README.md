# raylib.zig examples

This is a collection of examples using the Zig raylib bindings of [raylib.zig](https://github.com/ryupold/raylib.zig)


## supported platforms
- Windows
- macOS
- Linux
- HTML5/WebGL (emscripten)

## examples
During build you will be asked which example should be executed. The example code can be found in `./src/examples`.

You can test the WebGL examples [here](https://ryupold.de/pages/raylib.zig/raylib.zig.html).

## BUILD

### dependencies
- git
- [zig (0.10.0)](https://ziglang.org/documentation/master/)
- [emscripten sdk](https://emscripten.org/)

```
git clone --recurse-submodules https://github.com/ryupold/examples-raylib.zig
```

### run locally

```sh
zig build run
```

### build for host os and architecture

```sh
zig build -Drelease-small
```

The output files will be in `./zig-out/bin`

### html5 / emscripten

```sh
EMSDK=../emsdk #path to emscripten sdk

zig build -Drelease-small -Dtarget=wasm32-wasi --sysroot "$EMSDK/upstream/emscripten"
```

The output files will be in `./zig-out/web/`

- game.html (entry point)
- game.js
- game.wasm
- game.data

The game data needs to be served with a webserver. Just opening the game.html in a browser won't work

You can utilize python as local http server:
```sh
python -m http.server
```