# OpenClaw CLI Toolkit - Research Report

> 调研日期：2026-04-12 | 目标：筛选 Linux/WSL2/Ubuntu 上能增强 OpenClaw 系统效率和准确性的免费开源 CLI 工具

## 评估标准

| 维度 | 权重 | 说明 |
|------|------|------|
| 性能提升 | 30% | 相比系统默认工具的速度/准确度提升 |
| OpenClaw集成价值 | 25% | 对 agent 任务执行的直接帮助 |
| 安装便捷性 | 20% | apt/brew/cargo/pip 可直接安装 |
| 维护活跃度 | 15% | 近6个月有更新 |
| 兼容性 | 10% | WSL2/Linux/macOS 全平台 |

## 1. 文件搜索类

### ripgrep (rg) ⭐⭐⭐⭐⭐ — 强烈推荐
- **替代**: grep/find+xargs
- **性能**: 比grep快5-10倍，自动遵守.gitignore
- **安装**: apt install ripgrep
- **OpenClaw价值**: 极大提升文件内容搜索速度和准确性
- **关键特性**: 正则、文件类型过滤、彩色输出、并行搜索

### fd ⭐⭐⭐⭐⭐ — 强烈推荐
- **替代**: find
- **性能**: 比find快3-5倍，更简洁的语法
- **安装**: apt install fd-find (binary: fdfind) 或 cargo install fd-find
- **OpenClaw价值**: 按名称/类型/大小查找文件更高效
- **关键特性**: 并行遍历、正则、彩色输出、.gitignore感知

### the_silver_searcher (ag) ⭐⭐⭐ — 备选
- **替代**: grep
- **性能**: 比grep快5倍，但不如ripgrep
- **安装**: apt install silversearcher-ag
- **评价**: 历史项目，ripgrep在各方面已超越

## 2. 文件查看类

### bat ⭐⭐⭐⭐⭐ — 强烈推荐
- **替代**: cat
- **特性**: 语法高亮、Git集成、行号、不可打印字符可视化
- **安装**: apt install bat
- **OpenClaw价值**: 查看代码/配置文件时信息更完整准确
- **注意**: Ubuntu下binary为batcat，需alias

### eza ⭐⭐⭐⭐⭐ — 强烈推荐
- **替代**: ls/tree
- **特性**: 彩色输出、Git状态、文件类型图标、树形视图
- **安装**: cargo install eza 或 apt (Ubuntu 24.04+)
- **OpenClaw价值**: 目录浏览更直观，信息更丰富

## 3. 数据处理类

### jq ⭐⭐⭐⭐⭐ — 必装
- **用途**: JSON处理（OpenClaw agent最常用）
- **安装**: apt install jq
- **OpenClaw价值**: 解析API响应、配置文件、日志，几乎每个任务都需要
- **关键用法**: `.key`, `.[] | select()`, `-r` 原始输出

### yq ⭐⭐⭐⭐⭐ — 强烈推荐
- **用途**: YAML/JSON/XML/CSV/TOML处理
- **安装**: via go install 或下载binary
- **OpenClaw价值**: 处理YAML配置（K8s、CI/CD、OpenClaw自身配置）

### miller (mlr) ⭐⭐⭐⭐ — 推荐
- **用途**: CSV/TSV/JSON表格数据处理
- **安装**: apt install miller
- **OpenClaw价值**: 数据分析、报告生成、格式转换

### dasel ⭐⭐⭐⭐ — 推荐
- **用途**: 统一数据选择器（JSON/YAML/TOML/XML/CSV）
- **安装**: via go install
- **OpenClaw价值**: 一个工具处理所有数据格式

## 4. 系统监控类

### btop ⭐⭐⭐⭐ — 推荐
- **替代**: htop/top
- **特性**: 美观的TUI，CPU/GPU/内存/磁盘/网络/进程全显示
- **安装**: apt install btop
- **OpenClaw价值**: 系统诊断更全面准确

### dust ⭐⭐⭐⭐⭐ — 强烈推荐
- **替代**: du
- **特性**: 可视化磁盘使用，按大小排序
- **安装**: cargo install dust
- **OpenClaw价值**: 磁盘分析比du更直观准确

### duf ⭐⭐⭐⭐ — 推荐
- **替代**: df
- **特性**: 美观的磁盘空间显示
- **安装**: apt install duf

### procs ⭐⭐⭐⭐ — 推荐
- **替代**: ps
- **特性**: 彩色输出、按列排序、树形显示
- **安装**: cargo install procs

### hyperfine ⭐⭐⭐⭐⭐ — 强烈推荐
- **用途**: 命令行基准测试
- **安装**: cargo install hyperfine
- **OpenClaw价值**: 精确测量脚本/命令执行时间，优化性能

## 5. 网络工具类

### httpie (http) ⭐⭐⭐⭐⭐ — 强烈推荐
- **替代**: curl
- **特性**: 人性化HTTP客户端，自动JSON格式化
- **安装**: pip install httpie 或 apt install httpie
- **OpenClaw价值**: API测试更直观，自动处理JSON

### curlie ⭐⭐⭐⭐ — 推荐
- **特性**: curl的易用性 + httpie的输出格式
- **安装**: go install github.com/rs/curlie@latest

### dog ⭐⭐⭐⭐ — 推荐
- **替代**: dig/nslookup
- **用途**: DNS查询
- **安装**: via cargo 或下载binary

## 6. Git增强类

### delta ⭐⭐⭐⭐⭐ — 强烈推荐
- **用途**: Git diff美化（side-by-side、语法高亮、行级高亮）
- **安装**: cargo install git-delta
- **OpenClaw价值**: 代码审查更准确高效

### lazygit ⭐⭐⭐⭐ — 推荐
- **用途**: Git TUI界面
- **安装**: apt install lazygit
- **OpenClaw价值**: 复杂Git操作更直观

### tig ⭐⭐⭐⭐ — 推荐
- **用途**: Git日志浏览器
- **安装**: apt install tig
- **OpenClaw价值**: 快速浏览Git历史

## 7. 终端增强类

### fzf ⭐⭐⭐⭐⭐ — 必装
- **用途**: 模糊查找器
- **安装**: apt install fzf
- **OpenClaw价值**: 文件/命令/历史模糊搜索，提升交互效率

### zoxide ⭐⭐⭐⭐⭐ — 强烈推荐
- **替代**: cd
- **特性**: 智能目录跳转，记住常用路径
- **安装**: apt install zoxide 或 cargo install zoxide
- **OpenClaw价值**: 快速导航到常用项目目录

### tmux ⭐⭐⭐⭐⭐ — 必装
- **用途**: 终端复用器
- **安装**: apt install tmux
- **OpenClaw价值**: 长时间运行的命令/多任务管理

## 8. 开发辅助类

### shellcheck ⭐⭐⭐⭐⭐ — 必装
- **用途**: Shell脚本静态分析
- **安装**: apt install shellcheck
- **OpenClaw价值**: 确保脚本质量，减少bug

### shfmt ⭐⭐⭐⭐⭐ — 强烈推荐
- **用途**: Shell脚本格式化
- **安装**: go install mvdan.cc/sh/v3/cmd/shfmt@latest
- **OpenClaw价值**: 脚本风格一致性

## 9. 安全工具类

### age ⭐⭐⭐⭐ — 推荐
- **用途**: 简单现代的文件加密
- **安装**: apt install age 或 go install filippo.io/age@latest
- **OpenClaw价值**: 敏感文件加密

### sops ⭐⭐⭐⭐ — 推荐
- **用途**: 密钥管理（支持YAML/JSON/ENV加密）
- **安装**: go install go.mozilla.org/sops/v3/cmd/sops@latest
- **OpenClaw价值**: 安全管理配置中的密钥

## 10. 压缩归档类

### zstd ⭐⭐⭐⭐⭐ — 强烈推荐
- **用途**: 高性能压缩/解压
- **安装**: apt install zstd
- **OpenClaw价值**: 比gzip快10倍，压缩率更好

### ouch ⭐⭐⭐⭐ — 推荐
- **用途**: 统一压缩/解压接口（支持zip/tar/gz/xz/zst等）
- **安装**: cargo install ouch
- **OpenClaw价值**: 一个命令处理所有压缩格式

## 11. 文档处理类

### pandoc ⭐⭐⭐⭐⭐ — 必装
- **用途**: 万能文档格式转换（Markdown/HTML/PDF/DOCX/LaTeX等）
- **安装**: apt install pandoc
- **OpenClaw价值**: 文档格式转换、报告生成

### glow ⭐⭐⭐⭐⭐ — 强烈推荐
- **用途**: 终端Markdown渲染器
- **安装**: apt install glow
- **OpenClaw价值**: 在终端中美观地查看Markdown文档

## 12. 下载传输类

### aria2 ⭐⭐⭐⭐⭐ — 强烈推荐
- **替代**: wget/curl下载
- **特性**: 多线程、多协议（HTTP/FTP/BT）、断点续传
- **安装**: apt install aria2
- **OpenClaw价值**: 大文件下载更快更可靠

### rclone ⭐⭐⭐⭐ — 推荐
- **用途**: 云存储同步（支持40+云服务）
- **安装**: apt install rclone
- **OpenClaw价值**: 文件备份、云存储管理

## 13. AI辅助类

### llm (simonw/llm) ⭐⭐⭐⭐⭐ — 强烈推荐
- **用途**: 命令行LLM交互工具
- **安装**: pip install llm
- **OpenClaw价值**: 快速调用LLM处理文本任务

## 推荐安装优先级

### Tier 1 — 必装（高频使用）
ripgrep, fd, bat, jq, fzf, tmux, shellcheck, pandoc, zstd, aria2

### Tier 2 — 强烈推荐（显著提升效率）
eza, yq, dasel, dust, hyperfine, httpie, delta, zoxide, glow, llm, shfmt, duf

### Tier 3 — 按需安装
btop, procs, curlie, dog, lazygit, tig, miller, starship, age, sops, ouch, rclone, sgpt, hadolint

## 性能基准参考

| 工具 | 对比对象 | 提升倍数 | 场景 |
|------|---------|---------|------|
| ripgrep | grep | 5-10x | 大型代码库搜索 |
| fd | find | 3-5x | 文件名搜索 |
| zstd | gzip | 10x压缩, 3x解压 | 大文件压缩 |
| jq | python json | 5-10x | JSON处理 |
| hyperfine | time | N/A（统计级精度） | 基准测试 |
