#!/usr/bin/env bash
# install-mavlink-router.sh — Build & install mavlink-router from source.
#
# There is no official ARMv6 .deb, so we compile. On a Pi Zero W this takes
# ~10-20 min (single core). One-time cost; the binary is tiny and fast.
#
# Run as root:  sudo ./install-mavlink-router.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo." >&2; exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC=/usr/local/src/mavlink-router

echo "==> Installing build dependencies..."
apt-get update
# libsystemd-dev provides systemd.pc — mavlink-router links libsystemd (sd_notify)
# and meson.build hard-requires it via pkg-config. cmake is a fallback resolver meson
# probes for; having it avoids the "Found CMake: NO" detour during dependency lookup.
apt-get install -y git ninja-build pkg-config gcc g++ libsystemd-dev cmake python3-pip
# meson newer than the apt version is often needed; pip gives a current one.
pip3 install --break-system-packages meson 2>/dev/null || pip3 install meson

echo "==> Fetching mavlink-router source..."
if [[ -d "$SRC/.git" ]]; then
  git -C "$SRC" pull --recurse-submodules
  git -C "$SRC" submodule update --init --recursive
else
  rm -rf "$SRC"
  git clone --recurse-submodules https://github.com/mavlink-router/mavlink-router.git "$SRC"
fi

echo "==> Building (this is the slow part on a Pi Zero)..."
cd "$SRC"
meson setup build . --buildtype=release --wipe || meson setup build .
ninja -C build

echo "==> Installing..."
ninja -C build install
ldconfig

echo "==> Installing config to /etc/mavlink-router/main.conf..."
install -d /etc/mavlink-router
if [[ -f /etc/mavlink-router/main.conf ]]; then
  echo "    existing config found — saving new one as main.conf.new"
  install -m 644 "$SCRIPT_DIR/mavlink-router/main.conf" /etc/mavlink-router/main.conf.new
else
  install -m 644 "$SCRIPT_DIR/mavlink-router/main.conf" /etc/mavlink-router/main.conf
fi

echo "==> Enabling service..."
systemctl daemon-reload
systemctl enable mavlink-router.service

echo
echo "mavlink-router installed. Start it with:"
echo "    sudo systemctl start mavlink-router"
echo "Check it with:"
echo "    systemctl status mavlink-router"
echo "    journalctl -u mavlink-router -f"
