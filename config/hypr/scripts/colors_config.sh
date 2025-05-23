#!/bin/sh

echo "$(date +"%H:%M:%S.%N" | cut -c1-13) - COLORS CONFIG START"

# get the colors
color_primary=$(matugen --show-colors image ~/.config/hypr/wallpapers/wallpaper.jpg | grep " primary " | awk '{print $9}')

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
wloDIR=$HOME/.config/wlogout/icons
files=(hibernate lock logout reboot shutdown suspend)

# change the color of the icons
for file in ${files[@]}; do
  magick "${wloDIR}/${file}.png" -fuzz 10% -fill "${color_primary}" -opaque white "${wloDIR}/${file}_color.png"
done

echo "$(date +"%H:%M:%S.%N" | cut -c1-13) - COLORS CONFIG DONE"

