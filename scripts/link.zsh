#!/bin/zsh
# Symlinks a profile's configs into $HOME, so the repo is the live config and every
# edit (yours or a tool's) shows up in git status. A destination that exists and is
# not a symlink is a real file or directory: it is reported as blocked and never
# overwritten. Every link is attempted before the report, so a collision blocks only
# its own item.
#
# Usage: scripts/link.zsh <profile> [config|home|claude ...]   (default: all three)

setopt nounset nullglob

repo=${0:A:h:h}
profile=${1:?usage: link.zsh <profile> [config|home|claude ...]}
shift
wanted=("$@")
(( $#wanted )) || wanted=(config home claude)
src=$repo/$profile/config
[[ -d $src ]] || { print -u2 "link.zsh: no profile '$profile' (missing $src)"; exit 1 }

blocked=()

link() {
  local err
  if [[ -e $2 && ! -L $2 ]]; then
    blocked+=("$2 -- exists and is not a symlink")
  elif ! err=$(ln -sfn $1 $2 2>&1); then
    blocked+=("$2 -- $err")
  fi
}

# ~/.config/<dir> for each tool directory the profile versions
link_config() {
  local dir
  mkdir -p $HOME/.config
  for dir in nvim lazygit opencode; do
    [[ -d $src/$dir ]] && link $src/$dir $HOME/.config/$dir
  done
}

# Dotfiles in $HOME; a profile may leave some out (personal has no .zprofile, git or
# ssh config)
link_home() {
  local f
  for f in .zshrc .zprofile .zsh_plugins.txt .gitconfig .gitconfig-personal; do
    [[ -f $src/$f ]] && link $src/$f $HOME/$f
  done
  [[ -f $src/tmux.conf ]] && link $src/tmux.conf $HOME/.tmux.conf
  if [[ -f $src/ssh_config ]]; then
    mkdir -p -m 700 $HOME/.ssh
    link $src/ssh_config $HOME/.ssh/config
  fi
}

# claude/common, then the profile layer, item by item, so Claude Code's runtime state
# in ~/.claude (history, projects/, credentials) is never touched. skills/, rules/,
# hooks/ and mods/ link their children so profile items can sit next to common ones;
# settings.json loads each mod through CLAUDE_CODE_PLUGIN_DIRS.
# AGENTS.md stays out of ~/.claude: CLAUDE.md imports it, and Claude Code also loads
# ~/.claude/AGENTS.md as an ancestor's project file whenever the cwd is under $HOME, so
# it would load twice. opencode and pi link the repo file. When ~/.config/opencode is
# itself a symlink, that link lands in <profile>/config/opencode/, which .gitignore excludes.
link_claude() {
  local claude=$HOME/.claude layer item name sub
  mkdir -p $claude
  for layer in common $profile; do
    for item in $repo/claude/$layer/*; do
      name=${item:t}
      case $name in
        __pycache__|AGENTS.md) ;;
        skills|rules|hooks|mods)
          mkdir -p $claude/$name
          for sub in $item/*; do link $sub $claude/$name/${sub:t}; done ;;
        *) link $item $claude/$name ;;
      esac
    done
  done
  mkdir -p $HOME/.config/opencode $HOME/.pi/agent
  link $repo/claude/common/AGENTS.md $HOME/.config/opencode/AGENTS.md
  link $repo/claude/common/AGENTS.md $HOME/.pi/agent/AGENTS.md
}

for group in $wanted; do
  case $group in
    config|home|claude) link_$group ;;
    *) print -u2 "link.zsh: unknown group '$group' (expected config, home or claude)"; exit 1 ;;
  esac
done

if (( $#blocked )); then
  print -u2 "link.zsh: $#blocked item(s) blocked, everything else is linked:"
  print -u2 -l -- "  "${^blocked}
  print -u2 "Move each aside and rerun."
  exit 1
fi
print "Linked $wanted for profile '$profile' into $HOME"
