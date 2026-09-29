SHELL := /bin/zsh
CONFIG_DIRS := nvim lazygit opencode
CLAUDE_HOME := $(HOME)/.claude

ifndef DEVENV
$(error DEVENV is not set. Please run make <command> DEVENV=<env>)
endif

help: # Print help on Makefile
	@echo "Usage: make [target] DEVENV=<env>"
	@grep -E '^[^.#]+:[[:space:]]+.*#' Makefile | \
	sed -E "s/(.+):[[:space:]]*(.*) #[[:space:]]*(.*)/`printf "\033[93m"`\1`printf "\033[0m"`	\3 [\2]/" | \
	expand -t20


backup: # Full Backup
	$(MAKE) backup_config
	$(MAKE) backup_tmux
	$(MAKE) backup_zsh

backup_config: #Back up specified files in .config
	@for dir in $(CONFIG_DIRS); do \
		echo $$dir; \
		if [ -d "$(HOME)/.config/$$dir" ]; then \
			echo "Backing up $$dir..."; \
			rm -rf "$(DEVENV)/config/$$dir/" && \
			cp -R "$(HOME)/.config/$$dir" "$(DEVENV)/config/$$dir" && \
			echo "Successful $$dir backup"; \
		else \
			echo "Failed to backup $$dir - directory does not exist"; \
		fi; \
	done


backup_tmux: # Backup TMUX Config
	@if [ -f $(HOME)/.tmux.conf ]; then \
		[ -f $(DEVENV)/config/tmux.conf ] && rm $(DEVENV)/config/tmux.conf; \
		cp $(HOME)/.tmux.conf $(DEVENV)/config/tmux.conf && \
		echo "Successful TMUX backup"; \
	else \
		echo "Failed TMUX backup"; \
	fi

backup_zsh: # Backup ZSH Config
	@if [ -f $(HOME)/.zshrc ] && [ -f $(HOME)/.zsh_plugins.txt ]; then \
		[ -f $(DEVENV)/config/.zshrc ] && rm $(DEVENV)/config/.zshrc; \
		[ -f $(DEVENV)/config/.zsh_plugins.txt ] && rm $(DEVENV)/config/.zsh_plugins.txt; \
		cp $(HOME)/.zshrc $(DEVENV)/config/.zshrc && \
		cp $(HOME)/.zsh_plugins.txt $(DEVENV)/config/.zsh_plugins.txt && \
		echo "Successful ZSH backup"; \
	else \
		echo "Failed ZSH backup"; \
	fi

restore: # Full restore
	$(MAKE) restore_config
	$(MAKE) restore_tmux
	$(MAKE) restore_zsh
	$(MAKE) link_claude

restore_config: # Restore all /.config files
	@for dir in $(CONFIG_DIRS); do \
		if [ -d "$(DEVENV)/config/$$dir" ]; then \
			echo "Restoring $$dir..."; \
			cp -Rf "$(DEVENV)/config/$$dir" "$(HOME)/.config/" && \
			echo "Successful restore of $$dir"; \
		else \
			echo "Backup of $$dir not found"; \
		fi; \
		done


# The repo is the live config: every item under claude/common and claude/$(DEVENV) is
# symlinked one by one into ~/.claude, so runtime state there (history, projects/,
# cache/, credentials) is never touched and never enters git. Top-level entries link
# directly; skills/, rules/ and hooks/ link their children so profile items can sit
# next to common ones. A leftover non-symlink in ~/.claude is reported instead of
# replaced or shadowed (the explicit check, since BSD ln on macOS has no -T). Every
# link is attempted before the report: a collision blocks only its own item, never
# the entries that happen to sort after it or the profile layer that follows.
# AGENTS.md stays out of ~/.claude: CLAUDE.md already imports it, and Claude Code also
# loads ~/.claude/AGENTS.md as project instructions under ~, so a link loads it twice.
link_claude: # Symlink claude/common + claude/$(DEVENV) into ~/.claude; link AGENTS.md for opencode/pi
	@setopt nullglob; \
	blocked=(); \
	link() { \
		if [[ -e "$$2" && ! -L "$$2" ]]; then blocked+=("$$2 -- not a symlink"); \
		elif ! err=$$(ln -sfn "$$1" "$$2" 2>&1); then blocked+=("$$2 -- $${err##*: }"); fi; \
	}; \
	mkdir -p "$(CLAUDE_HOME)"; \
	for layer in common $(DEVENV); do \
		for src in "$(CURDIR)/claude/$$layer"/*; do \
			name=$$(basename "$$src"); \
			case "$$name" in \
				skills|rules|hooks) \
					mkdir -p "$(CLAUDE_HOME)/$$name"; \
					for item in "$$src"/*; do \
						link "$$item" "$(CLAUDE_HOME)/$$name/$$(basename "$$item")"; \
					done ;; \
				AGENTS.md) ;; \
				*) link "$$src" "$(CLAUDE_HOME)/$$name" ;; \
			esac; \
		done; \
	done; \
	mkdir -p "$(HOME)/.config/opencode" "$(HOME)/.pi/agent"; \
	link "$(CURDIR)/claude/common/AGENTS.md" "$(HOME)/.config/opencode/AGENTS.md"; \
	link "$(CURDIR)/claude/common/AGENTS.md" "$(HOME)/.pi/agent/AGENTS.md"; \
	if (( $${#blocked} )); then \
		print -u2 "link_claude: $${#blocked} item(s) blocked, everything else is linked."; \
		printf "  %s\n" "$${blocked[@]}" >&2; \
		print -u2 "Move each aside and rerun."; \
		exit 1; \
	fi; \
	echo "Linked claude/common + claude/$(DEVENV) into $(CLAUDE_HOME)"

restore_tmux: # Restore .tmux.conf file
	@cp -f $(DEVENV)/config/tmux.conf $(HOME)/.tmux.conf

restore_zsh: # Restore ZSH Config
	@if [ -f $(DEVENV)/config/.zshrc ] && [ -f $(DEVENV)/config/.zsh_plugins.txt ]; then \
		cp $(DEVENV)/config/.zshrc $(HOME)/.zshrc && \
		cp $(DEVENV)/config/.zsh_plugins.txt $(HOME)/.zsh_plugins.txt && \
		echo "Successful ZSH restore"; \
	else \
		echo "ZSH backup files not found"; \
	fi
