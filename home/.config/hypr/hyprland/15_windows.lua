hl.config({
    dwindle = {
        preserve_split = true,
        smart_split = false,
    },
    master = {
        new_status = "slave",
    },
})

-- to hide bar after holding mod+number key to switch workspace
-- hl.on("workspace.active", function()
--   hl.exec_cmd("noctalia msg bar-hide")
-- end)

hl.window_rule({
    name = "Enabling floating for some apps 1",
    match = { class = "blueman-manager|org.gnome.PowerStats|org.gnome.SystemMonitor|nm-connection-editor|org.pulseaudio.pavucontrol|blueberry.py" },
    float = true,
})

hl.window_rule({
    name = "Enabling floating for some apps 2",
    match = { title = "^(Rename)(.*)" },
    float = true,
})

hl.window_rule({
    name = "Tile for MATLAB",
    match = { class = "MATLAB" },
    tile = true,
})

hl.window_rule({
    name = "Thunderbird workspace",
    match = { class = "thunderbird" },
    workspace = 10,
})

hl.window_rule({
    name = "Teams workspace",
    match = { class = "teams-for-linux" },
    workspace = 9,
})

hl.window_rule({
    name = "Music apps go to workspace 8",
    match = { class = "spotify|spotube" },
    workspace = 8,
})

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
