#! /usr/bin/env sh

# A Hyprland script for setting the behavior of the laptop screen when the lid is opening.

NUM_MONITORS=$(hyprctl monitors all | grep --count Monitor)

# with only the laptop screen, Hyprland re-enables it by itself.
if [ "$NUM_MONITORS" -gt 1 ]; then
  hyprctl eval 'hl.monitor({output="eDP-1", disabled = false})'
fi

