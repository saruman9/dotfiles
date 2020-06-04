#!/bin/bash
if pgrep mpd 1>/dev/null ; then
    mpc | tr '\n' ' ' | grep -Po '.*(?= \[playing\])|paused' | tr -d '\n'
elif pgrep pianobar 1>/dev/null ; then
    cat $HOME/.config/pianobar/nowplaying
else
    echo ""
fi
