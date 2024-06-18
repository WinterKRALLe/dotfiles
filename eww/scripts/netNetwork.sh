#!/bin/bash

print() {
    type=$(nmcli -f TYPE connection show --active | awk 'NR==2')
    wifiStatus=$(nmcli r wifi)
    localIP=$(ip route | awk 'NR==1 { print $9 }')
    interface=$(ip route get 1.1.1.1 | awk '{ print $5 }' | tr -d '\n' | cut -f1 -d '%')

    JSON_STRING=$(jq -n \
        --arg type "$type" \
        --arg wifiStatus "$wifiStatus" \
        --arg localIP "$localIP" \
        --arg interface "$interface" \
        '{type: $type, wifiStatus: $wifiStatus, localIP: $localIP, interface: $interface}')
    echo $JSON_STRING
}

# print

journalctl -u systemd-networkd.service -f | while read -r _; do
    if [[ $line =~ "Connected" || $line =~ "Link DOWN" ]]; then
        echo "change"
    fi
done
