"""Validate schema of all tools/*.yaml files."""
from pathlib import Path

import pytest
import yaml


TOOLS_DIR = Path(__file__).resolve().parents[2] / "tools"
REQUIRED_TOOL_KEYS = {"name", "description", "install_methods"}
OPTIONAL_TOOL_KEYS = {
    "package", "binary", "homepage", "license", "openclaw_usage",
    "config", "min_version", "_category", "_source_file",
}
REQUIRED_CATEGORY_KEYS = {"category", "tools"}
VALID_INSTALL_METHODS = {"apt", "brew", "cargo", "pip", "go", "npm", "github_release"}


def load_all_yaml_files():
    """Load all tool YAML files."""
    files = sorted(TOOLS_DIR.glob("*.yaml"))
    assert len(files) > 0, "No YAML files found in tools/"
    return files


class TestYamlSyntax:
    """All YAML files must be valid YAML."""

    @pytest.mark.parametrize("yaml_file", load_all_yaml_files(), ids=lambda f: f.name)
    def test_valid_yaml(self, yaml_file):
        with open(yaml_file, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        assert data is not None, f"{yaml_file.name}: empty or invalid YAML"
        assert isinstance(data, dict), f"{yaml_file.name}: root must be a dict"


class TestCategorySchema:
    """Each YAML file must have valid category-level structure."""

    @pytest.mark.parametrize("yaml_file", load_all_yaml_files(), ids=lambda f: f.name)
    def test_has_category_key(self, yaml_file):
        with open(yaml_file, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        assert "category" in data, f"{yaml_file.name}: missing 'category' key"
        assert isinstance(data["category"], str)
        assert data["category"] == yaml_file.stem,             f"{yaml_file.name}: category='{data['category']}' but filename='{yaml_file.stem}'"

    @pytest.mark.parametrize("yaml_file", load_all_yaml_files(), ids=lambda f: f.name)
    def test_has_tools_list(self, yaml_file):
        with open(yaml_file, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        assert "tools" in data, f"{yaml_file.name}: missing 'tools' key"
        assert isinstance(data["tools"], list), f"{yaml_file.name}: 'tools' must be a list"
        assert len(data["tools"]) > 0, f"{yaml_file.name}: empty tools list"

    @pytest.mark.parametrize("yaml_file", load_all_yaml_files(), ids=lambda f: f.name)
    def test_has_description(self, yaml_file):
        with open(yaml_file, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        assert "description" in data, f"{yaml_file.name}: missing 'description'"


class TestToolSchema:
    """Each tool entry must have valid structure."""

    @pytest.mark.parametrize("yaml_file", load_all_yaml_files(), ids=lambda f: f.name)
    def test_required_keys(self, yaml_file):
        with open(yaml_file, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        for i, tool in enumerate(data["tools"]):
            missing = REQUIRED_TOOL_KEYS - set(tool.keys())
            assert not missing,                 f"{yaml_file.name} tool[{i}] ({tool.get('name', '?')}): missing keys: {missing}"

    @pytest.mark.parametrize("yaml_file", load_all_yaml_files(), ids=lambda f: f.name)
    def test_no_unknown_keys(self, yaml_file):
        with open(yaml_file, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        all_known = REQUIRED_TOOL_KEYS | OPTIONAL_TOOL_KEYS
        for i, tool in enumerate(data["tools"]):
            unknown = set(tool.keys()) - all_known
            assert not unknown,                 f"{yaml_file.name} tool[{i}] ({tool.get('name', '?')}): unknown keys: {unknown}"

    @pytest.mark.parametrize("yaml_file", load_all_yaml_files(), ids=lambda f: f.name)
    def test_install_methods_valid(self, yaml_file):
        with open(yaml_file, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        for i, tool in enumerate(data["tools"]):
            for j, method in enumerate(tool["install_methods"]):
                assert "method" in method,                     f"{yaml_file.name} tool[{i}] method[{j}]: missing 'method'"
                assert method["method"] in VALID_INSTALL_METHODS,                     f"{yaml_file.name} tool[{i}] method[{j}]: invalid method '{method['method']}'"
                assert "package" in method,                     f"{yaml_file.name} tool[{i}] method[{j}]: missing 'package'"

    @pytest.mark.parametrize("yaml_file", load_all_yaml_files(), ids=lambda f: f.name)
    def test_tool_names_unique_within_file(self, yaml_file):
        with open(yaml_file, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f)
        names = [t["name"] for t in data["tools"]]
        dupes = [n for n in names if names.count(n) > 1]
        assert not dupes, f"{yaml_file.name}: duplicate tool names: {set(dupes)}"


class TestTotalToolCount:
    def test_minimum_tool_count(self):
        """Project should have at least 130 tools across all categories."""
        total = 0
        for yaml_file in TOOLS_DIR.glob("*.yaml"):
            with open(yaml_file, "r", encoding="utf-8") as f:
                data = yaml.safe_load(f)
            total += len(data.get("tools", []))
        assert total >= 130, f"Expected >= 130 tools, got {total}"
