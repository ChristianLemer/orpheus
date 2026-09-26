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

## ZMK Studio

Studio talks to the dongle over its USB cable (`/dev/ttyACM*`). Its lock is compiled out —
`CONFIG_ZMK_STUDIO_LOCKING=n` in `zmk/config/halcyon_ferris.conf` — because the ported
keymap has no `&studio_unlock` key, and without one Studio found the board and stayed on
*Unlock to continue* for good. ZMK only `imply`s the lock, so the `=n` holds.

**Studio's labels drop implicit modifiers.** A binding like `&kp LS(N1)` — shifted 1 — is
drawn as `1`, and `[` and `{` both come out as `{`. The firmware sends the right thing; only
the picture is wrong. Editing such a key in Studio without ticking Shift again *would*
change it for real. Studio 0.3.1 is the latest release, so there is no update to wait for.

For a faithful picture, keymap-drawer reads the `.keymap` itself: `keymap parse -z` yields
44 positions — the 34 keys, then the 10 module slots of row `RC(4,x)` to drop — drawn on
`splitkb/halcyon/ferris/rev1`, `LAYOUT_split_3x5_2`.

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

## The configuration lives here

`zmk/` holds everything that compiles into the firmware, and pushing a change to it
builds all three files through `.github/workflows/build-zmk.yml`:

```
zmk/
├── build.yaml          the three targets — one per device
├── config/
│   ├── halcyon_ferris.keymap
│   ├── halcyon_ferris.conf
│   └── west.yml        pulls splitkb's ZMK fork and Halcyon module
└── local/mod.nu        `use local` — build without pushing
```

This used to be a second repository, because ZMK's reusable workflow runs `west update`
from the repository root while `west init -l <dir>` puts `.west` in the parent of `<dir>`
— so a nested config left west searching above the workspace it had just created. The
workflow here sets its own `working-directory` instead, which removes the constraint
entirely. Verified by building both ways: the dongle firmware came out byte-identical.

## A faithful port, deliberately

Nothing was added, nothing moved. Where the Vial layout had an empty key, this one has an
empty key. The mod-tap is set to `tap-preferred` at 175 ms, which is how QMK's mod-tap
behaves by default and what the `.vil` had for `TAPPING_TERM` — so the feel should carry
over rather than being something new to learn.

ZMK can do better than this — `hold-trigger-key-positions` implements the opposite-hands
rule and would end the mod-tap ambiguity that killed the `F`+`D` combo under QMK. It is
deliberately **not** used here. Change one thing at a time: first confirm the layout you
know works on this board, then tune.

## Three keys this firmware does not have

A wireless board needs keys a wired one never did, and the faithful port has none of them.
Worth knowing before flashing:

| Missing | Consequence |
|---|---|
| `&studio_unlock` | Not needed: Studio's lock is compiled out — see **ZMK Studio** above. |
| `&bt BT_CLR`, `&bt BT_SEL n` | No way to switch or clear a Bluetooth profile. A pairing that goes bad needs a rebuild. |
| `&bootloader` | Reflashing means double-tapping the physical reset button on each device. |

The Operators layer's top row is empty and would hold the other two without displacing
anything. That is a decision, not an oversight — say the word.

## Tuning

Everything below is one number, and no value is right for everyone — change one at a time
and type for a few days.

| Setting | Now | Raise it if | Lower it if |
|---|---|---|---|
| `tapping-term-ms` | 175 | modifiers fire when you meant letters | deliberate holds feel sluggish |

If stray modifiers survive a longer term, the next lever is `require-prior-idle-ms` — a key
pressed within N ms of the previous one is forced to a tap, so fast typing cannot throw
modifiers at all. After that, `hold-trigger-key-positions`: the opposite-hands rule, which
settles a mod-tap as a tap whenever the next key is on the same hand. Neither is set today.

## Building locally

Pushing and waiting four minutes is fine for a rare change; it is not fine for tuning a
tapping term by feel. Local builds turn that loop into seconds.

```nushell
omarchy pkg add cmake gperf dtc ccache   # once, needs sudo
cd keyboards/splitkb/halcyon-ferris-wireless/zmk

use local
local                    # what this module does
local setup              # once, 2+ GB and about a quarter of an hour
local build              # every time after that
local build dongle       # just the dongle — enough for a keymap change
local build --propre     # start over
```

`west update` is resumable — if it looks stuck at `Compressing objects: 0%`, it is not;
git sits there a long time on the larger repos before the counter moves. Interrupting and
re-running costs nothing but does not help either.

Everything lands in this repo and your home directory: a `.venv` for `west`, the Zephyr
workspace beside it, the ARM toolchain under your own SDK path. All of it is in
`.gitignore`.

**No Docker.** The container route would mean enabling the daemon and joining the `docker`
group, which is root-equivalent on this machine — too much to grant in order to compile a
keyboard. The four packages above are ordinary Arch repo packages and the rest needs no
privileges at all.

`local build` reads its targets from `zmk/build.yaml`, the same file GitHub Actions uses.
There is one list of build targets, not two.

## Sources

- [Firmware — Halcyon wireless build guide](https://docs.splitkb.com/product-guides/halcyon-series/build-guide/wireless/firmware)
- [Split keyboards — ZMK](https://zmk.dev/docs/features/split-keyboards) — central and peripheral roles
- [Introducing Halcyon Wireless](https://blog.splitkb.com/introducing-halcyon-wireless/)
