# dotfiles

**Hyprland · Gruvbox Dark · EndeavourOS**

Dual-monitor Hyprland setup with a consistent Gruvbox dark theme across all apps.

## What's included

| Config | Description |
|--------|-------------|
| `hypr/` | Hyprland WM, hypridle, hyprlock, dual-monitor workspace script |
| `waybar/` | Status bar (dual-monitor), power menu |
| `kitty/` | Terminal — Gruvbox, JetBrainsMono, 88% opacity |
| `rofi/` | Power menu theme |
| `wofi/` | App launcher |
| `gtk-3.0/4.0/` | Breeze dark theme, Papirus-Dark icons, breeze_cursors |
| `cava/` | Waybar audio visualizer output |
| `home/` | `.bashrc` (aliases: `php`, `composer`) |
| `wallpapers/` | Desktop wallpaper (`wall.jpg`) |

## Current Setup
<img width="1923" height="1080" alt="image" src="https://github.com/user-attachments/assets/187b210b-5350-47c8-888e-7d7018e349cf" />


## Install

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
bash install.sh
```

The installer will:
1. Install `yay` if missing
2. Install all pacman + AUR packages
3. Symlink all configs to `~/.config/`
4. Copy wallpaper to `~/Pictures/wallpapers/`
5. Optionally set up the dev stack

## Dev stack (optional)

PHP 8.1 + OCI8 (Oracle), Redis, Composer v2, Node.js.

Requires Oracle Instant Client 12c zips placed at:
```
oracle/libs/instantclient-basic-linux.x64-12.2.0.1.0.zip
oracle/libs/instantclient-sdk-linux.x64-12.2.0.1.0.zip
```
Get them from the `onboarding-resources` repo → `drive/oracle/lib/linux/`.

To run standalone:
```bash
bash scripts/dev-stack/install-dev-stack.sh
bash scripts/dev-stack/install-oci8.sh
```

## Theme

| | |
|---|---|
| **Color scheme** | Gruvbox Dark |
| **WM** | Hyprland |
| **Bar** | Waybar |
| **Terminal** | Kitty |
| **Launcher** | Wofi |
| **GTK theme** | Breeze |
| **Icons** | Papirus-Dark |
| **Cursor** | breeze_cursors |
| **Font (UI)** | JetBrainsMono Nerd Font |
| **Font (GTK)** | Noto Sans |

## Monitors

Default config assumes:
- `DP-3` — left monitor, workspaces 1–5
- `DP-2` — right monitor, workspaces 6–10 (paired with left)

Edit `config/hypr/hyprland.conf` monitor/workspace lines to match your setup.
