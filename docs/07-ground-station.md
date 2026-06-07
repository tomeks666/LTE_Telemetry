# 7 · Connect the ground station

mavlink-router on the Pi serves telemetry on the Pi's **Tailscale IP**:

- **UDP** `14550` (server — you connect as a UDP *client*)
- **TCP** `5760` (server — more robust on a lossy 4G link)

Get the Pi's address: `tailscale ip -4` on the Pi (e.g. `100.101.102.103`).

> **Tip:** over flaky 4G, **prefer TCP**. UDP is lower-latency but drops silently;
> TCP retransmits, so the param/mission download is far more reliable.

## Mission Planner (Windows)

Top-right connection dropdown:

**UDP client (UDPCl):**
1. Select **UDPCl**, click **Connect**.
2. Remote Host: `100.101.102.103`  ·  Remote Port: `14550`.

**or TCP (recommended on 4G):**
1. Select **TCP**, click **Connect**.
2. Host: `100.101.102.103`  ·  Port: `5760`.

Baud box is ignored for network links. Params should start downloading.

## QGroundControl

**Application Settings → Comm Links → Add:**

- **Type:** UDP → *Server Address* `100.101.102.103`, *Port* `14550`, Add → Connect.
- **or Type:** TCP → *Host* `100.101.102.103`, *Port* `5760`, Add → Connect.

(Disable QGC's "AutoConnect → UDP" if it grabs the wrong link.)

## Both at once

Both servers accept multiple clients, so Mission Planner and QGC can connect
simultaneously to the same Pi. mavlink-router de-duplicates and routes each GCS's
commands back to the FC.

## Other GCS / tools

Anything that speaks MAVLink over UDP/TCP works the same way — point it at
`<pi-tailscale-ip>:14550` (UDP) or `:5760` (TCP). For example MAVProxy on the PC:

```powershell
mavproxy.py --master=tcp:100.101.102.103:5760
```

## Next

If telemetry doesn't flow → [08 · Troubleshooting](08-troubleshooting.md).
