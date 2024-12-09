SHELL := /bin/zsh
CONFIG_DIRS := nvim

help: # Print help on Makefile
	@grep '^[^.#]\+:\s\+.*#' Makefile | \
	sed "s/\(.\+\):\s*\(.*\) #\s*\(.*\)/`printf "\033[93m"`\1`printf "\033[0m"`	\3 [\2]/" | \
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
			rm -rf "config/$$dir/" && \
			cp -r "$(HOME)/.config/$$dir/" "config/$$dir/" && \
			echo "Successful $$dir backup"; \
		else \
			echo "Failed to backup $$dir - directory does not exist"; \
		fi; \
	done



backup_tmux: # Backup TMUX Config
	@if [ -f $(HOME)/.tmux.conf ]; then \
		[ -f config/tmux.conf ] && rm config/tmux.conf; \
		cp $(HOME)/.tmux.conf config/tmux.conf && \
		echo "Successful TMUX backup"; \
	else \
		echo "Failed TMUX backup"; \
	fi

backup_zsh: # Backup ZSH Config
	@if [ -f $(HOME)/.zshrc ] && [ -f $(HOME)/.zsh_plugins.txt ]; then \
		[ -f config/.zshrc ] && rm config/.zshrc; \
		[ -f config/.zsh_plugins.txt ] && rm config/.zsh_plugins.txt; \
		cp $(HOME)/.zshrc config/.zshrc && \
		cp $(HOME)/.zsh_plugins.txt config/.zsh_plugins.txt && \
		echo "Successful ZSH backup"; \
	else \
		echo "Failed ZSH backup"; \
	fi

restore: # Full restore
	$(MAKE) restore_config
	$(MAKE) restore_tmux
	$(MAKE) restore_zsh

restore_config: # Restore all /.config files
	@for dir in $(CONFIG_DIRS); do \
		if [ -d "config/$$dir" ]; then \
			echo "Restoring $$dir..."; \
			cp -rf "config/$$dir/" "$(HOME)/.config/" && \
			echo "Successful restore of $$dir"; \
		else \
			echo "Backup of $$dir not found"; \
		fi; \
		done


restore_tmux: # Restore .tmux.conf file
	@cp -f config/tmux.conf $(HOME)/.tmux.conf

restore_zsh: # Restore ZSH Config
	@if [ -f config/.zshrc ] && [ -f config/.zsh_plugins.txt ]; then \
		cp config/.zshrc $(HOME)/.zshrc && \
		cp config/.zsh_plugins.txt $(HOME)/.zsh_plugins.txt && \
		echo "Successful ZSH restore"; \
	else \
		echo "ZSH backup files not found"; \
	fi
