# Brewfile — chquaggio/dotfiles (macOS, Apple Silicon)
# Uso:     brew bundle --file=Brewfile
# Drift:   brew bundle cleanup --file=Brewfile   (mostra cosa è installato ma non dichiarato)

# ---------- GNU userland (gli script scritti per WSL/Linux ne dipendono) ----------
brew "coreutils"      # gln, gdate, greadlink... (Makefile usa `ln -T`, solo GNU)
brew "gnu-sed"
brew "grep"           # `grep -T` in cheat() è solo GNU
brew "findutils"
brew "gawk"

# ---------- CLI base ----------
brew "git"
brew "gh"
brew "wget"
brew "jq"
brew "tree"
brew "btop"
brew "pam-reattach"   # Touch ID per sudo dentro tmux

# ---------- Shell / terminale / editor ----------
brew "tmux"
brew "neovim"
brew "tree-sitter-cli" # richiesto da nvim-treesitter (branch main) per compilare i parser
brew "ripgrep"         # fzf-lua / snacks picker
brew "fd"
brew "fzf"
brew "bat"             # su macOS si chiama `bat`, non `batcat`
brew "lazygit"
brew "stylua"          # formatter Lua del repo

# ---------- Linguaggi ----------
brew "uv"              # Python: interpreti + venv + tool (uvx ruff nel hook format-python.sh)
brew "fnm"             # Node per copilot.lua / LSP di Mason; sostituisce nvm (più veloce, supportato via brew)

# ---------- Agenti AI ----------
brew "rtk"             # hook PreToolUse di Claude Code (è il Rust Token Killer, verificato)
brew "opencode"
cask "claude-code"

# ---------- Cloud / container ----------
brew "awscli"
brew "colima"
brew "docker"          # solo CLI: il daemon lo fornisce Colima
brew "docker-compose"  # plugin: richiede cliPluginsExtraDirs in ~/.docker/config.json
brew "docker-buildx"

# ---------- App: terminale e font ----------
cask "ghostty"
cask "font-jetbrains-mono-nerd-font"   # icone di Powerlevel10k, devicons, neo-tree

# ---------- App: dalla pagina "Setup Macbook" ----------
cask "visual-studio-code"
cask "dbeaver-community"
cask "figma"
cask "todoist-app"
cask "rocket-chat"
cask "google-chrome"
cask "google-drive"
cask "alt-tab"
# FortiClient VPN: nessun cask, va scaricato da fortinet.com
