# get the colors
color_primary=$(matugen --show-colors image ~/.config/hypr/wallpapers/wallpaper.jpg | grep " primary " | awk '{print $9}')

# wlogout
wloDIR=$HOME/.config/wlogout/icons
files=(hibernate lock logout reboot shutdown suspend)

# change the color of the icons
for file in ${files[@]}; do
  magick "${wloDIR}/${file}.png" -fuzz 10% -fill "${color_primary}" -opaque white "${wloDIR}/${file}_color.png"
done

