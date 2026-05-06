"""Parse tool YAML definitions and output TSV for bash consumption.

Usage: python3 parse_tools.py <tools_dir> [config_file]
Output: name\tbinary\tpackage\tmethods\tcategory (one line per tool)

Each method can optionally override the package:
  - method: github_release
    package: xo/usql#usql_static=usql
  Produces: "github_release:xo/usql#usql_static=usql" in the methods column.
If no per-method package, just the method name is emitted.
"""

import sys
from pathlib import Path

import yaml


def parse_tools(tools_dir: Path, config_file: str = "") -> None:
    """Parse all tool YAML files and print TSV to stdout."""
    config: dict = {}
    if config_file:
        try:
            with open(config_file, "r", encoding="utf-8") as fh:
                config = yaml.safe_load(fh) or {}
        except (yaml.YAMLError, OSError) as e:
            print(f"[WARN] Failed to load config {config_file}: {e}", file=sys.stderr)
            config = {}

    for f in sorted(tools_dir.glob("*.yaml")):
        try:
            with open(f, "r", encoding="utf-8") as fh:
                data = yaml.safe_load(fh)
            if not data or "tools" not in data:
                continue
            category = data.get("category", f.stem)
            cat_cfg = config.get("categories", {}).get(category, {})
            if not cat_cfg.get("enabled", True):
                continue
            for t in data.get("tools", []):
                name = t.get("name", "")
                tool_cfg = cat_cfg.get("tools", {}).get(name, {})
                if not tool_cfg.get("enabled", True):
                    continue
                binary = t.get("binary", "")
                pkg = t.get("package", "")
                methods = " ".join(
                    m.get("method", "")
                    + (
                        ":" + m["package"]
                        if m.get("package") and m.get("method")
                        else ""
                    )
                    for m in t.get("install_methods", [])
                )
                print(f"{name}\t{binary}\t{pkg}\t{methods}\t{category}")
        except yaml.YAMLError as e:
            print(f"[WARN] Invalid YAML in {f}: {e}", file=sys.stderr)
        except (KeyError, TypeError) as e:
            print(f"[WARN] Schema error in {f}: {e}", file=sys.stderr)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <tools_dir> [config_file]", file=sys.stderr)
        sys.exit(1)
    tools_dir = Path(sys.argv[1])
    config_file = sys.argv[2] if len(sys.argv) > 2 else ""
    if not tools_dir.is_dir():
        print(f"[ERROR] Not a directory: {tools_dir}", file=sys.stderr)
        sys.exit(1)
    parse_tools(tools_dir, config_file)
