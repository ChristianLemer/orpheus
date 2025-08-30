# 🎵 Orpheus

_Configuration files and resources for my 40% mechanical keyboards_

## Overview

Orpheus, named after the legendary musician who could charm all living things with his melody, is my personal repository for keyboard configurations and resources. Just as Orpheus mastered the lyre, I aim to master the minimal yet powerful 40% keyboard layout.

## About

This repository contains configuration files, firmware, layout designs, and other resources for my collection of 40% mechanical keyboards. These compact keyboards represent the perfect balance between portability and functionality, requiring thoughtful design and customization to reach their full potential.

## Keyboard Collection

_My current 40% keyboards_:
- Keychron Q9 _Black_
- Keychron Q9 _Blue_
- Keychron Q9 _Plus White_
- Epomaker TH40 _Black Gold (Via)_
- Epomaker TH40 _Purple (Via)_
- Epomaker TH40 _Black Gold (QMK/Via)_
- Vortex Core plus _Black/Brown_
- SplitKB Halcyon Ferris _Split 40%_

_My other keyboards_:
- Custom DZ60RGB _Gray (60%)_
- Keychron Q4 _Blue (60%)_

## Features

- **Custom Keymaps**: Optimized layers for programming and daily use


## Tools & Technologies

- **Firmware**: QMK, VIA, Vial

## Firmware Management

### SplitKB Halcyon Series Firmware

To download firmware for SplitKB Halcyon keyboards (Ferris, Elora, Kyria, etc.):

1. **Visit the Firmware Finder**: Navigate to [SplitKB Composer Firmware Finder](https://canary.composer.splitkb.com/#/firmware)

2. **Select your configuration**:
   - Choose your keyboard model (e.g., Halcyon Ferris)
   - Select left module (None for base, or Cirque Trackpad/TFT Display if installed)
   - Select right module (None for base, or Cirque Trackpad/TFT Display if installed)
   - Choose firmware type (Vial recommended for easy configuration)

3. **Download the UF2 file**: The file will be downloaded to your browser's default download location (typically OneDrive Downloads)

4. **File management**: The downloaded firmware will be automatically moved from your OneDrive Downloads to `keyboards/splitkb/downloads/` in this repository

5. **Firmware naming convention**:
   - Base: `splitkb_halcyon_[model]_rev[X]_vial_hlc.uf2`
   - With trackpad: `splitkb_halcyon_[model]_rev[X]_vial_hlc_cirque_trackpad.uf2`
   - With display: `splitkb_halcyon_[model]_rev[X]_vial_hlc_display.uf2`

6. **Flashing process**:
   - Double-tap the reset button on your keyboard controller
   - A drive named `RPI-RP2` will appear
   - Drag and drop the UF2 file to this drive
   - Both halves need to be flashed individually

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributions

This is a personal repository, but suggestions and discussions are welcome through issues.

---
> "As Orpheus' music could move stones, these keyboard configurations aim to make code flow effortlessly through my fingertips."
