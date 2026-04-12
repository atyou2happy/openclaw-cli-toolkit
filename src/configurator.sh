#!/usr/bin/env bash
set -euo pipefail

CONFIGURATOR_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$(dirname "$SCRIPT_DIR")/tools"
CONFIG_DIR="$HOME/.config/openclaw-toolkit"

DRY_RUN=false

_info()    { echo -e "\033[34m[CONFIG]\033[0m $*"; }
_success() { echo -e "\033[32m[OK]\033[0m $*"; }
_warn()    { echo -e "\033[33m[WARN]\033[0m $*"; }

ensure_dir() {
    local dir="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        _info "[DRY-RUN] mkdir -p $dir"
        return
    fi
    mkdir -p "$dir"
}

write_config_file() {
    local filepath="$1"
    local content="$2"

    if [[ "$DRY_RUN" == "true" ]]; then
        _info "[DRY-RUN] write $filepath"
        return
    fi

    local dir
    dir="$(dirname "$filepath")"
    mkdir -p "$dir"

    if [[ -f "$filepath" ]]; then
        local backup="${filepath}.bak.$(date +%s)"
        cp "$filepath" "$backup"
        _warn "Backed up existing $filepath to $backup"
    fi

    echo "$content" > "$filepath"
    _success "Written: $filepath"
}

setup_bat_config() {
    if ! command -v bat &>/dev/null; then return; fi
    write_config_file "$HOME/.config/bat/config" "--theme=\"TwoDark\"
--style=\"full\"
--italic-text=always
--map-syntax=\"*.conf:INI\"
--map-syntax=\".gitignore:Git Ignore\""
}

setup_ripgrep_config() {
    if ! command -v rg &>/dev/null; then return; fi
    write_config_file "$HOME/.ripgreprc" "--smart-case
--max-columns=150
--max-columns-preview"

    if ! grep -q "RIPGREP_CONFIG_PATH" "$HOME/.bashrc" 2>/dev/null; then
        if [[ "$DRY_RUN" != "true" ]]; then
            echo '' >> "$HOME/.bashrc"
            echo 'export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"' >> "$HOME/.bashrc"
            _success "Added RIPGREP_CONFIG_PATH to .bashrc"
        fi
    fi
}

setup_fzf_config() {
    if ! command -v fzf &>/dev/null; then return; fi
    ensure_dir "$HOME/.bashrc.d"

    write_config_file "$HOME/.bashrc.d/fzf.sh" 'export FZF_DEFAULT_OPTS='"'"'--height 40% --layout=reverse --border'"'"'
export FZF_DEFAULT_COMMAND='"'"'fd --type f --hidden --follow --exclude .git'"'"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='"'"'fd --type d --hidden --follow --exclude .git'"'"''

    if ! grep -q "fzf.sh" "$HOME/.bashrc" 2>/dev/null; then
        if [[ "$DRY_RUN" != "true" ]]; then
            echo '' >> "$HOME/.bashrc"
            echo '[ -f "$HOME/.bashrc.d/fzf.sh" ] && source "$HOME/.bashrc.d/fzf.sh"' >> "$HOME/.bashrc"
            _success "Added fzf config to .bashrc"
        fi
    fi
}

setup_zoxide_config() {
    if ! command -v zoxide &>/dev/null; then return; fi
    ensure_dir "$HOME/.bashrc.d"

    write_config_file "$HOME/.bashrc.d/zoxide.sh" 'eval "$(zoxide init bash --cmd z)"'

    if ! grep -q "zoxide.sh" "$HOME/.bashrc" 2>/dev/null; then
        if [[ "$DRY_RUN" != "true" ]]; then
            echo '' >> "$HOME/.bashrc"
            echo '[ -f "$HOME/.bashrc.d/zoxide.sh" ] && source "$HOME/.bashrc.d/zoxide.sh"' >> "$HOME/.bashrc"
            _success "Added zoxide init to .bashrc"
        fi
    fi
}

setup_starship_config() {
    if ! command -v starship &>/dev/null; then return; fi
    ensure_dir "$HOME/.config"

    write_config_file "$HOME/.config/starship.toml" '[character]
success_symbol = "[>](bold green)"
error_symbol = "[x](bold red)"

[git_branch]
format = "[\$symbol\$branch](\$style) "

[directory]
truncation_length = 3
truncate_to_repo = true

[cmd_duration]
min_time = 2_000
format = "took [\$duration](\$style) "'

    if ! grep -q "starship init" "$HOME/.bashrc" 2>/dev/null; then
        if [[ "$DRY_RUN" != "true" ]]; then
            echo '' >> "$HOME/.bashrc"
            echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
            _success "Added starship init to .bashrc"
        fi
    fi
}

setup_delta_config() {
    if ! command -v delta &>/dev/null; then return; fi

    if ! git config --global core.pager &>/dev/null; then
        if [[ "$DRY_RUN" != "true" ]]; then
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
    ensure_dir "$HOME/.config/lazygit"

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
    ensure_dir "$HOME/.aria2"

    write_config_file "$HOME/.aria2/aria2.conf" 'max-connection-per-server=16
min-split-size=1M
split=16
continue=true
max-concurrent-downloads=5
dir=${HOME}/Downloads'
}

setup_aliases() {
    ensure_dir "$HOME/.bashrc.d"

    local aliases_file="$HOME/.bashrc.d/openclaw-aliases.sh"
    local content="#!/bin/bash\n"

    if command -v bat &>/dev/null; then
        content+="alias cat='bat --style=plain'\n"
        content+="alias catn='bat --style=full'\n"
    fi

    if command -v eza &>/dev/null; then
        content+="alias ls='eza'\n"
        content+="alias ll='eza -la'\n"
        content+="alias lt='eza -T -L 2'\n"
        content+="alias la='eza -la'\n"
    fi

    if command -v dust &>/dev/null; then
        content+="alias du='dust'\n"
    fi

    if command -v duf &>/dev/null; then
        content+="alias df='duf'\n"
    fi

    if command -v procs &>/dev/null; then
        content+="alias ps='procs'\n"
    fi

    if command -v http &>/dev/null; then
        content+="alias https='http --default-scheme=https'\n"
    fi

    write_config_file "$aliases_file" "$(echo -e "$content")"

    if ! grep -q "openclaw-aliases.sh" "$HOME/.bashrc" 2>/dev/null; then
        if [[ "$DRY_RUN" != "true" ]]; then
            echo '' >> "$HOME/.bashrc"
            echo '[ -f "$HOME/.bashrc.d/openclaw-aliases.sh" ] && source "$HOME/.bashrc.d/openclaw-aliases.sh"' >> "$HOME/.bashrc"
            _success "Added openclaw aliases to .bashrc"
        fi
    fi
}

configure_all() {
    _info "Configuring tools..."

    ensure_dir "$CONFIG_DIR"
    ensure_dir "$HOME/.bashrc.d"

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
    _info "Note: Restart your shell or run 'source ~/.bashrc' to apply changes"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script is meant to be sourced, not run directly."
    echo "Use install.sh as the entry point."
    exit 1
fi
