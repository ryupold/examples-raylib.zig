//! Zig version of: https://www.raylib.com/examples/physics/loader.html?name=physics_demo

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("raylib");

const PhysicsBody = raylib.PhysicsBodyData;

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 800;
const screenHeight: i32 = 450;

var logoX: i32 = 10;
const logoY: i32 = 15;

fn init(_: std.mem.Allocator) !void {
    raylib.SetConfigFlags(.FLAG_MSAA_4X_HINT);
    raylib.InitWindow(screenWidth, screenHeight, "raylib [physac] example - physics demo");

    logoX = screenWidth - raylib.MeasureText("Physac", 30) - 10;

    raylib.InitPhysics();

    // rectangle floor
    var floor = raylib.CreatePhysicsBodyRectangle(
        .{ .x = @as(f32, @floatFromInt(screenWidth)) / 2, .y = @as(f32, @floatFromInt(screenHeight)) },
        500,
        100,
        10,
    );
    // Disable body state to convert it to static (no dynamics, but collisions)
    floor.enabled = false;

    // static circle in the middle
    var circle = raylib.CreatePhysicsBodyCircle(
        .{ .x = @as(f32, @floatFromInt(screenWidth)) / 2, .y = @as(f32, @floatFromInt(screenHeight)) / 2 },
        45,
        10,
    );
    circle.enabled = false;

    raylib.SetTargetFPS(60);
}

fn update(_: f32) !void {
    raylib.UpdatePhysics();

    if (raylib.IsKeyPressed(.KEY_R)) {
        raylib.ResetPhysics();
        var floor = raylib.CreatePhysicsBodyRectangle(.{ .x = @as(f32, @floatFromInt(screenWidth)) / 2, .y = @as(f32, @floatFromInt(screenHeight)) }, 500, 100, 10);
        floor.enabled = false;
        var circle = raylib.CreatePhysicsBodyCircle(.{ .x = @as(f32, @floatFromInt(screenWidth)) / 2, .y = @as(f32, @floatFromInt(screenHeight)) / 2 }, 45, 10);
        circle.enabled = false;
    }

    // Physics body creation inputs
    if (raylib.IsMouseButtonPressed(.MOUSE_BUTTON_LEFT)) {
        _ = raylib.CreatePhysicsBodyPolygon(
            raylib.GetMousePosition(),
            @as(f32, @floatFromInt(raylib.GetRandomValue(20, 80))),
            raylib.GetRandomValue(3, 8),
            10,
        );
    } else if (raylib.IsMouseButtonPressed(.MOUSE_BUTTON_RIGHT)) {
        _ = raylib.CreatePhysicsBodyCircle(
            raylib.GetMousePosition(),
            @as(f32, @floatFromInt(raylib.GetRandomValue(10, 45))),
            10,
        );
    }

    // Destroy falling physics bodies
    var bodiesCount = raylib.GetPhysicsBodiesCount() - 1;
    while (bodiesCount >= 0) : (bodiesCount -= 1) {
        if (raylib.GetPhysicsBody(bodiesCount)) |body| {
            if (body.position.y > @as(f32, @floatFromInt(screenHeight * 2))) {
                raylib.DestroyPhysicsBody(body);
            }
        }
    }

    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.BLACK);

        raylib.DrawFPS(screenWidth - 90, screenHeight - 30);
        bodiesCount = raylib.GetPhysicsBodiesCount();
        while (bodiesCount >= 0) : (bodiesCount -= 1) {
            if (raylib.GetPhysicsBody(bodiesCount)) |body| {
                const vertexCount = raylib.GetPhysicsShapeVerticesCount(bodiesCount);
                var j: i32 = 0;
                while (j < vertexCount) : (j += 1) {
                    // Get physics bodies shape vertices to draw lines
                    // Note: GetPhysicsShapeVertex() already calculates rotation transformations
                    const vertexA = raylib.GetPhysicsShapeVertex(body, j);
                    // Get next vertex or first to close the shape
                    const jj = (if ((j + 1) < vertexCount) (j + 1) else 0);
                    const vertexB = raylib.GetPhysicsShapeVertex(body, jj);
                    raylib.DrawLineV(vertexA, vertexB, raylib.GREEN);
                }
            }
        }

        raylib.DrawText("Left mouse button to create a polygon", 10, 10, 10, raylib.WHITE);
        raylib.DrawText("Right mouse button to create a circle", 10, 25, 10, raylib.WHITE);
        raylib.DrawText("Press 'R' to reset example", 10, 40, 10, raylib.WHITE);
        raylib.DrawText("Physac", logoX, logoY, 30, raylib.WHITE);
        raylib.DrawText("Powered by", logoX + 50, logoY - 7, 10, raylib.WHITE);
    }
}

fn deinit() void {
    raylib.ClosePhysics();
    raylib.CloseWindow();
}
