#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT="$ROOT/dotfiles"
BREWFILE="${BREWFILE:-$ROOT/Brewfile}"                  # combined Brewfile
BREWFILE_CORE="${BREWFILE_CORE:-$ROOT/Brewfile.core}"   # optional split
BREWFILE_APPS="${BREWFILE_APPS:-$ROOT/Brewfile.apps}"   # optional split

_have_gum=0
say()  { if [ $_have_gum -eq 1 ]; then gum style --bold --foreground 212 "$*"; else printf "\033[1;35m%s\033[0m\n" "$*"; fi; }
warn() { if [ $_have_gum -eq 1 ]; then gum style --foreground 214 "$*"; else printf "\033[0;33m%s\033[0m\n" "$*"; fi; }

ensure_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    say "Installing Homebrew..."
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

# install gum early
if ! command -v gum >/dev/null 2>&1; then
  brew list gum >/dev/null 2>&1 || brew install gum || true
fi
command -v gum >/dev/null 2>&1 && _have_gum=1

# helpers for brewfile installs
_install_taps_from_file() {
  local file="$1"
  awk -F\" '/^tap /{print $2}' "$file" | while read -r tap; do
    [ -n "$tap" ] && brew tap "$tap" || true
  done
}

_install_formulae_only() {
  local file="$1" tmp="$(mktemp)"
  awk '/^tap |^brew /{print}' "$file" > "$tmp"
  if [ -s "$tmp" ]; then
    say "Installing CLI formulae from $(basename "$file")..."
    brew bundle --file="$tmp" || warn "Some formulae may have failed."
  fi
  rm -f "$tmp"
}

_install_vscode_extensions_from_file() {
  local file="$1" tmp="$(mktemp)"
  awk '/^vscode /{print}' "$file" > "$tmp"
  if [ -s "$tmp" ]; then
    if brew list --cask visual-studio-code >/dev/null 2>&1 || command -v code >/dev/null 2>&1; then
      say "Installing VS Code extensions..."
      brew bundle --file="$tmp" || warn "Some extensions may have failed."
    else
      warn "VS Code not installed; skipping extensions."
    fi
  fi
  rm -f "$tmp"
}

_install_casks_interactively_from_file() {
  local file="$1"
  say "Install GUI apps/fonts (casks) from $(basename "$file")?"
  if gum confirm; then
    local mode
    mode="$(printf "%s\n%s\n" "Install ALL listed casks" "Choose apps interactively" | gum choose --header "Select cask install mode")" || return 0
    if [ "$mode" = "Install ALL listed casks" ]; then
      local tmp="$(mktemp)"
      awk '/^tap |^cask /{print}' "$file" > "$tmp"
      brew bundle --file="$tmp" || warn "Some casks may have failed."
      rm -f "$tmp"
    else
      mapfile -t casks < <(awk -F\" '/^cask /{print $2}' "$file")
      if [ ${#casks[@]} -gt 0 ]; then
        local selection
        selection="$(printf "%s\n" "${casks[@]}" | gum choose --no-limit --header "Select apps to install")" || true
        if [ -n "${selection:-}" ]; then
          while IFS= read -r app; do
            [ -n "$app" ] && brew install --cask "$app" || warn "Skipped $app"
          done <<< "$selection"
        fi
      fi
    fi
  fi
}

# choose Brewfile mode
choice="combined"
if [ -f "$BREWFILE_CORE" ] && [ -f "$BREWFILE_APPS" ]; then
  choice="$(printf "%s\n%s\n" "combined (Brewfile)" "split (Brewfile.core + Brewfile.apps)" \
    | gum choose --header "Which Brewfile layout?")"
fi

if [[ "$choice" == combined* ]] || [ ! -f "$BREWFILE_CORE" ] || [ ! -f "$BREWFILE_APPS" ]; then
  _install_taps_from_file "$BREWFILE"
  _install_formulae_only "$BREWFILE"
  _install_casks_interactively_from_file "$BREWFILE"
  _install_vscode_extensions_from_file "$BREWFILE"
else
  _install_taps_from_file "$BREWFILE_CORE"
  _install_formulae_only "$BREWFILE_CORE"
  _install_taps_from_file "$BREWFILE_APPS"
  _install_casks_interactively_from_file "$BREWFILE_APPS"
  _install_vscode_extensions_from_file "$BREWFILE_APPS"
fi

# link dotfiles (same as minimal)
say "Linking dotfiles..."
[ -f "$DOT/fish/config.fish" ] && link "$DOT/fish/config.fish" "$HOME/.config/fish/config.fish"
[ -d "$DOT/fish/conf.d" ] && find "$DOT/fish/conf.d" -type f -name "*.fish" -exec bash -c 'for f; do link "$f" "$HOME/.config/fish/conf.d/$(basename "$f")"; done' bash {} +
[ -d "$DOT/fish/functions" ] && find "$DOT/fish/functions" -type f -name "*.fish" -exec bash -c 'for f; do link "$f" "$HOME/.config/fish/functions/$(basename "$f")"; done' bash {} +
[ -d "$DOT/fzf" ] && find "$DOT/fzf" -type f -exec bash -c 'for f; do link "$f" "$HOME/.config/fzf/$(basename "$f")"; done' bash {} +
[ -f "$DOT/starship.toml" ] && link "$DOT/starship.toml" "$HOME/.config/starship.toml"
[ -f "$DOT/karabiner/karabiner.json" ] && link "$DOT/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
[ -d "$DOT/lf" ] && {
  [ -f "$DOT/lf/lfrc" ] && link "$DOT/lf/lfrc" "$HOME/.config/lf/lfrc"
  [ -f "$DOT/lf/preview.sh" ] && link "$DOT/lf/preview.sh" "$HOME/.config/lf/preview.sh"
  [ -f "$DOT/lf/cleaner.sh" ] && link "$DOT/lf/cleaner.sh" "$HOME/.config/lf/cleaner.sh"
  chmod +x "$HOME/.config/lf/preview.sh" "$HOME/.config/lf/cleaner.sh" 2>/dev/null || true
}

# iTerm2 profile (only iTerm2-Profiles.json)
ITERM_SRC="$DOT/iterm2/DynamicProfiles"
PROFILE="iTerm2-Profiles.json"
if [ -f "$ITERM_SRC/$PROFILE" ]; then
  target_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$target_dir"
  link "$ITERM_SRC/$PROFILE" "$target_dir/$PROFILE"
  say "Linked iTerm2 profile."
  if brew list --cask iterm2 >/dev/null 2>&1; then open -g -a iTerm || true; fi
fi

# Quick Look reload & Karabiner
command -v qlmanage >/dev/null 2>&1 && qlmanage -r >/dev/null 2>&1 || true
if brew list --cask karabiner-elements >/dev/null 2>&1; then
  open -a "Karabiner-Elements" || true
  say "Karabiner Elements opened (approve permissions if prompted)."
fi

# Optional NvChad install
if command -v nvim >/dev/null 2>&1; then
  say "Install NvChad (Neovim starter)?"
  if gum confirm; then
    if [ ! -d "$HOME/.config/nvim" ]; then
      git clone --depth=1 https://github.com/NvChad/starter "$HOME/.config/nvim"
      say "NvChad installed at ~/.config/nvim"
    else
      warn "~/.config/nvim already exists; skipping."
    fi
  fi
fi

say "Setup complete. Start a new shell (or run: exec fish)."
