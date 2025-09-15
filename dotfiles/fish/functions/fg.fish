function fg --description 'ripgrep + fzf → open match in $EDITOR'
    if not type -q rg
        echo "ripgrep (rg) not found"
        return 1
    end
    set -l q $argv
    if test -z "$q"
        read -P "rg query> " q
    end
    set -l sel (rg --line-number --no-heading --color=always --smart-case --hidden -g '!**/.git/*' -- $q \
        | fzf --ansi --preview-window=down:60%:wrap \
              --preview 'bat --style=numbers --color=always --line-range=:200 {1} 2>/dev/null | sed -n "{2},+200p"')
    test -n "$sel"; or return
    set -l file (echo $sel | awk -F: '{print $1}')
    set -l line (echo $sel | awk -F: '{print $2}')
    test -n "$line"; or set line 1
    $EDITOR +$line -- $file
end
