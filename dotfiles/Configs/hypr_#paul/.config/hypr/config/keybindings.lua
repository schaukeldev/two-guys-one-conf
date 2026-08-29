local hyper        = "CTRL + ALT + SUPER"
local hyperShift   = hyper .. " + SHIFT"
local workspaceMod = "SUPER"

local terminal    = "alacritty"
local browser     = "zen-beta"
local fileManager = "thunar"
local menu        = "hyprlauncher"

hl.bind(workspaceMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(workspaceMod .. " + adiaeresis", hl.dsp.exec_cmd(browser))
hl.bind(hyper .. " + Q",      hl.dsp.window.close())
hl.bind(hyper .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(hyper .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(hyper .. " + F",      hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(hyper .. " + R",      hl.dsp.exec_cmd(menu))
hl.bind(hyper .. " + P",      hl.dsp.window.pseudo())
hl.bind(hyperShift .. " + 7", hl.dsp.layout("togglesplit")) -- Slash on German Macintosh.

-- Preserve macOS Command+Q through keyd's Command layer.
hl.bind(workspaceMod .. " + Q", hl.dsp.window.close())

-- Focus movement.
hl.bind(hyper .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(hyper .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(hyper .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(hyper .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move the active window.
hl.bind(hyperShift .. " + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(hyperShift .. " + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(hyperShift .. " + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(hyperShift .. " + down",  hl.dsp.window.move({ direction = "d" }))

-- Resize in both dimensions, matching AeroSpace's smart resize keys.
hl.bind(hyper .. " + minus", hl.dsp.window.resize({ x = -50, y = -50, relative = true }), { repeating = true })
hl.bind(hyper .. " + plus",  hl.dsp.window.resize({ x = 50,  y = 50,  relative = true }), { repeating = true })

-- Workspaces 1-10.
for i = 1, 10 do
    local key = i % 10
    hl.bind(workspaceMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(workspaceMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad.
hl.bind(hyper .. " + S",      hl.dsp.workspace.toggle_special("magic"))
hl.bind(hyperShift .. " + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Workspace scrolling.
hl.bind(hyper .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(hyper .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse move/resize.
hl.bind(hyper .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(hyper .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Player controls. Old bindl = locked.
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
