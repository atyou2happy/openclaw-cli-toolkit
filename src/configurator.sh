#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC2034
CONFIGURATOR_VERSION="$(cat "$(dirname "${BASH_SOURCE[0]}")/../VERSION" | tr -d '[:space:]')"
# shellcheck disable=SC2034
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/openclaw-toolkit"

setup_bat_config() {
	if ! command -v bat &>/dev/null; then return; fi
	write_config_file "${XDG_CONFIG_HOME:-$HOME/.config}/bat/config" '--theme="TwoDark"
--style="full"
--italic-text=always
--map-syntax="*.conf:INI"
--map-syntax=".gitignore:Git Ignore"'
}

setup_ripgrep_config() {
	if ! command -v rg &>/dev/null; then return; fi
	write_config_file "$HOME/.ripgreprc" '--smart-case
--max-columns=150
--max-columns-preview'

	# shellcheck disable=SC2016
	append_to_shell_rc "RIPGREP_CONFIG_PATH" 'export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"'
}

setup_fzf_config() {
	if ! command -v fzf &>/dev/null; then return; fi
	local rc_d
	rc_d="$(shell_rc_d_dir)"

	# shellcheck disable=SC2016
	write_config_file "$rc_d/fzf.sh" 'export FZF_DEFAULT_OPTS='"'"'--height 40% --layout=reverse --border'"'"'
export FZF_DEFAULT_COMMAND='"'"'fd --type f --hidden --follow --exclude .git'"'"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='"'"'fd --type d --hidden --follow --exclude .git'"'"''

	append_to_shell_rc "fzf.sh" "[ -f \"${rc_d}/fzf.sh\" ] && source \"${rc_d}/fzf.sh\""
}

setup_zoxide_config() {
	if ! command -v zoxide &>/dev/null; then return; fi
	local rc_d
	rc_d="$(shell_rc_d_dir)"

	local init_cmd
	# shellcheck disable=SC2016
	case "${SHELL_TYPE:-bash}" in
	zsh) init_cmd='eval "$(zoxide init zsh --cmd z)"' ;;
	fish) init_cmd='zoxide init fish --cmd z | source' ;;
	*) init_cmd='eval "$(zoxide init bash --cmd z)"' ;;
	esac

	write_config_file "$rc_d/zoxide.sh" "$init_cmd"
	append_to_shell_rc "zoxide.sh" "[ -f \"${rc_d}/zoxide.sh\" ] && source \"${rc_d}/zoxide.sh\""
}

setup_starship_config() {
	if ! command -v starship &>/dev/null; then return; fi

	# shellcheck disable=SC2016
	write_config_file "$HOME/.config/starship.toml" '[character]
success_symbol = "[>](bold green)"
error_symbol = "[x](bold red)"

[git_branch]
format = "[$symbol$branch]($style) "

[directory]
truncation_length = 3
truncate_to_repo = true

[cmd_duration]
min_time = 2_000
format = "took [$duration]($style) "'

	local init_cmd
	# shellcheck disable=SC2016
	case "${SHELL_TYPE:-bash}" in
	zsh) init_cmd='eval "$(starship init zsh)"' ;;
	fish) init_cmd='starship init fish | source' ;;
	*) init_cmd='eval "$(starship init bash)"' ;;
	esac
	append_to_shell_rc "starship init" "$init_cmd"
}

setup_delta_config() {
	if ! command -v delta &>/dev/null; then return; fi

	if ! git config --global core.pager &>/dev/null; then
		if [[ "${DRY_RUN:-false}" != "true" ]]; then
			git config --global core.pager delta
			git config --global interactive.diffFilter "delta --color-only"
			git config --global delta.navigate true
			git config --global delta.side-by-side true
			git config --global delta.line-numbers true
			_success "Configured git to use delta as pager"
		else
			_info "[DRY-RUN] git config --global for delta"
		fi
	fi
}

setup_tmux_config() {
	if ! command -v tmux &>/dev/null; then return; fi

	write_config_file "$HOME/.tmux.conf" 'set -g mouse on
set -g default-terminal "screen-256color"
set -g history-limit 10000
bind | split-window -h
bind - split-window -v
set -g base-index 1
setw -g pane-base-index 1'
}

setup_lazygit_config() {
	if ! command -v lazygit &>/dev/null; then return; fi

	write_config_file "$HOME/.config/lazygit/config.yml" 'gui:
  showIcons: true
  theme:
    activeBorderColor:
      - green
      - bold
git:
  paging:
    colorArg: always
    pager: delta'
}

setup_aria2_config() {
	if ! command -v aria2c &>/dev/null; then return; fi

	# shellcheck disable=SC2016
	write_config_file "$HOME/.aria2/aria2.conf" 'max-connection-per-server=16
min-split-size=1M
split=16
continue=true
max-concurrent-downloads=5
dir=${HOME}/Downloads'
}

setup_aliases() {
	local rc_d
	rc_d="$(shell_rc_d_dir)"
	local aliases_file="$rc_d/openclaw-aliases.sh"
	local content="#!/bin/bash"

	if command -v bat &>/dev/null; then
		content+=$'\n'"alias cat='bat --style=plain'"
		content+=$'\n'"alias catn='bat --style=full'"
	fi

	if command -v eza &>/dev/null; then
		content+=$'\n'"alias ls='eza'"
		content+=$'\n'"alias ll='eza -la'"
		content+=$'\n'"alias lt='eza -T -L 2'"
		content+=$'\n'"alias la='eza -la'"
	fi

	if command -v dust &>/dev/null; then
		content+=$'\n'"alias du='dust'"
	fi

	if command -v duf &>/dev/null; then
		content+=$'\n'"alias df='duf'"
	fi

	if command -v procs &>/dev/null; then
		content+=$'\n'"alias ps='procs'"
	fi

	if command -v http &>/dev/null; then
		content+=$'\n'"alias https='http --default-scheme=https'"
	fi

	write_config_file "$aliases_file" "$content"
	append_to_shell_rc "openclaw-aliases.sh" "[ -f \"${aliases_file}\" ] && source \"${aliases_file}\""
}

configure_all() {
	_info "Configuring tools..."

	ensure_dir "$CONFIG_DIR"

	local rc_d
	rc_d="$(shell_rc_d_dir)"
	ensure_dir "$rc_d"

	setup_ripgrep_config
	setup_bat_config
	setup_fzf_config
	setup_zoxide_config
	setup_starship_config
	setup_delta_config
	setup_tmux_config
	setup_lazygit_config
	setup_aria2_config
	setup_aliases

	_success "Tool configuration complete"
	echo ""
	_info "Note: Restart your shell or run 'source $(shell_rc_file)' to apply changes"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "This script is meant to be sourced, not run directly."
	echo "Use install.sh as the entry point."
	exit 1
fi
