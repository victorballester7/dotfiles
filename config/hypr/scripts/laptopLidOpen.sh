#! /usr/bin/env sh

# A Hyprland script for setting the behavior of the laptop screen when the lid is opening.

NUM_MONITORS=$(hyprctl monitors all | grep --count Monitor)

# we don't need to run hyprlock when there's only the laptop screen because it load automatically by default.
if [ "$NUM_MONITORS" -gt 1 ]; then
  hyprctl keyword monitor "eDP-1, preferred, 0x300, 1.3333, bitdepth, 8"
fi

