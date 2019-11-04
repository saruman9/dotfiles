#!/bin/bash
# change_volume.sh

# Arbitrary but unique message id
msgId="991049"

# Change the volume
if [[ "$@" == "mute" ]]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle > /dev/null
else
    pactl set-sink-volume @DEFAULT_SINK@ $@% > /dev/null
fi

# Query amixer for the current volume and whether or not the speaker is muted
volume="$(pamixer --get-volume)"
mute="$(pamixer --get-mute)"
if [[ $volume == 0 || "$mute" == "true" ]]; then
    # Show the sound muted notification
    dunstify -u low -i audio-volume-muted -r "$msgId" "Volume muted"
else
    # Show the volume notification
    dunstify -u low -i audio-volume-high -r "$msgId" \
             "Volume: ${volume}%" "$(get_progress_string.sh 10 "" "" $volume)"
fi
