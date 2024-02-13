#!/bin/bash

readarray -t sinks <<< "$(pactl list sinks | grep device.product.name | awk -F=' ' '{print $2}' | tr -d \")"

readarray -t switchSinks <<< "$(pactl list short sinks | awk '{print $2}')"

activeSink="$(pactl get-default-sink)"

n=${#sinks[@]}

echo "(box
        :orientation 'v'
        :space-evenly false
        :spacing 20"

for ((index=0; index<n; index++)); do
    sink="${sinks[index]}"
    switchSink="${switchSinks[index]}"
    
    if [ "$activeSink" == "$switchSink" ]; then
        style="'background-color: #e53265'"
    else
        style="''"
    fi

    echo "(eventbox
            :cursor 'pointer'
            :class 'sink'
            :onclick 'pactl set-default-sink $switchSink'
            :style $style
            (label
                :text '$sink'
                :xalign 0
              )
            )"
done

echo ")"
