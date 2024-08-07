pathscript="$HOME/.config/hypr/scripts"

# Check if there is a sleep process running, if so, kill it
if pgrep -f "volume_brightness" > /dev/null; then
    pkill -f "sleep"
    if [[ $1 != "volume_up" && $1 != "volume_down" && $1 != "brightness_up" && $1 != "brightness_down" && $1 != "volume_mute" ]]; then
        # Kill all dunst and mako processes
        killall -q dunst mako
        # Execute the set_notif.sh script
        ${pathscript}/set_notif.sh &
    fi
else
    if [[ $1 == "volume_up" || $1 == "volume_down" || $1 == "brightness_up" || $1 == "brightness_down" || $1 == "volume_mute" ]]; then
        # Kill all dunst and mako processes
        killall -q dunst mako
        # Execute the set_notif.sh script
        ${pathscript}/set_notif_volume_brightness.sh &
    fi
fi

# If the exit code of ${pathscript}/volume_brightness.sh $1 is 0, then execute the following
if ${pathscript}/volume_brightness.sh "$1"; then
    # Kill all dunst and mako processes
    killall -q dunst mako
    # Execute the set_notif.sh script
    ${pathscript}/set_notif.sh &
fi

