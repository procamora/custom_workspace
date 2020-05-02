#!/bin/bash


change_status() {
    alive=$(ps aux | egrep "redshift -c .*/.config/redshift.conf"| grep -v "grep" | wc -l)

    if [ $alive -eq 0 ]; then
        redshift -c ~/.config/redshift.conf > /dev/null 2>&1 &
    else
        killall -9 -q redshift
        redshift -x
    fi
    info
}

info() {
    if [ "$(pgrep -x redshift)" ]; then
        temp=$(redshift -p 2> /dev/null | grep temp | cut -d ":" -f 2 | tr -dc "[:digit:]")

        if [ -z "$temp" ]; then
            echo "%{F#ffffff}%{u-}"
        elif [ "$temp" -ge 5000 ]; then  # blue
            echo "%{F#7fe5f0}%{u-}"
        elif [ "$temp" -ge 4000 ]; then  # yellow
            echo "%{F#ffff00}%{u-}"
        else                             # orange
            echo "%{F#ff7f50}%{u-}"
        fi

    else
    	echo "%{F#555}%{u-}"
    fi
}



if [ "$1" = "info" ]; then
    info
elif [ "$1" = "change" ]; then
    change_status
fi
