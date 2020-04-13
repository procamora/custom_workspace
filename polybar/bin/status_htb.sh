#!/bin/sh

ETH="tun0"
IFACE=$(/usr/sbin/ip address | grep "$ETH:" | awk '{print $2}' | tr -d ":")

if [ "$IFACE" = "$ETH" ]; then
    echo "%{F#1BBF3E} %{F#E2EE6A}$(/usr/sbin/ip address show $ETH | grep "inet " | awk '{print $2}' | cut -d/ -f1)%{u-}"
else
    echo "%{F#1BBF3E}%{u-}%{F-}"
fi

