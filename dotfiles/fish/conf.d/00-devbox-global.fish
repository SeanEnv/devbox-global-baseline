if command -v devbox >/dev/null
    eval (devbox global shellenv | string collect)
end
