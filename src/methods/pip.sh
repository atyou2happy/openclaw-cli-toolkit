#!/usr/bin/env bash
# Install method: pip (Python package manager)
set -euo pipefail

install_via_pip() {
	local package="$1"
	local pip_cmd
	if command -v pip3 &>/dev/null; then
		pip_cmd="pip3"
	elif command -v pip &>/dev/null; then
		pip_cmd="pip"
	else
		_warn "pip not found"
		return 1
	fi

	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] $pip_cmd install --user $package"
		return 0
	fi
	_info "Installing $package via pip..."
	if $pip_cmd install --user "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via pip"
		log_install "SUCCESS: pip install $package"
		return 0
	fi
	_warn "Failed to install $package via pip"
	log_install "FAIL: pip install $package"
	return 1
}
