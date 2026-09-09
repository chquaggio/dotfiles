# Dotfiles README

Welcome to my personalized dotfiles repository. It contains your configurations for `Neovim` and `tmux`, as well as a list of `brew` applications I use.

## Structure

Here is the basic structure of the repository:

```
.
├── Makefile
├── README.md
└── config
    ├── nvim
    └── tmux.conf
```

## How to Use

This repository leverages a `Makefile` for various backup and setup tasks. 
Below are the commands you can use:

### Backup

1. **Backup**
  ```bash
  make backup
  ```
  This command is a high-level target that invokes the other backup targets:
  backup_config, backup_tmux, backup_zsh, and backup_claude. It's utilized for
  performing a full backup operation with just a single command.

2. **Backup Config Listed Directories**
  ```bash
  make backup_config
  ```
  This target iterates over directories specified in the variable CONFIG_DIRS,
  checks if these directories exist in the user's .config directory, backs them up
  by copying to a config directory within the current project, and reports the
  success or failure of each backup operation.

3. **Backup TMUX Configuration**
  ```bash
  make backup_tmux
  ```
  Copies your `.tmux.conf` file from your home directory to the `config`
  directory in this repository for backup.

The coding-agent config has no backup target: `~/.claude` is symlinked to this
repo (see `link_claude` below), so `git status` shows any drift directly.

### Restore Commands
 
1. **Restore** 
  ```bash
  make restore
  ```
  This target allows for a full restoration operation by invoking the other
  restore targets: restore_config, restore_tmux, restore_zsh, and
  restore_claude. It is used to restore previously backed up configuration
  and applications.

2. **Restore Config Listed Directories**
  ```bash
  make restore_config
  ```
  Iterates through the directories within the config directory and restores them
  into the user's .config directory, reporting the success or failure of each
  operation.

3. **Restore TMUX Configuration**
  ```bash
  make restore_tmux
  ```
  Restores the TMUX configuration by copying the backed-up .tmux.conf file from
  the config directory to the user's home directory, overwriting any existing
  .tmux.conf file.

4. **Link Coding-Agent Configuration**
  ```bash
  make link_claude DEVENV=personal
  ```
  Symlinks every item under `claude/common/` (the shared identity: AGENTS.md,
  CLAUDE.md, OPINIONS.md, RTK.md, skills/, rules/, hooks/, statusline.py) and then
  `claude/<DEVENV>/` (settings.json, profile rules) into `~/.claude/`, one item at
  a time, so Claude Code's runtime state in that directory stays local. Also links
  `~/.claude/AGENTS.md` for opencode (`~/.config/opencode/AGENTS.md`) and pi
  (`~/.pi/agent/AGENTS.md`), so every coding agent reads the same preferences.
  Edits made through the symlinks (by you or by Claude Code's `/permissions`,
  plugin toggles, …) land in the repo; commit them like any other change.

## Note

- It is important to periodically update the backup files in this repository to
  keep your configurations and brew packages list up to date.
- Any custom changes or additional configurations you wish to backup should be
  manually added to the appropriate directories or files.

## Contributing

Feel free to fork this repository and adapt the make commands and configurations
to suit your personal setup needs. Contributions and improvements to the script
are welcome.
