#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOT="$ROOT/dotfiles"
BREWFILE="$ROOT/Brewfile"

say()  { gum style --bold --foreground 212 "$*"; }
warn() { gum style --foreground 214 "$*"; }

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" || -f "$dst" ]]; then
    if cmp -s "$src" "$dst" 2>/dev/null; then return 0; fi
    mv -f "$dst" "$dst.bak.$(date +%Y%m%d%H%M%S)"
  fi
  ln -sfn "$src" "$dst"
}

ensure_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    say "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
  fi
}

brewfile_install_all() {
  ensure_brew
  brew bundle --file "$BREWFILE" --no-lock
}

brewfile_selective() {
  ensure_brew
  # parse Brewfile for items
  mapfile -t casks < <(awk -F\" '/^cask /{print $2}' "$BREWFILE")
  # multi-select UI
  selection="$(printf "%s\n" "${casks[@]}" | gum choose --no-limit --header "Select apps to install")" || true
  [[ -z "${selection:-}" ]] && return 0
  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    brew install --cask "$item" || warn "Skipped $item"
  done <<< "$selection"
}

reload_quicklook() {
  if command -v qlmanage >/dev/null 2>&1; then
    qlmanage -r >/dev/null 2>&1 || true
  fi
}

say "Linking dotfiles"
# fish & fzf
link "$DOT/fish/config.fish"                  "$HOME/.config/fish/config.fish"
link "$DOT/fish/conf.d/00-devbox-global.fish" "$HOME/.config/fish/conf.d/00-devbox-global.fish"
link "$DOT/fish/functions/ff.fish"            "$HOME/.config/fish/functions/ff.fish"
link "$DOT/fish/functions/fcd.fish"           "$HOME/.config/fish/functions/fcd.fish"
link "$DOT/fish/functions/fg.fish"            "$HOME/.config/fish/functions/fg.fish"
link "$DOT/fzf/fzf.conf"                      "$HOME/.config/fzf/fzf.conf"
link "$DOT/fzf/ctrl-t.conf"                   "$HOME/.config/fzf/ctrl-t.conf"
link "$DOT/fzf/alt-c.conf"                    "$HOME/.config/fzf/alt-c.conf"
link "$DOT/fzf/history.conf"                  "$HOME/.config/fzf/history.conf"
link "$DOT/starship.toml"                     "$HOME/.config/starship.toml"

# karabiner
link "$DOT/karabiner/karabiner.json"          "$HOME/.config/karabiner/karabiner.json"

# lf
link "$DOT/lf/lfrc"                           "$HOME/.config/lf/lfrc"
link "$DOT/lf/preview.sh"                     "$HOME/.config/lf/preview.sh"
link "$DOT/lf/cleaner.sh"                     "$HOME/.config/lf/cleaner.sh"
chmod +x "$HOME/.config/lf/preview.sh" "$HOME/.config/lf/cleaner.sh"

say "Install GUI apps from Brewfile?"
if gum confirm; then
  ensure_brew
  choice="$(printf "%s\n" "Install all (brew bundle)" "Select apps")"
  pick="$(echo "$choice" | gum choose --header "Choose install mode")"

  if [[ "$pick" == "Install all (brew bundle)" ]]; then
    brew bundle --file "$BREWFILE" --no-lock

  else
    # Parse casks from the Brewfile and let user choose
    mapfile -t casks < <(awk -F\" '/^cask /{print $2}' "$BREWFILE")
    selection="$(printf "%s\n" "${casks[@]}" | gum choose --no-limit --header "Select apps to install")" || true
    if [[ -n "${selection:-}" ]]; then
      while IFS= read -r item; do
        [[ -z "$item" ]] && continue
        brew install --cask "$item" || warn "Skipped $item"
      done <<< "$selection"
    fi

    # If VS Code is installed, offer to install our curated extensions via brew bundle (vscode stanzas)
    if brew list --cask visual-studio-code >/dev/null 2>&1; then
      say "Install recommended VS Code extensions?"
      if gum confirm; then
        # Extract our vscode entries and feed them to `brew bundle` in-memory
        vscode_lines="$(awk '/^vscode /{print}' "$BREWFILE")"
        if [[ -n "$vscode_lines" ]]; then
          # Ensure vscode cask is present first
          brew list --cask visual-studio-code >/dev/null 2>&1 || brew install --cask visual-studio-code

          # Build a tiny temp Brewfile with only the vscode entries
          tmpbf="$(mktemp)"
          printf 'tap "homebrew/cask"\n' > "$tmpbf"
          printf '%s\n' "$vscode_lines" >> "$tmpbf"
          brew bundle --file "$tmpbf" --no-lock || warn "Some VS Code extensions failed"
          rm -f "$tmpbf"
        fi
      fi
    else
      warn "VS Code not installed; skipping curated extensions."
    fi
  fi

  # Quick Look plugins take effect after a reload
  if command -v qlmanage >/dev/null 2>&1; then qlmanage -r >/dev/null 2>&1 || true; fi

  # Karabiner post-steps if installed
  if brew list --cask karabiner-elements >/dev/null 2>&1; then
    mkdir -p "$HOME/.config/karabiner"
    link "$DOT/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
    open -a "Karabiner-Elements" || true
    say "Karabiner config installed. Approve accessibility/input monitoring when prompted."
  fi
fi

say "Install NvChad for Neovim? See: https://nvchad.com/"
if gum confirm; then
  if [[ ! -d "$HOME/.config/nvim" ]]; then
    git clone --depth=1 https://github.com/NvChad/starter "$HOME/.config/nvim"
    say "NvChad installed to ~/.config/nvim"
  else
    warn "~/.config/nvim already exists; left unchanged."
  fi
fi

say "Setup complete. Restart your terminal or run: exec fish"
