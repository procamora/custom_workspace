#!/bin/sh

IFACE=$(/usr/sbin/ip address | grep "enp0s3:" | awk '{print $2}' | tr -d ":")

if [ "$IFACE" = "enp0s3" ]; then
    echo "%{F#2495e7} %{F#e2ee6a}$(/usr/sbin/ip address show enp0s3 | grep "inet " | awk '{print $2}' | cut -d/ -f1)%{u-}"

else
    echo "%{F#2495e7}%{u-}%{F-}"
fi

