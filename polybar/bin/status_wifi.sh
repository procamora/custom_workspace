#!/bin/sh

IFACE=$(ip address show | grep "wlp")

if [ "$?" -eq "0" ]; then
    echo "%{F#2495e7}直%{u-}"
else
    echo "%{F#ff0000}睊%{u-}%{F-}"
fi

