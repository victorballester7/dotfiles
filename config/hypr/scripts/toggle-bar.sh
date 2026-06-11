#!/bin/bash
# ~/.config/hypr/toggle-ashell.sh

if pgrep -x "ashell" > /dev/null; then
    pkill ashell
else
    ashell &
fi
