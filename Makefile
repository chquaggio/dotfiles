SHELL := /bin/zsh
CONFIG_DIRS := nvim lazygit opencode
CLAUDE_HOME := $(HOME)/.claude

# Targets that work on the machine rather than a profile run without DEVENV. A bare
# `make` runs help, so it is exempt too.
NO_DEVENV_GOALS := help brew docker_plugins
ifneq ($(filter-out $(NO_DEVENV_GOALS),$(or $(MAKECMDGOALS),help)),)
ifndef DEVENV
$(error DEVENV is not set. Please run make <command> DEVENV=<env>)
endif
ifeq ($(wildcard $(CURDIR)/$(DEVENV)/config),)
$(error DEVENV=$(DEVENV) has no $(DEVENV)/config directory)
endif
endif

# Shell helper shared by the symlinking targets. A destination that exists and is not a
# symlink is a real file or directory: it is recorded in `blocked` and left alone, never
# overwritten. Anything else (missing, or an old symlink) is replaced. `ln -sfn` behaves
# the same on BSD and GNU. Callers declare `blocked=()` and report it at the end, so
# every link is attempted before anything fails.
LINK_FN = link() { \
	if [ -e "$$2" ] && [ ! -L "$$2" ]; then \
		blocked+=("$$2 -- exists and is not a symlink"); \
	else \
		err=$$(ln -sfn "$$1" "$$2" 2>&1) || blocked+=("$$2 -- $$err"); \
	fi; \
};

help: # Print help on Makefile
	@echo "Usage: make [target] DEVENV=<env>   (help, brew and docker_plugins need no DEVENV)"
	@awk '/^[a-zA-Z_]+:.*#/ { \
		name = $$0; sub(/:.*/, "", name); \
		desc = $$0; sub(/^[^#]*# */, "", desc); \
		printf "\033[93m%-18s\033[0m %s\n", name, desc \
	}' $(firstword $(MAKEFILE_LIST))

brew: # Install everything listed in the Brewfile
	@command -v brew >/dev/null || { print -u2 "brew not found: install Homebrew first (https://brew.sh)"; exit 1; }
	brew bundle --file="$(CURDIR)/Brewfile"

# Homebrew's docker-compose and docker-buildx are CLI plugins the docker CLI only finds
# through cliPluginsExtraDirs. ~/.docker/config.json can hold registry credentials, so
# it is never versioned: this merges that one key in place and leaves the rest alone.
docker_plugins: # Point the docker CLI at Homebrew's compose/buildx plugins
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

backup: # Full Backup
	$(MAKE) backup_config
	$(MAKE) backup_tmux
	$(MAKE) backup_zsh

# restore_config symlinks these directories, so on a restored machine they already are
# the repo and are skipped. Only a real directory (a manual install) is copied back.
backup_config: # Back up real (non-symlinked) dirs from ~/.config
	@for dir in $(CONFIG_DIRS); do \
		src="$(HOME)/.config/$$dir"; \
		if [ -L "$$src" ]; then \
			echo "$$dir is a symlink into the repo, nothing to back up"; \
		elif [ -d "$$src" ]; then \
			echo "Backing up $$dir..."; \
			rm -rf "$(DEVENV)/config/$$dir" && \
			cp -R "$$src" "$(DEVENV)/config/$$dir" && \
			echo "Successful $$dir backup"; \
		else \
			echo "Failed to backup $$dir - directory does not exist"; \
		fi; \
	done

backup_tmux: # Backup TMUX Config
	@if [ -f $(HOME)/.tmux.conf ]; then \
		cp -f $(HOME)/.tmux.conf $(DEVENV)/config/tmux.conf && \
		echo "Successful TMUX backup"; \
	else \
		echo "Failed TMUX backup"; \
	fi

# .zprofile is backed up only for profiles that version one.
backup_zsh: # Backup ZSH Config
	@if [ -f $(HOME)/.zshrc ] && [ -f $(HOME)/.zsh_plugins.txt ]; then \
		cp -f $(HOME)/.zshrc $(DEVENV)/config/.zshrc && \
		cp -f $(HOME)/.zsh_plugins.txt $(DEVENV)/config/.zsh_plugins.txt && \
		echo "Successful ZSH backup"; \
	else \
		echo "Failed ZSH backup"; \
	fi
	@if [ -f $(DEVENV)/config/.zprofile ] && [ -f $(HOME)/.zprofile ]; then \
		cp -f $(HOME)/.zprofile $(DEVENV)/config/.zprofile && \
		echo "Successful .zprofile backup"; \
	fi

restore: # Full restore
	$(MAKE) restore_config
	$(MAKE) restore_tmux
	$(MAKE) restore_zsh
	$(MAKE) link_claude

# Same model as link_claude: ~/.config/<dir> becomes a symlink to the repo, so edits
# (lazy-lock.json updates included) show up in git status and need no backup step.
restore_config: # Symlink nvim/, lazygit/, opencode/ into ~/.config
	@blocked=(); \
	$(LINK_FN) \
	mkdir -p "$(HOME)/.config"; \
	for dir in $(CONFIG_DIRS); do \
		if [ -d "$(CURDIR)/$(DEVENV)/config/$$dir" ]; then \
			link "$(CURDIR)/$(DEVENV)/config/$$dir" "$(HOME)/.config/$$dir"; \
		else \
			echo "No $$dir in $(DEVENV)/config, skipped"; \
		fi; \
	done; \
	if (( $${#blocked} )); then \
		print -u2 "restore_config: $${#blocked} item(s) blocked, everything else is linked."; \
		printf "  %s\n" "$${blocked[@]}" >&2; \
		print -u2 "Move each aside and rerun."; \
		exit 1; \
	fi; \
	echo "Linked $(CONFIG_DIRS) from $(DEVENV)/config into $(HOME)/.config"

# The repo is the live config: every item under claude/common and claude/$(DEVENV) is
# symlinked one by one into ~/.claude, so runtime state there (history, projects/,
# cache/, credentials) is never touched and never enters git. Top-level entries link
# directly; skills/, rules/ and hooks/ link their children so profile items can sit
# next to common ones. A leftover non-symlink in ~/.claude is reported instead of
# silently shadowed. Every link is attempted before the report: a collision blocks
# only its own item, never the entries that happen to sort after it or the profile
# layer that follows. When ~/.config/opencode is itself a symlink (restore_config),
# its AGENTS.md link lands in $(DEVENV)/config/opencode/, which .gitignore excludes.
link_claude: # Symlink claude/common + claude/$(DEVENV) into ~/.claude; link AGENTS.md for opencode/pi
	@setopt nullglob; \
	blocked=(); \
	$(LINK_FN) \
	mkdir -p "$(CLAUDE_HOME)"; \
	for layer in common $(DEVENV); do \
		for src in "$(CURDIR)/claude/$$layer"/*; do \
			name=$$(basename "$$src"); \
			case "$$name" in \
				__pycache__) ;; \
				skills|rules|hooks) \
					mkdir -p "$(CLAUDE_HOME)/$$name"; \
					for item in "$$src"/*; do \
						link "$$item" "$(CLAUDE_HOME)/$$name/$$(basename "$$item")"; \
					done ;; \
				*) link "$$src" "$(CLAUDE_HOME)/$$name" ;; \
			esac; \
		done; \
	done; \
	mkdir -p "$(HOME)/.config/opencode" "$(HOME)/.pi/agent"; \
	link "$(CLAUDE_HOME)/AGENTS.md" "$(HOME)/.config/opencode/AGENTS.md"; \
	link "$(CLAUDE_HOME)/AGENTS.md" "$(HOME)/.pi/agent/AGENTS.md"; \
	if (( $${#blocked} )); then \
		print -u2 "link_claude: $${#blocked} item(s) blocked, everything else is linked."; \
		printf "  %s\n" "$${blocked[@]}" >&2; \
		print -u2 "Move each aside and rerun."; \
		exit 1; \
	fi; \
	echo "Linked claude/common + claude/$(DEVENV) into $(CLAUDE_HOME)"

# TPM is cloned once; `prefix + I` inside tmux then fetches the plugins it lists.
restore_tmux: # Restore ~/.tmux.conf and install TPM if missing
	@cp -f $(DEVENV)/config/tmux.conf $(HOME)/.tmux.conf && echo "Successful TMUX restore"
	@if [ -d "$(HOME)/.tmux/plugins/tpm" ]; then \
		echo "TPM already installed"; \
	else \
		git clone --quiet --depth=1 https://github.com/tmux-plugins/tpm "$(HOME)/.tmux/plugins/tpm" && \
		echo "Installed TPM: press prefix + I in tmux to fetch the plugins"; \
	fi

restore_zsh: # Restore ~/.zshrc, ~/.zsh_plugins.txt and (if versioned) ~/.zprofile
	@if [ -f $(DEVENV)/config/.zshrc ] && [ -f $(DEVENV)/config/.zsh_plugins.txt ]; then \
		cp $(DEVENV)/config/.zshrc $(HOME)/.zshrc && \
		cp $(DEVENV)/config/.zsh_plugins.txt $(HOME)/.zsh_plugins.txt && \
		echo "Successful ZSH restore"; \
	else \
		echo "ZSH backup files not found"; \
	fi
	@if [ -f $(DEVENV)/config/.zprofile ]; then \
		cp $(DEVENV)/config/.zprofile $(HOME)/.zprofile && \
		echo "Successful .zprofile restore"; \
	fi
