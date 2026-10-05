hl.config({
    input = {
        kb_layout = "us,es",
        kb_variant = "intl,",
        kb_options = "grp:alt_shift_toggle",
        kb_rules = "",
        numlock_by_default = true,

        follow_mouse = 1,
        mouse_refocus = false,

        touchpad = {
            natural_scroll = true,
        },

        sensitivity = 0,
    },
    gestures = {
        workspace_swipe_cancel_ratio = 0.3,
    }
})

hl.device({
    name = "at-translated-set-2-keyboard",
    kb_layout = "es",
    kb_variant = "",
    kb_options = "",
})

-- nuphy-kick75 keyboard (both cable (io) and 2.4GHz (io-dongle))
hl.device({
    name = "nuphy-kick75-io",
    kb_layout = "us",
    kb_variant = "intl",
    kb_options = "grp:alt_shift_toggle,altwin:swap_alt_win",
})

hl.device({
    name = "nuphy-kick75-io-1",
    kb_layout = "us",
    kb_variant = "intl",
    kb_options = "grp:alt_shift_toggle,altwin:swap_alt_win",
})

hl.device({
    name = "nuphy-kick75-io-dongle",
    kb_layout = "us",
    kb_variant = "intl",
    kb_options = "grp:alt_shift_toggle,altwin:swap_alt_win",
})

hl.device({
    name = "nuphy-kick75-io-dongle-1",
    kb_layout = "us",
    kb_variant = "intl",
    kb_options = "grp:alt_shift_toggle,altwin:swap_alt_win",
})

hl.device({
    name = "semico---usb-gaming-keyboard-",
    kb_layout = "us",
    kb_variant = "intl",
    kb_options = "",
})
