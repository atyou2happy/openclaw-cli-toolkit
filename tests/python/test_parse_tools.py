"""Tests for src/parse_tools.py."""
import subprocess
import sys
from pathlib import Path

import pytest
import yaml


SRC_DIR = Path(__file__).resolve().parents[2] / "src"
PARSER = SRC_DIR / "parse_tools.py"
TOOLS_DIR = Path(__file__).resolve().parents[2] / "tools"


def run_parser(tools_dir: Path, config_file: str = "") -> subprocess.CompletedProcess:
    """Run parse_tools.py as a subprocess and return result."""
    cmd = [sys.executable, str(PARSER), str(tools_dir)]
    if config_file:
        cmd.append(config_file)
    return subprocess.run(cmd, capture_output=True, text=True, timeout=30)


class TestParseToolsBasic:
    def test_produces_tsv_output(self, tmp_path):
        """Output should be tab-separated: name\tbinary\tpackage\tmethods\tcategory."""
        tool_def = {
            "category": "search",
            "description": "Search tools",
            "tools": [
                {
                    "name": "ripgrep",
                    "package": "ripgrep",
                    "binary": "rg",
                    "install_methods": [
                        {"method": "apt", "package": "ripgrep"},
                        {"method": "brew", "package": "ripgrep"},
                    ],
                }
            ],
        }
        yaml_file = tmp_path / "search.yaml"
        with open(yaml_file, "w") as f:
            yaml.dump(tool_def, f)

        result = run_parser(tmp_path)
        assert result.returncode == 0
        lines = result.stdout.strip().split("\n")
        assert len(lines) == 1
        fields = lines[0].split("\t")
        assert len(fields) == 5
        assert fields[0] == "ripgrep"
        assert fields[1] == "rg"
        assert "apt" in fields[3]
        assert "brew" in fields[3]
        assert fields[4] == "search"

    def test_handles_multiple_tools(self, tmp_path):
        tool_def = {
            "category": "multi",
            "tools": [
                {"name": "tool1", "binary": "t1", "install_methods": [{"method": "apt"}]},
                {"name": "tool2", "binary": "t2", "install_methods": [{"method": "brew"}]},
            ],
        }
        yaml_file = tmp_path / "multi.yaml"
        with open(yaml_file, "w") as f:
            yaml.dump(tool_def, f)

        result = run_parser(tmp_path)
        assert result.returncode == 0
        lines = result.stdout.strip().split("\n")
        assert len(lines) == 2

    def test_handles_empty_tools_dir(self, tmp_path):
        empty = tmp_path / "empty"
        empty.mkdir()
        result = run_parser(empty)
        assert result.returncode == 0
        assert result.stdout.strip() == ""


class TestParseToolsWithConfig:
    def test_disabled_category_skipped(self, tmp_path):
        """Tools in disabled categories should not appear."""
        tool_def = {
            "category": "disabled-cat",
            "tools": [
                {"name": "skip-me", "binary": "skip", "install_methods": [{"method": "apt"}]},
            ],
        }
        yaml_file = tmp_path / "disabled-cat.yaml"
        with open(yaml_file, "w") as f:
            yaml.dump(tool_def, f)

        config = {"categories": {"disabled-cat": {"enabled": False, "tools": {}}}}
        config_file = tmp_path / "config.yaml"
        with open(config_file, "w") as f:
            yaml.dump(config, f)

        result = run_parser(tmp_path, str(config_file))
        assert result.returncode == 0
        assert result.stdout.strip() == ""

    def test_disabled_tool_skipped(self, tmp_path):
        """Individual disabled tools should not appear."""
        tool_def = {
            "category": "partial",
            "tools": [
                {"name": "enabled-tool", "binary": "et", "install_methods": [{"method": "apt"}]},
                {"name": "disabled-tool", "binary": "dt", "install_methods": [{"method": "apt"}]},
            ],
        }
        yaml_file = tmp_path / "partial.yaml"
        with open(yaml_file, "w") as f:
            yaml.dump(tool_def, f)

        config = {
            "categories": {
                "partial": {
                    "enabled": True,
                    "tools": {"enabled-tool": {"enabled": True}, "disabled-tool": {"enabled": False}},
                }
            }
        }
        config_file = tmp_path / "config.yaml"
        with open(config_file, "w") as f:
            yaml.dump(config, f)

        result = run_parser(tmp_path, str(config_file))
        assert result.returncode == 0
        lines = result.stdout.strip().split("\n")
        assert len(lines) == 1
        assert "enabled-tool" in lines[0]

    def test_invalid_config_file_graceful(self, tmp_path):
        """Invalid config file should be ignored (not crash)."""
        tool_def = {
            "category": "test",
            "tools": [{"name": "tool", "binary": "t", "install_methods": [{"method": "apt"}]}],
        }
        yaml_file = tmp_path / "test.yaml"
        with open(yaml_file, "w") as f:
            yaml.dump(tool_def, f)

        bad_config = tmp_path / "bad_config.yaml"
        bad_config.write_text(":::invalid:::")

        result = run_parser(tmp_path, str(bad_config))
        assert result.returncode == 0
        # Should still output the tool (config ignored)
        assert "tool" in result.stdout


class TestParseToolsRealProject:
    def test_all_project_yamls_parseable(self):
        """All 26 tool YAML files should parse without error."""
        result = run_parser(TOOLS_DIR)
        assert result.returncode == 0
        lines = result.stdout.strip().split("\n")
        assert len(lines) >= 100  # 140+ tools expected
