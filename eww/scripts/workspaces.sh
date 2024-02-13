#!/bin/bash

n=7

print() {
    # Initialize an associative array
    declare -A array

    for ((i = 1; i <= n; i++)); do
        array["$i"]="0"
    done

    activeWS="$(hyprctl activeworkspace | grep "workspace ID" | awk '{print $3}')"

    readarray -t usedWorkspaces <<<"$(hyprctl workspaces | grep "workspace ID" | awk '{print $3}')"

    # Loop through usedWorkspaces and set corresponding elements to "2"
    for workspace_id in "${usedWorkspaces[@]}"; do
        if [ "$workspace_id" -le "$n" ]; then
            array["$workspace_id"]="2"
        fi
    done

    # Set the element at position activeWS to "1"
    array["$activeWS"]="1"

    # Construct a JSON array manually
    json_array="["
    for ((i = 1; i <= n; i++)); do
        json_array+="${array[$i]}"
        if [ "$i" -ne "$n" ]; then
            json_array+=","
        fi
    done
    json_array+="]"

    echo "$json_array"
}

print

socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    if [[ $line =~ "focusedmon" || $line =~ "workspace" ]]; then
        print
    fi
done
