#!/bin/bash

VPN_CONFIG="$HOME/Developer/adnu/vpn/config/mis-gene.ovpn"

case "$1" in
    toggle)
        if ip link show tun0 &>/dev/null 2>&1; then
            sudo killall openvpn
        else
            setsid sudo openvpn --config "$VPN_CONFIG" --daemon \
                --log "$HOME/Developer/adnu/vpn/config/OpenVPN.log" >/dev/null 2>&1 &
        fi
        ;;
    *)
        if ip link show tun0 &>/dev/null 2>&1; then
            IP=$(ip addr show tun0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1)
            echo "{\"text\": \"󰒃  VPN\", \"class\": \"connected\", \"tooltip\": \"Connected • ${IP}\"}"
        else
            echo "{\"text\": \"󰖂  VPN\", \"class\": \"disconnected\", \"tooltip\": \"VPN Disconnected\"}"
        fi
        ;;
esac
