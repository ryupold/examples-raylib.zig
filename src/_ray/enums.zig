/// System/Window config flags
/// NOTE: Every bit registers one state (use it with bit masks)
/// By default all flags are set to 0
pub const ConfigFlags = enum(c_uint) {
    FLAG_NONE = 0,
    FLAG_VSYNC_HINT = 0x00000040, // Set to try enabling V-Sync on GPU
    FLAG_FULLSCREEN_MODE = 0x00000002, // Set to run program in fullscreen
    FLAG_WINDOW_RESIZABLE = 0x00000004, // Set to allow resizable window
    FLAG_WINDOW_UNDECORATED = 0x00000008, // Set to disable window decoration (frame and buttons)
    FLAG_WINDOW_HIDDEN = 0x00000080, // Set to hide window
    FLAG_WINDOW_MINIMIZED = 0x00000200, // Set to minimize window (iconify)
    FLAG_WINDOW_MAXIMIZED = 0x00000400, // Set to maximize window (expanded to monitor)
    FLAG_WINDOW_UNFOCUSED = 0x00000800, // Set to window non focused
    FLAG_WINDOW_TOPMOST = 0x00001000, // Set to window always on top
    FLAG_WINDOW_ALWAYS_RUN = 0x00000100, // Set to allow windows running while minimized
    FLAG_WINDOW_TRANSPARENT = 0x00000010, // Set to allow transparent framebuffer
    FLAG_WINDOW_HIGHDPI = 0x00002000, // Set to support HighDPI
    FLAG_MSAA_4X_HINT = 0x00000020, // Set to try enabling MSAA 4X
    FLAG_INTERLACED_HINT = 0x00010000, // Set to try enabling interlaced video format (for V3D)
};

/// Mouse buttons
pub const MouseButton = enum(c_int) {
    MOUSE_BUTTON_LEFT = 0, // Mouse button left
    MOUSE_BUTTON_RIGHT = 1, // Mouse button right
    MOUSE_BUTTON_MIDDLE = 2, // Mouse button middle (pressed wheel)
    MOUSE_BUTTON_SIDE = 3, // Mouse button side (advanced mouse device)
    MOUSE_BUTTON_EXTRA = 4, // Mouse button extra (advanced mouse device)
    MOUSE_BUTTON_FORWARD = 5, // Mouse button fordward (advanced mouse device)
    MOUSE_BUTTON_BACK = 6, // Mouse button back (advanced mouse device)
};

/// Mouse cursor
pub const MouseCursor = enum(c_int) {
    MOUSE_CURSOR_DEFAULT = 0, // Default pointer shape
    MOUSE_CURSOR_ARROW = 1, // Arrow shape
    MOUSE_CURSOR_IBEAM = 2, // Text writing cursor shape
    MOUSE_CURSOR_CROSSHAIR = 3, // Cross shape
    MOUSE_CURSOR_POINTING_HAND = 4, // Pointing hand cursor
    MOUSE_CURSOR_RESIZE_EW = 5, // Horizontal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NS = 6, // Vertical resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NWSE = 7, // Top-left to bottom-right diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_NESW = 8, // The top-right to bottom-left diagonal resize/move arrow shape
    MOUSE_CURSOR_RESIZE_ALL = 9, // The omni-directional resize/move cursor shape
    MOUSE_CURSOR_NOT_ALLOWED = 10, // The operation-not-allowed shape
};

// Gamepad buttons
pub const GamepadButton = enum(c_int) {
    GAMEPAD_BUTTON_UNKNOWN = 0, // Unknown button, just for error checking
    GAMEPAD_BUTTON_LEFT_FACE_UP, // Gamepad left DPAD up button
    GAMEPAD_BUTTON_LEFT_FACE_RIGHT, // Gamepad left DPAD right button
    GAMEPAD_BUTTON_LEFT_FACE_DOWN, // Gamepad left DPAD down button
    GAMEPAD_BUTTON_LEFT_FACE_LEFT, // Gamepad left DPAD left button
    GAMEPAD_BUTTON_RIGHT_FACE_UP, // Gamepad right button up (i.e. PS3: Triangle, Xbox: Y)
    GAMEPAD_BUTTON_RIGHT_FACE_RIGHT, // Gamepad right button right (i.e. PS3: Square, Xbox: X)
    GAMEPAD_BUTTON_RIGHT_FACE_DOWN, // Gamepad right button down (i.e. PS3: Cross, Xbox: A)
    GAMEPAD_BUTTON_RIGHT_FACE_LEFT, // Gamepad right button left (i.e. PS3: Circle, Xbox: B)
    GAMEPAD_BUTTON_LEFT_TRIGGER_1, // Gamepad top/back trigger left (first), it could be a trailing button
    GAMEPAD_BUTTON_LEFT_TRIGGER_2, // Gamepad top/back trigger left (second), it could be a trailing button
    GAMEPAD_BUTTON_RIGHT_TRIGGER_1, // Gamepad top/back trigger right (one), it could be a trailing button
    GAMEPAD_BUTTON_RIGHT_TRIGGER_2, // Gamepad top/back trigger right (second), it could be a trailing button
    GAMEPAD_BUTTON_MIDDLE_LEFT, // Gamepad center buttons, left one (i.e. PS3: Select)
    GAMEPAD_BUTTON_MIDDLE, // Gamepad center buttons, middle one (i.e. PS3: PS, Xbox: XBOX)
    GAMEPAD_BUTTON_MIDDLE_RIGHT, // Gamepad center buttons, right one (i.e. PS3: Start)
    GAMEPAD_BUTTON_LEFT_THUMB, // Gamepad joystick pressed button left
    GAMEPAD_BUTTON_RIGHT_THUMB, // Gamepad joystick pressed button right
};

// Gamepad axis
pub const GamepadAxis = enum(c_int) {
    GAMEPAD_AXIS_LEFT_X = 0, // Gamepad left stick X axis
    GAMEPAD_AXIS_LEFT_Y = 1, // Gamepad left stick Y axis
    GAMEPAD_AXIS_RIGHT_X = 2, // Gamepad right stick X axis
    GAMEPAD_AXIS_RIGHT_Y = 3, // Gamepad right stick Y axis
    GAMEPAD_AXIS_LEFT_TRIGGER = 4, // Gamepad back trigger left, pressure level: [1..-1]
    GAMEPAD_AXIS_RIGHT_TRIGGER = 5, // Gamepad back trigger right, pressure level: [1..-1]
};


/// Keyboard keys (US keyboard layout)
/// NOTE: Use GetKeyPressed() to allow redefining
/// required keys for alternative layouts
pub const KEY_NULL: i32 = 0; // Key: NULL, used for no key pressed
// Alphanumeric keys
pub const KEY_APOSTROPHE: i32 = 39; // Key: '
pub const KEY_COMMA: i32 = 44; // Key: ,
pub const KEY_MINUS: i32 = 45; // Key: -
pub const KEY_PERIOD: i32 = 46; // Key: .
pub const KEY_SLASH: i32 = 47; // Key: /
pub const KEY_ZERO: i32 = 48; // Key: 0
pub const KEY_ONE: i32 = 49; // Key: 1
pub const KEY_TWO: i32 = 50; // Key: 2
pub const KEY_THREE: i32 = 51; // Key: 3
pub const KEY_FOUR: i32 = 52; // Key: 4
pub const KEY_FIVE: i32 = 53; // Key: 5
pub const KEY_SIX: i32 = 54; // Key: 6
pub const KEY_SEVEN: i32 = 55; // Key: 7
pub const KEY_EIGHT: i32 = 56; // Key: 8
pub const KEY_NINE: i32 = 57; // Key: 9
pub const KEY_SEMICOLON: i32 = 59; // Key: ;
pub const KEY_EQUAL: i32 = 61; // Key: =
pub const KEY_A: i32 = 65; // Key: A | a
pub const KEY_B: i32 = 66; // Key: B | b
pub const KEY_C: i32 = 67; // Key: C | c
pub const KEY_D: i32 = 68; // Key: D | d
pub const KEY_E: i32 = 69; // Key: E | e
pub const KEY_F: i32 = 70; // Key: F | f
pub const KEY_G: i32 = 71; // Key: G | g
pub const KEY_H: i32 = 72; // Key: H | h
pub const KEY_I: i32 = 73; // Key: I | i
pub const KEY_J: i32 = 74; // Key: J | j
pub const KEY_K: i32 = 75; // Key: K | k
pub const KEY_L: i32 = 76; // Key: L | l
pub const KEY_M: i32 = 77; // Key: M | m
pub const KEY_N: i32 = 78; // Key: N | n
pub const KEY_O: i32 = 79; // Key: O | o
pub const KEY_P: i32 = 80; // Key: P | p
pub const KEY_Q: i32 = 81; // Key: Q | q
pub const KEY_R_OR_KEY_MENU: i32 = 82; // Key: R | r
pub const KEY_S: i32 = 83; // Key: S | s
pub const KEY_T: i32 = 84; // Key: T | t
pub const KEY_U: i32 = 85; // Key: U | u
pub const KEY_V: i32 = 86; // Key: V | v
pub const KEY_W: i32 = 87; // Key: W | w
pub const KEY_X: i32 = 88; // Key: X | x
pub const KEY_Y: i32 = 89; // Key: Y | y
pub const KEY_Z: i32 = 90; // Key: Z | z
pub const KEY_LEFT_BRACKET: i32 = 91; // Key: [
pub const KEY_BACKSLASH: i32 = 92; // Key: '\'
pub const KEY_RIGHT_BRACKET: i32 = 93; // Key: ]
pub const KEY_GRAVE: i32 = 96; // Key: `
// Function keys
pub const KEY_SPACE: i32 = 32; // Key: Space
pub const KEY_ESCAPE: i32 = 256; // Key: Esc
pub const KEY_ENTER: i32 = 257; // Key: Enter
pub const KEY_TAB: i32 = 258; // Key: Tab
pub const KEY_BACKSPACE: i32 = 259; // Key: Backspace
pub const KEY_INSERT: i32 = 260; // Key: Ins
pub const KEY_DELETE: i32 = 261; // Key: Del
pub const KEY_RIGHT: i32 = 262; // Key: Cursor right
pub const KEY_LEFT: i32 = 263; // Key: Cursor left
pub const KEY_DOWN: i32 = 264; // Key: Cursor down
pub const KEY_UP: i32 = 265; // Key: Cursor up
pub const KEY_PAGE_UP: i32 = 266; // Key: Page up
pub const KEY_PAGE_DOWN: i32 = 267; // Key: Page down
pub const KEY_HOME: i32 = 268; // Key: Home
pub const KEY_END: i32 = 269; // Key: End
pub const KEY_CAPS_LOCK: i32 = 280; // Key: Caps lock
pub const KEY_SCROLL_LOCK: i32 = 281; // Key: Scroll down
pub const KEY_NUM_LOCK: i32 = 282; // Key: Num lock
pub const KEY_PRINT_SCREEN: i32 = 283; // Key: Print screen
pub const KEY_PAUSE: i32 = 284; // Key: Pause
pub const KEY_F1: i32 = 290; // Key: F1
pub const KEY_F2: i32 = 291; // Key: F2
pub const KEY_F3: i32 = 292; // Key: F3
pub const KEY_F4: i32 = 293; // Key: F4
pub const KEY_F5: i32 = 294; // Key: F5
pub const KEY_F6: i32 = 295; // Key: F6
pub const KEY_F7: i32 = 296; // Key: F7
pub const KEY_F8: i32 = 297; // Key: F8
pub const KEY_F9: i32 = 298; // Key: F9
pub const KEY_F10: i32 = 299; // Key: F10
pub const KEY_F11: i32 = 300; // Key: F11
pub const KEY_F12: i32 = 301; // Key: F12
pub const KEY_LEFT_SHIFT: i32 = 340; // Key: Shift left
pub const KEY_LEFT_CONTROL: i32 = 341; // Key: Control left
pub const KEY_LEFT_ALT: i32 = 342; // Key: Alt left
pub const KEY_LEFT_SUPER: i32 = 343; // Key: Super left
pub const KEY_RIGHT_SHIFT: i32 = 344; // Key: Shift right
pub const KEY_RIGHT_CONTROL: i32 = 345; // Key: Control right
pub const KEY_RIGHT_ALT: i32 = 346; // Key: Alt right
pub const KEY_RIGHT_SUPER: i32 = 347; // Key: Super right
pub const KEY_KB_MENU: i32 = 348; // Key: KB menu
// Keypad keys
pub const KEY_KP_0: i32 = 320; // Key: Keypad 0
pub const KEY_KP_1: i32 = 321; // Key: Keypad 1
pub const KEY_KP_2: i32 = 322; // Key: Keypad 2
pub const KEY_KP_3: i32 = 323; // Key: Keypad 3
pub const KEY_KP_4: i32 = 324; // Key: Keypad 4
pub const KEY_KP_5: i32 = 325; // Key: Keypad 5
pub const KEY_KP_6: i32 = 326; // Key: Keypad 6
pub const KEY_KP_7: i32 = 327; // Key: Keypad 7
pub const KEY_KP_8: i32 = 328; // Key: Keypad 8
pub const KEY_KP_9: i32 = 329; // Key: Keypad 9
pub const KEY_KP_DECIMAL: i32 = 330; // Key: Keypad .
pub const KEY_KP_DIVIDE: i32 = 331; // Key: Keypad /
pub const KEY_KP_MULTIPLY: i32 = 332; // Key: Keypad *
pub const KEY_KP_SUBTRACT: i32 = 333; // Key: Keypad -
pub const KEY_KP_ADD: i32 = 334; // Key: Keypad +
pub const KEY_KP_ENTER: i32 = 335; // Key: Keypad Enter
pub const KEY_KP_EQUAL: i32 = 336; // Key: Keypad =
// Android key buttons
pub const KEY_BACK: i32 = 4; // Key: Android back button
// pub const KEY_MENU:i32 = 82; // Key: Android menu button
pub const KEY_VOLUME_UP: i32 = 24; // Key: Android volume up button
pub const KEY_VOLUME_DOWN: i32 = 25; // Key: Android volume down button
