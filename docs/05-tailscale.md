# 5 · Tailscale (NAT traversal)

Tailscale gives the Pi and your PC stable `100.x.x.x` addresses and connects them
directly through carrier NAT — no public IP, no port forwarding.

## On the Pi

**`setup.sh` does this automatically.** During setup it prints a login URL:

```
To authenticate, visit:
    https://login.tailscale.com/a/xxxxxxxxxxxxxxx
```

Open it, sign in (Google/GitHub/email), and approve **dron-telem**. The Pi's
Tailscale IP is printed at the end (`tailscale ip -4`).

If you ran `setup.sh --no-tailscale`, do it manually now:

```bash
sudo ~/LTE_Telemetry/pi/install-tailscale.sh
```

`--ssh` is included, so you can also `ssh pi@dron-telem` over Tailscale from
anywhere — handy when the Pi is out in the field on 4G only.

## On your PC

1. Install Tailscale for Windows: https://tailscale.com/download/windows
2. Sign in with the **same account** you approved the Pi on.
3. Verify both devices see each other:

```powershell
ping 100.103.174.46          # the Pi's Tailscale IP
ssh pi@dron-telem            # SSH over Tailscale
Test-NetConnection 100.103.174.46 -Port 5760   # TCP reach test
```

## Next

→ [07 · Ground station](07-ground-station.md).
