#!/bin/sh
text=$(xclip -o)
firefox --new-tab https://translate.yandex.com/?text="$text"
