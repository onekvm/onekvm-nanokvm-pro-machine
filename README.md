# onekvm-nanokvm-pro-machine

Machine files for the Sipeed NanoKVM Pro (AX630C), built by `onekvm-distro`
(`meta-onekvm-nanokvm-pro`).

| Path | Content |
| --- | --- |
| `edid/` | 256-byte EDID presets installed on the Pro; `1080p60` is also the factory preset |
| `src/onekvm-machine-nanokvm-pro-edid` | Capture chip init hook: reads the LT6911 silicon and applies the Pro EDID |
| `src/onekvm-capture-chip-init`, `systemd/onekvm-capture-chip-init.service` | Runs the chip init hooks before Core starts |
| `tools/generate-pro-edid.py`, `tools/edid_modes.py` | Regenerate `edid/` from CTA/DMT timings |
| `tools/pack-pro-emmc.py` | Pack a system image into the vendor Pro eMMC raw layout |

`make test` checks the EDID presets and the eMMC packer.
