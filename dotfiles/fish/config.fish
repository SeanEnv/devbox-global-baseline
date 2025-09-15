# Editor
set -gx EDITOR nvim
abbr -a vim nvim

# Homebrew (for casks) on PATH if present
if test -d /opt/homebrew/bin
    fish_add_path -g /opt/homebrew/bin
end

# fzf sources & option files BEFORE sourcing integration
if type -q fd
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND   'fd --type d --hidden --exclude .git'
else
    set -gx FZF_DEFAULT_COMMAND "command find -L . -type f -not -path '*/.git/*'"
    set -gx FZF_CTRL_T_COMMAND  $FZF_DEFAULT_COMMAND
    set -gx FZF_ALT_C_COMMAND   "command find -L . -type d -not -path '*/.git/*'"
end

set -gx FZF_DEFAULT_OPTS_FILE ~/.config/fzf/fzf.conf
set -gx FZF_CTRL_T_OPTS (string trim (cat ~/.config/fzf/ctrl-t.conf 2>/dev/null))
set -gx FZF_ALT_C_OPTS  (string trim (cat ~/.config/fzf/alt-c.conf 2>/dev/null))
set -gx FZF_CTRL_R_OPTS (string trim (cat ~/.config/fzf/history.conf 2>/dev/null))

# Official fzf Fish integration (adds CTRL-T / ALT-C / CTRL-R bindings)
fzf --fish | source

# zoxide (official)
zoxide init fish | source

# Starship prompt
if type -q starship
    starship init fish | source
end

# Handy helpers: expose as functions (installed under functions/)
# ff  -> open picked file in $EDITOR
# fcd -> cd into picked directory
# fg  -> ripgrep -> pick -> open at line
