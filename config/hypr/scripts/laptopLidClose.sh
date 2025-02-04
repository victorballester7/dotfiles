#! /usr/bin/env sh

# A Hyprland script for setting the behavior of the laptop screen when the lid is closing.

NUM_MONITORS=$(hyprctl monitors all | grep --count Monitor)

if [ "$NUM_MONITORS" -eq 1 ]; then
  # Suspend the system if no external monitor is connected
  systemctl suspend
else
  # Get a list of external monitors
  EXTERNAL_MONITORS=($(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name'))
  NUM_EXT_MONITORS=${#EXTERNAL_MONITORS[@]}

  if [ "$NUM_EXT_MONITORS" -gt 0 ]; then
    # Get workspaces from eDP-1
    WORKSPACES=($(hyprctl workspaces -j | jq -r '.[] | select(.monitor == "eDP-1") | .id'))
    NUM_WORKSPACES=${#WORKSPACES[@]}
    
    # Distribute workspaces evenly across external monitors
    for i in "${!WORKSPACES[@]}"; do
      TARGET_MONITOR=${EXTERNAL_MONITORS[$((i % NUM_EXT_MONITORS))]}
      hyprctl dispatch moveworkspacetomonitor "${WORKSPACES[$i]} $TARGET_MONITOR"
      hyprctl dispatch workspace "${WORKSPACES[$i]}"
    done
  fi
  
  # Disable the internal display
  hyprctl keyword monitor "eDP-1, disable"
fi

