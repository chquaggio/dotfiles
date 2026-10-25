# Interactive shell config (macOS). PATH, Homebrew and XDG_CONFIG_HOME live in .zprofile.

# Plugins (antidote, cloned on first start)
[[ -e ${ZDOTDIR:-~}/.antidote ]] ||
  git clone --depth=1 https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# Source antidote.
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# Load the default plugin set from .zsh_plugins.txt
antidote load

# Location of this repo, used by cheat()
export DOTFILES="${DOTFILES:-$HOME/personal/dotfiles}"

# New terminals open in $HOME: start in ~/work instead. Shells started anywhere else
# (a tmux pane, an editor's terminal) keep their directory.
[[ $PWD == $HOME && -d $HOME/work ]] && cd $HOME/work

# Secrets from the login Keychain; stays silent when an entry is missing.
# Store one once with: security add-generic-password -a "$USER" -s OC_GITHUB_PAT -w
() {
  local pat
  pat=$(security find-generic-password -s OC_GITHUB_PAT -w 2>/dev/null) && export OC_GITHUB_PAT=$pat
}

bindkey -v
alias vim=nvim
(( $+commands[bat] )) && alias cat="bat -p"
alias dps="docker ps"

cheat()
{
  grep -n -- "$1" "$DOTFILES"/cheat_sheets/*
}

dcu()
{
  docker compose up "$@"
}

dcd()
{
  docker compose down "$@"
}

dl()
{
  docker logs "$@"
}

autoload -U +X bashcompinit && bashcompinit

# SSH: launchd provides SSH_AUTH_SOCK, and UseKeychain/AddKeysToAgent in ~/.ssh/config
# load the key, so the shell starts no agent.

# Node: fnm switches versions on cd (.nvmrc/.node-version); nvm only as a fallback
if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
elif [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  export NVM_DIR="$HOME/.nvm"
  source "$NVM_DIR/nvm.sh"
fi
