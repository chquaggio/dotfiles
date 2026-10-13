# Dotfiles

Configs for zsh, tmux, Neovim (LazyVim), lazygit, opencode and the coding agents
(Claude Code, opencode, pi), in two profiles picked with `DEVENV=<profile>`:

- `work/`: macOS on Apple Silicon (Homebrew in `/opt/homebrew`).
- `personal/`: Ubuntu under WSL.

## Structure

```
.
├── Brewfile              # every tool the configs depend on (macOS)
├── Makefile              # restore / link targets
├── scripts/link.zsh      # symlinks a profile into $HOME
├── work/config/          # .zprofile, .zshrc, .zsh_plugins.txt, tmux.conf,
│                         # nvim/, lazygit/, opencode/
├── personal/config/      # same layout, no .zprofile
├── claude/               # coding-agent config, symlinked into ~/.claude
│   ├── common/           # shared: AGENTS.md, CLAUDE.md, skills/, rules/, hooks/, ...
│   ├── work/             # settings.json, rules/git-identity.md
│   └── personal/
└── cheat_sheets/         # searched by the `cheat` shell function
```

## New Mac setup (work profile)

The repo is expected at `~/work/dotfiles` (`cheat` uses `$DOTFILES`, which defaults
to that path).

```bash
make brew                        # brew bundle --file=Brewfile
make restore DEVENV=work         # symlinks the profile into $HOME, see below
uv python install 3.13 --default # python/python3 in ~/.local/bin (Apple's is 3.9)
fnm install --lts                # Node for copilot.lua and Mason LSPs
make docker_plugins              # only if you use docker compose/buildx
```

Then open **Ghostty** (not Terminal.app: its font has no Nerd Font glyphs, so
LazyVim's icons show as `?` boxes; Ghostty bundles the Nerd Font symbols), start
tmux and press `prefix + I` to fetch the tmux plugins.

Start `nvim` once so lazy.nvim installs the plugins and builds hererocks, then
quit and run this one-time fix for rest.nvim (see the header of
`work/config/nvim/lua/plugins/rest.lua`):

```bash
~/.local/share/nvim/lazy-rocks/hererocks/bin/luarocks install luarocks-build-treesitter-parser
nvim --headless "+Lazy! build rest.nvim" +qa
```

### GitHub token for opencode (Keychain)

`.zshrc` exports `OC_GITHUB_PAT` from the login Keychain, and stays silent when
the entry is missing. Store it once (the `-w` with no value prompts for it, so the
token stays out of shell history):

```bash
security add-generic-password -a "$USER" -s OC_GITHUB_PAT -w
```

### SSH

macOS launchd already provides `SSH_AUTH_SOCK`, so the shell starts no agent. Let
the Keychain hold the key passphrase with this in `~/.ssh/config` (not versioned):

```
Host *
  UseKeychain yes
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519
```

and add the key once with `ssh-add --apple-use-keychain ~/.ssh/id_ed25519`.

### Docker (Colima)

The Docker daemon comes from Colima (`colima start`). Homebrew's `docker-compose`
and `docker-buildx` are CLI plugins, and the docker CLI only finds them through
`"cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]` in
`~/.docker/config.json`. That file can hold registry credentials, so it is **not**
versioned: `make docker_plugins` merges that single key in with `jq` and leaves the
rest of the file untouched.

### Touch ID for sudo inside tmux (optional)

`pam-reattach` is in the Brewfile. Enabling it is a manual system change: create
`/etc/pam.d/sudo_local` with

```
auth       optional       /opt/homebrew/lib/pam/pam_reattach.so
auth       sufficient     pam_tid.so
```

## Makefile targets

`help`, `brew` and `docker_plugins` run without `DEVENV`; every other target
needs `DEVENV=work` or `DEVENV=personal`.

| Target | What it does |
|---|---|
| `help` | List the targets (also the default) |
| `brew` | `brew bundle` the Brewfile; fails clearly if `brew` is missing |
| `docker_plugins` | Merge `cliPluginsExtraDirs` into `~/.docker/config.json` |
| `restore` | `tpm`, then every link below |
| `link_config` | Symlink `nvim/`, `lazygit/`, `opencode/` into `~/.config` |
| `link_home` | Symlink `.zshrc`, `.zprofile`, `.zsh_plugins.txt` and `tmux.conf` (as `~/.tmux.conf`) into `$HOME` |
| `link_claude` | Symlink `claude/common` + `claude/<DEVENV>` into `~/.claude`; link `AGENTS.md` for opencode and pi |
| `tpm` | Clone TPM if missing; `prefix + I` in tmux then fetches the plugins |

### The repo is the live config

Every config is a symlink into the repo, made by `scripts/link.zsh`. Edits made in
Neovim, lazygit, Claude Code (`/permissions`, plugin toggles), by `:Lazy update` or by
an installer that appends to `~/.zshrc` land in the repo and show up in `git status`.
Commit them, or discard them with `git checkout`. There is nothing to back up.

Linking never overwrites a real file or directory. Each one in the way is reported
as blocked, every other link is still made, and the command exits non-zero. Move the
blocked items aside and rerun. Reruns are idempotent.

Each machine links its own clone and its own profile (`work` on the Mac, `personal`
on WSL), so tools on one machine write that profile's files only. Changes reach the
other machine through git; `claude/common/` is the one layer both edit, so pull
before changing it.

### `.zprofile` and `.zshrc`

- `.zprofile` (login shells): `brew shellenv`, `XDG_CONFIG_HOME=~/.config` (without
  it lazygit on macOS reads `~/Library/Application Support/lazygit`), and
  `~/.local/bin` first on `PATH`.
- `.zshrc` (interactive): antidote plugins, aliases, `cheat`, the Keychain secret,
  and fnm (falls back to nvm only when fnm is missing).
