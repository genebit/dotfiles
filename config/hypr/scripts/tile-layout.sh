#!/bin/bash
# tile-layout.sh [left|right|up|down]
#
# Left/Right  → arrange windows in COLUMNS (side by side)
# Up/Down     → arrange windows in ROWS    (stacked)
#
# Detects current split orientation from window positions and toggles only if needed.

DIRECTION=$1
WORKSPACE=$(hyprctl activewindow -j | jq -r '.workspace.id')
CLIENTS=$(hyprctl clients -j | jq "[.[] | select(.workspace.id == $WORKSPACE and .floating == false)]")
COUNT=$(echo "$CLIENTS" | jq length)

if [ "$COUNT" -lt 2 ]; then
    exit 0
fi

# Infer current layout from the Y positions of windows:
# - Same Y → side by side → columns (vertical split)
# - Different Y → stacked   → rows    (horizontal split)
W1_Y=$(echo "$CLIENTS" | jq '.[0].at[1]')
W2_Y=$(echo "$CLIENTS" | jq '.[1].at[1]')

if [ "$W1_Y" -eq "$W2_Y" ]; then
    CURRENT="columns"
else
    CURRENT="rows"
fi

case $DIRECTION in
    left|right)
        if [ "$CURRENT" != "columns" ]; then
            hyprctl dispatch layoutmsg togglesplit
        fi
        ;;
    up|down)
        if [ "$CURRENT" != "rows" ]; then
            hyprctl dispatch layoutmsg togglesplit
        fi
        ;;
esac
