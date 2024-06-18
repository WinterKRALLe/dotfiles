#!/bin/bash

path=/sys/class/backlight/amdgpu_bl1

cat "$path"/actual_brightness

inotifywait -me modify --format '' "$path"/actual_brightness 2>/dev/null | while read; do
	cat "$path"/actual_brightness
done
