#!/bin/env sh
print_tag() {
    tag="$1"
    msg="$2"
    color="$3"
    case "$color" in
        "red" )
            color_code_0=0
            color_code_1=31
            ;;
        "green" )
            color_code_0=0
            color_code_1=32
            ;;
        "yellow" )
            color_code_0=1
            color_code_1=33
            ;;
    esac
    echo -e "\e[0;33m[${tag}] \e[${color_code_0};${color_code_1}m${msg}\e[0m"
}
check_dir() {
    dir="$1"
    msg="$2"
    if [[ -a "$dir" ]]; then
        print_tag "chezmoi" "$msg" "red"
        exit 2
    fi
}
