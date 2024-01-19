#!/bin/bash

echo "(box
    :orientation 'v'
    :vexpand true
    :spacing 10
"

for ((i = 0; i <= 4; ++i)); do
    item_content=$(copyq read $i)
    ((index = i + 1))
    escaped_content=$(echo "$item_content" | sed "s/['\\]/\\\\&/g")
    echo "
    (eventbox
        :cursor 'pointer'
        :onclick '"copyq select $i"'
        :class 'clipboard button'
        (label 
            :class 'text-light'
            :xalign 0
            :limit-width 55
            :text '"$index. $escaped_content"'
        )
    )"
done
echo ")"
