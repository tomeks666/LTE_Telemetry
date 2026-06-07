# 8 · Troubleshooting

Work down the chain: **UART → router → 4G → Tailscale → GCS**. Isolate which hop
is broken before changing things.

## No `/dev/serial0` after setup

```bash
ls -l /dev/serial0
```

- Should symlink to `ttyAMA0`. If it points to `ttyS0` (mini-UART) or is missing,
  the `disable-bt` overlay didn't apply. Re-run `sudo pi/config-uart.sh`, check
  `enable_uart=1` and `dtoverlay=disable-bt` are in `config.txt`, and **reboot**.
- Confirm no `console=serial0,...` remains in `cmdline.txt`.

## Router runs but no MAVLink packets

```bash
journalctl -u mavlink-router -f
```

- "opened UART" but zero packets → **wiring**: FC TX must go to Pi **RX (pin 10)**
  and FC RX to Pi **TX (pin 8)**. They cross. Verify common **GND**.
- **Baud mismatch:** `Baud=` in `main.conf` must equal `SERIALx_BAUD` on the FC
  (57600 ↔ `57`). Garbled/no parse = wrong baud.
- **Protocol:** FC `SERIALx_PROTOCOL=2` (MAVLink2). Reboot the FC after changing.
- Quick raw check that bytes arrive: `sudo apt install -y python3-serial` then
  `python3 -m serial.tools.miniterm /dev/serial0 57600` — you should see binary junk.

## 4G stick: no `usb0` / no internet

```bash
lsusb ; ip -br addr ; ip route ; dmesg | tail -30
```

- Stick shows as CD-ROM only → wait 30 s or replug; UZ801 mode-switches to RNDIS
  after enumerating. If it never switches, try a different cable/port and ensure
  adequate power (under-volt resets USB).
- `usb0` exists but no DHCP IP → `sudo dhclient -v usb0` and watch for a lease.
- Has IP but no internet → check the SIM has data/credit and isn't PIN-locked;
  the UZ801 handles the PDP context internally, so a locked/empty SIM = no route.

## Tailscale: can't reach the Pi

```bash
tailscale status        # both devices listed? Pi shown as online?
tailscale ip -4
```

- Both devices must be signed into the **same account** and approved.
- From the PC: `ping <pi-tailscale-ip>`. If ping works but the GCS doesn't
  connect, it's a port/endpoint issue, not the network.
- `tailscale ping <pi>` shows whether it's a direct or relayed (DERP) path.
  Relayed still works, just higher latency.

## GCS won't connect though ping works

- Service up? `systemctl status mavlink-router`.
- Right ports: UDP **14550** (client) or TCP **5760**.
- Test TCP reachability from PC: `Test-NetConnection <pi-ip> -Port 5760`.
- Windows Firewall can block QGC/Mission Planner — allow them on private networks.
- For UDP, the GCS must **send first** (it's a UDP client to the Pi's server),
  so use Mission Planner **UDPCl** / QGC UDP with the Pi as target — not a plain
  listening UDP.

## Link is laggy or dropping on 4G

- Switch the GCS from UDP to **TCP 5760** — retransmits hide packet loss.
- Lower telemetry rates on the FC: `SRx_POSITION`, `SRx_EXTRA1/2/3`,
  `SRx_RAW_SENS=0`, `SRx_RC_CHAN=0`. Less data = fewer drops + less mobile data.
- Check signal: a weak 4G cell adds latency/jitter you can't fix in software.

## Useful one-liners

```bash
# Watch everything the router does
journalctl -u mavlink-router -f

# Restart the bridge after a config edit
sudo systemctl restart mavlink-router

# Is the FC port actually open and streaming?
mavlink-routerd -e 0.0.0.0:14550 /dev/serial0:57600   # run manually, Ctrl-C to stop

# Pi's field address for the GCS
tailscale ip -4
```
