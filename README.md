# Dotfiles

My development environment (Neovim, tmux, Zsh, lazygit, coding-agent config),
kept in two profiles:

- `personal/`: the home PC, Windows with WSL.
- `work/`: the work Mac.

Both profiles share the coding-agent core in `claude/common/`; everything else
is kept per profile and ported by hand when a change should reach both.

## Set up a new work Mac

1. Install the command-line tools and Homebrew:
   ```bash
   xcode-select --install
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
2. Log in to GitHub and clone the repo into `~/dotfiles` (the `cheat` shell
   function expects that path):
   ```bash
   brew install gh && gh auth login
   gh repo clone chquaggio/dotfiles ~/dotfiles
   ```
3. Install the packages:
   ```bash
   brew bundle --file=~/dotfiles/work/Brewfile
   ```
4. Create the SSH key and keep it in the macOS Keychain:
   ```bash
   ssh-keygen -t ed25519
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   gh ssh-key add ~/.ssh/id_ed25519.pub
   ```
   and add to `~/.ssh/config`:
   ```
   Host *
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_ed25519
   ```
5. Put the GitHub token opencode uses in `~/Credentials/gh_token.txt`; `.zshrc`
   reads it at every shell start.
6. Restore the configs and link the coding-agent setup:
   ```bash
   cd ~/dotfiles && make restore DEVENV=work
   ```
7. Install Node through [nvm](https://github.com/nvm-sh/nvm) (Copilot and
   Codeium need it), then `nvm install --lts`.
8. Install Claude Code and log in:
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   claude
   ```
9. Install tmux plugins: clone TPM with
   `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, start
   tmux, press `prefix + I`. Open `nvim` once so lazy.nvim installs its plugins.
10. Set the terminal font to JetBrainsMono Nerd Font.

Done when `ssh -T git@github.com` greets your account, `claude doctor` reports
no problems, and `nvim` starts without errors.

## Daily use

Every target needs `DEVENV=personal` or `DEVENV=work`; `make help DEVENV=work`
lists them.

- `make backup DEVENV=work` copies the live configs (`~/.config/{nvim,lazygit,opencode}`,
  `~/.tmux.conf`, `~/.zshrc`, `~/.zsh_plugins.txt`) into the profile.
  `make restore DEVENV=work` copies them back and runs `link_claude`.
- `make link_claude DEVENV=work` symlinks every item under `claude/common/` and
  `claude/work/` into `~/.claude/`, one at a time, so Claude Code's runtime state
  there stays local. It also links `claude/common/AGENTS.md` for opencode and pi,
  so every coding agent reads the same preferences. A real file already sitting
  where a link should go (for example a `~/.claude/settings.json` Claude Code
  created before the first link) is reported, not replaced: move it aside and
  rerun.

`claude/` has no backup target: `~/.claude` points into this repo, so edits made
by you or by Claude Code (`/permissions`, plugin toggles) show up in
`git status`. Commit them like any other change.
