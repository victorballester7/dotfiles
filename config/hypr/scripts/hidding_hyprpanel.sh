#!/bin/bash

# Threshold in pixels from top edge to trigger panel
THRESHOLD=5
SLEEPTIME="0.5"
mouseOnTop=false

get_monitor_id() {
    cursor_x=$(hyprctl cursorpos -j | jq '.x')
    cursor_y=$(hyprctl cursorpos -j | jq '.y')

    hyprctl monitors -j | jq -c '.[]' | while read -r monitor; do
        x=$(echo "$monitor" | jq '.x')
        y=$(echo "$monitor" | jq '.y')
        width=$(echo "$monitor" | jq '.width')
        height=$(echo "$monitor" | jq '.height')

        if (( cursor_x >= x && cursor_x < x + width && cursor_y >= y && cursor_y < y + height )); then
            echo "$monitor" | jq -r '.id'
            return
        fi
    done
}

while true; do
    y=$(hyprctl cursorpos -j | jq '.y')

    if [ "$y" -le "$THRESHOLD" ] && [ "$mouseOnTop" = false ]; then
        monitor_id=$(get_monitor_id)
        echo $monitor_id
        hyprpanel toggleWindow bar-"$monitor_id"
        mouseOnTop=true
    elif [ "$y" -gt "$THRESHOLD" ] && [ "$mouseOnTop" = true ]; then
        monitor_id=$(get_monitor_id)
        echo $monitor_id
        hyprpanel toggleWindow bar-"$monitor_id"
        mouseOnTop=false
    fi

    sleep "${SLEEPTIME}"
done

