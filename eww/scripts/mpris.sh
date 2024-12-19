#!/bin/bash

playerctl metadata -F -f '{{playerName}} {{title}} {{artist}} {{mpris:artUrl}} {{status}} {{mpris:length}}' | while read -r line; do
    players_json="["
    first=true

    for playerName in $(playerctl -l); do
        title=$(playerctl --player=$playerName metadata -f "{{title}}")
        artist=$(playerctl --player=$playerName metadata -f "{{artist}}")
        artUrl=$(playerctl --player=$playerName metadata -f "{{mpris:artUrl}}")
        status=$(playerctl --player=$playerName metadata -f "{{status}}")
        name=$playerName

        if [[ $length != "" ]]; then
            length=$(($length / 1000000))
            length=$(echo "($length + 0.5) / 1" | bc)
        fi
        lengthStr=$(playerctl metadata -f "{{duration(mpris:length)}}")

        JSON_STRING=$(jq -n \
            --arg name "$name" \
            --arg title "$title" \
            --arg artist "$artist" \
            --arg artUrl "$artUrl" \
            --arg status "$status" \
            --arg length "$length" \
            --arg lengthStr "$lengthStr" \
            '{name: $name, title: $title, artist: $artist, artUrl: $artUrl, status: $status, length: $length, lengthStr: $lengthStr}')

        if [ "$first" = true ]; then
            first=false
        else
            players_json="$players_json,"
        fi

        players_json="$players_json$JSON_STRING"
    done
    echo $players_json"]"
done
