local home = os.getenv("HOME")
local hypr = home .. "/.config/hypr"


-- Create a file if it doesn't exist, optionally with initial content
local function maybe_create(file, content)
    local f = io.open(file)

    if f then
        f:close()
        return
    end

    f = io.open(file, "w")

    if f then
        if content then
            f:write(content)
        end

        f:close()
    end
end


-- Copy src to dst, but only if dst doesn't already exist
local function maybe_copy(src, dst)
    local out = io.open(dst)

    if out then
        out:close()
        return
    end

    local input = io.open(src, "r")

    if not input then
        return
    end

    out = io.open(dst, "w")

    if out then
        out:write(input:read("*a"))
        out:close()
    end

    input:close()
end


-- Maybe set current colours to defaults
maybe_copy(
    hypr .. "/scheme/default.lua",
    hypr .. "/scheme/current.lua"
)


-- User variables
if type(overrides) == "table" then
    local vars = require("variables")

    for k, v in pairs(overrides) do
        vars[k] = v
    end
end


-- Default monitor configuration
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 1 })


-- Load Hyprland configuration modules
require("hyprland.env")
require("hyprland.general")
require("hyprland.input")
require("hyprland.decoration")
require("hyprland.animations")
require("hyprland.gestures")
require("hyprland.group")
require("hyprland.misc")
require("hyprland.rules")
require("hyprland.keybinds")
require("hyprland.execs")

-- For Noctalia Color templates
require("noctalia").apply_theme()
