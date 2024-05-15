#!/bin/bash

print() {
    type=$(nmcli -f TYPE connection show --active | awk 'NR==2')
    wifiStatus=$(nmcli r wifi)
    localIP=$(ip route | awk 'NR==1 { print $9 }')

    JSON_STRING=$(jq -n \
        --arg type "$type" \
        --arg wifiStatus "$wifiStatus" \
        --arg localIP "$localIP" \
        '{type: $type, wifiStatus: $wifiStatus, localIP: $localIP}')
    echo $JSON_STRING
}

print

nmcli monitor | while read -r _; do
    print
done
