local vars = require("variables")

-- Direct readable binds.
hl.bind("SUPER + C", hl.dsp.exec_cmd(vars.editor), {
    description = "Open VS Code",
})

hl.bind("SUPER + B", hl.dsp.exec_cmd(vars.browser), {
    description = "Open browser",
})

hl.bind("SUPER + T", hl.dsp.exec_cmd(vars.terminal), {
    description = "Open terminal",
})

hl.bind("SUPER + E", hl.dsp.exec_cmd(vars.fileExplorer), {
    description = "Open file manager",
})

hl.bind("SUPER + Space", hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"), {
    description = "Open launcher",
})

hl.bind("SUPER + X", hl.dsp.exec_cmd("noctalia msg panel-toggle control-center"), {
    description = "Open control center",
})

hl.bind("SUPER + Comma", hl.dsp.exec_cmd("noctalia msg settings-toggle"), {
    description = "Toggle settings",
})

hl.bind("SUPER + L", hl.dsp.exec_cmd("noctalia msg session lock"), {
    description = "Lock screen",
})

hl.bind("SUPER + H", hl.dsp.exec_cmd("noctalia msg panel-toggle kenn/keybind-cheatsheet:cheatsheet"), {
    description = "Toggle keybind cheatsheet",
})

hl.bind("ALT + Tab", hl.dsp.window.cycle_next(), {
    description = "Cycle windows",
})

hl.bind("CTRL + ALT + C", hl.dsp.exec_cmd("noctalia msg notification-clear-active"), {
    description = "Clear notifications",
    locked = true,
})

hl.bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("pkill noctalia"), {
    description = "Restart Noctalia",
    release = true,
})

hl.bind("CTRL + SUPER + ALT + R", hl.dsp.exec_cmd("pkill noctalia; sleep 0.2; noctalia"), {
    description = "Restart and relaunch Noctalia",
    release = true,
})
