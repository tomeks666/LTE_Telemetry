# 1 · Flash the SD card

Goal: a headless Raspberry Pi OS that joins your home WiFi and accepts SSH on
first boot, so you never need a monitor/keyboard.

## Use Raspberry Pi Imager (recommended)

1. Install **Raspberry Pi Imager** from https://www.raspberrypi.com/software/.
2. Insert the microSD card.
3. **Choose Device:** Raspberry Pi 3 Model B (or 3B+).
4. **Choose OS:** *Raspberry Pi OS (other)* → **Raspberry Pi OS Lite (32-bit)**.
   Lite = no desktop; we only need a headless bridge. Stick to 32-bit — ARMv7
   32-bit is well-tested and sufficient.
5. **Choose Storage:** your SD card.
6. Click **Next → Edit Settings** (the OS customisation dialog). Set:
   - **Hostname:** `dron-telem`  (we'll use this name to find it on the LAN)
   - **Enable SSH** → *Use password authentication* (or paste a public key)
   - **Username / password:** e.g. `pi` / *your-password*
   - **Configure wireless LAN:**
     - SSID + password of **your home WiFi** (used for setup only)
     - **Wireless LAN country:** set correctly (e.g. `PL`) — WiFi won't enable without it
   - **Locale / timezone:** your choice
7. **Save**, then **Write**. Wait for write + verify.

> The Imager bakes these into a first-boot config on the boot partition, so the
> Pi self-configures on its first power-up. No `wpa_supplicant.conf` editing
> needed (that method is deprecated on Bookworm).

## Manual headless fallback (if not using the Imager dialog)

After writing a plain image, mount the **boot** partition and:

- Create an empty file named `ssh` (enables the SSH server).
- Provide WiFi + user via a `custom.toml` / `firstrun.sh` — but the Imager dialog
  above generates these correctly for the OS version, so prefer it.

## Next

Eject the card, put it in the Pi, power it from a good **5 V / 2.5 A supply**
(micro-USB PWR port). The 3B draws more than a Zero W, especially with the 4G
stick attached. → [02 · First boot & SSH](02-first-boot-ssh.md)
