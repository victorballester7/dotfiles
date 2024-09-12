#!/bin/sh

# source: https://github.com/lgaboury/Sway-Waybar-Install-Script/blob/master/.config/sway/scripts/get_bing_image.sh

function execute_hyprpaper {
  killall nwg-wrapper || true


  # Display image name on bottom right of the wallpaper
  nwg-wrapper -t $DIR/bing_name.txt -c $HOME/.config/hypr/scripts/bing_name.css -p right -a end -mb 10 -mr 10 &
  nwg-wrapper -t $DIR/bing_name.txt -c $HOME/.config/hypr/scripts/bing_name.css -p right -a end -mb 10 -mr 10 -o HDMI-A-1 &

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
  execute_waybar
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

# set colors
$HOME/.config/hypr/scripts/wal_setup.sh

# Blur existing wallpaper to user later as a lock screen
magick $wlpath -filter Gaussian -blur 0x8 $lswlpath

# Execute hyprpaper
execute_hyprpaper

# Execute waybar
execute_waybar
