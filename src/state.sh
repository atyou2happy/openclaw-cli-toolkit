#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/openclaw-toolkit"
STATE_FILE="$STATE_DIR/state"

state_init() {
	if [[ "${FORCE:-false}" != "true" ]] && [[ -f "$STATE_FILE" ]]; then
		_info "Found previous install state, resuming..."
		return 0
	fi
	mkdir -p "$STATE_DIR"
	: >"$STATE_FILE"
}

state_record() {
	local status="$1" tool="$2"
	local entry="${status}:${tool}"
	if grep -qFx "$entry" "$STATE_FILE" 2>/dev/null; then
		return 0
	fi
	echo "$entry" >>"$STATE_FILE"
}

state_is_done() {
	local tool="$1"
	grep -qE "^(installed|skipped):${tool}$" "$STATE_FILE" 2>/dev/null
}

state_get_count() {
	local status="$1"
	local count
	count="$(grep -c "^${status}:" "$STATE_FILE" 2>/dev/null)" || count=0
	echo "$count"
}

state_get_list() {
	local status="$1"
	grep "^${status}:" "$STATE_FILE" 2>/dev/null | cut -d: -f2 || true
}

state_cleanup() {
	rm -f "$STATE_FILE"
}

state_reset() {
	mkdir -p "$STATE_DIR"
	: >"$STATE_FILE"
}
