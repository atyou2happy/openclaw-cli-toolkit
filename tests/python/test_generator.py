"""Tests for src/generator.py."""
import sys
from pathlib import Path

import pytest
import yaml

from generator import (
    check_tool_installed,
    generate_openclaw_entry,
    generate_output,
    get_version,
    load_tool_definitions,
)


class TestGetVersion:
    def test_returns_version_from_file(self, version_file):
        version = get_version()
        assert version  # not empty
        # Should be semver-like
        parts = version.split(".")
        assert len(parts) >= 2
        assert all(p.isdigit() for p in parts)

    def test_returns_default_when_no_file(self, tmp_path):
        """If VERSION file does not exist, return 0.0.0."""
        # We test by patching the module-level constant indirectly
        # by calling with a non-existent path
        import generator
        orig = generator.VERSION_FILE
        generator.VERSION_FILE = tmp_path / "NONEXISTENT"
        try:
            assert generator.get_version() == "0.0.0"
        finally:
            generator.VERSION_FILE = orig


class TestLoadToolDefinitions:
    def test_loads_from_project_tools_dir(self, tools_dir):
        tools = load_tool_definitions(tools_dir)
        assert len(tools) > 0
        # Every tool should have required keys
        for tool in tools:
            assert "name" in tool or "binary" in tool, f"Tool missing name: {tool}"
            assert "_category" in tool
            assert "_source_file" in tool

    def test_loads_from_sample_yaml(self, sample_tool_yaml):
        tools = load_tool_definitions(sample_tool_yaml.parent)
        assert len(tools) == 1
        assert tools[0]["name"] == "test-tool"
        assert tools[0]["_category"] == "test-cat"

    def test_handles_empty_dir(self, tmp_path):
        empty_dir = tmp_path / "empty"
        empty_dir.mkdir()
        tools = load_tool_definitions(empty_dir)
        assert tools == []

    def test_handles_invalid_yaml(self, tmp_path):
        """Invalid YAML files should be skipped with warning."""
        bad_file = tmp_path / "bad.yaml"
        bad_file.write_text(":::invalid:::yaml:::[")
        tools = load_tool_definitions(tmp_path)
        assert tools == []

    def test_handles_yaml_without_tools_key(self, tmp_path):
        """YAML without tools key should be skipped."""
        no_tools = tmp_path / "notools.yaml"
        no_tools.write_text("category: test\ndescription: no tools here\n")
        tools = load_tool_definitions(tmp_path)
        assert tools == []


class TestGenerateOpenclawEntry:
    def test_basic_entry(self):
        tool = {
            "name": "test-tool",
            "binary": "testbin",
            "description": "A test tool",
            "_category": "test-cat",
            "_source_file": "test.yaml",
            "install_methods": [
                {"method": "apt", "package": "test-pkg"},
            ],
            "openclaw_usage": {
                "replace": "old-tool",
                "examples": ["testbin --flag  # do something"],
                "benefits": "Test benefits",
            },
        }
        entry = generate_openclaw_entry(tool)
        assert entry["name"] == "testbin"  # prefers binary
        assert entry["category"] == "test-cat"
        assert entry["description"] == "A test tool"
        assert entry["usage"] == "testbin --flag"  # strips comment
        assert entry["replaces"] == "old-tool"
        assert len(entry["install_methods"]) == 1

    def test_entry_without_openclaw_usage(self):
        tool = {
            "name": "basic",
            "binary": "basic",
            "description": "Basic tool",
            "_category": "basic-cat",
            "_source_file": "basic.yaml",
            "install_methods": [],
        }
        entry = generate_openclaw_entry(tool)
        assert entry["name"] == "basic"
        assert entry["usage"] == "basic <args>"  # fallback
        assert entry["best_for"] == "Basic tool"  # falls back to description
        assert entry["replaces"] == ""

    def test_entry_with_empty_examples(self):
        tool = {
            "name": "noex",
            "binary": "noex",
            "description": "No examples",
            "_category": "cat",
            "_source_file": "noex.yaml",
            "openclaw_usage": {"replace": "", "examples": [], "benefits": ""},
            "install_methods": [],
        }
        entry = generate_openclaw_entry(tool)
        assert entry["usage"] == "noex <args>"


class TestGenerateOutput:
    def test_generates_valid_yaml(self, tools_dir, temp_output_file):
        tools = load_tool_definitions(tools_dir)
        result = generate_output(tools, temp_output_file)
        assert temp_output_file.exists()
        with open(temp_output_file) as f:
            data = yaml.safe_load(f)
        assert "meta" in data
        assert "tools" in data
        assert data["meta"]["total_tools"] == len(data["tools"])
        assert data["meta"]["total_tools"] > 0

    def test_only_installed_mode(self, tools_dir, temp_output_file):
        tools = load_tool_definitions(tools_dir)
        # Most tools won't be installed in CI, so result may be 0 tools
        result = generate_output(tools, temp_output_file, only_installed=True)
        # Just verify it doesn't crash
        assert temp_output_file.exists()

    def test_categories_sorted(self, tools_dir, temp_output_file):
        tools = load_tool_definitions(tools_dir)
        result = generate_output(tools, temp_output_file)
        cats = result["meta"]["categories"]
        assert cats == sorted(cats)
