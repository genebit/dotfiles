#!/usr/bin/env bash

CACHE="$HOME/.cache/rofi-appmenu"

# Execute selected app
if [[ "$ROFI_RETV" == "1" ]]; then
    setsid gtk-launch "$ROFI_INFO" &>/dev/null &
    exit
fi

# Rebuild cache if any .desktop file is newer
if [[ ! -f "$CACHE" ]] || find /usr/share/applications ~/.local/share/applications \
        -name "*.desktop" -newer "$CACHE" 2>/dev/null | grep -q .; then
    declare -A seen
    {
        printf '\0markup-rows\x1ftrue\n'
        while IFS= read -r desktop; do
            name=$(grep -m1 "^Name=" "$desktop" 2>/dev/null | cut -d= -f2-)
            nodisplay=$(grep -m1 "^NoDisplay=" "$desktop" 2>/dev/null | cut -d= -f2-)
            hidden=$(grep -m1 "^Hidden=" "$desktop" 2>/dev/null | cut -d= -f2-)
            exec_line=$(grep -m1 "^Exec=" "$desktop" 2>/dev/null)

            [[ -z "$name" || -z "$exec_line" ]] && continue
            [[ "$nodisplay" == "true" || "$hidden" == "true" ]] && continue
            [[ -n "${seen[$name]}" ]] && continue
            seen[$name]=1

            desktop_id=$(basename "$desktop" .desktop)
            printf '<span foreground="#fe8019" size="x-small">⬤</span>  %s\0info\x1f%s\n' "$name" "$desktop_id"
        done < <(find /usr/share/applications ~/.local/share/applications \
            -name "*.desktop" 2>/dev/null | sort)
    } > "$CACHE"
fi

cat "$CACHE"
