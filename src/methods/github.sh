#!/usr/bin/env bash
# Install method: GitHub Release binary download
set -euo pipefail

# Package format: "owner/repo[#archive_binary[=install_name]]"
install_via_github_release() {
	local package="$1"
	if [[ "${DRY_RUN:-false}" == "true" ]]; then
		_info "[DRY-RUN] github_release install $package"
		return 0
	fi
	if ! command -v curl &>/dev/null; then
		_verbose "curl not available for github_release"
		return 1
	fi

	local repo="${package%%#*}"
	local rest="${package#*#}"
	local archive_binary=""
	local install_as=""
	if [[ "$rest" != "$package" ]]; then
		archive_binary="${rest%%=*}"
		install_as="${rest#*=}"
		[[ "$install_as" == "$rest" ]] && install_as="$archive_binary"
	fi
	[[ -z "$archive_binary" ]] && archive_binary=""
	[[ -z "$install_as" ]] && install_as="$(basename "$repo")"

	local owner="${repo%%/*}"
	local proj="${repo##*/}"

	_info "Installing $repo via GitHub release..."

	local os_name arch_names
	os_name="$(uname -s | tr '[:upper:]' '[:lower:]')"
	case "$(uname -m)" in
	x86_64 | amd64) arch_names="amd64 x86_64" ;;
	aarch64 | arm64) arch_names="arm64 aarch64" ;;
	armv7l | arm) arch_names="arm armv7" ;;
	*) arch_names="$(uname -m)" ;;
	esac

	local api_url="https://api.github.com/repos/${owner}/${proj}/releases/latest"
	local release_json
	release_json="$(curl -sL --retry 3 --retry-delay 2 --retry-all-errors "$api_url" 2>>"$INSTALL_LOG")" || {
		_warn "Failed to fetch GitHub releases for $repo"
		log_install "FAIL: github_release $repo (API fetch failed)"
		return 1
	}

	local tag
	tag="$(echo "$release_json" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tag_name',''))" 2>/dev/null)" || true
	if [[ -z "$tag" ]]; then
		_warn "Could not determine latest release for $repo (API may be rate-limited or unreachable)"
		log_install "FAIL: github_release $repo (no tag found)"
		return 1
	fi

	local download_url=""
	local asset_name=""
	while IFS=$'\t' read -r name url; do
		local lower_name
		lower_name="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
		local arch_matched=false
		for arch in $arch_names; do
			[[ "$lower_name" == *"$arch"* ]] && arch_matched=true && break
		done
		if [[ "$lower_name" == *"$os_name"* ]] && $arch_matched; then
			if [[ -z "$download_url" ]] || [[ "$lower_name" == *"static"* ]]; then
				download_url="$url"
				asset_name="$name"
			fi
		fi
	done < <(echo "$release_json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for a in data.get('assets', []):
    print(f\"{a['name']}\t{a['browser_download_url']}\")
" 2>/dev/null)

	if [[ -z "$download_url" ]]; then
		_warn "No matching release asset found for $repo ($os_name/$arch_name)"
		log_install "FAIL: github_release $repo (no matching asset)"
		return 1
	fi

	_info "Downloading $asset_name ..."
	local tmp_dir
	tmp_dir="$(mktemp -d)"
	local tmp_file="${tmp_dir}/${asset_name}"

	if ! curl -sL --retry 3 --retry-delay 2 --retry-all-errors -o "$tmp_file" "$download_url" 2>>"$INSTALL_LOG"; then
		_warn "Failed to download $asset_name"
		rm -rf "$tmp_dir"
		log_install "FAIL: github_release $repo (download failed)"
		return 1
	fi

	case "$asset_name" in
	*.tar.bz2)
		tar xjf "$tmp_file" -C "$tmp_dir" 2>>"$INSTALL_LOG"
		;;
	*.tar.gz | *.tgz)
		tar xzf "$tmp_file" -C "$tmp_dir" 2>>"$INSTALL_LOG"
		;;
	*.zip)
		unzip -o -q "$tmp_file" -d "$tmp_dir" 2>>"$INSTALL_LOG"
		;;
	*.tar.xz)
		tar xJf "$tmp_file" -C "$tmp_dir" 2>>"$INSTALL_LOG"
		;;
	*)
		chmod +x "$tmp_file"
		;;
	esac

	local install_target=""
	if [[ -n "$archive_binary" ]]; then
		install_target="$(find "$tmp_dir" -maxdepth 2 -name "$archive_binary" -type f -executable 2>/dev/null | head -1)" || true
	fi
	if [[ -z "$install_target" ]]; then
		install_target="$(find "$tmp_dir" -maxdepth 2 -name "$proj" -type f -executable 2>/dev/null | head -1)" || true
	fi
	if [[ -z "$install_target" ]]; then
		install_target="$(find "$tmp_dir" -maxdepth 2 -name "${proj}*" -type f -executable 2>/dev/null | head -1)" || true
	fi

	if [[ -z "$install_target" ]]; then
		_warn "Could not find binary in $asset_name"
		rm -rf "$tmp_dir"
		log_install "FAIL: github_release $repo (binary not found in archive)"
		return 1
	fi

	local dest_dir
	if command -v brew &>/dev/null; then
		dest_dir="$(brew --prefix)/bin"
	elif [[ -d /usr/local/bin ]] && [[ -w /usr/local/bin ]]; then
		dest_dir="/usr/local/bin"
	else
		dest_dir="$HOME/.local/bin"
		mkdir -p "$dest_dir"
	fi

	cp "$install_target" "${dest_dir}/${install_as}" 2>>"$INSTALL_LOG"
	chmod +x "${dest_dir}/${install_as}"
	rm -rf "$tmp_dir"

	_success "$repo installed via GitHub release ($tag) -> ${dest_dir}/${install_as}"
	log_install "SUCCESS: github_release $repo ($tag)"
	return 0
}
