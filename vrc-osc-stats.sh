#!/bin/bash
set -euo pipefail

# Options or some shit like that
oscIP="127.0.0.1" # useful if sending to other device
oscPORT="9000"
rmAllAFTER="[" # removes symbol and evrything after
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
    for tmp_var_shit in "${rmBEGIN[@]}"; do
        if [[ ${media} == "${tmp_var_shit}"* ]]; then 
            media="${media#"${tmp_var_shit}"}"
        fi
    done
    media="${media%%["${rmAllAFTER}"]*}"
    media="${media##+([[:space:]])}"
    media="${media%%+([[:space:]])}"
    echo "${media}"
}

get_media_info() {
    if playerctl -p "$prefPLAYER" status > /dev/null; then # sudo kill me
        PLAYER="--player="${prefPLAYER}""
    else
        PLAYER=""
    fi
    if [[ $(playerctl "${PLAYER}" status) == "Paused" ]]; then
        get="Media paused"
    else
        get="$(playerctl "${PLAYER}" metadata --format "{{title}} - {{artist}}")"
    fi
    if [[ "${get}" !=  "Media paused" ]]; then
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