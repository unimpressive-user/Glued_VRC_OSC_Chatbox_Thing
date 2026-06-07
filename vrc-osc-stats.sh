#!/bin/bash
set -uo pipefail
shopt -s extglob
# Options or some shit like that
oscIP="127.0.0.1" # useful if sending to other device
oscPORT="9000"
# remove specific prefix from begining case and whitespace sensitive
rmBEGIN=(
        "Songs - "
        "Song - "
        "Music - "
        "not - "
)
prefPLAYER="firefox" # check with "playerctl --list-all", "firefox.instance_1_110", set prefered player

# big thanks to that random guy that figure this out on a random forum  
clean_media_info() {
    local media="$1"
    local tmp_var_shit
    for tmp_var_shit in "${rmBEGIN[@]}"; do
        if [[ "$media" == "$tmp_var_shit"* ]]; then 
            media="${media#"$tmp_var_shit"}"
        fi
    done
    while [[ "$media" == *\[*\]* ]]; do
        media="${media%%\[*\]*}${media#*\]*}"
    done
    media="${media##+([[:space:]])}"
    media="${media%%+([[:space:]])}"
    echo "$media"
}

get_media_info() {
    local PLAYER
    local get
    local state
    state="$(playerctl -p "$prefPLAYER" status)"
    if [[ "$state" == "Paused" || "$state" == "Playing" ]]; then # sudo kill me
        PLAYER=(-p "$prefPLAYER")
    else
        PLAYER=()
    fi
    if [[ "$state" == "Paused" ]]; then
        echo "Media paused"
        return
    else
        get="$(playerctl "${PLAYER[@]}" metadata --format "{{title}} - {{artist}}")"
    fi
    get="$(clean_media_info "$get")"
    echo "$get"
}

send_osc() {
    oscsend "$oscIP" "$oscPORT" /chatbox/input sTF "$1"
}

while true; do
    MESSAGE="$(date +%H:%M:%S)"$'\n'"$(get_media_info)"
    send_osc "$MESSAGE"
    echo "$MESSAGE"
    sleep 1.5
done