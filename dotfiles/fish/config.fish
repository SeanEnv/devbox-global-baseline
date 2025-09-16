# Editor
set -gx EDITOR nvim
alias vim nvim

# Homebrew on PATH
if test -d /opt/homebrew/bin
    fish_add_path -g /opt/homebrew/bin
end

# Only run interactive customizations in interactive shells
if status is-interactive
    # fzf defaults (set BEFORE integration)
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
    set -gx FZF_CTRL_T_OPTS (string trim -- (cat ~/.config/fzf/ctrl-t.conf 2>/dev/null))
    set -gx FZF_ALT_C_OPTS  (string trim -- (cat ~/.config/fzf/alt-c.conf  2>/dev/null))
    set -gx FZF_CTRL_R_OPTS (string trim -- (cat ~/.config/fzf/history.conf 2>/dev/null))

    # fzf integration (adds fuzzy completion and CTRL-T / ALT-C / CTRL-R bindings)
    fzf --fish | source

    # zoxide
    type -q zoxide; and zoxide init fish | source

    # starship
    type -q starship; and starship init fish | source
end

# Handy helpers: expose as functions (installed under functions/)
# ff    -> open picked file in $EDITOR
# fcd   -> cd into picked directory
# fg    -> ripgrep -> pick -> open at line
# lfcd  -> open lf file manager, then cd to selected dir
# l     -> alias for lfcd
