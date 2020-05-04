#!/bin/sh

IFACE=$(ip address show | grep "wlp")

if [ "$?" -eq "0" ]; then
    test $(echo $IFACE | grep inet) && echo "%{F#2495e7}直%{u-}"
    ! test $(echo $IFACE | grep inet) && echo "%{F#FF0000}直%{u-}"
else
    echo "%{F#555}睊%{u-}%{F-}"
fi

