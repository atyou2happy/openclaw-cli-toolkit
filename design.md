# Design: OpenClaw CLI Toolkit v2.0

## 核心架构变更

### 1. 模块拆分

```
common.sh        → 共享函数（_info/_warn/_success/_error/_verbose, is_installed, ensure_dir）
state.sh         → 状态管理（纯bash，基于文本文件，无python3依赖）
detector.sh      → 系统检测（OS/架构/包管理器/shell类型）
installer.sh     → 安装逻辑（apt/brew/cargo/pip/go install）
configurator.sh  → 工具配置（bash + zsh 自动检测）
generator.py     → 生成 openclaw-tools.yaml
```

### 2. 状态管理（纯bash）

替代当前的 python3 JSON inline脚本：

```bash
# state.sh
STATE_DIR="$HOME/.local/share/openclaw-toolkit"
STATE_FILE="$STATE_DIR/state"

# 格式: status:toolname (每行一个)
state_init() {
    mkdir -p "$STATE_DIR"
    touch "$STATE_FILE"
}

state_record() {
    local status="$1" tool="$2"
    echo "$status:$tool" >> "$STATE_FILE"
}

state_is_done() {
    local tool="$1"
    grep -q "^(installed|skipped):$tool$" "$STATE_FILE" 2>/dev/null
}

state_get_count() {
    local status="$1"
    grep -c "^$status:" "$STATE_FILE" 2>/dev/null || echo 0
}
```

### 3. 批量工具解析

替代每工具4次python3调用：

```bash
# 一次解析所有YAML，输出TSV格式
parse_all_tools() {
    python3 -c "
import yaml, sys, json
from pathlib import Path

tools_dir = Path('$TOOLS_DIR')
for f in sorted(tools_dir.glob('*.yaml')):
    try:
        data = yaml.safe_load(open(f))
        for t in data.get('tools', []):
            name = t.get('name', '')
            binary = t.get('binary', '')
            pkg = t.get('package', '')
            methods = ' '.join(m.get('method','') for m in t.get('install_methods', []))
            print(f'{name}\t{binary}\t{pkg}\t{methods}\t{f.stem}')
    except Exception:
        pass
"
}

# 读取到bash数组
while IFS=$'\t' read -r name binary pkg methods category; do
    TOOLS_LIST+=("$name|$binary|$pkg|$methods|$category")
done < <(parse_all_tools)
```

### 4. config.yaml 真正读取

```bash
filter_by_config() {
    python3 -c "
import yaml, sys
config = yaml.safe_load(open('$CONFIG_FILE'))
tools_raw = sys.stdin.read()  # TSV from parse_all_tools
for line in tools_raw.strip().split('\n'):
    parts = line.split('\t')
    name, binary, pkg, methods, category = parts
    cat_cfg = config.get('categories', {}).get(category, {})
    if not cat_cfg.get('enabled', True):
        continue
    tool_cfg = cat_cfg.get('tools', {}).get(name, {})
    if tool_cfg.get('enabled', True):
        print(line)
"
}
```

### 5. Shell类型检测与配置

```bash
detect_shell_type() {
    case "$DETECTED_SHELL" in
        */zsh)  SHELL_TYPE="zsh"; SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_TYPE="bash"; SHELL_RC="$HOME/.bashrc" ;;
        */fish) SHELL_TYPE="fish"; SHELL_RC="$HOME/.config/fish/config.fish" ;;
        *)      SHELL_TYPE="bash"; SHELL_RC="$HOME/.bashrc" ;;
    esac
}
```

### 6. go install 支持

```bash
install_via_go() {
    local package="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        _info "[DRY-RUN] go install $package"
        return 0
    fi
    _info "Installing $package via go..."
    if go install "$package" 2>>"$INSTALL_LOG"; then
        _success "$package installed via go"
        return 0
    fi
    return 1
}
```

### 7. install.sh 重构

install.sh 变为精简编排器：

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

source "$SRC_DIR/common.sh"
source "$SRC_DIR/state.sh"
source "$SRC_DIR/detector.sh"
source "$SRC_DIR/installer.sh"
source "$SRC_DIR/configurator.sh"

parse_args "$@"
check_prerequisites
detect_all
state_init

collect_and_filter_tools   # parse YAML + filter by config.yaml
install_all_tools          # sequential with progress bar
configure_all_tools        # bash/zsh auto-detect
generate_tools_yaml        # python3 generator.py

final_report
```

## openclaw-tools.yaml 输出格式（不变）

保持现有格式，仅更新dog→doggo。
