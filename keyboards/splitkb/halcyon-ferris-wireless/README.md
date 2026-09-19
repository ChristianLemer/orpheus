# Halcyon Ferris — wireless

_SplitKB Halcyon Ferris on nRF52840 controllers, e-paper module on both halves,
driven through the USB-C dongle. **ZMK, not Vial.**_

Downloaded 12 September 2026 from the splitkb Composer (`splitkb.com/fw`, which
redirects to `canary.composer.splitkb.com`).

## Not the same keyboard as the wired one

The wired Halcyon Ferris in `../` runs QMK with Vial: its layout is a `.vil` file,
edited live at vial.rocks, no compiling. This board runs **ZMK**. Nothing carries
over:

| | Wired (`../`) | Wireless (here) |
|---|---|---|
| Firmware | QMK + Vial | ZMK |
| Layout source | `.vil`, edited live | `.keymap`, compiled |
| Changing a key | instant, in the browser | edit, build, flash |
| Mouse keys, combos, tap dance | Vial tables | declared in the keymap |

The 34-key layout itself is transferable as a *design*; the file is not. Porting it
is its own job and has not been done — see **What is not here**.

## The three firmware files

With a dongle, ZMK gives the dongle the **central** role and both halves become
**peripherals**. Each device needs its own build.

| File | Device | Role | sha256 (first 8 bytes) |
|---|---|---|---|
| `halcyon_ferris_dongle.uf2` | USB-C dongle | central | `2a183267bdc186ff` |
| `halcyon_ferris_left_cc_epaper.uf2` | left half | peripheral | `ad8e5e836e4667cd` |
| `halcyon_ferris_right_cc_epaper.uf2` | right half | peripheral | `53c452ae3700b608` |

The `_cc_epaper` part names the module physically mounted on that half. A half with a
different module — or none — takes a different file; the firmware must match the
hardware, it is not a preference.

**A file named `…_central` is not the right half.** It is the *left* half built as
central, for running without the dongle (ZMK's convention: left is central, right is
peripheral). That configuration is not the one in use here, so its file is not kept.
Re-downloadable from the Composer in one click if the dongle is ever dropped.

## Flashing

Each device is flashed individually, by drag-and-drop, in this order: dongle, left,
right.

1. Connect the device — it mounts as a volume named `HALCYON`
2. Drop its `.uf2` file on it
3. The volume unmounts on its own after a second or two — that is the success signal
4. **Press the reset button once** (halves only; the dongle has no battery)
5. Repeat for the next device

### The two gestures on the same button

Easy to confuse, and they do opposite things:

| Gesture | When | Why |
|---|---|---|
| **Double-tap** reset | *before* flashing | forces the bootloader, so `HALCYON` appears |
| **One press** on reset | *after* flashing | avoids the battery-drain bug |

> **The press in step 4 is not optional.** A known bug drains the battery much faster
> if the controller is not reset after flashing. It costs one press; skipping it costs
> hours of runtime.

**A factory-fresh board needs no double-tap.** With no valid application firmware, the
bootloader has nothing to start and stays in mass-storage mode by itself — the volume
appears on a plain connection. The double-tap only becomes necessary once a board has
been flashed, which is to say: from the second time onwards.

### Telling the devices apart

You cannot, from the computer. All three report the same bootloader identity:

```
UF2 Bootloader 0.10.0
Model: Halcyon
Board-ID: nRF52840-halcyon
```

The only source of truth is which device you physically plugged in. And the two half
firmwares are byte-for-byte the same size (657.9 kB), so the file name is the only
thing that distinguishes them — not the weight, not the board.

### What the USB IDs look like

Useful for telling at a glance what state a device is in:

| ID | Meaning |
|---|---|
| `239a:e34b` Adafruit Halcyon | in bootloader, waiting for a `.uf2` |
| `1d50:615e` Halcyon Ferris | running ZMK — flashed and booted |
| `8d1d:e050` splitkb.com Halcyon Ferris rev1 | the **wired** board, a different keyboard |

A flashed device also appears as `usb-ZMK_Project_Halcyon_Ferris_…` under
`/dev/input/by-id/`, and exposes a `/dev/ttyACM*` endpoint — that serial port is how
**ZMK Studio** talks to the keyboard.

Two things that look like faults and are not:

- **A half connected alone over USB produces nothing.** Peripherals cannot talk to a
  host — only the central can. The dongle must be plugged in for the keyboard to type.
- **The `HALCYON` volume no longer appears on a plain connection.** That is the proof
  the flash worked: the board now boots into firmware instead of into a USB drive.
- **Keymap-only changes need only the central reflashed** — here, just the dongle. The
  halves stay untouched, and stay closed.

## Unlocking ZMK Studio

Studio connects but refuses to edit until the keyboard is unlocked, and the unlock is a
key in the keymap — not a setting in the app. On the stock splitkb build:

> **Hold `Space` (right inner thumb) and press `T`.**

`&studio_unlock` lives on layer 7, *Always accessible*, reached by `&lt 7 SPACE`. On that
layer the position `T` occupies on the base layer carries the unlock:

```
layer 7   | BT+ |     |  :  | ESC | STDIO |   …
base      |  Q  |  W  |  E  |  R  |   T   |   …
```

The keyboard relocks after a period of inactivity in Studio, or on disconnect.

Source: [`splitkb/zmk-halcyon-module`](https://github.com/splitkb/zmk-halcyon-module/blob/main/boards/shields/halcyon_ferris/halcyon_ferris.keymap)
— read 12 September 2026. Not copied here: it is upstream's to change, and a copy would
drift.

## The stock keymap is not this repo's layout

Worth knowing before porting anything. The stock ZMK build and the wired Vial layout share
a base and almost nothing else:

| | Wired (`../`, Vial) | Stock ZMK |
|---|---|---|
| Base | QWERTY | QWERTY |
| Home-row mods | ⇧⌃⌥⌘ mirrored, both hands | **Shift on the pinkies only** |
| The other home-row keys | letters with modifiers | **layer-taps** — `S`→5, `D`→1, `F`→3, `J`→4, `K`→2, `L`→6 |
| Layers | 4, on the thumbs | 7, under the fingers |
| Thumbs | four layer keys | `0`, `Bksp`, `Space` (layer 7), `1` |

It puts the layers under the fingers and the digits under the thumbs — the opposite bet.
So porting is a rebuild, not a translation, and muscle memory will not carry over.

## What is not here

- **The keymap.** No `.keymap` yet — the board runs whatever the stock build ships.
  Porting the 34-key layout from `../splitkb-halcyon-ferris.vil` is the next job.
- **A drawn keymap.** `admin/vil-to-svg.nu` reads `.vil` files and knows nothing about
  ZMK. `keymap-drawer` does parse ZMK (`-z`), so the tooling can be extended rather
  than duplicated — but it has not been.
- **An audit.** The wired board has one (`../splitkb-halcyon-ferris-audit.md`); this
  one has no reasoning to record yet.

## Sources

- [Firmware — Halcyon wireless build guide](https://docs.splitkb.com/product-guides/halcyon-series/build-guide/wireless/firmware)
- [Split keyboards — ZMK](https://zmk.dev/docs/features/split-keyboards) — central and peripheral roles
- [Introducing Halcyon Wireless](https://blog.splitkb.com/introducing-halcyon-wireless/)
