# Design: OpenClaw CLI Toolkit

## 目录结构
```
openclaw-cli-toolkit/
├── README.md                    # 英文
├── README_CN.md                 # 中文
├── LICENSE                      # MIT
├── install.sh                   # 一键安装脚本
├── uninstall.sh                 # 卸载脚本
├── config.yaml                  # 工具选择配置（用户可自定义）
├── openclaw-tools.yaml          # 生成的 OpenClaw 工具描述
├── src/
│   ├── detector.sh              # 系统检测（OS/包管理器/架构）
│   ├── installer.sh             # 各工具安装逻辑
│   ├── configurator.sh          # 工具配置（别名、环境变量）
│   └── generator.py             # 生成 OpenClaw 工具描述
├── tools/                       # 按类别组织的工具定义
│   ├── search.yaml              # 文件搜索类
│   ├── data.yaml                # 数据处理类
│   ├── system.yaml              # 系统监控类
│   ├── network.yaml             # 网络工具类
│   ├── git.yaml                 # Git增强类
│   ├── terminal.yaml            # 终端增强类
│   ├── dev.yaml                 # 开发辅助类
│   ├── security.yaml            # 安全工具类
│   ├── archive.yaml             # 压缩归档类
│   ├── docs.yaml                # 文档处理类
│   ├── disk.yaml                # 磁盘分析类
│   └── download.yaml            # 下载传输类
├── docs/
│   ├── research.md              # 完整调研报告
│   └── benchmarks.md            # 性能基准测试结果
└── tests/
    ├── test_install.sh          # 安装测试
    └── test_tools.sh            # 工具可用性测试
```

## install.sh 流程
```
1. 系统检测（OS/架构/包管理器）
2. 读取 config.yaml（用户可选装）
3. 按优先级安装工具（apt > brew > cargo > pip > 手动下载）
4. 运行 configurator.sh（设置别名、环境变量、默认配置）
5. 运行 generator.py（生成 openclaw-tools.yaml）
6. 输出安装报告
```

## 工具定义 YAML 格式
```yaml
- name: ripgrep
  category: search
  package: ripgrep
  binary: rg
  description: "极速正则搜索工具，替代grep"
  install_methods:
    - method: apt
      package: ripgrep
    - method: cargo
      package: ripgrep
  openclaw_usage:
    replace: grep
    examples:
      - "rg 'pattern' /path  # 递归搜索"
      - "rg -l 'pattern'     # 只列文件名"
      - "rg -t py 'pattern'  # 只搜Python文件"
    benefits: "比grep快5-10倍，支持.gitignore，彩色输出"
  config:
    - file: ~/.ripgreprc
      content: "--smart-case"
```

## openclaw-tools.yaml 输出格式
安装完成后自动生成，OpenClaw agent 可直接读取：
```yaml
tools:
  - name: rg
    description: "极速文件内容搜索（替代grep）"
    usage: "rg <pattern> [path] [options]"
    best_for: "代码搜索、日志查找、批量文件内容检索"
    replaces: "grep"
  
  - name: fd
    description: "智能文件查找（替代find）"
    usage: "fd <pattern> [path] [options]"
    best_for: "按名称查找文件、查找目录"
    replaces: "find"
```
