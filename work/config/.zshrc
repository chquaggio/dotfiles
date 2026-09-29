# Created by dev for 5.8

[[ -e ${ZDOTDIR:-~}/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

eval "$(/opt/homebrew/bin/brew shellenv)"
# lazygit reads ~/Library/Application Support on macOS unless this is set
export XDG_CONFIG_HOME="$HOME/.config"

# Source antidote.
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# Load the default plugin set from .zsh_plugins.txt
antidote load

export PATH="$PATH:$HOME/.local/bin"
export OC_GITHUB_PAT=$(<~/Credentials/gh_token.txt)

bindkey -v
alias vim=nvim
alias cat="bat -p"
alias python=python3
alias dps="docker ps"

cheat()
{
    grep -n $1 ~/dotfiles/cheat_sheets/*
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


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
