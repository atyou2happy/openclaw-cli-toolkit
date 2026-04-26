# Tasks: OpenClaw CLI Toolkit v4.0 — Expand Tool Ecosystem

## Overview

Create 5 new tool category YAML files, update 6 existing YAML files, update config, and refresh documentation.

**Target**: 140+ tools across 26 categories

---

## Phase 1: Create New Category YAML Files

### T01: Create `tools/kubernetes.yaml`
- [ ] kubectl — Kubernetes control CLI
- [ ] helm — K8s package manager
- [ ] k9s — Terminal UI for Kubernetes
- [ ] popeye — K8s cluster sanitizer
- [ ] stern — Multi-pod log tailing
- [ ] kubectx — K8s context switcher

### T02: Create `tools/golang.yaml`
- [ ] golangci-lint — Go linter aggregator
- [ ] staticcheck — Go static analysis
- [ ] goimports — Format imports
- [ ] godef — Go to definition
- [ ] gore — Go REPL
- [ ] ginkgo — Go BDD testing

### T03: Create `tools/observability.yaml`
- [ ] stern — Tail K8s logs (also in kubernetes)
- [ ] logcli — Loki CLI
- [ ] promtool — Prometheus CLI
- [ ] ctop — Container metrics
- [ ] glances — System monitor

### T04: Create `tools/git-helpers.yaml`
- [ ] git-lfs — Git Large File Storage
- [ ] ghq — Git remote management
- [ ] git-filter-repo — Rewrite git history
- [ ] myrepos — Multi-repo management

### T05: Create `tools/testing.yaml`
- [ ] bats — Bash testing framework
- [ ] cricket — Python coverage UI (disabled by default)
- [ ] coverage — Python coverage CLI
- [ ] junit2html — JUnit to HTML converter

---

## Phase 2: Update Existing Category YAML Files

### T06: Update `tools/dev.yaml`
- [ ] Add `buf` — Protocol buffers linter

### T07: Update `tools/git.yaml`
- [ ] Add `ghq` — Clone management (also in git-helpers)

### T08: Update `tools/terminal.yaml`
- [ ] Add `autojump` — Directory jumping
- [ ] Add `zellij` — Tmux alternative

### T09: Update `tools/security.yaml`
- [ ] Add `bitwarden-cli` — Bitwarden CLI
- [ ] Add `vault` — HashiCorp Vault CLI

### T10: Update `tools/network.yaml`
- [ ] Add `mtr` — Traceroute + ping combined
- [ ] Add `nmap` — Network scanner

---

## Phase 3: Update Config and Documentation

### T11: Update `config.yaml`
- [ ] Add `kubernetes` category (disabled by default)
- [ ] Add `golang` category (enabled by default)
- [ ] Add `observability` category (enabled by default)
- [ ] Add `git-helpers` category (enabled by default)
- [ ] Add `testing` category (enabled by default)
- [ ] Add all new tools with appropriate enabled/disabled flags
- [ ] Update `actionlint` to enabled: true
- [ ] Update `ffmpeg` to enabled: true

### T12: Update `openclaw-tools.yaml`
- [ ] Run `python3 src/generator.py`
- [ ] Verify tool count is 140+
- [ ] Verify all new tools appear correctly

### T13: Update `README.md`
- [ ] Update tool count badge: `107+` → `140+`
- [ ] Update category count: `21` → `26`
- [ ] Add new categories to Tool Categories table
- [ ] Update project structure if needed

### T14: Update `README_CN.md`
- [ ] Same updates as README.md in Chinese

### T15: Update `VERSION`
- [ ] Change `3.1.0` → `4.0.0`

### T16: Update `CHANGELOG.md`
- [ ] Add v4.0.0 section with all additions
- [ ] Include 5 new categories listed
- [ ] Include tools added to existing categories
- [ ] Update total tool/category counts

---

## Phase 4: Validation

### T17: YAML Validation
- [ ] All new YAML files parse without error
- [ ] Run: `python3 -c "import yaml; [yaml.safe_load(open(f)) for f in tools/*.yaml]"`

### T18: Generator Test
- [ ] `python3 src/generator.py` runs without error
- [ ] Output shows 140+ tools

### T19: Shellcheck
- [ ] `shellcheck -s bash install.sh uninstall.sh src/*.sh` passes

### T20: Dry Run Install
- [ ] `./install.sh --dry-run` works
- [ ] New categories appear in output

---

## Implementation Order

```
T01 → T02 → T03 → T04 → T05    (New categories - parallel)
        ↓
T06 → T07 → T08 → T09 → T10    (Existing updates - parallel)
        ↓
T11: Update config.yaml           (After YAML files done)
        ↓
T12: Generate openclaw-tools.yaml (After config)
        ↓
T13 → T14 → T15 → T16          (Documentation)
        ↓
T17 → T18 → T19 → T20          (Validation)
```

---

## Tool Details Reference

### kubernetes.yaml
```yaml
category: kubernetes
description: "Kubernetes container orchestration tools"
```

### golang.yaml
```yaml
category: golang
description: "Go programming language tools"
```

### observability.yaml
```yaml
category: observability
description: "System monitoring and observability tools"
```

### git-helpers.yaml
```yaml
category: git-helpers
description: "Git workflow enhancement tools"
```

### testing.yaml
```yaml
category: testing
description: "Testing frameworks and coverage tools"
```

---

## Notes

- All new YAML files must follow exact schema of existing files
- Use `openclaw_usage.examples` format for all tool entries
- Install methods must use correct method names: apt, brew, cargo, pip, go
- Most new tools disabled by default in config.yaml (except core dev tools)
- kubernetes category entirely disabled by default (requires cluster access)
