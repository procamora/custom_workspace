#!/bin/bash

xrandr --output DP-1 --off
xrandr --output HDMI-1 --off
xrandr --output eDP-1  --mode 1920x1080 -r 60 --pos 0x0    --rotate normal --auto --primary
xrandr --output HDMI-2 --mode 1920x1080 -r 60 --pos 1920x0 --rotate normal --auto --right-of eDP-1

bspc wm -r
