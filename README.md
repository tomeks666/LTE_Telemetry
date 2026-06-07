# LTE_Telemetry — ArduPilot UART bridge over 4G

Turn a **Raspberry Pi Zero W** + a **UZ801 4G USB stick** into a long-range
telemetry link: it reads MAVLink from a **Matek flight controller** over UART and
forwards it across the internet (through carrier NAT, via **Tailscale**) to
**Mission Planner** / **QGroundControl** on your PC.

```
 Matek FC ──UART/MAVLink──▶  RPi Zero W  ──mavlink-router──▶ Tailscale ──▶  PC GCS
 (3.3V, 57600 baud)         /dev/serial0    UDP 14550 /        100.x       Mission Planner
                                 │           TCP 5760          overlay     / QGroundControl
                                 │
                                 └─ internet via UZ801 4G stick (USB-RNDIS → usb0)
```

## Why this design

- **UZ801 is behind carrier-grade NAT (CGNAT)** → the Pi has no public inbound IP,
  so you cannot port-forward to it. **Tailscale** builds an encrypted mesh that
  pierces NAT on both ends; the Pi and PC get stable `100.x.x.x` addresses and
  reach each other directly.
- **mavlink-router** on the Pi reads the serial port once and serves it to
  multiple ground stations simultaneously (UDP server + TCP server), so Mission
  Planner and QGC can both connect.
- The Pi's **onboard WiFi** is used only for first-time setup (joins your home
  network). In the field, internet comes from the **4G stick**.

## Hardware

| Part | Notes |
|------|-------|
| Raspberry Pi Zero W (512 MB) | Single USB data port — used by the 4G stick |
| UZ801 4G stick | Presents as USB RNDIS (`usb0`), DHCP, works on Linux out of the box |
| Matek FC w/ ArduPilot | 3.3 V UART (same logic level as Pi — no level shifter) |
| 5 V BEC, ≥2 A | Power the Pi separately; 4G stick draws current spikes |
| microSD, 8 GB+ | Raspberry Pi OS Lite |

## Runbook (do these in order)

1. [Flash the SD card](docs/01-flash-pi.md) — Raspberry Pi OS Lite, pre-seed WiFi + SSH.
2. [First boot & SSH](docs/02-first-boot-ssh.md) — find the Pi on your LAN, log in.
3. [Run the setup script](docs/06-mavlink-bridge.md) — `pi/setup.sh` configures UART, builds mavlink-router, installs the service.
4. [Tailscale](docs/05-tailscale.md) — join the Pi and PC to the same tailnet.
5. [4G stick](docs/04-4g-stick.md) — verify internet via `usb0`, optionally silence its WiFi.
6. [Wire the FC + ArduPilot params](docs/03-uart-wiring.md).
7. [Connect Mission Planner / QGC](docs/07-ground-station.md).
8. [Troubleshooting](docs/08-troubleshooting.md) if anything misbehaves.

> **TL;DR for a Pi that's already flashed & online:**
> ```bash
> git clone <this repo> ~/LTE_Telemetry   # or scp the pi/ folder over
> sudo ~/LTE_Telemetry/pi/setup.sh
> ```
> then `tailscale up` and connect your GCS to `udp://<pi-tailscale-ip>:14550`.

## Repo layout

```
pi/                         Everything that runs ON the Raspberry Pi
  setup.sh                  Master setup: UART + deps + mavlink-router + service
  config-uart.sh           Frees PL011 UART to GPIO, disables BT & serial console
  install-mavlink-router.sh Builds & installs mavlink-router from source
  install-tailscale.sh      Installs Tailscale
  mavlink-router/main.conf  Router config (serial in, UDP+TCP out)
docs/                       Step-by-step guides (see runbook above)
```

## Data usage

MAVLink telemetry at default stream rates is ~10–15 MB/hour. To cut it, lower the
`SR0_*` / `SR1_*` parameters in ArduPilot. See [troubleshooting](docs/08-troubleshooting.md).
