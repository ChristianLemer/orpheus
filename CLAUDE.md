# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Orpheus is a personal mechanical keyboard configuration repository focused on 40% keyboards using QMK/VIA firmware. The repository contains keyboard layouts, firmware binaries, and Nushell utilities for keyboard management.

## Architecture & Structure

### Keyboard Organization
Each keyboard brand has its own directory under `keyboards/`:
- `dz/` - DZ60RGB configurations
- `epomaker/` - Epomaker TH40 (VIA and QMK variants)
- `keychron/` - Keychron Q series (Q0, Q4, Q9)
- `vortex/` - Vortex Core configurations
- `windstudio/` - Windstudio Hola Mini
- `ymdk/` - YMDK Ferris configurations

### File Types
- `.json` - VIA keyboard layout definitions
- `.vil` - VIA IL format layouts
- `.bin` - Compiled firmware binaries
- `.nu` - Nushell utility scripts

### Nushell Utilities
The `local/` directory contains Nushell modules for keyboard management:
- `local/mod.nu` - Main module entry point
- `local/sweep/` - Sweep keyboard utilities
- `local/voyager/` - Voyager keyboard utilities

## Development Workflow

### Working with Keyboard Configurations
1. VIA configurations are JSON files that can be edited directly
2. Use VIA software to load/test configurations
3. Firmware binaries are pre-compiled and stored in the repository

### Commit Standards

#### Jujutsu (jj) Workflow
This repository uses jujutsu for version control with the following commit patterns:
- **Format**: `type(scope): emoji description`
- **Common types**: `feat` (features/additions), `fix` (bug fixes), `docs` (documentation)
- **Emojis**: 
  - :tada: - Initial keyboard layouts
  - :sparkles: - Layout updates and improvements
  - :globe_with_meridians: - Multi-mode/connectivity changes
  - :page_facing_up: - Documentation updates

#### Scopes
Defined in `.cz-config.js`:
- Brand scopes: `dz`, `vortex`, `epomaker`, `keychron`, `windstudio`, `ymdk`, `splitkb`
- Model-specific scopes: `q0`, `q4`, `q9`, `q9-plus`, `th40`, `th40-black`, `th40-purple`, `core-plus`, `hola-mini`, `ferris`, `halcyon-ferris`
- Other: `README/LICENSE`, `git`

#### Commitizen Integration
- Uses commitizen with custom keyboard scopes
- Follow conventional commit format: `type(scope): emoji message`

### Common Tasks

**Adding a new keyboard configuration:**
1. Create appropriate directory under `keyboards/<brand>/`
2. Add VIA JSON configuration file
3. Include firmware binary if available
4. Update README.md with keyboard details

**Modifying keyboard layouts:**
1. Edit the appropriate JSON file
2. Test in VIA software
3. Commit with keyboard-specific scope

**Working with Nushell utilities:**
```nushell
# Load the local module
use local

# Example: USB profiling for specific keyboards
# (Check individual module files for available functions)
```

## Important Notes

- This is a personal configuration repository, not a software development project
- No build system or compilation needed - configurations are used directly
- Firmware binaries are pre-compiled and included in the repository
- Greek mythology theme: Orpheus (legendary musician) for keyboard enthusiasts
- Focus on 40% keyboard layouts with occasional larger keyboards

## Repository Conventions

- Maintain clear directory structure by keyboard brand
- Include both JSON configuration and firmware binary when available
- Document keyboard-specific quirks in commit messages
- Keep Nushell utilities focused on practical keyboard management tasks