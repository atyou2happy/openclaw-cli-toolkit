# OpenClaw CLI Toolkit

> A curated collection of 50+ open-source CLI tools to supercharge your OpenClaw agent — one script to install them all.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CI](https://github.com/your-org/openclaw-cli-toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/your-org/openclaw-cli-toolkit/actions)

## What is this?

OpenClaw CLI Toolkit researches, evaluates, and installs the best free CLI tools for Linux/WSL2/Ubuntu that significantly improve OpenClaw's task execution efficiency and accuracy.

## Features

- **13 tool categories** covering search, data processing, system monitoring, networking, Git, terminal, development, security, compression, documentation, download, and AI
- **One-click installation** with automatic system detection (WSL2/Linux/macOS)
- **Config-driven** — `config.yaml` controls which tools to install
- **Shell-aware** — auto-detects bash/zsh/fish and configures accordingly
- **OpenClaw integration** — auto-generates `openclaw-tools.yaml` for agent consumption
- **Resume support** — safely re-run to continue interrupted installs
- **Idempotent** — safe to run multiple times

## Quick Start

```bash
# Install everything
./install.sh

# Dry run (preview only)
./install.sh --dry-run

# Install specific category
./install.sh --category search

# Force reinstall
./install.sh --force
```

## Tool Categories

| Category | Tools | Key Replacement |
|----------|-------|----------------|
| 🔍 Search | ripgrep, fd, ag | grep → rg, find → fd |
| 👁️ Viewer | bat, eza, tree | cat → bat, ls → eza |
| 📊 Data | jq, yq, miller, dasel | JSON/YAML/CSV processing |
| 🖥️ System | btop, dust, duf, procs, hyperfine | htop, du, df, ps |
| 🌐 Network | httpie, curlie, doggo | curl → httpie, dig → doggo |
| 🔀 Git | delta, lazygit, tig, gh | Git diff/log UI |
| 🎛️ Terminal | fzf, zoxide, tmux, starship | cd → z, fuzzy search |
| 🛠️ Dev | shellcheck, shfmt, hadolint | Script quality |
| 🔒 Security | age, sops | File/config encryption |
| 📦 Archive | zstd, ouch, 7z | gzip → zstd |
| 📄 Docs | pandoc, glow, poppler-utils | Document conversion/viewing |
| ⬇️ Download | aria2, rclone | wget → aria2 |
| 🤖 AI | llm, sgpt, aider | CLI LLM tools |

## Installation Priority

**Tier 1 (Must-have):** ripgrep, fd, bat, jq, fzf, tmux, shellcheck, pandoc, zstd, aria2

**Tier 2 (Highly recommended):** eza, yq, dasel, dust, hyperfine, httpie, delta, zoxide, glow, llm, shfmt, duf

**Tier 3 (Install as needed):** btop, procs, curlie, doggo, lazygit, tig, miller, starship, age, sops, ouch, rclone, sgpt, hadolint

## OpenClaw Integration

After installation, `openclaw-tools.yaml` is generated with structured tool descriptions that OpenClaw agents can directly read.

Example entry:
```yaml
- name: rg
  description: "Fast regex search tool (replaces grep)"
  usage: "rg <pattern> [path] [options]"
  best_for: "Code search, log analysis, content search across files"
  replaces: "grep"
```

## Configuration

Edit `config.yaml` to customize which tools and categories to install:

```yaml
categories:
  search:
    enabled: true
    tools:
      ripgrep:
        enabled: true
      the_silver_searcher:
        enabled: false  # skip this tool
```

## Supported Package Managers

`apt` > `brew` > `cargo` > `pip` > `go install` (tried in order)

## Requirements

- Linux, WSL2, or macOS
- At least one package manager: apt, brew, cargo, pip, or go
- bash 4.0+
- python3 (for generator and YAML parsing)

## Uninstall

```bash
./uninstall.sh              # Remove all tools
./uninstall.sh --keep-config  # Keep config files
```

## License

MIT License — see [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Add/edit tool definitions in `tools/`
3. Test with `./install.sh --dry-run`
4. Submit a pull request

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

---

[中文文档](README_CN.md)
