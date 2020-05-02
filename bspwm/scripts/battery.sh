#!/bin/bash


notify-send -u normal -t 5000 "Battery" "Battery monitoring started."


while sleep 60; do 
    capacity=$(cat /sys/class/power_supply/BAT0/capacity)
    if [ "$capacity" -eq 30 ]; then
        notify-send -u normal -t 5000 "Battery" "The capacity of the battery is $capacity%."
        light -S 20  # 20% britgness

    else if [ "$capacity" -eq 30 ]; then
        notify-send -u normal -t 5000 "Battery" "The capacity of the battery is $capacity%."
        light -S 20  # 20% britgness

    else if [ "$capacity" -lt 12 ]; then
        notify-send -u critical -t 5000 "Battery" "The battery capacity is critical, the laptop will now hibernate."
        #systemctl hibernate
    fi
done