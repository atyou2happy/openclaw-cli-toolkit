# OpenClaw CLI 工具包

> 为 Linux/WSL2/Ubuntu 精选的 50+ CLI 工具，旨在提升 OpenClaw AI 代理的执行效率和开发者的工作流程。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Shell: Bash](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)

## 这是什么？

OpenClaw CLI 工具包是一个一键安装器，在你的 Linux/WSL2/Ubuntu 系统上配置最佳的开源 CLI 工具。每个工具都经过：

- **免费开源** - 无隐藏成本
- **精心筛选** - 与同类工具对比测试和基准评测
- **AI 友好** - 自动生成 `openclaw-tools.yaml` 供 AI 代理直接使用
- **易于管理** - 单条命令完成安装、配置和卸载

## 快速开始

```bash
# 克隆仓库
git clone https://github.com/your-org/openclaw-cli-toolkit.git
cd openclaw-cli-toolkit

# 添加执行权限
chmod +x install.sh

# 预览将安装的工具（干运行模式）
./install.sh --dry-run

# 安装所有推荐工具
./install.sh

# 只安装特定类别
./install.sh --category search --category data
```

## 工具清单（13 个类别）

### 搜索工具
| 工具 | 替代 | 说明 |
|------|------|------|
| **ripgrep** (rg) | grep | 快 5-10 倍的文本搜索 |
| **fd** | find | 智能文件查找 |
| the_silver_searcher (ag) | grep | 快速代码搜索 |
| ack | grep | 程序员专用 grep |

### 文件查看
| 工具 | 替代 | 说明 |
|------|------|------|
| **bat** | cat | 语法高亮的 cat |
| **eza** | ls | 带 Git 状态的现代 ls |
| lsd | ls | 带图标的 ls |
| tree | - | 目录树查看器 |

### 数据处理
| 工具 | 替代 | 说明 |
|------|------|------|
| **jq** | python json | JSON 处理器 |
| **yq** | 手动编辑 YAML | YAML/JSON/XML 处理器 |
| **miller** | awk for CSV | CSV/TSV 处理器 |
| csvkit | - | CSV 工具集 |
| fx | jq | 交互式 JSON 查看器 |
| dasel | jq+yq | 通用数据选择器 |

### 系统监控
| 工具 | 替代 | 说明 |
|------|------|------|
| **btop** | top/htop | 系统监控器 |
| **dust** | du | 可视化磁盘使用 |
| **duf** | df | 磁盘空间工具 |
| **procs** | ps | 进程查看器 |
| hyperfine | time | 命令基准测试 |

### 网络工具
| 工具 | 替代 | 说明 |
|------|------|------|
| **httpie** (http) | curl | 直觉式 HTTP 客户端 |
| curlie | curl | curl 功能 + httpie 体验 |
| dog | dig | DNS 查询工具 |
| nali | whois | IP 地理位置 |
| wget2 | wget | 多线程下载 |

### Git 增强
| 工具 | 替代 | 说明 |
|------|------|------|
| **delta** | git diff pager | 美化的 diff 显示 |
| **lazygit** | git CLI | Git 图形界面 |
| tig | git log | 日志查看器 |
| gh | GitHub 网页 | GitHub CLI |

### 终端工具
| 工具 | 替代 | 说明 |
|------|------|------|
| **fzf** | 手动选择 | 模糊查找器 |
| **zoxide** | cd | 智能 cd |
| **tmux** | 终端标签页 | 终端复用器 |
| **starship** | PS1 | 自定义提示符 |

### 开发工具
| 工具 | 替代 | 说明 |
|------|------|------|
| **shellcheck** | 人工审查 | Shell 脚本静态检查 |
| **shfmt** | 手动格式化 | Shell 格式化器 |
| hadolint | 人工审查 | Dockerfile 检查器 |
| actionlint | 人工审查 | GitHub Actions 检查器 |

### 安全工具
| 工具 | 替代 | 说明 |
|------|------|------|
| **age** | gpg | 简单加密 |
| **sops** | 手动管理 | 密钥管理 |
| pass | 手动管理 | 密码管理器 |

### 压缩工具
| 工具 | 替代 | 说明 |
|------|------|------|
| **zstd** | gzip/xz | 快速压缩 |
| ouch | tar/unzip | 通用归档工具 |
| 7zip | unzip | 7z 归档工具 |

### 文档工具
| 工具 | 替代 | 说明 |
|------|------|------|
| **pandoc** | 手动转换 | 通用文档转换器 |
| **glow** | cat *.md | Markdown 渲染器 |
| poppler-utils | 手动处理 | PDF 工具 |
| chafa | - | 终端图片查看器 |

### 下载工具
| 工具 | 替代 | 说明 |
|------|------|------|
| **aria2** | wget | 多连接下载器 |
| rclone | 云存储 CLI | 云存储同步 |

### AI 辅助
| 工具 | 说明 |
|------|------|
| aider | AI 配对编程 |
| llm | 多模型 LLM CLI |
| sgpt | Shell-GPT |

## 使用方法

### 安装
```bash
./install.sh                          # 安装所有工具
./install.sh --dry-run                # 仅预览
./install.sh --category search        # 只安装搜索类工具
./install.sh -c search -c data        # 多个类别
./install.sh --force                  # 强制重装
./install.sh --skip-config            # 跳过配置
./install.sh --help                   # 显示帮助
```

### 卸载
```bash
./uninstall.sh                        # 卸载全部
./uninstall.sh --keep-config          # 保留配置文件
./uninstall.sh --yes                  # 跳过确认
```

### 生成工具定义
```bash
python3 src/generator.py              # 生成 openclaw-tools.yaml
python3 src/generator.py --installed-only  # 仅已安装的工具
```

### 运行测试
```bash
bash tests/test_install.sh            # 测试安装结构
bash tests/test_tools.sh              # 测试工具可用性
```

## 配置

编辑 `config.yaml` 自定义安装的工具：

```yaml
categories:
  search:
    enabled: true
    tools:
      ripgrep:
        enabled: true
      ack:
        enabled: false
```

## 工作原理

```
install.sh
├── 1. 系统检测 (detector.sh)
│   ├── 操作系统: Linux/macOS
│   ├── 发行版: Ubuntu/Debian/...
│   ├── WSL2 检测
│   └── 包管理器: apt/brew/cargo/pip
├── 2. 工具安装 (installer.sh)
│   ├── 解析 tools/*.yaml 定义
│   ├── 按优先级尝试每种安装方法
│   └── 跟踪已安装/失败/跳过
├── 3. 配置 (configurator.sh)
│   ├── Shell 别名 (bat→cat, eza→ls 等)
│   ├── 工具配置 (.ripgreprc, bat/config 等)
│   └── Shell 集成 (fzf, zoxide, starship)
└── 4. 生成 (generator.py)
    └── 生成 openclaw-tools.yaml
```

## 系统要求

- **操作系统**: Linux (Ubuntu 20.04+)、WSL2、macOS
- **Shell**: Bash 4.0+
- **包管理器**: 至少一个 apt、brew、cargo、pip
- **Python**: 3.8+（用于 generator.py，可选）

## 项目结构

```
openclaw-cli-toolkit/
├── install.sh           # 主安装脚本
├── uninstall.sh         # 卸载脚本
├── config.yaml          # 配置文件
├── tools/               # 工具定义（13 个 YAML 文件）
├── src/                 # 核心脚本
│   ├── detector.sh      # 系统检测
│   ├── installer.sh     # 安装逻辑
│   ├── configurator.sh  # 工具配置
│   └── generator.py     # YAML 生成器
├── docs/
│   └── research.md      # 完整调研报告
└── tests/
    ├── test_install.sh  # 安装测试
    └── test_tools.sh    # 工具测试
```

## 许可证

MIT License - 详见 [LICENSE](LICENSE)。
