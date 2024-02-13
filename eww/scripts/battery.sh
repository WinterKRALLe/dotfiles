player_numbers=()
while IFS= read -r player; do
    number=$(echo "$player" | awk -F '_' '/[0-9]+$/ {print $NF}')
    if [[ -n "$number" ]]; then
        player_numbers+=("$number")
    fi
done < <(playerctl -l)

echo "[${player_numbers[@]}]"
