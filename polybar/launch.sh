#!/bin/bash

#killall -q -9 polybar
#ps aux | grep ".config/polybar/scripts/" | grep -v grep | awk '{print $2}' | xargs kill -9 2> /dev/null
# shellcheck disable=SC2046
pgrep -fa polybar | grep -v "launch.sh" | awk '{print $1}' | xargs kill -9 || true

#while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

#if type "xrandr"; then
#  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#    MONITOR=$m polybar --reload my_config &
#  done
#else
#  polybar --reload my_config &
#fi

#for m in $(xrandr --query | grep " connected" | awk '{print $1}'); do
for m in $(polybar --list-monitors | grep -v xrandr | awk -F ":" '{print $1}'); do
    MONITOR=$m polybar --reload my_config & disown
done

#polybar my_config &

echo "Polybar launched..."
