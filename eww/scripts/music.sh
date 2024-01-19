#!/bin/bash

time_to_seconds() {
  local time=$1
  IFS=':' read -r minutes seconds <<<"$time"
  echo $((minutes * 60 + seconds))
}

pp=$(playerctl --list-all)

if [[ -z "$pp" || "$pp" == "No players found" ]]; then
  echo '(box
          :halign "center"
          (label :text "No players found")
        )'
else

  echo '(box
          :orientation "v"
          :valign "start"
          :space-evenly false
        '

  for i in $pp; do
    playerctl metadata -F -f '{{playerName}} {{title}} {{artist}} {{mpris:artUrl}} {{status}} {{mpris:length}}' | while read -r line; do
      title=$(playerctl metadata -f "{{title}}")
      artist=$(playerctl metadata -f "{{artist}}")
      artUrl=$(playerctl metadata -f "{{mpris:artUrl}}")
      status=$(playerctl metadata -f "{{status}}")
      # length=$(playerctl metadata -f "{{mpris:length}}")
      # if [[ $length != "" ]]; then
      #   length=$(($length / 1000000))
      #   length=$(echo "($length + 0.5) / 1" | bc)
      # fi
      # lengthStr=$(playerctl metadata -f "{{duration(mpris:length)}}")

      echo '(box
        :orientation "h"
        :space-evenly false
        :spacing 20
        :class "player"
        '

      if [[ ! -z "$artUrl" ]]; then
        echo '(box
              :space-evenly false
              :width 100
              :height 100
              :style "background-image: url(\"'$artUrl'\"); background-size: cover; background-repeat: no-repeat; background-position: center;"
            )'
      fi
      echo '(box
            :orientation "v"
            :hexpand true
            (label 
            :limit-width 35
            :text "'"$artist"'")
            (label 
            :limit-width 35
            :text "'"$title"'")
          (box
            (eventbox
              :cursor "pointer"
              :onclick "playerctl --player='"$i"' previous"
              (label
                :style "font-size: 1.4em;"
                :text "󰙤"
              )
            )
            (eventbox
              :cursor "pointer"
              :onclick "playerctl --player='"$i"' play-pause"
              :class "music-btn"
              (label
                :style "font-size: 1.4em;"
                :text {
                  "'"$status"'" == "Playing" ? "󰏦" : "󰐍"
                }
              )
            )
            (eventbox
              :cursor "pointer"
              :onclick "playerctl --player='"$i"' next"
              :class "music-btn"
              (label 
                :style "font-size: 1.4em;"
                :text "󰙢"
              )
            )
          )
    ))'

      echo ')'
    done
  done

fi
