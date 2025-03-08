#!/bin/sh

function execute_hyprpaper {
  # Ensure no instances of hyprpaper are already running
  killall hyprpaper || true

  # Execute hyprpaper
  hyprpaper &
}

function execute_hyprpanel {
  # Ensure no instances of hyprpanel are already running
  killall gjs || true

  # Execute hyprpanel
  hyprpanel &
}

function execute_bingtext {
  killall nwg-wrapper || true
  # we wait for 1 sec, otherwise it loads this before the colors.css
  # sleep 1
  for monitor in $MONITORS; do
    nwg-wrapper -t $DIR/bing_name.txt -c $HOME/.config/hypr/style/bing_name.css -p right -a end -mb 10 -mr 10 -o $monitor &
  done
}

# fucntion to plot log info, which takes 1 argument
function plotInfo {
  echo "$(date +"%H:%M:%S.%N" | cut -c1-13) - $1"
}


function start_config {
  plotInfo "Setting COLORS CONFIG"
  $HOME/.config/hypr/scripts/colors_config.sh

  plotInfo "Setting HYPRPAPER CONFIG"
  execute_hyprpaper

  plotInfo "Setting BINGTEXT CONFIG"
  execute_bingtext

  plotInfo "Setting HYPRPANEL CONFIG"
  execute_hyprpanel

  plotInfo "Setting GNOME THEME"
  gsettings set org.gnome.desktop.interface gtk-theme victorballester7
}

plotInfo "Setting variables"
DIR="$HOME/.config/hypr/wallpapers"
MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

# Wallpaper path
wlpath="$DIR/wallpaper.jpg"
# Lockscreen wallpaper path
lswlpath="$DIR/lockscreen_wallpaper.jpg"
output="*"
baseurl="https://www.bing.com/"

# check the modification date of the wallpaper, if it is today, exit
# even if it is not from today we start hyprpanel (in order to prevent wifi slowdown download problems at startup)
plotInfo "Checking if the wallpaper is from today"
start_config
if [ "$(date -r $wlpath +%Y-%m-%d)" = "$(date +%Y-%m-%d)" ]; then
  exit
fi

# set locale for type of image (slightly different for each region)
# Available regions: "de-DE", "en-CA", "en-US", "en-GB", "es-ES"
# "fr-CA", "fr-FR", "it-IT", "ja-JP", "zh-CN"
REGION="en-GB"

# Check if the directory exists, if not create it.
if [ ! -d "$DIR" ]; then
  mkdir -p $DIR
fi

# Get URL and image name for Bing Image Of The Day for Canada
plotInfo "Getting Bing Image Of The Day (before loop)"
while [ -z "$wlurl" ]; do
  response=$(curl -s "${baseurl}HPImageArchive.aspx?format=js&idx=0&n=1&mkt=${REGION}")
  imageName=$(echo "$response" | jq -r '.images[].copyright')
  wlurl=$(echo "$response" | jq -r '.images[].url')
done

plotInfo "Getting Bing Image Of The Day (after loop)"
# image name is of the form "xxx, yyy, zzz (© aaaa)"
# we want to keep only "xxx, yyy, zzz"
imageName=$(echo $imageName | sed 's/ (.*$//')

# Save Bing image name
echo $imageName > $DIR/bing_name.txt

# Download and save Bing Image of the Day
curl "$baseurl$wlurl" -s > $wlpath

# Blur existing wallpaper to user later as a lock screen
magick $wlpath -filter Gaussian -blur 0x8 $lswlpath

plotInfo "Setting start config"
start_config
