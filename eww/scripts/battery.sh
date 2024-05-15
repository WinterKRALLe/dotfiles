#!/bin/bash

print() {
    state=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep state | cut -d ':' -f2 | xargs)
    capacity=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep percentage | grep -o "[0-9]*")

    JSON_STRING=$(jq -n \
        --arg state $state \
        --arg capacity $capacity \
        '{state: $state, capacity: $capacity}')
    echo $JSON_STRING
}

upower -m | while read -r _; do
    print
done
