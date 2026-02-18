#!/bin/sh

echo "$(date +"%H:%M:%S.%N" | cut -c1-13) - COLORS CONFIG START"

# get the colors
colors_output=$(matugen --source-color-index 0 --show-colors image ~/.config/hypr/wallpapers/wallpaper.jpg)

color_primary=$(printf "%s\n" "$colors_output" | grep " primary " | awk '{print $9}')

echo "color_primary: $color_primary"

# echo colors to ashell config file (find the line that starts with primary_color and text_color and replace the color values with the new ones)
# only echo if color_primary is not empty
if [ -n "$color_primary" ]; then
    sed -i "s/primary_color = .*/primary_color = \"$color_primary\"/g" $HOME/.config/ashell/config.toml
    sed -i "s/workspace_colors = .*/workspace_colors = [\"$color_primary\"]/g" $HOME/.config/ashell/config.toml
fi


###### I need this for fastfetch to work ######

# convert color to r, g, b
color_rgb=$(echo $color_primary | sed 's/#//')
r=$(echo $((16#${color_rgb:0:2})))
g=$(echo $((16#${color_rgb:2:2})))
b=$(echo $((16#${color_rgb:4:2})))

# store variables r, g, b for future shell sessions
echo "export r='$r'" > $HOME/.config/hypr/wallpapers/colors.sh
echo "export g='$g'" >> $HOME/.config/hypr/wallpapers/colors.sh
echo "export b='$b'" >> $HOME/.config/hypr/wallpapers/colors.sh
###############################################

# wlogout
# wloDIR=$HOME/.config/wlogout/icons
# files=(hibernate lock logout reboot shutdown suspend)

# change the color of the icons
# for file in ${files[@]}; do
#   magick "${wloDIR}/${file}.png" -fuzz 10% -fill "${color_primary}" -opaque white "${wloDIR}/${file}_color.png"
# done


echo "$(date +"%H:%M:%S.%N" | cut -c1-13) - COLORS CONFIG DONE"

