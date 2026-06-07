#!/bin/bash

# deps: liblo, playerctl, bash

set -euo pipefail

# Options or some shit like that
oscIP="127.0.0.1" # useful if sending to other device
oscPORT="9000"

# var init I guess it's good to have these?
MESSAGE=""
MEDIA_TITLE_ARTIST=""


# big thanks to that random guy that figure this out on a random forum  
clean_media_info() {
    local media="$1"
    local other_bs='['
    local text_bs=(
        "Songs - "
        "Song - "
        "Music - "
        "not - "
    )
    local tmp_var_shit
    for tmp_var_shit in "${text_bs[@]}"; do
        if [[ ${media} == "${tmp_var_shit}"* ]]; then 
            media="${media#"${tmp_var_shit}"}"
        fi
    done
    media="${media%%["${other_bs}"]*}"
    media="${media##+([[:space:]])}"
    media="${media%%+([[:space:]])}"
    echo "$media"
}


get_media_info() {
    PLAYERS="$(playerctl --list-all)"
    if [[ $(playerctl status) == "Paused" ]]; then
        get="Media paused"
    else
        get="$(playerctl metadata --format "{{title}} - {{artist}}")"
    fi
    if [[ "$get" !=  "Media paused" ]]; then
        get="$(clean_media_info "${get}")"
    fi
    echo "${get}"
}

send_osc() {
    oscsend "$oscIP" "$oscPORT" /chatbox/input sTF "$1"
}

while true; do
MESSAGE="$(date +%H:%M:%S)"$'\n'"$(get_media_info)"
send_osc "${MESSAGE}"
echo "${MESSAGE}"
sleep 1.5
done