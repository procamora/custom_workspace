#!/bin/sh

ping google.es -c 1 > /dev/null 2>&1

# Chceck stderr program, if 0 correct else error
if [ "$?" -eq "0" ]; then
    echo ""
else
    echo "%{F#BD2C40}%{u-}%{F-}"
fi