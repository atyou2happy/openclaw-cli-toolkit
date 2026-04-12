# OpenClaw CLI Toolkit

> 🚀 A curated collection of the best open-source CLI tools to supercharge your OpenClaw agent — one script to install them all.

## What is this?

OpenClaw CLI Toolkit researches, evaluates, and installs the best free CLI tools for Linux/WSL2/Ubuntu that significantly improve OpenClaw's task execution efficiency and accuracy.

## Features

- **13 tool categories** covering search, data processing, system monitoring, networking, Git, terminal, development, security, compression, documentation, download, and AI
- **One-click installation** with automatic system detection (WSL2/Linux/macOS)
- **OpenClaw integration** — auto-generates `openclaw-tools.yaml` for agent consumption
- **Modular** — install all tools or pick specific categories
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
| 🌐 Network | httpie, curlie, dog | curl → httpie, dig → dog |
| 🔀 Git | delta, lazygit, tig | Git diff/log UI |
| 🎛️ Terminal | fzf, zoxide, tmux, starship | cd → z, fuzzy search |
| 🛠️ Dev | shellcheck, shfmt, hadolint | Script quality |
| 🔒 Security | age, sops | File/config encryption |
| 📦 Archive | zstd, ouch | gzip → zstd |
| 📄 Docs | pandoc, glow | Document conversion/viewing |
| ⬇️ Download | aria2, rclone | wget → aria2 |
| 🤖 AI | llm, sgpt | CLI LLM tools |

## Installation Priority

**Tier 1 (Must-have):** ripgrep, fd, bat, jq, fzf, tmux, shellcheck, pandoc, zstd, aria2

**Tier 2 (Highly recommended):** eza, yq, dasel, dust, hyperfine, httpie, delta, zoxide, glow, llm, shfmt, duf

**Tier 3 (Install as needed):** btop, procs, curlie, dog, lazygit, tig, miller, starship, age, sops, ouch, rclone, sgpt, hadolint

## OpenClaw Integration

After installation, `openclaw-tools.yaml` is generated with structured tool descriptions that OpenClaw agents can directly read to choose the right tool for each task.

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

## Uninstall

```bash
./uninstall.sh              # Remove all tools
./uninstall.sh --keep-config  # Keep config files
```

## Requirements

- Linux, WSL2, or macOS
- At least one package manager: apt, brew, cargo, pip, or go
- bash 4.0+
- python3 (for generator)

## License

MIT License — see [LICENSE](LICENSE)

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Add/edit tool definitions in `tools/`
3. Test with `./install.sh --dry-run`
4. Submit a pull request
