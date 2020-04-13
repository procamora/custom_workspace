#!/bin/sh

ETH="wlan0"
IFACE=$(/usr/sbin/ip address | grep "$ETH:" | awk '{print $2}' | tr -d ":")

if [ "$IFACE" = "$ETH" ]; then
    echo "%{F#2495e7}直 %{F#e2ee6a}$(/usr/sbin/ip address show $ETH | grep "inet " | awk '{print $2}' | cut -d/ -f1)%{u-}"
else
    echo "%{F#2495e7}睊%{u-}%{F-}"
fi

