#!/bin/bash

state=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep state | cut -d ':' -f2 | xargs)
capacity=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep percentage | grep -o "[0-9]*")

JSON_STRING=$(jq -n \
    --arg state $state \
    --arg level $level \
    '{state: $state, level: $level}')
echo $JSON_STRING

pactl subscribe | grep --line-buffered "on sink" | while read -r _; do
    state=$(pamixer --get-mute)
    level=$(pamixer --get-volume | tr -d '%')

    JSON_STRING=$(jq -n \
        --arg state $state \
        --arg level $level \
        '{state: $state, level: $level}')
    echo $JSON_STRING
done
