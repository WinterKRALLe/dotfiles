#!/bin/bash

print() {
    names=$(pactl list sources | sed -n '/Name:/h;/device.description/!d;x;/input/!d;g;s/.*= "\(.*\)".*/\1/p')
    switches=$(pactl list short sources | grep input | awk '{print $2}')
    names_json=$(echo "$names" | jq -R -s -c 'split("\n") | map(select(length > 0))')
    switches_json=$(echo "$switches" | jq -R -s -c 'split("\n") | map(select(length > 0))')

    active=$(pactl get-default-source)

    name_count=$(echo "$names_json" | jq length)
    switch_count=$(echo "$switches_json" | jq length)

    count=$(seq $name_count | jq -s -c '[.[] | tonumber]')

    JSON_STRING=$(jq -n \
        --argjson names "$names_json" \
        --argjson switches "$switches_json" \
        --arg active "$active" \
        --argjson count "$count" \
        '{names: $names, switches: $switches, active: $active, count: $count}')

    echo $JSON_STRING
}

print

pactl subscribe | while read -r _; do
    print
done
