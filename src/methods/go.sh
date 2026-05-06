#!/usr/bin/env bash
# Install method: go install
set -euo pipefail

install_via_go() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] go install $package"
		return 0
	fi

	local proxies=("$(go env GOPROXY)" "https://goproxy.cn,direct" "https://goproxy.io,direct")
	for proxy in "${proxies[@]}"; do
		_info "Installing $package via go (proxy: ${proxy%%,*})..."
		if GOPROXY="$proxy" go install "$package" 2>>"$INSTALL_LOG"; then
			_success "$package installed via go"
			log_install "SUCCESS: go install $package (proxy: ${proxy%%,*})"
			return 0
		fi
	done
	_warn "Failed to install $package via go (tried all proxies)"
	log_install "FAIL: go install $package"
	return 1
}
