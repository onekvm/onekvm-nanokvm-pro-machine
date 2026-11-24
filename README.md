# onekvm-nanokvm-pro-machine

English | [简体中文](README.zh-CN.md)

Machine files for the Sipeed NanoKVM Pro (AX630C), built by `onekvm-distro`
(`meta-sipeed/meta-nanokvm-pro`).

| Path | Content |
| --- | --- |
| `edid/` | 256-byte EDID presets installed on the Pro; `1080p60` is also the factory preset |
| `src/onekvm-machine-nanokvm-pro-edid` | Capture chip init hook (`20-pro-chip-info`): links the LT6911 driver's chip info to `/run/onekvm/lt6911_info` |
| `src/onekvm-capture-chip-init`, `systemd/onekvm-capture-chip-init.service` | Runs the chip init hooks before Core starts |
| `systemd/onekvm-machine-nanokvm-pro-ethernet.service` | Brings `eth0` up as boot starts so gigabit negotiation overlaps the rest of boot |
| `tools/generate-pro-edid.py`, `tools/edid_modes.py` | Regenerate `edid/` from CTA/DMT timings |
| `tools/pack-pro-emmc.py` | Pack a system image into the vendor Pro eMMC raw layout |

`make test` checks the EDID presets, the eMMC packer and capture chip initialization.

## EDID

Presets installed from `edid/` include:

- `factory.edid.bin` — default 1920×1080 @ 60 Hz, identical to `1080p60.edid.bin`
- `2160p30.edid.bin` — preferred 3840×2160 @ 30 Hz
- `1080p60.edid.bin` — 1920×1080 @ 60 Hz
- `1440p30.edid.bin` — 2560×1440 @ 30 Hz
- `1440p60.edid.bin` — 2560×1440 @ 59.95 Hz (nominal 60 Hz)
- `720p60.edid.bin` — 1280×720 @ 60 Hz
- `1080p120.edid.bin` — preferred 1920×1080 @ 120 Hz, with 1080p60 / 720p60 fallbacks

Dedicated resolution presets advertise their preferred timing and lower-bandwidth fallback modes,
including BIOS-safe established timings and stereo LPCM audio. Pro capture
supports up to 4K30; select the separate 2160p30 preset to advertise 4K30.
The default 1080p60 preset does not advertise 4K modes. The HDMI splitter presents
the host with modes shared by the selected capture EDID and the loopout display.
The separate 1080p120 preset supports high refresh input; encoding still follows
the configured stream frame rate (120 Hz input to 60 FPS output is verified on Pro).
The loopout display must also support 4K30 for that mode to be advertised.
Stopping SoC capture does not disable the capture bridge or remove its EDID
from this negotiation. Regenerate the Pro files with
`python3 tools/generate-pro-edid.py`; the SG200x machine repository keeps its own presets.

The Pro machine package ships EDID presets, including 1080p60, for the Web
EDID settings. Boot never programs the bridge EDID: the bridge keeps its
existing EDID until the user changes it. The Pro bridge can be LT6911UXC,
LT6911D or LT6911C; the family driver detects the register ID rather than
assuming UXC from the board name. Pro's `20-pro-chip-info` hook only links
`/run/onekvm/lt6911_info` to the driver's `/proc/lt6911_info`, the same shell
lookup path used by the SG2002 MMF diagnostic cache. A missing driver is not
an initialization failure.

UXC and D permanent EDID settings are written to the bridge Flash; D uses its
own Flash sequence. C supports guarded manual EDID management; its Pro erase
extent still needs hardware validation. UXC temporary RAM application belongs
to the backend's optional mode and does not change Flash. Unavailable Shadow
support only disables temporary mode, not permanent Flash management. Pro
Shadow hardware acceptance is still pending.
