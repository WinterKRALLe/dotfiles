#!/bin/bash

function remove_leading_zeros() {
    local value=$1
    echo $((10#$value))
}

time_to_seconds() {
    local time=$1
    IFS=':' read -r minutes seconds <<< "$time"
    echo $((minutes * 60 + seconds))
}

# function time_to_seconds() {
#     local time_str=$1
#     local hours=${time_str%%:*}
#     time_str=${time_str#*:}
#     local minutes=${time_str%%:*}
#     local seconds=${time_str##*:}
#     hours=$(remove_leading_zeros "$hours")
#     minutes=$(remove_leading_zeros "$minutes")
#     seconds=$(remove_leading_zeros "$seconds")
#     echo $((hours * 3600 + minutes * 60 + seconds))
# }

duration=$(playerctl metadata --format "{{duration(mpris:length)}}")

atPosition=$(playerctl metadata --format "{{duration(position)}}")

song_duration_seconds=$(time_to_seconds $duration)

current_position_seconds=$(time_to_seconds $atPosition)

# percentage=0

# if [[ $song_duration_seconds -ne 0 ]]; then
#     percentage=$(( ($current_position_seconds * 100) / $song_duration_seconds ))
# fi

pp=$(playerctl --list-all)
echo '(box
      :class "music"
      :orientation "h"
      :space-evenly false
      :halign "center"
      :spacing 20'

for i in $pp; do
    music=$(playerctl --player=$i metadata --format "{{artist}} - {{title}}")
    playerStatus=$(playerctl --player=$i status)

    isSpotify=false
    if [[ $i == *"spotify"* ]]; then
        isSpotify=true
    fi

    echo '
      (box
        :orientation "v"
        :style "min-width: 5em"
        (label :text "'"$music"'")'
if $isSpotify; then
        echo '
          (box
            :class "progress"
              (scale
              :min 0
              :value '$current_position_seconds'
              :max '$song_duration_seconds'
              :onchange "playerctl position {}"
            )
          )'
    fi
        echo '(box
          :class "buttons"
          (eventbox
            :cursor "pointer"
            :onclick "playerctl --player='"$i"' previous"
            :class "music-btn"
            (label :text "󰙤")
          )
          (eventbox
            :cursor "pointer"
            :onclick "playerctl --player='"$i"' play-pause"
            :class "music-btn"
            (label :text {
              "'"$playerStatus"'" == "Playing" ? "󰏦" : "󰐍"
            })
          )
          (eventbox
            :cursor "pointer"
            :onclick "playerctl --player='"$i"' next"
            :class "music-btn"
            (label :text "󰙢")
          )

    
    ))'
done
echo ')'
