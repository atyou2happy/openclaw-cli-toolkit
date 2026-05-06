#!/usr/bin/env bash
# Install method: Cargo (Rust package manager)
set -euo pipefail

install_via_cargo() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] cargo install $package"
		return 0
	fi
	_info "Installing $package via cargo..."
	if cargo install "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via cargo"
		log_install "SUCCESS: cargo install $package"
		return 0
	fi
	_warn "Failed to install $package via cargo"
	log_install "FAIL: cargo install $package"
	return 1
}
