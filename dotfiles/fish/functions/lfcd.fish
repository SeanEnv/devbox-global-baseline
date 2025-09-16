
function lfcd --description "Open lf, then cd to the dir you ended in"
    set -l tmp (mktemp)
    # Pass through any args, and capture the last directory on exit
    lf -last-dir-path="$tmp" $argv

    if test -f "$tmp"
        set -l dir (cat "$tmp")
        rm -f "$tmp"
        if test -d "$dir"
            cd "$dir"
        end
    end
end

# Optional convenience alias:
alias l='lfcd'
