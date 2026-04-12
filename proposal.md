# Proposal: OpenClaw CLI Toolkit

> 项目代号: `openclaw-cli-toolkit` | 模式: Standard | 开源: MIT

## 目标
系统性调研 Linux/WSL2/Ubuntu 上免费开源的 CLI 工具，筛选出能增强 OpenClaw 系统执行效率和准确性的工具，并提供：
1. 一键安装/配置脚本 (`install.sh`)
2. 详细的调研评测文档
3. OpenClaw 可直接使用的工具描述（自动生成 SKILL.md 或 TOOLS.md 片段）

## 调研范围
按功能类别全面覆盖：

| 类别 | 示例工具 | 增强方向 |
|------|---------|---------|
| 文件搜索/处理 | ripgrep, fd, bat, eza | 更快更准确的文件操作 |
| 文本/数据处理 | jq, yq, miller, csvkit | 结构化数据解析 |
| 系统信息/监控 | btop, dust, duf, procs | 系统诊断更精准 |
| 网络工具 | httpie, curlie, dog | API调用更可靠 |
| Git增强 | delta, lazygit, tig | 代码管理更高效 |
| 终端/交互 | fzf, zoxide, tmux, starship | 导航和交互增强 |
| 开发辅助 | shellcheck, shfmt, hadolint | 脚本质量保证 |
| 安全/加密 | age, sops, pass | 安全操作 |
| 压缩/归档 | zstd, ouch, bandizip-cli | 文件压缩解压 |
| PDF/文档 | poppler, pandoc, glow | 文档处理 |
| 进程管理 | htop, lsof-alt, killall | 进程诊断 |
| 磁盘/文件系统 | ncdu, dust, duf | 磁盘分析 |
| 下载/传输 | aria2, rclone, wget2 | 文件传输 |

## 交付物
1. **调研文档**: `docs/research.md` — 每个工具的评测（功能、性能、适用场景、OpenClaw集成价值）
2. **安装脚本**: `install.sh` — 检测系统 → 安装工具 → 配置默认值 → 生成工具描述
3. **工具描述**: `openclaw-tools.yaml` — 结构化工具描述，可直接导入 OpenClaw
4. **README**: 双语 README（MIT 开源）

## 筛选标准
- ✅ 免费开源
- ✅ Linux/WSL2/Ubuntu 兼容
- ✅ 对 OpenClaw 任务执行有明显效率/准确性提升
- ✅ 安装简单（apt/brew/cargo/pip 可装）
- ✅ 维护活跃（6个月内有更新）

## 技术方案
- **安装脚本**: Bash（系统检测 + 包管理器选择 + 安装 + 配置）
- **调研脚本**: Python（自动化评测：版本检查、性能基准、功能测试）
- **工具描述生成**: Python（从评测结果生成 YAML）
