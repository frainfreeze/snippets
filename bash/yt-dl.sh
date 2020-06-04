#!/bin/bash
#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
# My youtube archival tool, for downloading playlists. Saves best audio-video, subtitles,
# metadata and thumbnails. Metadata is saved in json files, audiovideo tags and xattrs.
# When done parses log to find failed videos and generates list of their links.
# Depends on: youtube-dl, xattrs
# Use as: ./yt-dl.sh playlist_id

youtube-dl -f "bestvideo[width>=1920]/bestvideo+bestaudio/best" --write-all-thumbnails --all-subs --xattrs --write-annotations --geo-bypass --add-metadata --ignore-errors https://www.youtube.com/playlist?list=$1 2>&1 | tee log.txt
echo "Done dowloading. Processing the log file..."
echo $(date '+%Y-%m-%d %H:%M:%S') > failed.txt
grep "ERROR:" log.txt | while read -r line ; do
    echo $line | awk -F  ":" '{print $2}' | xargs echo -n  | awk '{print "https://youtu.be/"$1}' >> failed.txt
done
