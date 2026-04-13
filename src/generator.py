#!/usr/bin/env python3
"""Generate openclaw-tools.yaml from tools/*.yaml definitions.

Reads all YAML tool definitions from the tools/ directory and produces
a unified openclaw-tools.yaml that OpenClaw agents can directly read.
"""

import shutil
import sys
from pathlib import Path

import yaml

SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_DIR = SCRIPT_DIR.parent
TOOLS_DIR = PROJECT_DIR / "tools"
OUTPUT_FILE = PROJECT_DIR / "openclaw-tools.yaml"


def load_tool_definitions(tools_dir: Path) -> list[dict]:
    """Load all tool YAML definitions from the tools directory."""
    all_tools: list[dict] = []
    for yaml_file in sorted(tools_dir.glob("*.yaml")):
        try:
            with open(yaml_file, "r", encoding="utf-8") as f:
                data = yaml.safe_load(f)
            if data and "tools" in data:
                category = data.get("category", yaml_file.stem)
                for tool in data["tools"]:
                    tool["_category"] = category
                    tool["_source_file"] = yaml_file.name
                    all_tools.append(tool)
        except Exception as e:
            print(f"[WARN] Failed to load {yaml_file}: {e}", file=sys.stderr)
    return all_tools


def check_tool_installed(binary: str) -> bool:
    """Check if a tool binary is available on the system."""
    return shutil.which(binary) is not None


def generate_openclaw_entry(tool: dict) -> dict:
    """Generate a single tool entry for openclaw-tools.yaml."""
    name = tool.get("binary", tool.get("name", "unknown"))
    category = tool.get("_category", "unknown")
    description = tool.get("description", "")
    usage_info = tool.get("openclaw_usage", {})

    replaces = usage_info.get("replace", "")
    examples = usage_info.get("examples", [])
    benefits = usage_info.get("benefits", "")

    if examples:
        primary_usage = (
            examples[0].split("#")[0].strip()
            if "#" in examples[0]
            else examples[0].strip()
        )
    else:
        primary_usage = f"{name} <args>"

    entry = {
        "name": name,
        "package_name": tool.get("name", name),
        "category": category,
        "description": description,
        "usage": primary_usage,
        "best_for": benefits if benefits else description,
        "replaces": replaces,
        "examples": examples,
        "install_methods": [
            {"method": m.get("method"), "package": m.get("package", name)}
            for m in tool.get("install_methods", [])
        ],
    }

    return entry


def generate_output(
    tools: list[dict], output_file: Path, only_installed: bool = False
) -> dict:
    """Generate the openclaw-tools.yaml output file."""
    openclaw_tools: list[dict] = []

    for tool in tools:
        binary = tool.get("binary", tool.get("name", ""))
        if only_installed and not check_tool_installed(binary):
            continue
        entry = generate_openclaw_entry(tool)
        openclaw_tools.append(entry)

    categories = sorted(set(e.get("category", "other") for e in openclaw_tools))

    output = {
        "meta": {
            "version": "2.0.0",
            "description": "OpenClaw CLI Toolkit - Tool definitions for AI agent usage",
            "generated_by": "openclaw-cli-toolkit generator.py",
            "total_tools": len(openclaw_tools),
            "categories": categories,
        },
        "tools": openclaw_tools,
    }

    with open(output_file, "w", encoding="utf-8") as f:
        yaml.dump(
            output, f, default_flow_style=False, allow_unicode=True, sort_keys=False
        )

    print(
        f"[OK] Generated {output_file} with {len(openclaw_tools)} tools across {len(categories)} categories"
    )
    return output


def main() -> None:
    only_installed = "--installed-only" in sys.argv
    output_file = OUTPUT_FILE
    tools_dir = TOOLS_DIR

    for i, arg in enumerate(sys.argv):
        if arg == "--output" and i + 1 < len(sys.argv):
            output_file = Path(sys.argv[i + 1])
        if arg == "--tools-dir" and i + 1 < len(sys.argv):
            tools_dir = Path(sys.argv[i + 1])

    if not tools_dir.exists():
        print(f"[ERROR] Tools directory not found: {tools_dir}", file=sys.stderr)
        sys.exit(1)

    tools = load_tool_definitions(tools_dir)
    if not tools:
        print("[ERROR] No tool definitions found", file=sys.stderr)
        sys.exit(1)

    print(f"[INFO] Loaded {len(tools)} tool definitions from {tools_dir}")
    generate_output(tools, output_file, only_installed)


if __name__ == "__main__":
    main()
