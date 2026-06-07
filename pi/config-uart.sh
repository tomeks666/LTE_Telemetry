#!/usr/bin/env bash
# config-uart.sh — Free the good PL011 UART to the GPIO header and disable the
# serial login console, so /dev/serial0 is a clean MAVLink link to the FC.
#
# On the Pi Zero W the PL011 UART is wired to the onboard Bluetooth by default,
# leaving only the unreliable mini-UART (its baud drifts with the core clock) on
# the GPIO pins. `disable-bt` swaps them: PL011 -> GPIO14/15, BT off.
#
# Run as root:  sudo ./config-uart.sh
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo." >&2; exit 1
fi

# config.txt lives in /boot/firmware on Bookworm, /boot on older releases.
BOOT=/boot/firmware
[[ -f "$BOOT/config.txt" ]] || BOOT=/boot
CONFIG="$BOOT/config.txt"
CMDLINE="$BOOT/cmdline.txt"

echo "Using $CONFIG and $CMDLINE"

add_line() { # add_line <file> <line>
  grep -qxF "$2" "$1" || { echo "$2" >> "$1"; echo "  + $2"; }
}

echo "Enabling UART and disabling Bluetooth (frees PL011 to GPIO14/15)..."
add_line "$CONFIG" "enable_uart=1"
add_line "$CONFIG" "dtoverlay=disable-bt"

echo "Disabling the serial login console (so the FC has the port to itself)..."
# Strip any console=serial0,... or console=ttyAMA0,... token from cmdline.txt
sed -i -E 's/console=(serial0|ttyAMA0|ttyS0)[^ ]*[ ]?//g' "$CMDLINE"
# Trim doubled/trailing spaces left behind
sed -i -E 's/  +/ /g; s/^ //; s/ $//' "$CMDLINE"

systemctl disable --now serial-getty@ttyAMA0.service 2>/dev/null || true
systemctl disable --now serial-getty@serial0.service 2>/dev/null || true
systemctl disable --now hciuart.service 2>/dev/null || true

echo
echo "Done. UART will be ready after a reboot."
echo "After reboot, /dev/serial0 should symlink to ttyAMA0:"
echo "    ls -l /dev/serial0"
