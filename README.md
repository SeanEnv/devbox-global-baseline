# Global Baseline (macOS)

This repository provides a reproducible **global developer baseline** for macOS.
It installs common CLI tools, GUI apps, fonts, Quick Look plugins, and links useful dotfiles.

The setup is managed entirely with **Homebrew** and a **Brewfile** — no Devbox or Nix required.

## Prerequisites

* macOS (Apple Silicon or Intel)
* Admin account (Homebrew requires sudo on first install)
* Git installed

## Quick Start

Run the bootstrap script in one line:

```bash
curl -fsSL https://raw.githubusercontent.com/SeanEnv/devbox-global-baseline/main/bootstrap.sh | bash
```

This will:

1. Install Homebrew if missing
2. Clone this repository to `~/.global-baseline`
3. Run `setup.sh`

## Setup Modes

There are two setup scripts to choose from:

### 1. `setup.sh` (default, non-interactive)

* Installs **everything** in `Brewfile` (formulae, casks, fonts, VS Code extensions)
* Links dotfiles into `~/.config/`
* Sets up iTerm2 dynamic profiles
* Refreshes Quick Look, opens Karabiner if installed
* Creates `.bak.<timestamp>` backups of any existing dotfiles

**Use this if you just want the baseline installed with no prompts.**

### 2. `setup-interactive.sh` (optional, guided)

* Uses [gum](https://github.com/charmbracelet/gum) for a friendly TUI
* Lets you choose:
  * Combined `Brewfile` vs split `Brewfile.core` + `Brewfile.apps`
  * Whether to install all casks or select interactively
  * Whether to install VS Code extensions
  * Whether to install NvChad for Neovim

**Use this if you want control over what gets installed.**


## Dotfiles

The repo includes dotfiles under `dotfiles/`:

* `fish/` → Fish shell config, conf.d scripts, functions
* `fzf/` → fzf configuration
* `starship.toml` → Starship prompt
* `karabiner/` → Karabiner Elements config
* `lf/` → lf file manager config + preview/cleaner scripts
* `iterm2/DynamicProfiles/iTerm2-Profiles.json` → iTerm2 dynamic profile

All files are symlinked into `~/.config/` during setup.
Existing files are backed up with a timestamp suffix.

## Executable Permissions

If required, make sure the scripts have execute permissions:

```bash
chmod +x bootstrap.sh setup.sh setup-interactive.sh
```

## Updating

To update the baseline later:

```bash
cd ~/.global-baseline
git pull
./setup.sh    # or ./setup-interactive.sh
```

## Notes

* Homebrew formulas and casks are kept up to date by Homebrew maintainers
* VS Code extensions are installed only if VS Code is present
* iTerm2 profile is automatically linked and loaded if iTerm2 is installed
* Quick Look plugins require `qlmanage -r` (done automatically in setup)
