#!/usr/bin/env bash

if [[ "$ROFI_RETV" == "1" ]]; then
    case "$ROFI_INFO" in
        lock)     hyprlock ;;
        logout)   hyprctl dispatch exit ;;
        reboot)   systemctl reboot ;;
        shutdown) systemctl poweroff ;;
        suspend)  systemctl suspend ;;
    esac
    exit
fi

printf '\0markup-rows\x1ftrue\n'
printf '<span foreground="#fe8019" size="x-small">⬤</span>  Lock\0info\x1flock\n'
printf '<span foreground="#fe8019" size="x-small">⬤</span>  Logout\0info\x1flogout\n'
printf '<span foreground="#fe8019" size="x-small">⬤</span>  Reboot\0info\x1freboot\n'
printf '<span foreground="#fe8019" size="x-small">⬤</span>  Shutdown\0info\x1fshutdown\n'
printf '<span foreground="#fe8019" size="x-small">⬤</span>  Suspend\0info\x1fsuspend\n'
