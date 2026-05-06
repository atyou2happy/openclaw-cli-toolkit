#!/usr/bin/env bash
# Install method: apt (Advanced Package Tool)
set -euo pipefail

install_via_apt() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] apt install -y $package"
		return 0
	fi
	_info "Installing $package via apt..."
	if apt-get update -qq 2>/dev/null && apt-get install -y --no-install-recommends -qq "$package" 2>>"$INSTALL_LOG"; then
		_success "$package installed via apt"
		log_install "SUCCESS: apt install $package"
		return 0
	fi
	_warn "Failed to install $package via apt"
	log_install "FAIL: apt install $package"
	return 1
}
