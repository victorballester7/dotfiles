#! /usr/bin/env sh

# A Hyprland script for toggling between mirroring display and extended display mode.

# Path to your configuration file
config_file="$HOME/.config/hypr/hypr.d/13_output.conf"

MONITORS=$(hyprctl monitors all | grep "Monitor" | awk '{print $2}')
INTERNAL_MONITOR="eDP-1"
NUM_MONITORS=$(hyprctl monitors all | grep --count Monitor)

# If there's only one monitor, we don't need to do anything
if [ "$NUM_MONITORS" -eq 1 ]; then
  exit 0
fi

for monitor in $MONITORS; do
  if [ "$monitor" != "$INTERNAL_MONITOR" ]; then
    if grep -q "^monitor = $monitor, preferred, auto, 1, mirror, $INTERNAL_MONITOR, " "$config_file"; then
      # Currently mirroring, switch to extended mode
      echo "Switching to extended mode"
      sed -i \
        -e "/^# monitor = $monitor, preferred, /s/^# //" \
        -e "/^monitor = $monitor, preferred, auto, 1, mirror, $INTERNAL_MONITOR, /s/^/# /" \
        "$config_file"
    else
      # Currently extended, switch to mirroring
      echo "Switching to mirroring mode"
      sed -i \
        -e "/^monitor = $monitor, preferred, /s/^/# /" \
        -e "/^# monitor = $monitor, preferred, auto, 1, mirror, $INTERNAL_MONITOR, /s/^# //" \
        "$config_file"
    fi
  fi
done

# Reload Hyprland configuration
hyprctl reload

