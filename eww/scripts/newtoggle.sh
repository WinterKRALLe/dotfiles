#!/bin/bash

toggle_window() {
    MONITOR=$(hyprctl monitors | awk '/model/ {gsub("[:)]",""); id=$NF} /focused: yes/ {print id}' | awk '{if (NF) print}')
    window_name=$1
    state_var="open_$window_name"
    state=$(eww get "$state_var")

    open_window() {
        eww open --screen $MONITOR $window_name-closer
        eww open --screen $MONITOR $window_name
        eww update "$state_var=true"
    }

    close_window() {
        eww close $window_name-closer
        eww update "$state_var=false"
        sleep 0.5s
        eww close $window_name
    }

    case $1 in
    close)
        close_window
        exit 0
        ;;
    esac

    case $state in
    true)
        close_window
        ;;
    false)
        open_window
        ;;
    esac
}

toggle_window $1
