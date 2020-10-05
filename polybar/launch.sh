#!/bin/bash

killall -q -9 polybar
ps aux | grep "scripts/gmail/launch.py" | awk '{print $2}' | xargs kill -9 -q 2> /dev/null
ps aux | grep "scripts/networkmanager_dmenu.py" | awk '{print $2}' | xargs kill -9 -q 2> /dev/null

while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

#if type "xrandr"; then
#  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#    MONITOR=$m polybar --reload my_config &
#  done
#else
#  polybar --reload my_config &
#fi

# filter monitor xrandr
for m in $(polybar --list-monitors | grep -v xrandr | awk -F ":" '{print $1}'); do
    MONITOR=$m polybar --reload my_config &
done

#polybar my_config &

echo "Polybar launched..."
