#!/bin/bash

print() {
  state=$(pamixer --get-mute)
  level=$(pamixer --get-volume | tr -d '%')

  JSON_STRING=$(jq -n \
    --arg state $state \
    --arg level $level \
    '{state: $state, level: $level}')
  echo $JSON_STRING
}

print

pactl subscribe | grep --line-buffered "on sink" | while read -r _; do
  print
done
