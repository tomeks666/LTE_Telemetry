# 5 · Tailscale (NAT traversal)

Tailscale gives the Pi and your PC stable `100.x.x.x` addresses and connects them
directly through carrier NAT — no public IP, no port forwarding.

## On the Pi

```bash
sudo ~/LTE_Telemetry/pi/install-tailscale.sh
```

It installs Tailscale and runs `tailscale up --ssh`. Copy the printed login URL,
open it on any device, sign in (Google/GitHub/email), and approve **dron-telem**.

Then note the Pi's address:

```bash
tailscale ip -4        # e.g. 100.101.102.103
```

`--ssh` also lets you `ssh pi@dron-telem` over Tailscale from anywhere — very
handy for debugging the Pi while it's out in the field on 4G.

## On your PC

1. Install Tailscale for Windows: https://tailscale.com/download/windows
2. Sign in with the **same account** you used for the Pi.
3. Confirm both devices show up in your tailnet and you can reach the Pi:

```powershell
tailscale ip -4
ping 100.101.102.103        # the Pi's Tailscale IP
ssh pi@dron-telem           # over Tailscale (works even on 4G)
```

## Verify the path end-to-end

Once mavlink-router is running (next step) and the FC is wired, the GCS will
connect to `<pi-tailscale-ip>:14550`. Test raw reachability first:

```powershell
# from the PC, should connect to mavlink-router's TCP server
Test-NetConnection 100.101.102.103 -Port 5760
```

## Next

→ [04 · 4G stick](04-4g-stick.md) (if not done) and
[07 · Ground station](07-ground-station.md).
