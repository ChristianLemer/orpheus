# 🎵 Orpheus

_Personal keymap configurations for 40% mechanical keyboards_

## Design Philosophy

Less keys, more intention. The 40% layout forces every key to earn its place — no redundancy, no wasted reach. Home-row mods keep fingers anchored, layers keep everything accessible without leaving home position.

**Principles:**
- Home-row mods (GACS) on both halves
- Layers by function: navigation, symbols, operators, mouse
- Muscle memory over labels — the layout rewards commitment

## Current Layout — SplitKB Halcyon Ferris

My daily driver. 34 keys, split ergonomic, column-staggered.

![Halcyon Ferris Annotated](keyboards/splitkb/splitkb-halcyon-ferris-annotated.svg)

<details>
<summary><strong>Technical keymap (keymap-drawer)</strong></summary>

![Halcyon Ferris Keymap](keyboards/splitkb/splitkb-halcyon-ferris.svg)

</details>

## Design Rationale

The reasoning behind the current layout — layer-by-layer snapshot, known weaknesses,
combo-vs-layer theory, and the open leads — lives in
[Halcyon Ferris — Audit](keyboards/splitkb/splitkb-halcyon-ferris-audit.md).

## The Journey — from 60% to 34 keys

| Period | Keyboard | Keys | What changed |
|--------|----------|------|--------------|
| Nov 2022 | DZ60RGB | 60% | First custom, first VIA config |
| Feb 2023 | Keychron Q4 + Q0 | 60% + numpad | Separated the numpad — thinking in modules |
| Apr 2023 | Keychron Q9 | 40% | The jump. 18 months of intense iteration |
| Jan 2024 | Keychron Q9 Plus | 40% + knob | Layers stabilize |
| Oct 2024 | Epomaker TH40 ×2 | 40% | Multi-mode (BT, 2.4GHz). Two units, daily refinement |
| Apr 2025 | Vortex Core Plus | 40% | Third brand, same philosophy |
| May 2025 | Windstudio Hola Mini | 40% | First Vial board |
| May 2025 | YMDK Ferris | 34, split | First split. Tap-dance for accents |
| Jun 2025 | ZSA Voyager | 52, split | First premium split. Validates column-stagger. Layout on [Oryx](https://configure.zsa.io/) |
| Aug 2025 | SplitKB Halcyon Ferris | 34, split | Daily driver. The destination |

Each step removed keys and added firmware intelligence. The path goes from hardware (more keys) to software (more layers).

## Keyboard Collection

**34-key split (daily driver):**
- SplitKB Halcyon Ferris — _column-stagger, Vial_

**52-key split:**
- ZSA Voyager — _column-stagger, Oryx_

**40% (rotation):**
- Epomaker TH40 — _Black Gold (QMK/VIA), Purple (VIA)_
- Vortex Core Plus — _Black/Brown_
- Keychron Q9 / Q9 Plus — _Black, Blue, White_
- Windstudio Hola Mini — _Vial_
- YMDK Ferris — _Vial_

**60% (retired):**
- Custom DZ60RGB — _Gray_
- Keychron Q4 — _Blue_

## Repository Structure

```
keyboards/
├── splitkb/          Halcyon Ferris (Vial + firmware)
├── epomaker/         TH40 variants (VIA + QMK)
├── keychron/         Q0, Q4, Q9, Q9 Plus
├── vortex/           Core Plus
├── windstudio/       Hola Mini
├── ymdk/             Ferris
└── dz/               DZ60RGB
admin/                SVG generation tooling
local/                Nushell keyboard utilities
```

## Tools

- **Firmware**: QMK, VIA, Vial
- **Visualization**: [keymap-drawer](https://github.com/caksoylar/keymap-drawer) via `admin/vil-to-svg.nu`
- **Shell**: Nushell utilities for keyboard management

## License

MIT — see [LICENSE.md](LICENSE.md)

---

> _As Orpheus' music could move stones, these keymaps aim to make code flow effortlessly._
