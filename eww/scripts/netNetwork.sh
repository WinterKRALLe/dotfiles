#!/bin/bash

print() {
  # Extract and process WiFi data
  readarray -t wifi_data < <(
    nmcli -t -f SSID,MODE,FREQ,RATE,SIGNAL dev wifi | awk -F: '
    function get_wifi_standard(freq, rate) {
      if (freq >= 2400 && freq < 2500) {
        return "4"  # 2.4 GHz (802.11n)
      } else if (freq >= 5000 && freq < 6000) {
        if (rate <= 3500) {
          return "5"  # 5 GHz (802.11ac)
        } else {
          return "6"  # 5 GHz or 6 GHz (802.11ax)
        }
      } else if (freq >= 6000 && freq < 7000) {
        return "6"  # 6 GHz (802.11ax)
      }
      return "Unknown"
    }
    {
      wifi_standard = get_wifi_standard($3, $4)
      ssid_key = $1 ":" wifi_standard  # Concatenate SSID and standard as key
      # Compare the signal strength and select the best one for each unique SSID and standard
      if (!(ssid_key in signals) || signals[ssid_key] < $5) {
        signals[ssid_key] = $5
        standards[ssid_key] = wifi_standard
        ssids[ssid_key] = $1
      }
    }
    END {
      for (ssid_key in signals) {
        split(ssid_key, ssid_std_arr, ":")
        ssid = ssid_std_arr[1]
        standard = ssid_std_arr[2]
        signal = signals[ssid_key]
        print ssid ":" standard ":" signal
      }
    }
    ' | sort -t: -k1,1 -k2,2 -k3,3nr
  )

  # Separate SSIDs, standards, and signals into arrays
  ssid_array=()
  standards_array=()
  signals_array=()
  count_array=()
  count=1

  for entry in "${wifi_data[@]}"; do
    IFS=':' read -r ssid standard signal <<<"$entry"
    ssid_array+=("$ssid")
    standards_array+=("$standard")
    signals_array+=("$signal")
    count_array+=("$count")
    count=$((count + 1))
  done

  # Get other network information
  type=$(nmcli -f TYPE connection show --active | awk 'NR==2')
  wifiStatus=$(nmcli r wifi)
  localIP=$(ip route | awk 'NR==1 { print $9 }')
  interface=$(ip route get 1.1.1.1 | awk '{ print $5 }' | tr -d '\n' | cut -f1 -d '%')

  # Get the current SSID you're connected to
  current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
  current_standard="Unknown"

  # Find the current SSID's standard if connected
  if [ -n "$current_ssid" ]; then
    for entry in "${wifi_data[@]}"; do
      IFS=':' read -r ssid standard signal <<<"$entry"
      if [ "$ssid" == "$current_ssid" ]; then
        current_standard=$standard
        break
      fi
    done
  fi

  # Create the final JSON string
  JSON_STRING=$(
    jq -n \
      --argjson ssid "$(printf '%s\n' "${ssid_array[@]}" | jq -R . | jq -s .)" \
      --argjson standards "$(printf '%s\n' "${standards_array[@]}" | jq -R . | jq -s .)" \
      --argjson signals "$(printf '%s\n' "${signals_array[@]}" | jq -R . | jq -s .)" \
      --argjson available_wifi_count "$(printf '%s\n' "${count_array[@]}" | jq -R . | jq -s .)" \
      --arg type "$type" \
      --arg wifiStatus "$wifiStatus" \
      --arg interface "$interface" \
      --arg currentSsid "$current_ssid" \
      --arg currentStandard "$current_standard" \
      '{ssid: $ssid, standards: $standards, signals: $signals, available_wifi_count: $available_wifi_count, type: $type, wifiStatus: $wifiStatus, interface: $interface, currentSsid: $currentSsid, currentStandard: $currentStandard}'
  )

  echo "$JSON_STRING"
}

print
