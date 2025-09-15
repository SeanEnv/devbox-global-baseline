# Devbox Global Baseline (macOS)

Baseline CLI, prompt, shell config, and GUI apps with a single command.

## Install

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/SeanEnv/devbox-global-baseline/main/bootstrap.sh)"
```

- Installs Devbox if missing
- Pulls this repo into Devbox Global
- Runs a guided setup (CLI & GUI)
- Links Fish/Starship/fzf/Karabiner configs
- Optionally installs NvChad for Neovim

Open a new terminal or run exec fish after setup.

## Notes
- CLI tools are provided by Devbox Global (devbox.json), pinned via devbox.lock.
- GUI apps are installed with Homebrew casks (interactive picker).
- Starship uses the Pure Prompt with command duration; time appears on the right (hh:mm:ss).
- Karabiner profile enables Ctrl+h/j/k/l navigation (with Shift for selection; Ctrl+Option for word/paragraph moves).
