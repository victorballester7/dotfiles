#! /usr/bin/env sh

# A Hyprland script for toggling between mirroring display and extended display mode.

INTERNAL_MONITOR="eDP-1"
EXTERNAL_MONITORS=$(hyprctl monitors all | grep "Monitor" | awk '{print $2}' | grep -v "$INTERNAL_MONITOR")
NUM_MONITORS=$(hyprctl monitors all | grep --count Monitor)

# If there's only one monitor, we don't need to do anything
if [ "$NUM_MONITORS" -eq 1 ]; then
  exit 0
fi

# mirrorOf: none will always be on one screen, so we need to check for more outputs than 1 in grep
if [[ $(hyprctl monitors all | grep -c "mirrorOf: none") -gt 1 ]]; then
  # mirror is not detected, we need to set it to mirror
  for monitor in $EXTERNAL_MONITORS; do
    hyprctl keyword monitor "$monitor, preferred, auto, 1, mirror, $INTERNAL_MONITOR, bitdepth, 8"
  done
else
  # mirror is detected, we reload the config file.
  hyprctl reload
fi

