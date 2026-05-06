#!/usr/bin/env bash
# Install method: Homebrew
set -euo pipefail

install_via_brew() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] brew install $package"
		return 0
	fi
	_info "Installing $package via brew..."
	if brew install "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via brew"
		log_install "SUCCESS: brew install $package"
		return 0
	fi
	_warn "Failed to install $package via brew"
	log_install "FAIL: brew install $package"
	return 1
}
