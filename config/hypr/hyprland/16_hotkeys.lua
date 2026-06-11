local m = _G.mainMod
local term = _G.terminal
local fm = _G.fileManager
local menu = _G.menu

hl.bind(m .. " + RETURN", hl.dsp.exec_cmd(term))
hl.bind(m .. " + Q", hl.dsp.window.close())
hl.bind(m .. " + E", hl.dsp.exec_cmd(fm))
hl.bind(m .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(m .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(m .. " + P", hl.dsp.window.pseudo())
hl.bind(m .. " + F", hl.dsp.window.fullscreen())
hl.bind(m .. " + S", hl.dsp.exec_cmd("noctalia msg settings-open"))

-- Move focus
hl.bind(m .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(m .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(m .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(m .. " + down", hl.dsp.focus({ direction = "d" }))
hl.bind(m .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(m .. " + j", hl.dsp.focus({ direction = "d" }))
hl.bind(m .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(m .. " + l", hl.dsp.focus({ direction = "r" }))

-- Move windows
hl.bind(m .. " + SHIFT + left", hl.dsp.window.move({ direction = "l" }))
hl.bind(m .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(m .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
hl.bind(m .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))
hl.bind(m .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(m .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))
hl.bind(m .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(m .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(m .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(m .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Switch to next/prev
hl.bind(m .. " + ALT + h", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(m .. " + ALT + l", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(m .. " + ALT + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(m .. " + ALT + right", hl.dsp.focus({ workspace = "e+1" }))

-- Move current workspace to a different monitor
hl.bind(m .. " + SHIFT + bracketleft", hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(m .. " + SHIFT + bracketright", hl.dsp.workspace.move({ monitor = "r" }))

-- Resize windows (mainMod + ctrl)
hl.bind(m .. " + CTRL + left", hl.dsp.window.resize({ x = -60, y = 0, relative = true }))
hl.bind(m .. " + CTRL + right", hl.dsp.window.resize({ x = 60, y = 0, relative = true }))
hl.bind(m .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -60, relative = true }))
hl.bind(m .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 60, relative = true }))
hl.bind(m .. " + CTRL + h", hl.dsp.window.resize({ x = -60, y = 0, relative = true }))
hl.bind(m .. " + CTRL + j", hl.dsp.window.resize({ x = 0, y = 60, relative = true }))
hl.bind(m .. " + CTRL + k", hl.dsp.window.resize({ x = 0, y = -60, relative = true }))
hl.bind(m .. " + CTRL + l", hl.dsp.window.resize({ x = 60, y = 0, relative = true }))

-- Scroll workspaces
hl.bind(m .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(m .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- show bar on hold mod key
-- hl.bind("SUPER_L", hl.dsp.exec_cmd("noctalia msg bar-show"))

-- -- Hide bar when Super is released
-- hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("noctalia msg  bar-hide"), { release = true })


-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("noctalia msg screenshot-region"))

-- Volume control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("noctalia msg volume-up"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("noctalia msg volume-down"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("noctalia msg volume-mute"))
hl.bind(m .. " + Next", hl.dsp.exec_cmd("noctalia msg media next"))
hl.bind(m .. " + Prior", hl.dsp.exec_cmd("noctalia msg media previous"))
hl.bind("Pause", hl.dsp.exec_cmd("noctalia msg media toggle"))

-- Brightness control
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("noctalia msg brightness-up all"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down all"))

-- Move/resize with mouse
hl.bind(m .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(m .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- hyprswitch
-- local key = "tab"
-- local reverse = "SHIFT"
-- hl.bind(
-- 	m .. " + " .. key,
-- 	hl.dsp.exec_cmd(
-- 		"hyprswitch gui --mod-key "
-- 			.. m
-- 			.. " --key "
-- 			.. key
-- 			.. " --close mod-key-release --reverse-key=mod="
-- 			.. reverse
-- 			.. " --switch-type workspace && hyprswitch dispatch"
-- 	)
-- )
-- hl.bind(
-- 	m .. " + SHIFT + " .. reverse,
-- 	hl.dsp.exec_cmd(
-- 		"hyprswitch gui --mod-key "
-- 			.. m
-- 			.. " --key "
-- 			.. key
-- 			.. " --close mod-key-release --reverse-key=mod="
-- 			.. reverse
-- 			.. " --switch-type workspace && hyprswitch dispatch -r"
-- 	)
-- )

-- toggle mirror monitors
hl.bind(m .. " + M", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/toggleMirrorMonitors.sh"))

-- lid close and open
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/laptopLidClose.sh"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/laptopLidOpen.sh"), { locked = true })

-- power
hl.bind(m .. " + KP_End", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind(m .. " + KP_Down", hl.dsp.exec_cmd("noctalia msg session lock-and-suspend"))
hl.bind(m .. " + KP_Next", hl.dsp.exec_cmd("noctalia msg session reboot"))
hl.bind(m .. " + KP_Left", hl.dsp.exec_cmd("noctalia msg session shutdown"))
