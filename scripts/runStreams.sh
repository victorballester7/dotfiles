#!/bin/bash

# Script to run the streams of football, F1 or whatever.
# The script will run the streams in mpv player.

# Requirements:
# - mpv player with extension mpv-acestream (https://github.com/Digitalone1/mpv-acestream)
# - acestream-engine (having the acestream-engine.service enabled and running)

# Usage:
# ./runStreams.sh content_id

if [ $# -eq 0 ]; then
  echo "Usage: ./runStreams.sh content_id"
  exit 1
fi

content_id=$1

mpv http://127.0.0.1:6878/ace/getstream\?id\=${content_id}\&pid\=8087
