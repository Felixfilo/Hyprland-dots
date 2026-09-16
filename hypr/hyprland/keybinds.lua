local vars = require("variables")
local fn   = require("utils.functions")


-- Flags
local locked           = { locked = true }
local mouse            = { mouse = true }
local release          = { release = true }
local repeating        = { repeating = true }
local locked_repeating = { locked = true, repeating = true }


local function normalise_key(key)
    return key:gsub("%s+", ""):lower()
end


local function valid_keybind(key)
    return type(key) == "string" and key:match("%S") ~= nil
end


local function repeating_unless_mouse(key)
    return not normalise_key(key):find("mouse", 1, true)
        and repeating
        or nil
end


local function flatten_keybinds(keybinds, keys)
    keys = keys or {}

    if type(keybinds) == "table" then
        for _, keybind in pairs(keybinds) do
            flatten_keybinds(keybind, keys)
        end
    elseif valid_keybind(keybinds) then
        keys[#keys + 1] = keybinds
    end

    return keys
end


local function create_bind(keybinds, action, flags, description)
    local get_flags = type(flags) == "function" and flags or function()
        return flags
    end

    for _, key in ipairs(flatten_keybinds(keybinds)) do
        local options = get_flags(key) or {}
        local bind_options = {}

        for name, value in pairs(options) do
            bind_options[name] = value
        end

        bind_options.description = description or bind_options.description or ("Keybind: " .. key)
        hl.bind(key, action, bind_options)
    end
end


local function extend_keybind(base, suffix)
    return valid_keybind(base)
        and base .. " + " .. suffix
        or nil
end


-- ============================================================
-- NOCTALIA
-- ============================================================

-- Launcher
local launcher_default = normalise_key("SUPER + SUPER_L")

create_bind(
    vars.kbLauncher,
    hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"),
    function(key)
        return normalise_key(key) == launcher_default
            and release
            or nil
    end,
    "Open launcher"
)


-- Session menu / logout / shutdown / reboot
create_bind(
    vars.kbSession,
    hl.dsp.exec_cmd("noctalia msg settings-open session"),
    nil,
    "Open session settings"
)


-- Control center
create_bind(
    vars.kbShowSidebar,
    hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"),
    nil,
    "Open control center"
)


-- Clear active notifications
create_bind(
    vars.kbClearNotifs,
    hl.dsp.exec_cmd("noctalia msg notification-clear-active"),
    locked,
    "Clear notifications"
)


-- Show panels / control center
create_bind(
    vars.kbShowPanels,
    hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"),
    nil,
    "Toggle panels"
)


-- Lock screen
create_bind(
    vars.kbLock,
    hl.dsp.exec_cmd("noctalia msg session lock"),
    locked,
    "Lock screen"
)


-- Keybind cheatsheet
create_bind(
    vars.kbCheatsheet,
    hl.dsp.exec_cmd("noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"),
    nil,
    "Toggle keybind cheatsheet"
)


-- Settings
create_bind(
    vars.kbSettings,
    hl.dsp.exec_cmd("noctalia shell settings"),
    nil,
    "Open Noctalia settings"
)


-- ============================================================
-- NOCTALIA RESTART
-- ============================================================

create_bind(
    "CTRL + SUPER + SHIFT + R",
    hl.dsp.exec_cmd("pkill noctalia"),
    release
)

create_bind(
    "CTRL + SUPER + ALT + R",
    hl.dsp.exec_cmd("pkill noctalia; sleep 0.2; noctalia"),
    release
)


-- ============================================================
-- WORKSPACES
-- ============================================================

for i = 1, 10 do
    local key = i % 10

    create_bind(
        extend_keybind(vars.kbGoToWs, key),
        fn.wsaction("focus", "", i)
    )

    create_bind(
        extend_keybind(vars.kbMoveWinToWs, key),
        fn.wsaction("move", "", i)
    )

    create_bind(
        extend_keybind(vars.kbGoToWsGroup, key),
        fn.wsaction("focus", "group", i)
    )

    create_bind(
        extend_keybind(vars.kbMoveWinToWsGroup, key),
        fn.wsaction("move", "group", i)
    )
end


-- Workspace -1/+1
create_bind(
    vars.kbPrevWs,
    hl.dsp.focus({ workspace = "-1" }),
    repeating_unless_mouse
)

create_bind(
    vars.kbNextWs,
    hl.dsp.focus({ workspace = "+1" }),
    repeating_unless_mouse
)


-- Workspace group -1/+1
create_bind(
    vars.kbPrevWsGroup,
    hl.dsp.focus({ workspace = "-10" }),
    repeating_unless_mouse
)

create_bind(
    vars.kbNextWsGroup,
    hl.dsp.focus({ workspace = "+10" }),
    repeating_unless_mouse
)


-- Move window to workspace -1/+1
create_bind(
    vars.kbMoveWinToWsNext,
    hl.dsp.window.move({ workspace = "+1" }),
    repeating_unless_mouse
)

create_bind(
    vars.kbMoveWinToWsPrev,
    hl.dsp.window.move({ workspace = "-1" }),
    repeating_unless_mouse
)


-- Special workspace
create_bind(
    vars.kbMoveWinToWsSpecial,
    hl.dsp.window.move({
        workspace = "special:special"
    })
)

create_bind(
    vars.kbMoveWinFromWsSpecial,
    hl.dsp.window.move({
        workspace = "e+0"
    })
)


-- ============================================================
-- WINDOW GROUPS
-- ============================================================

create_bind(
    vars.kbWindowCycleNext,
    hl.dsp.window.cycle_next(),
    repeating
)

create_bind(
    vars.kbWindowCyclePrev,
    hl.dsp.window.cycle_next({
        next = false
    }),
    repeating
)

create_bind(
    vars.kbWindowGroupCycleNext,
    hl.dsp.group.next(),
    repeating
)

create_bind(
    vars.kbWindowGroupCyclePrev,
    hl.dsp.group.prev(),
    repeating
)

create_bind(
    vars.kbToggleGroup,
    hl.dsp.group.toggle()
)

create_bind(
    vars.kbUngroup,
    hl.dsp.window.move({
        out_of_group = true
    })
)

create_bind(
    vars.kbGroupLockActive,
    hl.dsp.group.lock_active()
)


-- ============================================================
-- WINDOW ACTIONS
-- ============================================================

for _, dir in ipairs({
    "left",
    "right",
    "up",
    "down"
}) do

    create_bind(
        "SUPER + " .. dir,
        hl.dsp.focus({
            direction = dir
        })
    )

    create_bind(
        "SUPER + SHIFT + " .. dir,
        hl.dsp.window.move({
            direction = dir
        })
    )

end


create_bind(
    vars.kbWindowDecreaseWidth,
    fn.resize_active_window(-10, 0),
    repeating
)

create_bind(
    vars.kbWindowIncreaseWidth,
    fn.resize_active_window(10, 0),
    repeating
)

create_bind(
    vars.kbWindowDecreaseHeight,
    fn.resize_active_window(0, -10),
    repeating
)

create_bind(
    vars.kbWindowIncreaseHeight,
    fn.resize_active_window(0, 10),
    repeating
)


create_bind(
    { vars.kbMoveWindow, "SUPER + mouse:272" },
    hl.dsp.window.drag(),
    mouse
)

create_bind(
    { vars.kbResizeWindow, "SUPER + mouse:273" },
    hl.dsp.window.resize(),
    mouse
)


create_bind(
    vars.kbCenterWindow,
    hl.dsp.window.center()
)


create_bind(
    vars.kbNormalizeWindow,
    function()

        hl.dispatch(
            hl.dsp.window.resize(
                fn.resize_by_screen(55, 70)
            )
        )

        hl.dispatch(
            hl.dsp.window.center()
        )

    end
)


create_bind(
    vars.kbWindowPip,
    function()

        local a = hl.get_active_window()

        if a then

            local pip = fn.move_actions(a) or {}

            if not a.floating then
                table.insert(
                    pip,
                    1,
                    hl.dsp.window.float()
                )
            end

            table.insert(
                pip,
                hl.dsp.window.pin({
                    action = "on",
                    window = "address:" .. a.address
                })
            )

            for _, x in ipairs(pip) do
                hl.dispatch(x)
            end

        end

    end
)


create_bind(
    vars.kbPinWindow,
    hl.dsp.window.pin()
)

create_bind(
    vars.kbWindowFullscreen,
    hl.dsp.window.fullscreen({
        mode = "fullscreen"
    })
)

create_bind(
    vars.kbWindowBorderedFullscreen,
    hl.dsp.window.fullscreen({
        mode = "maximized"
    })
)

create_bind(
    vars.kbToggleWindowFloating,
    hl.dsp.window.float()
)

create_bind(
    vars.kbCloseWindow,
    hl.dsp.window.close()
)


-- ============================================================
-- SPECIAL WORKSPACES
-- ============================================================

create_bind(
    vars.kbSpecialWs,
    fn.toggle("specialws")
)

create_bind(
    vars.kbSystemMonitorWs,
    fn.toggle("sysmon")
)

create_bind(
    vars.kbMusicWs,
    fn.toggle("music")
)

create_bind(
    vars.kbCommunicationWs,
    fn.toggle("communication")
)

create_bind(
    vars.kbTodoWs,
    fn.toggle("todo")
)


-- ============================================================
-- APPLICATIONS
-- ============================================================

create_bind(
    vars.kbTerminal,
    hl.dsp.exec_cmd(vars.terminal)
)

create_bind(
    vars.kbBrowser,
    hl.dsp.exec_cmd(vars.browser)
)

create_bind(
    vars.kbEditor,
    hl.dsp.exec_cmd(vars.editor)
)

create_bind(
    vars.kbOffice,
    hl.dsp.exec_cmd(vars.office)
)

create_bind(
    vars.kbFileExplorer,
    hl.dsp.exec_cmd(vars.fileExplorer)
)

create_bind(
    vars.kbAudioSettings,
    hl.dsp.exec_cmd(vars.audioSettings)
)


-- ============================================================
-- SCREENSHOTS
-- ============================================================

-- Fullscreen screenshot
create_bind(
    vars.kbScreenshot,
    hl.dsp.exec_cmd(
        "noctalia msg screenshot-fullscreen"
    ),
    locked
)


-- Interactive region screenshot
create_bind(
    vars.kbScreenshotRegion,
    hl.dsp.exec_cmd(
        "noctalia msg screenshot-region"
    )
)


-- Screenshot freeze
-- Noctalia has no separate freeze command.
-- Use fullscreen screenshot.
create_bind(
    vars.kbScreenshotFreeze,
    hl.dsp.exec_cmd(
        "noctalia msg screenshot-fullscreen"
    )
)


-- ============================================================
-- SCREEN RECORDING
-- ============================================================

-- Recording is NOT provided by Noctalia.
-- Keep your existing recording program here if installed.

create_bind(
    vars.kbRecord,
    hl.dsp.exec_cmd(
        "wf-recorder"
    )
)

create_bind(
    vars.kbRecordSound,
    hl.dsp.exec_cmd(
        "wf-recorder -a"
    )
)

create_bind(
    vars.kbRecordRegion,
    hl.dsp.exec_cmd(
        "slurp | wf-recorder -g -"
    )
)


-- Color picker
create_bind(
    vars.kbColorPicker,
    hl.dsp.exec_cmd(
        "hyprpicker -a"
    )
)


-- ============================================================
-- BRIGHTNESS
-- ============================================================

create_bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd(
        "noctalia msg brightness-up"
    ),
    locked
)

create_bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd(
        "noctalia msg brightness-down"
    ),
    locked
)


-- ============================================================
-- MEDIA
-- ============================================================

create_bind(
    {
        vars.kbMediaToggle,
        "XF86AudioPlay",
        "XF86AudioPause"
    },
    hl.dsp.exec_cmd(
        "noctalia msg media toggle"
    ),
    locked
)

create_bind(
    {
        vars.kbMediaNext,
        "XF86AudioNext"
    },
    hl.dsp.exec_cmd(
        "noctalia msg media next"
    ),
    locked
)

create_bind(
    {
        vars.kbMediaPrev,
        "XF86AudioPrev"
    },
    hl.dsp.exec_cmd(
        "noctalia msg media previous"
    ),
    locked
)

create_bind(
    {
        vars.kbMediaStop,
        "XF86AudioStop"
    },
    hl.dsp.exec_cmd(
        "noctalia msg media stop"
    ),
    locked
)


-- ============================================================
-- VOLUME
-- ============================================================

create_bind(
    {
        vars.kbVolumeMute,
        "XF86AudioMute"
    },
    hl.dsp.exec_cmd(
        "noctalia msg volume-mute"
    ),
    locked
)

create_bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd(
        "noctalia msg mic-mute"
    ),
    locked
)


create_bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "noctalia msg volume-up " ..
        vars.volumeStep
    ),
    locked_repeating
)

create_bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "noctalia msg volume-down " ..
        vars.volumeStep
    ),
    locked_repeating
)


-- ============================================================
-- SLEEP
-- ============================================================

create_bind(
    vars.kbSleep,
    hl.dsp.exec_cmd(
        vars.sleepGestureCmd
    ),
    locked
)


-- ============================================================
-- CLIPBOARD
-- ============================================================

-- Noctalia v5 exposes clipboard management,
-- but NOT a clipboard-history picker through `noctalia msg`.
--
-- Therefore do NOT use cliphist here.

create_bind(
    vars.kbClipboard,
    hl.dsp.exec_cmd(
        "noctalia msg panel-toggle clipboard"
    )
)

create_bind(
    vars.kbClipboardDel,
    hl.dsp.exec_cmd(
        "noctalia msg clipboard-clear"
    )
)


-- ============================================================
-- EMOJI
-- ============================================================

-- Noctalia v5 does not expose an emoji-picker command
-- through `noctalia msg`.
--
-- Keep your preferred emoji picker here if installed.


-- ============================================================
-- TESTING
-- ============================================================

create_bind(
    "SUPER + ALT + F12",
    hl.dsp.exec_cmd(
        "notify-send -u low " ..
        "-i dialog-information-symbolic " ..
        "'Test notification' " ..
        [["Here's a really long message to test truncation and wrapping\nYou can middle click or flick this notification to dismiss it!"]] ..
        " -a 'Shell' " ..
        "-A 'Test1=I got it!' " ..
        "-A 'Test2=Another action'"
    )
)