# 3 · Wire the FC ↔ Pi and set ArduPilot params

Both the Matek FC UART and the Pi GPIO UART are **3.3 V logic** — connect them
directly, **no level shifter**.

## Wiring

Cross TX↔RX, share ground. Use a spare Matek UART (e.g. TX2/RX2 → ArduPilot SERIAL2).

| Matek FC | Raspberry Pi Zero W | Pin (Pi 40-pin header) |
|----------|---------------------|------------------------|
| TX (UARTn) | **RXD** (GPIO15)   | pin 10 |
| RX (UARTn) | **TXD** (GPIO14)   | pin 8  |
| GND        | **GND**            | pin 6  |

```
   Matek                 Pi Zero W
   TXn  ───────────────▶ GPIO15 / RXD  (pin 10)
   RXn  ◀─────────────── GPIO14 / TXD  (pin 8)
   GND  ─────────────── GND            (pin 6)
```

> **Do NOT** connect the FC's 5 V to the Pi if the Pi has its own supply. Power
> the Pi from a dedicated **5 V BEC (≥2 A)** — the Pi Zero W + 4G stick draw
> current spikes that a small FC BEC may not handle. Always share **GND**.

## Power

- Pi `PWR IN` micro-USB ← 5 V BEC.
- 4G stick in the Pi's **USB data** port (the other micro-USB).
- FC powered as usual; only its UART TX/RX/GND go to the Pi.

## ArduPilot parameters

In Mission Planner/QGC (over USB to the FC, before going wireless), set the
serial port you wired — example for **SERIAL2 (TELEM2)**:

| Parameter | Value | Meaning |
|-----------|-------|---------|
| `SERIAL2_PROTOCOL` | `2` | MAVLink 2 |
| `SERIAL2_BAUD` | `57` | 57600 baud — must match `Baud=` in main.conf |
| `SERIAL2_OPTIONS` | `0` | no inversion/half-duplex |

Optional, to trim 4G data usage, lower the stream rates for that port
(`SR2_*` group): e.g. `SR2_POSITION=2`, `SR2_EXTRA1=4`, `SR2_RAW_SENS=0`.

Reboot the FC after changing `SERIALx_*`.

## Next

→ [06 · MAVLink bridge](06-mavlink-bridge.md) to start mavlink-router, then
[07 · Ground station](07-ground-station.md) to connect.
