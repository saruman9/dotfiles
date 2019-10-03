#!/bin/sh
text=`xclip -selection clipboard -o`
trans=`trans :ru -brief "$text"`
notify-send -t 0 "$trans"
