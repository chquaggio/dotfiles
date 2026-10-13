SHELL := /bin/zsh

# Targets that set up the machine run without DEVENV; a bare `make` runs help.
NO_DEVENV_GOALS := help brew docker_plugins tpm
ifneq ($(filter-out $(NO_DEVENV_GOALS),$(or $(MAKECMDGOALS),help)),)
ifndef DEVENV
$(error DEVENV is not set. Please run make <command> DEVENV=<env>)
endif
ifeq ($(wildcard $(CURDIR)/$(DEVENV)/config),)
$(error DEVENV=$(DEVENV) has no $(DEVENV)/config directory)
endif
endif

.PHONY: help brew docker_plugins restore link_config link_home link_claude tpm

## Machine

help: # Print help on Makefile
	@echo "Usage: make [target] DEVENV=<env>   (help, brew, docker_plugins and tpm need no DEVENV)"
	@awk '/^[a-zA-Z_]+:.*#/ { \
		name = $$0; sub(/:.*/, "", name); \
		desc = $$0; sub(/^[^#]*# */, "", desc); \
		printf "\033[93m%-14s\033[0m %s\n", name, desc \
	}' $(firstword $(MAKEFILE_LIST))

brew: # Install everything listed in the Brewfile
	@command -v brew >/dev/null || { print -u2 "brew not found: install Homebrew first (https://brew.sh)"; exit 1; }
	brew bundle --file="$(CURDIR)/Brewfile"

# Homebrew's docker-compose and docker-buildx are CLI plugins the docker CLI only finds
# through cliPluginsExtraDirs. ~/.docker/config.json can hold registry credentials, so
# it is never versioned: this merges that one key in place and leaves the rest alone.
docker_plugins: # Point the docker CLI at Homebrew's compose/buildx plugins (macOS only)
	@[ "$$(uname -s)" = Darwin ] || { print -u2 "docker_plugins is macOS only: on Linux the docker packages install compose/buildx where the CLI finds them"; exit 1; }
	@command -v jq >/dev/null || { print -u2 "jq not found: run make brew first"; exit 1; }
	@command -v brew >/dev/null || { print -u2 "brew not found: install Homebrew first"; exit 1; }
	@plugins="$$(brew --prefix)/lib/docker/cli-plugins"; \
	cfg="$(HOME)/.docker/config.json"; \
	mkdir -p "$(HOME)/.docker"; \
	[ -f "$$cfg" ] || echo '{}' > "$$cfg"; \
	tmp=$$(mktemp) && \
	jq --arg d "$$plugins" '.cliPluginsExtraDirs = ((.cliPluginsExtraDirs // []) + [$$d] | unique)' "$$cfg" > "$$tmp" && \
	mv "$$tmp" "$$cfg" && \
	echo "cliPluginsExtraDirs in $$cfg now includes $$plugins"

## Profile: scripts/link.zsh symlinks the repo into $HOME, so the repo is the live config

restore: tpm # Link every config of $(DEVENV) into $HOME and install TPM
	@scripts/link.zsh $(DEVENV)

link_config: # Symlink nvim/, lazygit/, opencode/ into ~/.config
	@scripts/link.zsh $(DEVENV) config

link_home: # Symlink .zshrc, .zprofile, .zsh_plugins.txt and tmux.conf into $HOME
	@scripts/link.zsh $(DEVENV) home

link_claude: # Symlink claude/common + claude/$(DEVENV) into ~/.claude; AGENTS.md for opencode/pi
	@scripts/link.zsh $(DEVENV) claude

tpm: # Clone TPM if missing; prefix + I in tmux then fetches the plugins
	@[ -d "$(HOME)/.tmux/plugins/tpm" ] || \
	git clone --quiet --depth=1 https://github.com/tmux-plugins/tpm "$(HOME)/.tmux/plugins/tpm"
