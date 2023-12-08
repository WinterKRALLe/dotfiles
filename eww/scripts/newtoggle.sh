#!/bin/bash

toggle_window() {
    window_name=$1
    state_var="open_$window_name"
    state=$(eww get "$state_var")

    open_window() {
        eww open "$window_name"
        eww update "$state_var=true"
    }

    close_window() {
        eww update "$state_var=false"
        sleep 1
        eww close $window_name
    }

    case $1 in
        close)
            close_window
            exit 0;;
    esac

    case $state in
        true)
            close_window;;
        false)
            open_window;;
    esac
}

toggle_window $1