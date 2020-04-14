#!/bin/sh

IFACE=$(ip address show | grep "enp")

if [ "$?" -eq "0" ]; then
    echo "%{F#2495E7}%{u-}"
else
    echo "%{F#2495E7}%{u-}%{F-}"
fi

