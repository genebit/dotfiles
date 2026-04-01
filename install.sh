#!/bin/bash
# ============================================================
#  gennux dotfiles — EndeavourOS / Arch-based installer
#  Installs packages, symlinks configs, sets up dev stack
# ============================================================
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NONE='\033[0m'

log()  { echo -e "${GREEN}[✓]${NONE} $*"; }
info() { echo -e "${CYAN}[→]${NONE} $*"; }
warn() { echo -e "${YELLOW}[!]${NONE} $*"; }
err()  { echo -e "${RED}[✗]${NONE} $*"; exit 1; }

# ─── Prompt ──────────────────────────────────────────────────────────────────

clear
echo -e "${CYAN}"
cat << 'EOF'
   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
   ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
   ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
   gennux — Hyprland · Gruvbox · EndeavourOS
EOF
echo -e "${NONE}"
echo "  This script will:"
echo "  1. Install all required packages (pacman + AUR)"
echo "  2. Symlink all dotfiles to ~/.config"
echo "  3. Copy wallpaper to ~/Pictures/wallpapers"
echo "  4. Optionally install the dev stack (PHP 8.1, Redis, OCI8, Node.js)"
echo ""
read -rp "  Continue? [Y/n]: " confirm
[[ "${confirm,,}" == "n" ]] && echo "Aborted." && exit 0

echo ""

# ─── Sanity checks ───────────────────────────────────────────────────────────

[[ "$EUID" -eq 0 ]] && err "Do not run as root. Run as your normal user (sudo will be called as needed)."
command -v pacman &>/dev/null || err "pacman not found — this script requires an Arch-based distro."

# ─── yay ─────────────────────────────────────────────────────────────────────

if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    sudo pacman -S --noconfirm --needed base-devel git
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    (cd /tmp/yay-install && makepkg -si --noconfirm)
    rm -rf /tmp/yay-install
    log "yay installed."
else
    log "yay already present."
fi

# ─── Pacman packages ─────────────────────────────────────────────────────────

PACMAN_PACKAGES=(
    # System / base
    base-devel git wget curl unzip jq
    # Hyprland stack
    hyprland hyprpaper hypridle hyprlock hyprswitch
    xdg-desktop-portal-hyprland xdg-desktop-portal-kde
    qt5-wayland qt6-wayland
    # Bar / launcher / notifications
    waybar wofi rofi rofi-calc dunst wlogout swww
    # Terminal / file manager
    kitty thunar thunar-archive-plugin
    # Audio
    wireplumber pipewire-pulse pipewire-alsa pamixer playerctl
    pavucontrol
    # Fonts
    ttf-jetbrains-mono-nerd ttf-firacode-nerd ttf-fira-code
    ttf-fira-sans ttf-liberation noto-fonts noto-fonts-emoji
    woff2-font-awesome
    # GTK theme / icons / cursor
    breeze-gtk papirus-folders
    # Screenshots / clipboard
    grim slurp wl-clipboard cliphist
    # Network / Bluetooth
    networkmanager network-manager-applet bluez bluez-utils
    # Utilities
    brightnessctl fastfetch cava gsimplecal
    gum flatpak polkit-gnome
    # Dev stack dependencies
    libaio autoconf gcc make
    # Media
    firefox
)

info "Installing pacman packages..."
sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"
log "Pacman packages done."

# ─── AUR packages ────────────────────────────────────────────────────────────

AUR_PACKAGES=(
    # Hyprland extras
    hyprswitch
    # PHP 8.1 + extensions
    php81 php81-cli php81-fpm
    php81-curl php81-mbstring php81-xml php81-dom php81-zip
    php81-gd php81-intl php81-bcmath php81-pdo php81-mysql
    php81-redis php81-tokenizer php81-simplexml php81-xmlreader
    php81-xmlwriter php81-fileinfo php81-openssl php81-ctype
    php81-phar php81-iconv php81-exif php81-pcntl php81-posix
    php81-sodium php81-opcache php81-sockets php81-pear
)

info "Installing AUR packages..."
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
log "AUR packages done."

# ─── System services ─────────────────────────────────────────────────────────

info "Enabling system services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
sudo systemctl enable --now valkey      2>/dev/null \
    || sudo systemctl enable --now redis 2>/dev/null \
    || warn "Redis/Valkey service not found — skipping."
log "Services enabled."

# ─── Dotfiles symlinks ───────────────────────────────────────────────────────

info "Symlinking dotfiles..."

_link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up existing $dst → $dst.bak"
        mv "$dst" "$dst.bak"
    fi
    ln -sfn "$src" "$dst"
}

_link "$DOTFILES_DIR/config/hypr"      "$HOME/.config/hypr"
_link "$DOTFILES_DIR/config/waybar"    "$HOME/.config/waybar"
_link "$DOTFILES_DIR/config/kitty"     "$HOME/.config/kitty"
_link "$DOTFILES_DIR/config/rofi"      "$HOME/.config/rofi"
_link "$DOTFILES_DIR/config/wofi"      "$HOME/.config/wofi"
_link "$DOTFILES_DIR/config/gtk-3.0"   "$HOME/.config/gtk-3.0"
_link "$DOTFILES_DIR/config/gtk-4.0"   "$HOME/.config/gtk-4.0"
_link "$DOTFILES_DIR/config/cava"      "$HOME/.config/cava"

# Shell files (link individual files, not the whole home dir)
_link "$DOTFILES_DIR/home/.bashrc"       "$HOME/.bashrc"
_link "$DOTFILES_DIR/home/.bash_profile" "$HOME/.bash_profile"

# Make scripts executable
chmod +x "$DOTFILES_DIR/config/hypr/scripts/workspace.sh"
chmod +x "$DOTFILES_DIR/config/waybar/scripts/power-menu.sh"

log "Dotfiles symlinked."

# ─── Wallpaper ───────────────────────────────────────────────────────────────

info "Copying wallpaper..."
mkdir -p "$HOME/Pictures/wallpapers"
cp "$DOTFILES_DIR/wallpapers/wall.jpg" "$HOME/Pictures/wallpapers/wall.jpg"
log "Wallpaper installed at ~/Pictures/wallpapers/wall.jpg"

# ─── Dev stack ───────────────────────────────────────────────────────────────

echo ""
read -rp "  Install dev stack (PHP 8.1 + OCI8, Redis, Composer, Node.js)? [Y/n]: " install_dev
if [[ "${install_dev,,}" != "n" ]]; then
    # Redis / Valkey already started above; install Node.js and Composer
    sudo pacman -S --noconfirm --needed nodejs npm composer

    # OCI8
    ORACLE_LIBS_DEFAULT="$DOTFILES_DIR/oracle/libs"
    if [ -d "$ORACLE_LIBS_DEFAULT" ]; then
        ORACLE_LIBS="$ORACLE_LIBS_DEFAULT"
    else
        warn "Oracle Instant Client zips not found in $ORACLE_LIBS_DEFAULT"
        echo "  Copy them from onboarding-resources/drive/oracle/lib/linux/ first."
        echo "  Expected:"
        echo "    $ORACLE_LIBS_DEFAULT/instantclient-basic-linux.x64-12.2.0.1.0.zip"
        echo "    $ORACLE_LIBS_DEFAULT/instantclient-sdk-linux.x64-12.2.0.1.0.zip"
        read -rp "  Enter path to the directory containing the Oracle zips (or skip): " ORACLE_LIBS
    fi

    if [ -d "$ORACLE_LIBS" ]; then
        info "Setting up Oracle Instant Client..."
        ORACLE_DIR="/opt/oracle/instantclient_12_2"
        sudo mkdir -p /opt/oracle
        sudo unzip -o "$ORACLE_LIBS/instantclient-basic-linux.x64-12.2.0.1.0.zip" -d /opt/oracle/ > /dev/null
        sudo unzip -o "$ORACLE_LIBS/instantclient-sdk-linux.x64-12.2.0.1.0.zip"   -d /opt/oracle/ > /dev/null
        cd "$ORACLE_DIR"
        [ ! -f libclntsh.so ]  && sudo ln -sf libclntsh.so.12.1  libclntsh.so
        [ ! -f libocci.so ]    && sudo ln -sf libocci.so.12.1    libocci.so
        [ ! -f libclntshcore.so ] && sudo ln -sf libclntshcore.so.12.1 libclntshcore.so 2>/dev/null || true
        cd - > /dev/null
        echo "$ORACLE_DIR" | sudo tee /etc/ld.so.conf.d/oracle-instantclient.conf > /dev/null
        sudo ldconfig
        log "Oracle Instant Client configured."

        info "Building OCI8 for PHP 8.1..."
        bash "$DOTFILES_DIR/scripts/dev-stack/install-oci8.sh"
    else
        warn "Skipping Oracle / OCI8 — no valid path provided."
    fi

    log "Dev stack done."
fi

# ─── Done ────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}============================================================${NONE}"
echo -e "${GREEN}  Installation complete!${NONE}"
echo -e "${GREEN}============================================================${NONE}"
echo ""
echo "  Symlinked configs:"
echo "    ~/.config/hypr       → hyprland, hypridle, hyprlock, workspace script"
echo "    ~/.config/waybar     → dual-monitor bar + power menu"
echo "    ~/.config/kitty      → gruvbox terminal"
echo "    ~/.config/rofi       → power menu theme"
echo "    ~/.config/wofi       → app launcher"
echo "    ~/.config/gtk-3.0/4  → breeze dark + papirus-dark icons"
echo "    ~/.config/cava       → waybar audio visualizer"
echo "    ~/.bashrc            → aliases (composer, php)"
echo ""
echo "  Log out and log back in to start Hyprland."
echo ""
