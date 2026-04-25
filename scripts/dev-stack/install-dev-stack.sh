#!/bin/bash
# Development Stack Installer for EndeavourOS (Arch-based)
# Installs: PHP 8.1 + OCI8, Composer v2, Oracle Instant Client 12c, Node.js
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

ORACLE_LIBS="$DOTFILES_DIR/oracle/libs"
ORACLE_EXTRACT_DIR="/opt/oracle"
ORACLE_DIR="/opt/oracle/instantclient_12_2"

echo ""
echo "========================================================"
echo "  Dev Stack Installer: PHP 8.1 + OCI8, Node.js"
echo "  Composer v2, Oracle Instant Client 12c"
echo "========================================================"
echo ""

# ─── Step 1: System Dependencies ─────────────────────────────────────────────
echo "[1/7] Installing system dependencies..."
sudo pacman -S --noconfirm --needed libaio autoconf gcc make unzip

# ─── Step 2: Node.js ──────────────────────────────────────────────────────────
echo "[2/7] Installing Node.js..."
sudo pacman -S --noconfirm --needed nodejs npm
node --version
npm --version

# ─── Step 3: PHP 8.1 + Extensions ────────────────────────────────────────────
echo "[3/7] Installing PHP 8.1 and extensions from AUR..."
yay -S --noconfirm --needed \
    php81 \
    php81-cli \
    php81-fpm \
    php81-curl \
    php81-mbstring \
    php81-xml \
    php81-dom \
    php81-zip \
    php81-gd \
    php81-intl \
    php81-bcmath \
    php81-pdo \
    php81-mysql \
    php81-tokenizer \
    php81-simplexml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-fileinfo \
    php81-openssl \
    php81-ctype \
    php81-phar \
    php81-iconv \
    php81-exif \
    php81-pcntl \
    php81-posix \
    php81-sodium \
    php81-opcache \
    php81-sockets \
    php81-pear

echo "  PHP 8.1 installed."
php81 --version

# ─── Step 4: Composer v2 ──────────────────────────────────────────────────────
echo "[4/7] Installing Composer v2..."
sudo pacman -S --noconfirm --needed composer
COMPOSER_VER=$(composer --version)
echo "  $COMPOSER_VER"
# Ensure it is v2
if composer --version | grep -q "Composer version 1"; then
    echo "  WARNING: pacman installed Composer v1, upgrading to v2..."
    sudo composer self-update --2
fi

# ─── Step 5: Oracle Instant Client 12c ───────────────────────────────────────
echo "[5/7] Setting up Oracle Instant Client 12c..."
sudo mkdir -p "$ORACLE_EXTRACT_DIR"

if [ ! -d "$ORACLE_LIBS" ]; then
    echo "  ERROR: Oracle library directory not found at $ORACLE_LIBS"
    echo "  Please ensure you have placed the Oracle zips in the 'oracle/libs' folder of this repo."
    exit 1
fi

echo "  Extracting instantclient-basic..."
sudo unzip -o "$ORACLE_LIBS/instantclient-basic-linux.x64-12.2.0.1.0.zip" \
    -d "$ORACLE_EXTRACT_DIR" > /dev/null

echo "  Extracting instantclient-sdk..."
sudo unzip -o "$ORACLE_LIBS/instantclient-sdk-linux.x64-12.2.0.1.0.zip" \
    -d "$ORACLE_EXTRACT_DIR" > /dev/null

# The zips extract into instantclient_12_2 folder inside ORACLE_EXTRACT_DIR
if [ ! -d "$ORACLE_DIR" ]; then
    echo "  ERROR: Expected directory $ORACLE_DIR not found after extraction."
    ls "$ORACLE_EXTRACT_DIR"
    exit 1
fi

# Create required symlinks
cd "$ORACLE_DIR"
[ ! -f libclntsh.so ]   && sudo ln -sf libclntsh.so.12.1  libclntsh.so
[ ! -f libocci.so ]     && sudo ln -sf libocci.so.12.1    libocci.so
[ ! -f libclntshcore.so ] && sudo ln -sf libclntshcore.so.12.1 libclntshcore.so 2>/dev/null || true
cd - > /dev/null

# Register with ldconfig
echo "$ORACLE_DIR" | sudo tee /etc/ld.so.conf.d/oracle-instantclient.conf > /dev/null
sudo ldconfig
echo "  Oracle Instant Client configured at $ORACLE_DIR"

# ─── Step 6: OCI8 PHP Extension ──────────────────────────────────────────────
echo "[6/7] Installing OCI8 extension for PHP 8.1..."

# Determine pecl binary for php81
PECL_BIN=""
for candidate in pecl81 pecl8.1 pecl; do
    if command -v "$candidate" &>/dev/null; then
        PHP_CHECK=$(${candidate} version 2>/dev/null | grep -i "php.*8\.1" || true)
        if [[ -n "$PHP_CHECK" ]]; then
            PECL_BIN="$candidate"
            break
        fi
    fi
done

# Fallback: use pecl with explicit php81 binary
if [ -z "$PECL_BIN" ] && command -v pecl &>/dev/null; then
    PECL_BIN="pecl"
fi

if [ -z "$PECL_BIN" ]; then
    echo "  ERROR: Could not find pecl. Please install php81-pear."
    exit 1
fi
echo "  Using PECL binary: $PECL_BIN"

# Install oci8 — specify instantclient dir when prompted
ORACLE_HOME="$ORACLE_DIR" \
PHP_DTRACE=no \
    echo "instantclient,$ORACLE_DIR" | sudo -E "$PECL_BIN" install oci8-3.3.0

# ─── Step 7: Configure OCI8 extension ────────────────────────────────────────
echo "[7/7] Configuring OCI8 in PHP 8.1..."

# Detect PHP 8.1 config directory
PHP81_CONF_DIR=""
for dir in /etc/php81/conf.d /etc/php/8.1/mods-available /etc/php81.d; do
    if [ -d "$(dirname $dir)" ] || [ -d "$dir" ]; then
        PHP81_CONF_DIR="$dir"
        break
    fi
done

# Check php81 --ini for the conf.d path
PHP81_CONF_DIR=$(php81 --ini 2>/dev/null | grep "Scan for additional" | sed 's/.*: //' || echo "")

if [ -z "$PHP81_CONF_DIR" ] || [ "$PHP81_CONF_DIR" = "  (none)" ]; then
    # Default for AUR php81 package
    PHP81_CONF_DIR="/etc/php81/conf.d"
fi

sudo mkdir -p "$PHP81_CONF_DIR"
echo "extension=oci8.so" | sudo tee "$PHP81_CONF_DIR/oci8.ini" > /dev/null
echo "  OCI8 configured in $PHP81_CONF_DIR/oci8.ini"

# ─── Verification ─────────────────────────────────────────────────────────────
echo ""
echo "========================================================"
echo "  Installation Complete — Summary"
echo "========================================================"
echo ""
echo "PHP 8.1:   $(php81 --version | head -1)"
echo "Node.js:   $(node --version)"
echo "npm:       $(npm --version)"
echo "Redis:     $(redis-cli --version)"
echo "Composer:  $(composer --version)"
echo ""
echo "PHP loaded extensions:"
php81 -m | grep -E "oci8|redis|pdo|mbstring|curl|xml|zip|gd|intl|bcmath|json|openssl|opcache" || true
echo ""
echo "Oracle Instant Client: $ORACLE_DIR"
ls "$ORACLE_DIR"/*.so.* 2>/dev/null | head -5 || true
echo ""
echo "OCI8: $(php81 -m | grep -i oci8 && echo 'INSTALLED' || echo 'NOT FOUND - check errors above')"
