# 6 · Build the MAVLink bridge

`mavlink-router` reads the FC serial port and serves it to your ground
station(s) over UDP and TCP. It accepts multiple GCS at once.

## One-shot setup

On the Pi, with the `pi/` folder copied over:

```bash
sudo ~/LTE_Telemetry/pi/setup.sh
```

This runs, in order:

1. **`config-uart.sh`** — `enable_uart=1` + `dtoverlay=disable-bt` so the reliable
   PL011 UART is on GPIO14/15, and disables the serial login console.
2. **`install-mavlink-router.sh`** — builds mavlink-router from source
   (~3–5 min on a Pi 3B), installs the systemd service, and
   drops the config at `/etc/mavlink-router/main.conf`.
3. **`install-tailscale.sh`** — installs Tailscale and runs `tailscale up`
   (skip with `sudo ./setup.sh --no-tailscale`).

Then **reboot** so the UART change takes effect:

```bash
sudo reboot
```

## Verify after reboot

```bash
ls -l /dev/serial0                 # -> ../ttyAMA0  (PL011)
systemctl status mavlink-router    # active (running)
journalctl -u mavlink-router -f    # watch it; with FC wired you'll see packets
```

With the FC powered and wired, the log shows the serial endpoint opening and
MAVLink traffic. If you see "opened UART /dev/serial0" but no packets, recheck
TX/RX (they cross over) and the baud — see [troubleshooting](08-troubleshooting.md).

## The config

See [`pi/mavlink-router/main.conf`](../pi/mavlink-router/main.conf):

- `[UartEndpoint fc]` — `/dev/serial0` at `Baud=57600` (match `SERIALx_BAUD`).
- `[UdpEndpoint gcs]` — UDP **server** on `:14550` (GCS dial in).
- `[General] TcpServerPort=5760` — TCP **server** for lossy-link reliability.

Edit it then `sudo systemctl restart mavlink-router` to apply.

To run the bridge by hand for debugging (stop the service first):

```bash
sudo systemctl stop mavlink-router
mavlink-routerd -e 0.0.0.0:14550 /dev/serial0:57600
```

## Next

→ [07 · Ground station](07-ground-station.md)
