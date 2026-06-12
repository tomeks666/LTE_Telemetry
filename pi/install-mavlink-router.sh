#!/usr/bin/env bash
# install-mavlink-router.sh — Build & install mavlink-router from source.
#
# There is no official .deb, so we compile. On a Pi 3B (ARMv7, 4 cores) this
# takes ~3-5 min. One-time cost; the binary is tiny and fast.
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
# mavlink-router's meson.build does dependency('systemd'), which resolves the
# pkg-config module named "systemd" (systemd.pc). On Debian Trixie+ (systemd 257)
# that .pc file moved OUT of libsystemd-dev into the separate systemd-dev package.
# We need BOTH: systemd-dev (systemd.pc, unit dir) and libsystemd-dev (libsystemd.pc,
# headers for sd_notify). cmake is a fallback dependency resolver meson probes for.
apt-get install -y git ninja-build pkg-config gcc g++ \
  systemd-dev libsystemd-dev cmake python3-pip
# meson newer than the apt version is often needed; pip gives a current one.
pip3 install --break-system-packages meson 2>/dev/null || pip3 install meson

echo "==> Fetching mavlink-router source..."
if [[ ! -d "$SRC/.git" ]]; then
  rm -rf "$SRC"
  git clone https://github.com/mavlink-router/mavlink-router.git "$SRC"
else
  # Best-effort update; never let a flaky 4G pull abort the whole build.
  git -C "$SRC" pull --ff-only || echo "    (pull skipped — using existing checkout)"
fi
# Submodules are REQUIRED to build. 4G can drop mid-fetch, so retry.
for attempt in 1 2 3 4 5; do
  if git -C "$SRC" submodule update --init --recursive; then
    break
  fi
  echo "    submodule fetch attempt $attempt failed; retrying in 3s..."
  sleep 3
done

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

echo "==> Installing our systemd unit (robust against mavlink-router's own install path)..."
BIN="$(command -v mavlink-routerd || echo /usr/local/bin/mavlink-routerd)"
echo "    binary at: $BIN"
sed "s|^ExecStart=.*|ExecStart=$BIN -c /etc/mavlink-router/main.conf|" \
  "$SCRIPT_DIR/mavlink-router.service" > /etc/systemd/system/mavlink-router.service

echo "==> Enabling service..."
systemctl daemon-reload
systemctl enable mavlink-router.service

echo
echo "mavlink-router installed. Start it with:"
echo "    sudo systemctl start mavlink-router"
echo "Check it with:"
echo "    systemctl status mavlink-router"
echo "    journalctl -u mavlink-router -f"
