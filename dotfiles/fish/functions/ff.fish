function ff --description 'Fuzzy-pick a file and open in $EDITOR'
    set -l ed $EDITOR
    test -n "$ed"; or set ed nvim
    set -l f (eval $FZF_CTRL_T_COMMAND | fzf $FZF_CTRL_T_OPTS)
    test -n "$f"; or return
    $ed -- $f
end
