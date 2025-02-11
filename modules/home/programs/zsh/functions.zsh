mkcd() {
    mkdir -p "$1" && cd "$1"
}

codenv() {
    local dir=$(realpath "$1")
    if nix develop "$dir" -c true; then
        nix develop "$dir" -c code "$dir"
    else
        echo "Warning: Failed to initialize developer environment for '$dir'"
        code "$dir"
    fi
}