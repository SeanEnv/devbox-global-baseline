function fcd --description 'Fuzzy cd into a directory'
    set -l d (eval $FZF_ALT_C_COMMAND | fzf $FZF_ALT_C_OPTS)
    test -n "$d"; or return
    cd -- $d
end
