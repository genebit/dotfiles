# dotfiles

**Hyprland · Gruvbox Dark · EndeavourOS**

Dual-monitor Hyprland setup with a consistent Gruvbox dark theme across all apps.

## What's included

| Config | Description |
|--------|-------------|
| `hypr/` | Hyprland WM, hypridle, hyprlock, dual-monitor workspace script |
| `waybar/` | Status bar (dual-monitor), power menu, VPN toggle |
| `kitty/` | Terminal — Gruvbox, JetBrainsMono, 88% opacity |
| `rofi/` | App launcher + power menu |
| `gtk-3.0/4.0/` | Breeze dark theme, Papirus-Dark icons, breeze_cursors |
| `cava/` | Waybar audio visualizer output |
| `home/` | `.bashrc` (aliases: `php`, `composer`) |
| `wallpapers/` | Desktop wallpaper (`wall.jpg`) |

## Current Setup
<img width="3841" height="1080" alt="image" src="https://github.com/user-attachments/assets/33535b52-0e53-4414-bcc9-9217241e61b0" />

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
| **Launcher** | Rofi |
| **GTK theme** | Breeze |
| **Icons** | Papirus-Dark |
| **Cursor** | breeze_cursors |
| **Font (UI)** | Geist Mono |
| **Font (GTK)** | Geist |

## VPN (OpenVPN)

A custom Waybar module (`custom/vpn`) shows connection status and toggles on click.

- **Connected** — shows `󰒃  VPN` in green, tooltip shows your VPN IP
- **Disconnected** — shows `󰖂  VPN` in gray
- **Left-click** — connects or disconnects

The VPN config files live at `~/Developer/adnu/vpn/config/` and are **not** tracked in dotfiles (they contain certs/keys).

### First-time setup on a new machine

1. **Install OpenVPN:**
   ```bash
   sudo pacman -S openvpn
   ```

2. **Place your VPN config files** at `~/Developer/adnu/vpn/config/`:
   - `mis-gene.ovpn`
   - `ca.crt`, `mis-gene.crt`, `mis-gene-nopass.key`, `ta.key`

3. **Strip the private key passphrase** (required for click-to-connect):
   ```bash
   cd ~/Developer/adnu/vpn/config
   openssl rsa -in mis-gene.key -out mis-gene-nopass.key
   chmod 600 mis-gene-nopass.key
   ```
   Then ensure `mis-gene.ovpn` references `mis-gene-nopass.key`.

4. **Allow passwordless sudo** for openvpn commands:
   ```bash
   sudo tee /etc/sudoers.d/openvpn <<< "$(whoami) ALL=(ALL) NOPASSWD: /usr/bin/openvpn *, /usr/bin/killall openvpn"
   sudo chmod 440 /etc/sudoers.d/openvpn
   ```

5. **Reload Waybar:**
   ```bash
   pkill waybar && waybar &
   ```

## Monitors

Default config assumes:
- `DP-3` — left monitor, workspaces 1–5
- `DP-2` — right monitor, workspaces 6–10 (paired with left)

Edit `config/hypr/hyprland.conf` monitor/workspace lines to match your setup.
