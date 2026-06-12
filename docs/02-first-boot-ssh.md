# 2 · First boot & SSH

The Pi boots, joins your home WiFi, and starts its SSH server. Give it ~60–90 s
on the first boot (it expands the filesystem and reboots once automatically).

## Find it and log in

From this PC (PowerShell or any terminal):

```powershell
ssh pi@dron-telem.local
```

If `.local` doesn't resolve, look up the IP in your router's DHCP list and use
`ssh pi@<that-ip>` instead. Accept the host key fingerprint and enter your password.

## Clone the repo and run setup

On the Pi (one command gets everything):

```bash
git clone https://github.com/tomeks666/LTE_Telemetry.git ~/LTE_Telemetry
sudo ~/LTE_Telemetry/pi/setup.sh
```

`setup.sh` takes ~5 min (compiling mavlink-router) and then **pauses** to print a
Tailscale login URL like:

```
To authenticate, visit:
    https://login.tailscale.com/a/xxxxxxxxxxxxxxx
```

Open that URL on **any device**, sign in with Google/GitHub/email, and approve
`dron-telem`. The script resumes, prints the Pi's Tailscale IP (`100.x.x.x`),
and exits.

## Sanity check

```bash
ping -c3 1.1.1.1          # internet over home WiFi
ls -l /dev/serial0        # shows ttyAMA0 once rebooted
tailscale ip -4            # the 100.x address your GCS will connect to
```

## Reboot

The UART change only takes effect after a reboot:

```bash
sudo reboot
```

## Next

→ [04 · 4G stick](04-4g-stick.md) — plug it in and verify `usb0`.
→ [05 · Tailscale on your PC](05-tailscale.md#on-your-pc) — install and sign in with the same account.
→ [03 · Wire the FC](03-uart-wiring.md).
