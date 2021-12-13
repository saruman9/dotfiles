#!/bin/bash
# changeVolume

# Arbitrary but unique message tag
msgTag="myvolume"

# Change the volume
if [[ "$@" == "mute" ]]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle > /dev/null
else
    pactl set-sink-volume @DEFAULT_SINK@ $@% > /dev/null
fi

volume="$(pamixer --get-volume)"
mute="$(pamixer --get-mute)"
if [[ $volume == 0 || "$mute" == "true" ]]; then
    # Show the sound muted notification
    dunstify -a "changeVolume" -u low -i audio-volume-muted -h string:x-dunst-stack-tag:$msgTag "Volume muted"
else
    # Show the volume notification
    dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:$msgTag \
    -h int:value:"$volume" "Volume: ${volume}%"
fi
