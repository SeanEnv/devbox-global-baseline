
# Devbox Global Baseline (macOS)

Unified CLI, prompt, shell config, and GUI app setup for macOS, powered by [Devbox](https://jetify.com/devbox) and Homebrew.

## Features

- **CLI tools** managed by Devbox Global ([devbox.json](devbox.json)), reproducible and pinned via `devbox.lock`.
- **GUI apps** installed via Homebrew casks ([Brewfile](Brewfile)), with interactive selection.
- **Dotfiles** for Fish shell, Starship prompt, fzf, Karabiner, lf, and more, auto-linked to `~/.config`.
- **Curated VS Code extensions** installed via Brewfile if VS Code is present.
- **Optional Neovim config**: Guided install of [NvChad](https://nvchad.com/) starter.
- **Quick Look plugins** for enhanced file previews (reloads automatically).
- **Karabiner profile** for Vim-style navigation (Ctrl/Shift/Option combos).

## Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SeanEnv/devbox-global-baseline/main/bootstrap.sh)"
```

- Installs Devbox if missing
- Pulls this repo into Devbox Global directory
- Runs a guided setup (setup.sh)
- Links all dotfiles (Fish, Starship, fzf, Karabiner, lf, etc.)
- Installs CLI tools (Devbox) and GUI apps (Homebrew)
- Optionally installs NvChad for Neovim

Open a new terminal or run `exec fish` after setup.

## Project Structure

- `devbox.json`: CLI tool list (Devbox Global)
- `Brewfile`: Homebrew casks & VS Code extensions
- `dotfiles/`: Fish, Starship, fzf, Karabiner, lf configs
- `setup.sh`: Main guided setup script
- `bootstrap.sh`: One-liner installer

## Notes

- All CLI tools are available globally via Devbox.
- GUI apps are installed interactively; you can pick which to install.
- Dotfiles are symlinked to `~/.config` (backups made if needed).
- Starship prompt uses a modified Pure Prompt style, shows command duration and time (hh:mm:ss) on the right.
- Karabiner profile enables Vim-style navigation:  
  - Ctrl+h/j/k/l = arrows  
  - Ctrl+Shift = select while moving  
  - Ctrl+Option = word/paragraph moves  
  - Ctrl+Option+Shift = word/paragraph selection

---
For details, see [setup.sh](setup.sh) and [devbox.json](devbox.json).
