#!/bin/bash

# Script to run the streams of football, F1 or whatever.
# The script will run the streams in mpv player.

# Requirements:
# - mpv player with extension mpv-acestream (https://github.com/Digitalone1/mpv-acestream)
# - acestream-engine (having the acestream-engine.service enabled and running)

# Usage:
# ./watchStreams.sh content_id

if [ $# -eq 0 ]; then
  echo "Usage: $0 content_id"
  echo "Example: $0 1234567890abcdef1234567890abcdef12345678"
  exit 1
fi

content_id=$1

mpv http://127.0.0.1:6878/ace/getstream\?id\=${content_id}\&pid\=8087



# f1="d6281d4e6310269b416180442a470d23a4a99dc9"
# motogp="d5446f3cc8e42ba965fd9f1c73b1e2ac3921a6ab"
# champions_league="e572a5178ff72eed7d1d751a18b4b3419699f370"
# la_liga="ec29289b0b14756e686c03a501bae1efa05be70c"

# if [ $# -eq 0 ]; then
#   echo "Usage: $0 [custom_acestream_id | f1 | motogp | champions_league | la_liga]"
#   echo "Example: $0 f1"
#   echo "Example: $0 d6281d4e6310269b416180442a470d23a4a99dc9"
#   exit 1
# fi

# case "$1" in
#   f1) content_id=$f1 ;;
#   motogp) content_id=$motogp ;;
#   champions_league) content_id=$champions_league ;;
#   la_liga) content_id=$la_liga ;;
#   *) content_id=$1 ;;  # Assume user provided a custom acestream ID
# esac

# mpv "http://127.0.0.1:6878/ace/getstream?id=$content_id"
# .1:6878/ace/getstream\?id\=${content_id}\&pid\=8087
