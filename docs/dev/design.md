# Design: OpenClaw CLI Toolkit v4.0 — Expand Tool Ecosystem

## 1. Design Principles

### 1.1 Minimal Architecture Impact
- No changes to install.sh, installer.sh, or core modules
- Only adding YAML definitions + config updates
- Generator.py already handles any number of tools

### 1.2 YAML Schema Consistency
All new tool entries follow existing schema:

```yaml
category: <category-name>
description: "Category description"
tools:
  - name: <tool-name>
    package: <package-name>
    binary: <binary-name>
    description: "Tool description"
    homepage: "https://github.com/..."
    license: <SPDX>
    install_methods:
      - method: <apt|brew|cargo|pip|go>
        package: <package-name>
    openclaw_usage:
      replace: "what it replaces"
      examples:
        - "example usage"
      benefits: "Why AI agents need this"
    config: []
```

### 1.3 Installation Method Priority
Same as existing: `apt > brew > cargo > pip > go install`

### 1.4 Naming Conventions
- Category names: lowercase, hyphenated (e.g., `git-helpers`, `observability`)
- Tool names: lowercase, hyphenated or standard (e.g., `golangci-lint`, `git-lfs`)
- Binary names: match system conventions (e.g., `kubectl`, `k9s`)

## 2. New Category Definitions

### 2.1 kubernetes

```yaml
category: kubernetes
description: "Kubernetes container orchestration tools — kubectl, helm, and cluster utilities"
```

**Tools**: kubectl, helm, k9s, popeye, stern, kubectx

**Design Notes**:
- kubectl is the most important — add to apt and brew
- k9s is TUI-only, add brew and download method
- stern for log tailing — very useful for AI debugging

### 2.2 golang

```yaml
category: golang
description: "Go programming language tools — linting, formatting, and development utilities"
```

**Tools**: golangci-lint, staticcheck, goimports, godef, gore, ginkgo

**Design Notes**:
- golangci-lint is the aggregator linter — must have
- goimports handles both formatting and import organization
- ginkgo is BDD testing framework for Go

### 2.3 observability

```yaml
category: observability
description: "System monitoring, logging, and observability tools"
```

**Tools**: stern, logcli, promtool, ctop, glances

**Design Notes**:
- Mix of container-level (stern, ctop) and system-level (glances)
- promtool for Prometheus metrics validation
- All are helpful for AI agents debugging production

### 2.4 git-helpers

```yaml
category: git-helpers
description: "Git workflow enhancement tools — large files, repo management, history rewriting"
```

**Tools**: git-lfs, ghq, git-filter-repo, myrepos

**Design Notes**:
- git-lfs is a git extension, installs git-lfs binary
- ghq provides GitHub-style clone management
- git-filter-repo is powerful history rewriting tool

### 2.5 testing

```yaml
category: testing
description: "Testing frameworks and coverage tools for multiple languages"
```

**Tools**: bats, cricket, coverage, junit2html

**Design Notes**:
- bats for shell/bash testing
- cricket/coverage for Python coverage
- junit2html for Java test output

## 3. Config.yaml Integration

### 3.1 New Category Structure

```yaml
categories:
  kubernetes:
    enabled: false  # Disabled by default - requires K8s setup
    tools:
      kubectl:
        enabled: true
      helm:
        enabled: true
      k9s:
        enabled: false  # TUI, not script-friendly
      popeye:
        enabled: false
      stern:
        enabled: true
      kubectx:
        enabled: false

  golang:
    enabled: true
    tools:
      golangci-lint:
        enabled: true
      staticcheck:
        enabled: true
      goimports:
        enabled: true
      godef:
        enabled: true
      gore:
        enabled: false  # Interactive REPL
      ginkgo:
        enabled: false  # Testing framework

  observability:
    enabled: true
    tools:
      stern:
        enabled: true
      logcli:
        enabled: false  # Requires Loki setup
      promtool:
        enabled: false  # Requires Prometheus
      ctop:
        enabled: true
      glances:
        enabled: true

  git-helpers:
    enabled: true
    tools:
      git-lfs:
        enabled: true
      ghq:
        enabled: false  # Alternative to direct clone
      git-filter-repo:
        enabled: false  # Dangerous tool
      myrepos:
        enabled: false  # Complex setup

  testing:
    enabled: true
    tools:
      bats:
        enabled: true
      cricket:
        enabled: false  # GUI tool
      coverage:
        enabled: true
      junit2html:
        enabled: false  # Java-specific
```

## 4. Documentation Updates

### 4.1 README.md Changes

- Update tool count badge: `107+` → `140+`
- Update category count: `21` → `26`
- Add new categories to table
- Update project structure diagram

### 4.2 README_CN.md Changes

- Same updates as README.md in Chinese

### 4.3 CHANGELOG.md

```markdown
## [4.0.0] - 2026-04-26

### Added — 5 New Categories

- **Kubernetes** (`tools/kubernetes.yaml`):
  - `kubectl` — Kubernetes control CLI (apt, brew)
  - `helm` — K8s package manager (apt, brew)
  - `k9s` — Terminal UI for Kubernetes (brew)
  - `popeye` — K8s cluster sanitizer (brew, go)
  - `stern` — Multi-pod log tailing (brew, go)
  - `kubectx` — K8s context switcher (brew)

- **Go Development** (`tools/golang.yaml`):
  - `golangci-lint` — Go linter aggregator (brew, go, cargo)
  - `staticcheck` — Go static analysis (go)
  - `goimports` — Format imports (go)
  - `godef` — Go to definition (go)
  - `gore` — Go REPL (go)
  - `ginkgo` — Go BDD testing (go)

- **Observability** (`tools/observability.yaml`):
  - `stern` — Tail K8s logs (brew, go)
  - `logcli` — Loki CLI (brew, go)
  - `promtool` — Prometheus CLI (brew, go)
  - `ctop` — Container metrics (brew, apt)
  - `glances` — System monitor (apt, brew, pip)

- **Git Helpers** (`tools/git-helpers.yaml`):
  - `git-lfs` — Git Large File Storage (apt, brew)
  - `ghq` — Git remote management (brew, go)
  - `git-filter-repo` — Rewrite git history (pip, brew)
  - `myrepos` — Multi-repo management (brew, pip)

- **Testing** (`tools/testing.yaml`):
  - `bats` — Bash testing framework (apt, brew, pip)
  - `coverage` — Python coverage CLI (pip)
  - `junit2html` — JUnit to HTML converter (pip, go)

### Added — Tools in Existing Categories

- **dev**: `buf` — Protocol buffers linter (brew, go)
- **git**: `ghq` — Clone management (brew, go)
- **terminal**: `autojump`, `zellij` — Directory navigation
- **security**: `bitwarden-cli`, `vault` — Secrets management
- **network**: `mtr`, `nmap` — Network diagnostics

### Changed

- Now **26 categories, 140+ tools** total (was 21 categories, 107 tools)
```

## 5. Version Update

- VERSION: `3.1.0` → `4.0.0`
- Reason: Breaking change by adding 5 new categories and 30+ tools

## 6. Testing Requirements

### 6.1 Validation Steps

```bash
# 1. YAML syntax check
python3 -c "import yaml; [yaml.safe_load(open(f)) for f in tools/*.yaml]"

# 2. Generator runs without error
python3 src/generator.py --dry-run 2>&1 | head -20

# 3. shellcheck on any modified shell scripts
shellcheck -s bash src/*.sh install.sh uninstall.sh

# 4. Verify tool count
grep -c "^  - name:" tools/*.yaml | awk -F: '{sum+=$2} END {print sum}'
```

## 7. Rollback Plan

If issues arise:
1. Revert to v3.1.0 by reverting git commit
2. Remove new YAML files
3. Restore config.yaml from previous version
4. Regenerate openclaw-tools.yaml
