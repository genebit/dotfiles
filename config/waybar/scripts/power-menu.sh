#!/usr/bin/env bash

options=" Lock\n Logout\n Suspend\n Reboot\n Shutdown"

# location 3 = top-right corner; yoffset pushes it below the bar (34px height + 8px margin-top + 4px gap)
chosen=$(echo -e "$options" | rofi \
    -dmenu \
    -p "" \
    -location 3 \
    -xoffset -8 \
    -yoffset 54 \
    -theme ~/.config/rofi/power-menu.rasi)

case "$chosen" in
    " Lock")     hyprlock ;;
    " Logout")   hyprctl dispatch exit ;;
    " Suspend")  systemctl suspend ;;
    " Reboot")   systemctl reboot ;;
    " Shutdown") systemctl poweroff ;;
esac
