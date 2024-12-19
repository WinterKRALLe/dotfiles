playerctl metadata -F -f '{{playerName}} {{title}} {{artist}} {{mpris:artUrl}} {{status}} {{mpris:length}}' | while read -r line; do
    player_numbers=($(playerctl -l | awk '{print $NF}' | awk -F '_' '{print $NF}' | sort -u | awk '{print NR}'))
    result="[${player_numbers[@]}]"
    result="${result// /,}"
    echo $result
done
