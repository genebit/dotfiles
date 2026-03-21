#!/bin/bash
# Unified virtual desktop switching for dual-monitor setup
# DP-3 (left):  workspaces 1-5
# DP-2 (right): workspaces 6-10  (paired: 6=vd1, 7=vd2, 8=vd3, 9=vd4, 10=vd5)

CMD=$1
N=$2

get_focused_monitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name'
}

get_current_vd() {
    local monitor=$1
    local ws
    ws=$(hyprctl monitors -j | jq -r ".[] | select(.name==\"$monitor\") | .activeWorkspace.id")
    if [ "$monitor" = "DP-2" ]; then
        echo $((ws - 5))
    else
        echo "$ws"
    fi
}

switch_both() {
    local n=$1
    local focused
    focused=$(get_focused_monitor)
    hyprctl --batch "dispatch focusmonitor DP-3 ; dispatch workspace $n ; dispatch focusmonitor DP-2 ; dispatch workspace $((n + 5)) ; dispatch focusmonitor $focused"
}

switch_next() {
    local focused
    focused=$(get_focused_monitor)
    local current
    current=$(get_current_vd "$focused")
    local target=$(( (current % 5) + 1 ))
    switch_both "$target"
}

switch_prev() {
    local focused
    focused=$(get_focused_monitor)
    local current
    current=$(get_current_vd "$focused")
    local target
    if [ "$current" -le 1 ]; then
        target=5
    else
        target=$((current - 1))
    fi
    switch_both "$target"
}

case $CMD in
    switch)
        switch_both "$N"
        ;;

    switch-next)
        switch_next
        ;;

    switch-prev)
        switch_prev
        ;;

    move)
        focused=$(get_focused_monitor)
        if [ "$focused" = "DP-3" ]; then
            hyprctl dispatch movetoworkspacesilent "$N"
        else
            hyprctl dispatch movetoworkspacesilent "$((N + 5))"
        fi
        switch_both "$N"
        ;;

    move-next)
        focused=$(get_focused_monitor)
        current=$(get_current_vd "$focused")
        target=$(( (current % 5) + 1 ))
        if [ "$focused" = "DP-3" ]; then
            hyprctl dispatch movetoworkspacesilent "$target"
        else
            hyprctl dispatch movetoworkspacesilent "$((target + 5))"
        fi
        switch_both "$target"
        ;;

    move-prev)
        focused=$(get_focused_monitor)
        current=$(get_current_vd "$focused")
        if [ "$current" -le 1 ]; then
            target=5
        else
            target=$((current - 1))
        fi
        if [ "$focused" = "DP-3" ]; then
            hyprctl dispatch movetoworkspacesilent "$target"
        else
            hyprctl dispatch movetoworkspacesilent "$((target + 5))"
        fi
        switch_both "$target"
        ;;
esac
