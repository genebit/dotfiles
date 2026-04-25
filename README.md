# dotfiles

**Hyprland · Gruvbox Dark · EndeavourOS**

A dual-monitor Hyprland setup featuring dynamic workspace pairing and a consistent Gruvbox dark theme.

## Current Setup
<img width="3841" height="1080" alt="image" src="https://github.com/user-attachments/assets/26b68773-f9de-4f39-a78d-046086bce99a" />

## What's included

| Config | Description |
|--------|-------------|
| `hypr/` | Hyprland WM, hypridle, hyprlock, dynamic workspace script |
| `waybar/` | Status bar (dual-monitor), power menu, VPN toggle |
| `kitty/` | Terminal — Gruvbox, JetBrainsMono, 88% opacity |
| `rofi/` | App launcher + power menu |
| `gtk-3.0/4.0/` | Breeze dark theme, Papirus-Dark icons |
| `cava/` | Waybar audio visualizer output |
| `home/` | `.bashrc` (aliases: `php`, `composer`, `clock`) |
| `wallpapers/` | Desktop wallpaper managed by `swww` |

## Keybindings (The Essentials)

| Keybind | Action |
|---------|--------|
| `SUPER + T` | Open Terminal (Kitty) |
| `CTRL + Space` | App Launcher (Rofi) |
| `SUPER + B` | Open Browser (Firefox) |
| `SUPER + E` | File Manager (Thunar) |
| `ALT + F4` | Close active window |
| `SUPER + L` | Lock screen |
| `SUPER + 1-5` | Switch "Virtual Desktop" (moves both monitors) |
| `SUPER + SHIFT + 1-5` | Move window to Virtual Desktop |
| `ALT + Tab` | Window Switcher (Hyprswitch) |
| `SUPER + Arrows` | Move focus |
| `SUPER + CTRL + Arrows` | Resize active window |
| `SUPER + SHIFT + M` | Exit Hyprland (Logout) |

## Install

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
bash install.sh
```

## Monitors & Workspaces

This setup uses a **Virtual Desktop** concept for dual monitors:
- **Monitor 1 (Left)**: Shows workspaces 1–5.
- **Monitor 2 (Right)**: Shows workspaces 6–10.
- When you switch to "Desktop 1" (`SUPER+1`), the left monitor shows workspace 1 and the right shows workspace 6.

**Dynamic Detection**: The `workspace.sh` script automatically detects your monitor names. It assigns the first monitor found by `hyprctl` as "Left" and the second as "Right". 

> **Customization**: If your monitors are swapped, edit `~/.config/hypr/hyprland.conf` to explicitly define your monitor names (e.g., `monitor = DP-1, 1920x1080, 0x0, 1`).

## Dev stack (Optional)

PHP 8.1 + OCI8 (Oracle), Composer v2, Node.js. 
*Note: Redis is excluded as it is intended to be run via Docker.*

**Prerequisites for OCI8**: 
Place Oracle Instant Client 12c zips in `oracle/libs/`:
- `instantclient-basic-linux.x64-12.2.0.1.0.zip`
- `instantclient-sdk-linux.x64-12.2.0.1.0.zip`

To install:
```bash
bash scripts/dev-stack/install-dev-stack.sh
```

## VPN (OpenVPN)

The Waybar module (`custom/vpn`) toggles your connection on click. It looks for configs in `~/Developer/adnu/vpn/config/`.

1. **Place certs/keys** in the directory above.
2. **Allow passwordless sudo** for the toggle to work:
   ```bash
   sudo tee /etc/sudoers.d/openvpn <<< "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/openvpn *, /usr/bin/killall openvpn"
   sudo chmod 440 /etc/sudoers.d/openvpn
   ```
