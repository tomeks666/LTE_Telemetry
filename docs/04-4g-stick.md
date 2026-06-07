# 4 · UZ801 4G stick

The UZ801 enumerates as a **USB RNDIS/CDC-Ethernet** device. On Raspberry Pi OS
the `rndis_host` / `cdc_ether` driver loads automatically, creating a `usb0`
interface that gets an IP by DHCP from the stick. **It usually works out of the
box** — no drivers to install.

## Verify

Plug the stick into the Pi's **USB data** port, wait ~20–30 s for it to register
on the network, then:

```bash
ip -br addr            # expect a usb0 with a 192.168.x.x address
ip route               # expect a default route via usb0 (192.168.x.1)
ping -c3 1.1.1.1       # internet over 4G
ping -c3 google.com    # DNS works
```

If `usb0` is missing:

```bash
lsusb                  # is the stick listed? note its ID
dmesg | tail -30       # look for rndis_host / cdc_ether binding usb0
```

Some UZ801 firmware enumerates first as a CD-ROM (Windows installer) and switches
to RNDIS after a moment — give it time, or replug. If it never appears as a
network device, see [troubleshooting](08-troubleshooting.md).

## Routing note (home WiFi + 4G at the same time)

During setup both `wlan0` (home WiFi) and `usb0` (4G) may be up. That's fine —
Tailscale works over whichever default route exists. In the field, only `usb0`
is up. If you want the 4G to always win while both are present, give it a lower
metric, but it's not required for Tailscale to function.

## Silencing the stick's WiFi AP (optional)

The UZ801 also broadcasts its own WiFi AP, which you don't need. To try disabling
it, from a device connected to that AP (or the Pi, if it can reach the gateway):

1. Open the admin page, usually `http://192.168.100.1` or `http://192.168.0.1`
   (check `ip route` for the gateway).
2. Log in (commonly `admin` / `admin`).
3. Find **WiFi / WLAN settings** and disable the AP / hide the SSID.

Firmware varies; some UZ801 builds don't expose a WiFi toggle. It's harmless to
leave on — it doesn't affect the telemetry link. Just don't connect to it.

## Data usage

Telemetry ≈ 10–15 MB/hour at default rates. Trim with the `SRx_*` params
(see [03 · UART wiring](03-uart-wiring.md)) if you're on a small data plan.

## Next

→ [05 · Tailscale](05-tailscale.md)
