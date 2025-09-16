#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/SeanEnv/devbox-global-baseline}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.global-baseline}"

log() { printf "\033[1;36m%s\033[0m\n" "$*"; }
err() { printf "\033[1;31m%s\033[0m\n" "$*" >&2; }

ensure_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew not found — installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # The installer may prompt for your password to create /opt/homebrew.
    eval "$(/opt/homebrew/bin/brew shellenv)" || true
  fi
}

ensure_brew

if [ -d "$INSTALL_DIR/.git" ]; then
  log "Updating repo in $INSTALL_DIR..."
  git -C "$INSTALL_DIR" pull --ff-only
else
  log "Cloning repo into $INSTALL_DIR..."
  rm -rf "$INSTALL_DIR"
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

log "Running setup..."
exec bash "$INSTALL_DIR/setup.sh"
