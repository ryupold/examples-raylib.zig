//! Zig version of: https://github.com/raysan5/raygui/blob/bd4d2d860c2cc8bcf01565fc7068e6611f6d0738/examples/controls_test_suite/controls_test_suite.c

const std = @import("std");
const Example = @import("../example.zig").Example;
const raylib = @import("raylib");
const raygui = @import("raygui");

pub const example = Example{
    .initFn = init,
    .updateFn = update,
    .deinitFn = deinit,
};

const screenWidth: i32 = 690;
const screenHeight: i32 = 560;

// GUI controls initialization
//----------------------------------------------------------------------------------
var dropdownBox000Active: i32 = 0;
var dropDown000EditMode: bool = false;

var dropdownBox001Active: i32 = 0;
var dropDown001EditMode: bool = false;

var spinner001Value: i32 = 0;
var spinnerEditMode: bool = false;

var valueBox002Value: i32 = 0;
var valueBoxEditMode: bool = false;

var textBoxText = std.mem.zeroes([64]u8);
var textBoxEditMode: bool = false;

var listViewScrollIndex: i32 = 0;
var listViewActive: i32 = -1;

var listViewExScrollIndex: i32 = 0;
var listViewExActive: i32 = 2;
var listViewExFocus: i32 = -1;
var listViewExList: [8][:0]const u8 = .{
    "This",
    "is",
    "a",
    "list view",
    "with",
    "disable",
    "elements",
    "amazing!",
};

var multiTextBoxText = std.mem.zeroes([256]u8);
var multiTextBoxEditMode: bool = false;
var colorPickerValue: raylib.Color = raylib.WHITE;

var sliderValue: f32 = 50;
var sliderBarValue: f32 = 60;
var progressValue: f32 = 0.4;

var forceSquaredChecked: bool = false;

var alphaValue: f32 = 0.5;

var comboBoxActive: i32 = 1;

var toggleGroupActive: i32 = 0;

var viewScroll: raylib.Vector2 = .{};
//----------------------------------------------------------------------------------

// Custom GUI font loading
//Font font = LoadFontEx("fonts/rainyhearts16.ttf", 12, 0, 0);
//GuiSetFont(font);

var exitWindow = false;
var showMessageBox = false;

var textInput = std.mem.zeroes([256]u8);
var showTextInputBox = false;

var textInputFileName = std.mem.zeroes([256]u8);

//--------------------------------------------------------------------------------------

fn init(_: std.mem.Allocator) !void {
    raylib.InitWindow(screenWidth, screenHeight, "raygui - controls test suite");
    raylib.SetTargetFPS(60);
    raylib.SetExitKey(.KEY_NULL);

    std.mem.copyForwards(u8, &textBoxText, "Text box");
    std.mem.copyForwards(u8, &multiTextBoxText, "Multi text box");
}

fn update(_: f32) !void {
    var buf: [16 * 1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);

    // Update
    //----------------------------------------------------------------------------------
    {
        exitWindow = raylib.WindowShouldClose();

        if (raylib.IsKeyPressed(.KEY_ESCAPE)) showMessageBox = !showMessageBox;

        if (raylib.IsKeyDown(.KEY_LEFT_CONTROL) and raylib.IsKeyPressed(.KEY_S)) showTextInputBox = true;

        if (raylib.IsFileDropped()) {
            const droppedFiles = raylib.LoadDroppedFiles();

            if ((droppedFiles.count > 0) and raylib.IsFileExtension(droppedFiles.paths[0], ".rgs")) raygui.GuiLoadStyle(droppedFiles.paths[0]);

            raylib.UnloadDroppedFiles(droppedFiles); // Clear internal buffers
        }
    }
    //----------------------------------------------------------------------------------

    {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();

        raylib.ClearBackground(raylib.GetColor(@as(u32, @bitCast(raygui.GuiGetStyle(.DEFAULT, @intFromEnum(raygui.GuiDefaultProperty.BACKGROUND_COLOR))))));

        // raygui: controls drawing
        //----------------------------------------------------------------------------------
        if (dropDown000EditMode or dropDown001EditMode) {
            raygui.GuiLock();
        } else if (!dropDown000EditMode and !dropDown001EditMode) {
            raygui.GuiUnlock();
        }
        //GuiDisable();

        // First GUI column
        //GuiSetStyle(CHECKBOX, @enumToInt(raygui.GuiControlProperty.TEXT_ALIGNMENT), @enumToInt(raygui.GuiTextAlignment.TEXT_ALIGN_LEFT));
        _ = raygui.GuiCheckBox(.{ .x = 25, .y = 108, .width = 15, .height = 15 }, "FORCE CHECK!", &forceSquaredChecked);

        raygui.GuiSetStyle(@intFromEnum(raygui.GuiControl.TEXTBOX), @intFromEnum(raygui.GuiControlProperty.TEXT_ALIGNMENT), @intFromEnum(raygui.GuiTextAlignment.TEXT_ALIGN_CENTER));
        //GuiSetStyle(VALUEBOX, @enumToInt(raygui.GuiControlProperty.TEXT_ALIGNMENT), @enumToInt(raygui.GuiTextAlignment.TEXT_ALIGN_LEFT));
        if (raygui.GuiSpinner(.{ .x = 25, .y = 135, .width = 125, .height = 30 }, "", &spinner001Value, 0, 100, spinnerEditMode) != 0) {
            spinnerEditMode = !spinnerEditMode;
        }
        if (raygui.GuiValueBox(.{ .x = 25, .y = 175, .width = 125, .height = 30 }, "", &valueBox002Value, 0, 100, valueBoxEditMode) != 0) {
            valueBoxEditMode = !valueBoxEditMode;
        }
        raygui.GuiSetStyle(@intFromEnum(raygui.GuiControl.TEXTBOX), @intFromEnum(raygui.GuiControlProperty.TEXT_ALIGNMENT), @intFromEnum(raygui.GuiTextAlignment.TEXT_ALIGN_LEFT));
        if (raygui.GuiTextBox(.{ .x = 25, .y = 215, .width = 125, .height = 30 }, @as(?[*:0]u8, @ptrCast(&textBoxText)), 63, textBoxEditMode) != 0) {
            textBoxEditMode = !textBoxEditMode;
        }

        raygui.GuiSetStyle(@intFromEnum(raygui.GuiControl.BUTTON), @intFromEnum(raygui.GuiControlProperty.TEXT_ALIGNMENT), @intFromEnum(raygui.GuiTextAlignment.TEXT_ALIGN_CENTER));

        if (raygui.GuiButton(
            .{ .x = 25, .y = 255, .width = 125, .height = 30 },
            raygui.GuiIconText(@intFromEnum(raygui.GuiIconName.ICON_FILE_SAVE), "Save File"),
        ) != 0) {
            showTextInputBox = true;
        }

        _ = raygui.GuiGroupBox(.{ .x = 25, .y = 310, .width = 125, .height = 150 }, "STATES");
        //GuiLock();
        raygui.GuiSetState(.STATE_NORMAL);
        if (raygui.GuiButton(.{ .x = 30, .y = 320, .width = 115, .height = 30 }, "NORMAL") != 0) {}
        raygui.GuiSetState(.STATE_FOCUSED);
        if (raygui.GuiButton(.{ .x = 30, .y = 355, .width = 115, .height = 30 }, "FOCUSED") != 0) {}
        raygui.GuiSetState(.STATE_PRESSED);
        if (raygui.GuiButton(.{ .x = 30, .y = 390, .width = 115, .height = 30 }, "#15#PRESSED") != 0) {}
        raygui.GuiSetState(.STATE_DISABLED);
        if (raygui.GuiButton(.{ .x = 30, .y = 425, .width = 115, .height = 30 }, "DISABLED") != 0) {}
        raygui.GuiSetState(.STATE_NORMAL);
        //GuiUnlock();

        _ = raygui.GuiComboBox(.{ .x = 25, .y = 470, .width = 125, .height = 30 }, "ONE;TWO;THREE;FOUR", &comboBoxActive);

        // NOTE: GuiDropdownBox must draw after any other control that can be covered on unfolding
        raygui.GuiSetStyle(@intFromEnum(raygui.GuiControl.DROPDOWNBOX), @intFromEnum(raygui.GuiControlProperty.TEXT_ALIGNMENT), @intFromEnum(raygui.GuiTextAlignment.TEXT_ALIGN_LEFT));
        if (raygui.GuiDropdownBox(.{ .x = 25, .y = 65, .width = 125, .height = 30 }, "#01#ONE;#02#TWO;#03#THREE;#04#FOUR", &dropdownBox001Active, dropDown001EditMode) != 0) dropDown001EditMode = !dropDown001EditMode;

        raygui.GuiSetStyle(@intFromEnum(raygui.GuiControl.DROPDOWNBOX), @intFromEnum(raygui.GuiControlProperty.TEXT_ALIGNMENT), @intFromEnum(raygui.GuiTextAlignment.TEXT_ALIGN_CENTER));
        if (raygui.GuiDropdownBox(.{ .x = 25, .y = 25, .width = 125, .height = 30 }, "ONE;TWO;THREE", &dropdownBox000Active, dropDown000EditMode) != 0) dropDown000EditMode = !dropDown000EditMode;

        // Second GUI column
        _ = raygui.GuiListView(.{ .x = 165, .y = 25, .width = 140, .height = 140 }, "Charmander;Bulbasaur;#18#Squirtel;Pikachu;Eevee;Pidgey", &listViewScrollIndex, &listViewActive);
        //FIXME: crashes with Segmentation Fault on first string
        // listViewExActive = raygui.GuiListViewEx(.{ .x = 165, .y = 180, .width = 140, .height = 200 }, &listViewExList, 8, &listViewExFocus, &listViewExScrollIndex, listViewExActive);

        toggleGroupActive = raygui.GuiToggleGroup(.{ .x = 165, .y = 400, .width = 140, .height = 25 }, "#1#ONE\n#3#TWO\n#8#THREE\n#23#", &toggleGroupActive);

        _ = raygui.GuiSlider(.{ .x = 355, .y = 400, .width = 165, .height = 20 }, "TEST", try raylib.TextFormat(fba.allocator(), "{d}", .{sliderValue}), &sliderValue, -50, 100);
        _ = raygui.GuiSliderBar(.{ .x = 320, .y = 430, .width = 200, .height = 20 }, "", try raylib.TextFormat(fba.allocator(), "{d}", .{sliderBarValue}), &sliderBarValue, 0, 100);
        _ = raygui.GuiProgressBar(.{ .x = 320, .y = 460, .width = 200, .height = 20 }, "", "", &progressValue, 0, 1);

        // NOTE: View rectangle could be used to perform some scissor test
        var view = raygui.Rectangle{ .x = 560, .y = 25, .width = 100, .height = 160 };
        _ = raygui.GuiScrollPanel(.{ .x = 560, .y = 25, .width = 100, .height = 160 }, "", .{ .x = 560, .y = 25, .width = 200, .height = 400 }, &viewScroll, &view);

        _ = raygui.GuiPanel(.{ .x = 560, .y = 25 + 180, .width = 100, .height = 160 }, "Panel Info");

        var mouseCell = raygui.Vector2{ .x = 0, .y = 0 };
        _ = raygui.GuiGrid(.{ .x = 560, .y = 25 + 180 + 180, .width = 100, .height = 120 }, "", 20, 2, &mouseCell);

        _ = raygui.GuiStatusBar(.{ .x = 0, .y = @as(f32, @floatFromInt(raylib.GetScreenHeight() - 20)), .width = @as(f32, @floatFromInt(raylib.GetScreenWidth())), .height = 20 }, "This is a status bar");

        _ = raygui.GuiColorBarAlpha(.{ .x = 320, .y = 490, .width = 200, .height = 30 }, "", &alphaValue);

        if (showMessageBox) {
            raylib.DrawRectangle(0, 0, raylib.GetScreenWidth(), raylib.GetScreenHeight(), raylib.Fade(raylib.RAYWHITE, 0.8));
            const result = raygui.GuiMessageBox(.{ .x = @as(f32, @floatFromInt(raylib.GetScreenWidth())) / 2 - 125, .y = @as(f32, @floatFromInt(raylib.GetScreenHeight())) / 2 - 50, .width = 250, .height = 100 }, raygui.GuiIconText(@intFromEnum(raygui.GuiIconName.ICON_EXIT), "Close Window"), "Do you really want to exit?", "Yes;No");

            if ((result == 0) or (result == 2)) {
                showMessageBox = false;
            } else if (result == 1) {
                exitWindow = true;
                return error.Exit;
            }
        }

        if (showTextInputBox) {
            raylib.DrawRectangle(0, 0, raylib.GetScreenWidth(), raylib.GetScreenHeight(), raylib.Fade(raylib.RAYWHITE, 0.8));
            var secretViewActive = false;
            const result = raygui.GuiTextInputBox(
                .{ .x = @as(f32, @floatFromInt(raylib.GetScreenWidth())) / 2 - 120, .y = @as(f32, @floatFromInt(raylib.GetScreenHeight())) / 2 - 60, .width = 240, .height = 140 },
                "Save",
                raygui.GuiIconText(@intFromEnum(raygui.GuiIconName.ICON_FILE_SAVE), "Save file as..."),
                "Ok;Cancel",
                @as(?[*:0]u8, @ptrCast(&textInput)),
                255,
                &secretViewActive,
            );

            if (result == 1) {
                // TODO: Validate textInput value and save
                std.mem.copyForwards(u8, &textInputFileName, &textInput);
            }

            if ((result == 0) or (result == 1) or (result == 2)) {
                showTextInputBox = false;
                std.mem.copyForwards(u8, &textInput, &[_]u8{0});
            }
        }
    }
}

fn deinit() void {
    raylib.CloseWindow();
}
