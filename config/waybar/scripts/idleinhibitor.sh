#!/bin/bash

# Check the current state of the idle inhibitor
status=$(hyprctl getactive | grep -c "idle_inhibitor")

if [ "$status" -eq 1 ]; then
    # Idle inhibitor is active, disable it
    hyprctl keyword misc:idle_inhibitor off
    notify-send "Idle Inhibitor" "Disabled"
else
    # Idle inhibitor is inactive, enable it
    hyprctl keyword misc:idle_inhibitor on
    notify-send "Idle Inhibitor" "Enabled"
fi

