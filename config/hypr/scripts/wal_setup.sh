# clear the cache
wal -c 

# get the colors
wal -s -t -i "$HOME/.config/hypr/wallpapers/wallpaper.jpg"

WALDIR=$HOME/.cache/wal
CONFIGDIR=$HOME/.config
THEMESDIR=$HOME/.themes/victorballester7
# copy wallpaper to sddm folder
# sudo cp $CONFIGDIR/hypr/wallpapers/wallpaper.jpg /usr/share/sddm/themes/sugar-dark/

# copy the colors to apps that use them
cp $WALDIR/10_colors.conf $CONFIGDIR/hypr/hypr.d/
cp $WALDIR/colors-rofi-custom.rasi $CONFIGDIR/rofi/
cp $WALDIR/colors-waybar.css $CONFIGDIR/waybar/
cp $WALDIR/mycolors-gtk.css $THEMESDIR/
cp $WALDIR/mycolors-kitty.conf $CONFIGDIR/kitty/

mycolor=$(sed -n '18{p;q}' $HOME/.cache/wal/colors)

# dunst
cat <<EOF > $HOME/.config/dunst/dunstrc
# DO NOT EDIT THIS FILE. THIS FILE IS AUTOGENERATED BY wal_setup.sh. INSTEAD EDIT THE dunstrc_default FILE.
[global]
    format = "<span foreground='${mycolor}'><b>%s</b></span>\n%b"
[urgency_low]
    highlight = "${mycolor}"
[urgency_normal]
    highlight = "${mycolor}"
[urgency_critical]
    highlight = "${mycolor}"

EOF
cat $HOME/.config/dunst/dunstrc_default >> $HOME/.config/dunst/dunstrc

cat <<EOF > $HOME/.config/dunst/dunstrc_volume_brightness
# DO NOT EDIT THIS FILE. THIS FILE IS AUTOGENERATED BY wal_setup.sh. INSTEAD EDIT THE dunstrc_volume_brightness_default FILE.
[global]
    format = "<span foreground='${mycolor}'><b>%s</b></span>\n%b"
[urgency_low]
    highlight = "${mycolor}"
[urgency_normal]
    highlight = "${mycolor}"
[urgency_critical]
    highlight = "${mycolor}"

EOF
cat $HOME/.config/dunst/dunstrc_volume_brightness_default >> $HOME/.config/dunst/dunstrc_volume_brightness


# wlogout
wloDIR=$HOME/.config/wlogout/icons
files=(hibernate lock logout reboot shutdown suspend)

# change the color of the icons
for file in ${files[@]}; do
  magick "${wloDIR}/${file}.png" -fuzz 10% -fill "${mycolor}" -opaque white "${wloDIR}/${file}_color.png"
done

