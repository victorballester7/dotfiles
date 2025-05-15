#! /usr/bin/env sh

# A Hyprland script for setting the behavior of the laptop screen when the lid is closing.

NUM_MONITORS=$(hyprctl monitors all | grep --count Monitor)

if [ "$NUM_MONITORS" -eq 1 ]; then
  # Suspend the system if no external monitor is connected
  systemctl suspend
else
  source $HOME/.config/hypr/scripts/moveWorkspacesToMonitors.sh  
  # Disable the internal display
  hyprctl keyword monitor "eDP-1, disable"
fi

