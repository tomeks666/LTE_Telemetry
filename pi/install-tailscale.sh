#!/usr/bin/env bash
# install-tailscale.sh — Install Tailscale and bring the link up.
#
# Run as root:  sudo ./install-tailscale.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo." >&2; exit 1
fi

if ! command -v tailscale >/dev/null 2>&1; then
  echo "==> Installing Tailscale..."
  curl -fsSL https://tailscale.com/install.sh | sh
else
  echo "==> Tailscale already installed."
fi

systemctl enable --now tailscaled

echo
echo "==> Bringing the tailnet up."
echo "    A login URL will be printed — open it on any device and approve the Pi."
echo "    --ssh lets you SSH to the Pi over Tailscale from anywhere (handy in the field)."
echo
# --accept-dns=false avoids the 4G stick's DNS being overridden if you don't use MagicDNS.
tailscale up --ssh --accept-dns=false

echo
echo "Pi Tailscale IP:"
tailscale ip -4
echo
echo "Use that 100.x address as the host in Mission Planner / QGC."
