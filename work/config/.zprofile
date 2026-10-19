# Login-shell environment (macOS, Apple Silicon). Runs once per login shell, before
# .zshrc; Ghostty and tmux both start login shells, so everything below is inherited.

# Homebrew: PATH, MANPATH, INFOPATH and the zsh site-functions on fpath
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Without this, lazygit on macOS reads ~/Library/Application Support/lazygit and
# ignores the repo config symlinked into ~/.config
export XDG_CONFIG_HOME="$HOME/.config"

# User binaries: uv-managed python/python3, uv tools, scripts
typeset -U path
path=("$HOME/.local/bin" $path)
