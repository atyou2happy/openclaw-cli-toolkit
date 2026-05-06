# Design: OpenClaw CLI Toolkit v5.0 — Full Refactoring

## 1. Design Principles

### 1.1 External API 不变

install.sh 的命令行参数、行为、输出格式完全保持 v4.0 兼容。

```
# 以下用法完全不变
./install.sh
./install.sh --dry-run
./install.sh -c search -c data
./install.sh --force
```

### 1.2 Bash 模块化拆分策略

采用 **source-based 模块化**（非子进程），保持现有 source 模式：

```bash
# install.sh 中 (refactor后)
source "$SRC_DIR/paths.sh"       # ← NEW: 最先加载
source "$SRC_DIR/common.sh"
source "$SRC_DIR/state.sh"       # 不再重复计算路径
source "$SRC_DIR/detector.sh"
source "$SRC_DIR/installer.sh"   # 变为调度器，按需 source methods/
```

### 1.3 拆分兼容模式 ⭐v6

installer.sh 拆为调度器后，内部函数名保持不变（`install_via_apt`, `try_install_method` 等），所有 source installer.sh 的外部脚本无需改动。

### 1.4 Python 质量不增加依赖

- 不引入新 Python 依赖
- 仅用 ruff（dev dependency）做 lint
- pytest 作为 dev dependency

## 2. Module Design

### 2.1 paths.sh (NEW)

集中管理所有路径常量：

```bash
#!/usr/bin/env bash
# paths.sh — Centralized path management
# MUST be sourced first (before common.sh is even needed)

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$PROJECT_DIR/VERSION" | tr -d '[:space:]')"
SRC_DIR="$PROJECT_DIR/src"
TOOLS_DIR="$PROJECT_DIR/tools"
CONFIG_FILE="$PROJECT_DIR/config.yaml"
INSTALL_LOG="/tmp/openclaw-toolkit-install.log"
```

**影响文件**: install.sh, uninstall.sh, common.sh, detector.sh, state.sh, installer.sh, configurator.sh

### 2.2 installer.sh → 调度器

从 394 行 → ~50 行调度器：

```bash
#!/usr/bin/env bash
set -euo pipefail

# Source all install methods
METHODS_DIR="$SRC_DIR/methods"
for method_file in "$METHODS_DIR"/*.sh; do
    source "$method_file"
done

INSTALLED_TOOLS=()
FAILED_TOOLS=()
SKIPPED_TOOLS=()

log_install() { ... }

# 保留 try_install_method, install_single_tool, install_report
# 保留 parse_all_tools
```

### 2.3 methods/ 目录

每个文件一个安装方法：

| 文件 | 内容 | 预估行数 |
|------|------|---------|
| apt.sh | `install_via_apt()` | ~25 |
| brew.sh | `install_via_brew()` | ~25 |
| cargo.sh | `install_via_cargo()` | ~25 |
| pip.sh | `install_via_pip()` | ~30 |
| go.sh | `install_via_go()` | ~40 |
| github.sh | `install_via_github_release()` | ~130 |

### 2.4 Python Fixes

#### parse_tools.py

```python
# Before (P2):
except Exception:
    pass

# After:
except yaml.YAMLError as e:
    print(f"[WARN] Invalid YAML in {f}: {e}", file=sys.stderr)
except KeyError as e:
    print(f"[WARN] Missing key in {f}: {e}", file=sys.stderr)
```

```python
# Before (P3):
config = yaml.safe_load(open(config_file))
# ...
data = yaml.safe_load(open(f))

# After:
with open(config_file, "r", encoding="utf-8") as fh:
    config = yaml.safe_load(fh)
# ...
with open(f, "r", encoding="utf-8") as fh:
    data = yaml.safe_load(fh)
```

#### generator.py

- 增加类型标注（已有部分）
- `generate_openclaw_entry()` 增加 None 检查
- `load_tool_definitions()` 改用 `with` 语句（已是，确认）

### 2.5 Test Architecture

#### Python Tests (pytest)

```
tests/python/
  conftest.py           ← fixtures: sample YAML, temp dirs
  test_generator.py     ← 单元测试: get_version, load_tool_definitions,
                          generate_openclaw_entry, generate_output
  test_parse_tools.py   ← 单元测试: parse_tools 函数，config过滤
  test_yaml_schema.py   ← 验证 26个 tools/*.yaml 的 schema 合法性
```

覆盖率目标：
- generator.py >80%
- parse_tools.py >80%
- YAML schema 验证 100%（26个文件全部检查）

#### Shell Tests

```
tests/
  test_install.sh       ← 增强: 检查新 paths.sh, methods/ 目录
  test_tools.sh         ← 不变
  test_structure.sh     ← NEW: 验证目录结构、文件存在、语法
```

### 2.6 Makefile

```makefile
.PHONY: lint test test-python test-shell check clean generate

lint:
	shellcheck -s bash install.sh uninstall.sh src/*.sh src/methods/*.sh tests/*.sh
	ruff check src/

test: test-shell test-python

test-python:
	python3 -m pytest tests/python/ -v --tb=short

test-shell:
	bash tests/test_install.sh
	bash tests/test_structure.sh

check: lint test

generate:
	python3 src/generator.py

clean:
	rm -f openclaw-tools.yaml
	rm -rf __pycache__ .ruff_cache .pytest_cache
```

### 2.7 pyproject.toml (dev-only, 不用于打包)

```toml
[tool.ruff]
target-version = "py39"
line-length = 100

[tool.ruff.lint]
select = ["E", "F", "W", "I"]

[tool.pytest.ini_options]
testpaths = ["tests/python"]
```

### 2.8 CI Enhancement

在现有 ci.yml 增加：

```yaml
  python-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: pip install pyyaml pytest ruff
      - name: Lint Python
        run: ruff check src/
      - name: Run pytest
        run: python3 -m pytest tests/python/ -v
```

## 3. Migration Strategy

按 v7 文件拆分纪律：

1. **先补测试** — 确保当前行为有 baseline
2. **建 paths.sh** — 所有文件切换到集中路径
3. **拆 installer.sh** — 建 methods/ 目录，逐方法拆出
4. **修 Python** — 修复 parse_tools.py + generator.py
5. **加工具链** — Makefile + ruff + CI
6. **每步验证** — `bash tests/test_install.sh && python3 -m pytest tests/python/`

## 4. Version

v4.0.0 → v5.0.0 (major: 架构变更)
