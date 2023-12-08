#!/bin/bash

echo "(box
    :orientation 'v'
    :vexpand true
" 
    
 for ((i = 0; i <= 4; ++i)); do
    item_content=$(copyq read $i)
    ((index=i+1))
    escaped_content=$(echo "$item_content" | sed "s/'/\\\\'/g")
    echo "
    (eventbox
        :cursor 'pointer'
        :onclick '"copyq select $i"'
        :class 'clipboard'
        (label 
            :class 'text-light'
            :xalign 0
            :limit-width 50
            :text '"$index. $escaped_content"'
        )
    )"
 done
echo ")"