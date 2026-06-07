# 2 · First boot & SSH

The Pi boots, joins your home WiFi, and starts its SSH server. Give it ~60–90 s
on the first boot (it expands the filesystem and reboots once).

## Find it and log in

From this PC (PowerShell):

```powershell
# mDNS usually works — the hostname you set in the Imager, with .local
ssh pi@dron-telem.local
```

If `.local` doesn't resolve (some Windows setups), find the IP instead:

```powershell
# Look at your router's DHCP client list for "dron-telem", or scan:
ssh pi@<ip-from-router>
```

First connection asks to trust the host key — type `yes`. Then enter the password
you set in the Imager.

## Copy the project onto the Pi

From this PC, in the project folder:

```powershell
# Option A: clone if you've pushed this repo somewhere
ssh pi@dron-telem.local "git clone <your-repo-url> ~/LTE_Telemetry"

# Option B: copy the pi/ folder straight over with scp
scp -r C:\src\dron\LTE_Telemetry\pi pi@dron-telem.local:~/LTE_Telemetry/
```

## Sanity check internet (over home WiFi for now)

```bash
ping -c3 1.1.1.1
sudo apt update
```

## Next

→ [06 · Build the MAVLink bridge](06-mavlink-bridge.md) (run `setup.sh`), then
[05 · Tailscale](05-tailscale.md) and [04 · 4G stick](04-4g-stick.md).
