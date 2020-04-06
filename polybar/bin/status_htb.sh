#!/bin/sh

IFACE=$(/usr/sbin/ip address | grep "tun0:" | awk '{print $2}' | tr -d ":")

if [ "$IFACE" = "tun0" ]; then
    echo "%{F#1bbf3e} %{F#e2ee6a}$(/usr/sbin/ip address show tun0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)%{u-}"

else
    echo "%{F#1bbf3e}%{u-}%{F-}"
fi

