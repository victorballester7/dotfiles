#!/bin/bash
# This script opens a new terminal window in the same directory as the active terminal window (if it is a terminal window), otherwise it opens a new terminal window in the home directory.

# Get the class name of the active window
active_window_class=$(hyprctl activewindow -j | jq -r '.class')

# Check if the active window is a terminal (in this case, Kitty)
if [[ "$active_window_class" == "kitty" ]]; then
    # Extract the current working directory from the active terminal
    title=$(hyprctl activewindow -j | jq -r '.title')
    cwd="~${title#*~}"
    echo $cwd
    # Open a new terminal in the same directory
    # kitty --directory "$cwd" &
    kitty --directory $cwd &
else
    # Open a new terminal in the home directory
    # kitty --directory "$HOME" &
    kitty &
fi

