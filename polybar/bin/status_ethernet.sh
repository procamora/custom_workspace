#!/bin/sh

ETH="enp4s0"
IFACE=$(/usr/sbin/ip address | grep "$ETH:" | awk '{print $2}' | tr -d ":")

if [ "$IFACE" = "$ETH" ]; then
    echo "%{F#2495E7} %{F#E2EE6A}$(/usr/sbin/ip address show $ETH | grep "inet " | awk '{print $2}' | cut -d/ -f1)%{u-}"
else
    echo "%{F#2495E7}%{u-}%{F-}"
fi

