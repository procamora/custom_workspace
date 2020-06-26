#!/bin/sh

IFACE=$(ip address show | grep "wlp")

if [ "$?" -eq "0" ]; then
    # interface disconnected
    test $(echo $IFACE | grep inet | wc -l) -eq 0 && "%{F#FF0000}直%{u-}%{F-}"
    # interface connected
    test $(echo $IFACE | grep inet | wc -l) -gt 0 && echo "%{F#2495e7}直%{u-}%{F-}"
else
    echo "%{F#555}睊%{u-}%{F-}"
fi

