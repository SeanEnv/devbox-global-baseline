#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/SeanEnv/devbox-global-baseline}"

if ! command -v devbox >/dev/null 2>&1; then
  echo "Installing Devbox..."
  curl -fsSL https://get.jetify.com/devbox | bash
  if [ -x /opt/homebrew/bin/devbox ]; then
    export PATH="/opt/homebrew/bin:$PATH"
  fi
fi

GLOBAL_DIR="$(devbox global path)"
mkdir -p "$GLOBAL_DIR"

if [ -d "$GLOBAL_DIR/.git" ]; then
  echo "Updating baseline in $GLOBAL_DIR"
  git -C "$GLOBAL_DIR" pull --ff-only
else
  echo "Cloning baseline into $GLOBAL_DIR"
  rm -rf "$GLOBAL_DIR"/*
  git clone "$REPO_URL" "$GLOBAL_DIR"
fi

echo "Running baseline setup..."
devbox global run setup

echo "Done. Open a new terminal or run: exec fish"
