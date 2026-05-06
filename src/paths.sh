#!/usr/bin/env bash
# paths.sh — Centralized path management
# MUST be sourced first (before any other src/ module)
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$PROJECT_DIR/VERSION" | tr -d '[:space:]')"
SRC_DIR="$PROJECT_DIR/src"
TOOLS_DIR="$PROJECT_DIR/tools"
CONFIG_FILE="$PROJECT_DIR/config.yaml"
INSTALL_LOG="/tmp/openclaw-toolkit-install.log"
METHODS_DIR="$SRC_DIR/methods"
