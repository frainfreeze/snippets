#!/bin/sh
#---License---
#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#---Description---
# sets my philips 273v 1920x1080 as left monitor and samsung syncmaster 152v as right one.  
xrandr --output DVI-D-0 --off --output HDMI-0 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DVI-I-1 --off --output DVI-I-0 --mode 1024x768 --pos 1920x0 --rotate normal --output DP-1 --off --output DP-0 --off
