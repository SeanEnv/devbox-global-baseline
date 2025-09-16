#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT="$ROOT/dotfiles"
BREWFILE="${BREWFILE:-$ROOT/Brewfile}"

log()  { printf "\033[1;36m%s\033[0m\n" "$*"; }
warn() { printf "\033[0;33m%s\033[0m\n" "$*"; }

ensure_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" || true
  fi
}

# Backup-aware symlink
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] || [ -f "$dst" ]; then
    if cmp -s "$src" "$dst" 2>/dev/null; then return 0; fi
    mv -f "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  fi
  ln -sfn "$src" "$dst"
}

ensure_brew

[ -f "$BREWFILE" ] || { echo "Brewfile not found at $BREWFILE"; exit 1; }

log "Installing packages via brew bundle..."
brew bundle --file="$BREWFILE"

log "Linking dotfiles (backups created with .bak.<timestamp> if needed)..."

# fish
if [ -d "$DOT/fish" ]; then
  [ -f "$DOT/fish/config.fish" ] && link "$DOT/fish/config.fish" "$HOME/.config/fish/config.fish"

  if [ -d "$DOT/fish/conf.d" ]; then
    find "$DOT/fish/conf.d" -type f -name "*.fish" -print0 \
      | while IFS= read -r -d '' f; do
          link "$f" "$HOME/.config/fish/conf.d/$(basename "$f")"
        done
  fi

  if [ -d "$DOT/fish/functions" ]; then
    find "$DOT/fish/functions" -type f -name "*.fish" -print0 \
      | while IFS= read -r -d '' f; do
          link "$f" "$HOME/.config/fish/functions/$(basename "$f")"
        done
  fi
fi

# fzf
if [ -d "$DOT/fzf" ]; then
  find "$DOT/fzf" -type f -print0 \
    | while IFS= read -r -d '' f; do
        link "$f" "$HOME/.config/fzf/$(basename "$f")"
      done
fi

# starship
[ -f "$DOT/starship.toml" ] && link "$DOT/starship.toml" "$HOME/.config/starship.toml"

# karabiner
[ -f "$DOT/karabiner/karabiner.json" ] && link "$DOT/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"

# lf
if [ -d "$DOT/lf" ]; then
  [ -f "$DOT/lf/lfrc" ] && link "$DOT/lf/lfrc" "$HOME/.config/lf/lfrc"
  [ -f "$DOT/lf/preview.sh" ] && link "$DOT/lf/preview.sh" "$HOME/.config/lf/preview.sh"
  [ -f "$DOT/lf/cleaner.sh" ] && link "$DOT/lf/cleaner.sh" "$HOME/.config/lf/cleaner.sh"
  chmod +x "$HOME/.config/lf/preview.sh" "$HOME/.config/lf/cleaner.sh" 2>/dev/null || true
fi

# iTerm2 Dynamic Profiles
ITERM_SRC="$DOT/iterm2/DynamicProfiles"
PROFILE_FILE="iTerm2-Profiles.json"

if [ -f "$ITERM_SRC/$PROFILE_FILE" ]; then
  target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$target_dir"
  link "$ITERM_SRC/$PROFILE_FILE" "$target_dir/$PROFILE_FILE"
  log "Linked iTerm2 profile: $PROFILE_FILE"
  # If iTerm2 is installed, open once to load profiles
  if brew list --cask iterm2 >/dev/null 2>&1; then
    open -g -a iTerm || true
  fi
fi

# Quick Look reload & open Karabiner if installed
command -v qlmanage >/dev/null 2>&1 && qlmanage -r >/dev/null 2>&1 || true
if brew list --cask karabiner-elements >/dev/null 2>&1; then
  open -a "Karabiner-Elements" || true
fi

log "Setup complete. Start a new shell (or run: exec fish)."
