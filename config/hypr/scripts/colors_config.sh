# get the colors
color_primary=$(matugen --show-colors image ~/.config/hypr/wallpapers/wallpaper.jpg | grep " primary " | awk '{print $9}')

# wlogout
wloDIR=$HOME/.config/wlogout/icons
files=(hibernate lock logout reboot shutdown suspend)

# change the color of the icons
for file in ${files[@]}; do
  magick "${wloDIR}/${file}.png" -fuzz 10% -fill "${color_primary}" -opaque white "${wloDIR}/${file}_color.png"
done

# dunst
# cat <<EOF > $HOME/.config/dunst/dunstrc
# # DO NOT EDIT THIS FILE. THIS FILE IS AUTOGENERATED BY wal_setup.sh. INSTEAD EDIT THE dunstrc_default FILE.
# [global]
#     format = "<span foreground='${color_primary}'><b>%s</b></span>\n%b"
# [urgency_low]
#     highlight = "${color_primary}"
# [urgency_normal]
#     highlight = "${color_primary}"
# [urgency_critical]
#     highlight = "${color_primary}"

# EOF
# cat $HOME/.config/dunst/dunstrc_default >> $HOME/.config/dunst/dunstrc

# cat <<EOF > $HOME/.config/dunst/dunstrc_volume_brightness
# # DO NOT EDIT THIS FILE. THIS FILE IS AUTOGENERATED BY wal_setup.sh. INSTEAD EDIT THE dunstrc_volume_brightness_default FILE.
# [global]
#     format = "<span foreground='${color_primary}'><b>%s</b></span>\n%b"
# [urgency_low]
#     highlight = "${color_primary}"
# [urgency_normal]
#     highlight = "${color_primary}"
# [urgency_critical]
#     highlight = "${color_primary}"

# EOF
# cat $HOME/.config/dunst/dunstrc_volume_brightness_default >> $HOME/.config/dunst/dunstrc_volume_brightness
