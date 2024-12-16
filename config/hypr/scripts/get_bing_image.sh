#!/bin/sh

# source: https://github.com/lgaboury/Sway-Waybar-Install-Script/blob/master/.config/sway/scripts/get_bing_image.sh

function execute_hyprpaper {
  # Ensure no instances of hyprpaper are already running
  killall hyprpaper || true

  # Execute hyprpaper
  hyprpaper &
}

function execute_waybar {
  # Ensure no instances of waybar are already running
  killall waybar || true

  # Execute waybar
  waybar &
}

function execute_hyprpanel {
  # Ensure no instances of hyprpanel are already running
  killall agsv1 || true

  # Execute hyprpanel
  agsv1 &
}

function execute_bingtext {
  killall nwg-wrapper || true
  # we wait for 1 sec, otherwise it loads this before the colors.css
  sleep 1
  nwg-wrapper -t $DIR/bing_name.txt -c $HOME/.config/hypr/style/bing_name.css -p right -a end -mb 10 -mr 10 &
  nwg-wrapper -t $DIR/bing_name.txt -c $HOME/.config/hypr/style/bing_name.css -p right -a end -mb 10 -mr 10 -o HDMI-A-1 &
  nwg-wrapper -t $DIR/bing_name.txt -c $HOME/.config/hypr/style/bing_name.css -p right -a end -mb 10 -mr 10 -o DP-1 &
}


DIR="$HOME/.config/hypr/wallpapers"

# Wallpaper path
wlpath="$DIR/wallpaper.jpg"
# Lockscreen wallpaper path
lswlpath="$DIR/lockscreen_wallpaper.jpg"
output="*"
baseurl="https://www.bing.com/"

# check the modification date of the wallpaper, if it is today, exit
if [ -f $wlpath ]; then
  execute_hyprpaper
  # execute_waybar
  execute_hyprpanel

  execute_bingtext

  gsettings set org.gnome.desktop.interface gtk-theme victorballester7

  # configure colors on other apps
  $HOME/.config/hypr/scripts/colors_config.sh

  if [ "$(date -r $wlpath +%Y-%m-%d)" = "$(date +%Y-%m-%d)" ]; then
    exit
  fi
fi

# set locale for type of image (slightly different for each region)
# Available regions: "de-DE", "en-CA", "en-US", "en-GB", "es-ES"
# "fr-CA", "fr-FR", "it-IT", "ja-JP", "zh-CN"
REGION="en-GB"

# Check if the directory exists, if not create it.
if [ ! -d "$DIR" ]; then
  mkdir -p $DIR
fi

# Get URL for Bing Image Of The Day for Canada
while [ -z $wlurl ]; do
  wlurl=$(curl $baseurl"HPImageArchive.aspx?format=js&idx=0&n=1&mkt="$REGION -s | jq '.images[].url' --raw-output)
done

# Get name for Bing Image of the Day
imageName=$(curl $baseurl"HPImageArchive.aspx?format=js&idx=0&n=1&mkt="$REGION -s | jq '.images[].copyright' --raw-output)

# image name is of the form "xxx, yyy, zzz (© aaaa)"
# we want to keep only "xxx, yyy, zzz"
imageName=$(echo $imageName | sed 's/ (.*$//')

# Save Bing image name
echo $imageName > $DIR/bing_name.txt

# Download and save Bing Image of the Day
curl "$baseurl$wlurl" -s > $wlpath

# Blur existing wallpaper to user later as a lock screen
magick $wlpath -filter Gaussian -blur 0x8 $lswlpath

# # configure colors on other apps
$HOME/.config/hypr/scripts/colors_config.sh
# $HOME/Desktop/dotfiles/config/hypr/scripts/colors_config.sh

# Execute waybar/hyprpanel
# execute_waybar
execute_hyprpanel

# Execute hyprpaper
execute_hyprpaper

execute_bingtext

sleep 5 & gsettings set org.gnome.desktop.interface gtk-theme victorballester7
