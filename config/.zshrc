# Created by dev for 5.8

[[ -e ${ZDOTDIR:-~}/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# Source antidote.
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# Load the default plugin set from .zsh_plugins.txt
antidote load

export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH=$PATH:/home/dev/mybin/nvim-linux64/bin:/home/dev/.local/bin
export PYTHONPATH=$PYTHONPATH:/home/dev/FantaQuoggio:/home/dev
export PYTHONPATH=$PYTHONPATH:/home/dev/genai/gpa

bindkey -v
alias vim=nvim
alias cat="batcat -p"
alias python=python3
alias dps="docker ps"

cheat()
{
    grep -nT $1 /home/dev/cheat_sheets/*
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
