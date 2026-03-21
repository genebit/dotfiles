#!/bin/bash
# Compiles and installs OCI8 for PHP 8.1 using phpize81
set -e

ORACLE_DIR="/opt/oracle/instantclient_12_2"
OCI8_VERSION="3.2.1"
BUILD_DIR="/tmp/oci8-build"

echo "[1/5] Downloading OCI8 $OCI8_VERSION from PECL..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
curl -fsSL "https://pecl.php.net/get/oci8-${OCI8_VERSION}.tgz" -o "oci8-${OCI8_VERSION}.tgz"
tar -xzf "oci8-${OCI8_VERSION}.tgz"
cd "oci8-${OCI8_VERSION}"

echo "[2/5] Running phpize81..."
phpize81

echo "[3/5] Configuring with Oracle Instant Client at $ORACLE_DIR..."
./configure \
    --with-oci8=instantclient,"$ORACLE_DIR" \
    --with-php-config=/usr/bin/php-config81

echo "[4/5] Building..."
make -j"$(nproc)"

echo "[5/5] Installing..."
sudo make install

# Detect conf.d directory from php81 --ini
PHP81_CONF_DIR=$(php81 --ini 2>/dev/null \
    | grep "Scan for additional" \
    | sed 's/.*: //' \
    | tr -d '[:space:]')

if [ -z "$PHP81_CONF_DIR" ] || [ "$PHP81_CONF_DIR" = "(none)" ]; then
    PHP81_CONF_DIR="/etc/php81/conf.d"
fi

echo "Writing extension config to $PHP81_CONF_DIR/oci8.ini..."
sudo mkdir -p "$PHP81_CONF_DIR"
echo "extension=oci8.so" | sudo tee "$PHP81_CONF_DIR/oci8.ini" > /dev/null

echo ""
echo "=== Verification ==="
php81 -m | grep -i oci8 && echo "OCI8: OK" || echo "OCI8: NOT FOUND — check output above"
php81 --version | head -1

echo ""
echo "Done! Clean up build directory with: rm -rf $BUILD_DIR"
