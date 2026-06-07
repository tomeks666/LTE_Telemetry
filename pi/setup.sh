#!/usr/bin/env bash
# setup.sh — Master setup, run ON the Raspberry Pi.
#
#   sudo ./setup.sh           # do everything
#   sudo ./setup.sh --no-tailscale   # skip the Tailscale step (do it later)
#
# Steps:
#   1. Configure the UART (frees PL011 to GPIO, disables BT + serial console)
#   2. Build & install mavlink-router + service + config
#   3. Install Tailscale and bring the link up (unless --no-tailscale)
#
# A REBOOT is required afterwards for the UART change to take effect.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo:  sudo ./setup.sh" >&2; exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DO_TAILSCALE=1
[[ "${1:-}" == "--no-tailscale" ]] && DO_TAILSCALE=0

echo "############################################"
echo "# 1/3  UART configuration"
echo "############################################"
bash "$SCRIPT_DIR/config-uart.sh"

echo
echo "############################################"
echo "# 2/3  mavlink-router"
echo "############################################"
bash "$SCRIPT_DIR/install-mavlink-router.sh"

if [[ $DO_TAILSCALE -eq 1 ]]; then
  echo
  echo "############################################"
  echo "# 3/3  Tailscale"
  echo "############################################"
  bash "$SCRIPT_DIR/install-tailscale.sh"
else
  echo
  echo "Skipping Tailscale (--no-tailscale). Run pi/install-tailscale.sh later."
fi

echo
echo "================================================================"
echo "Setup complete. REBOOT now to activate the UART change:"
echo "    sudo reboot"
echo
echo "After reboot, verify:"
echo "    ls -l /dev/serial0              # -> ttyAMA0"
echo "    systemctl status mavlink-router"
echo "    tailscale ip -4                 # the 100.x address for your GCS"
echo "================================================================"
