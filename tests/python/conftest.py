"""Shared fixtures for Python tests."""
import os
import sys
import tempfile
from pathlib import Path

import pytest
import yaml

# Add src to path for imports
SRC_DIR = Path(__file__).resolve().parents[2] / "src"
sys.path.insert(0, str(SRC_DIR))

PROJECT_DIR = Path(__file__).resolve().parents[2]
TOOLS_DIR = PROJECT_DIR / "tools"
CONFIG_FILE = PROJECT_DIR / "config.yaml"
VERSION_FILE = PROJECT_DIR / "VERSION"


@pytest.fixture
def project_dir():
    """Return the project root directory."""
    return PROJECT_DIR


@pytest.fixture
def tools_dir():
    """Return the tools YAML directory."""
    return TOOLS_DIR


@pytest.fixture
def version_file():
    """Return the VERSION file path."""
    return VERSION_FILE


@pytest.fixture
def sample_tool_yaml(tmp_path):
    """Create a minimal valid tool YAML file."""
    tool_def = {
        "category": "test-cat",
        "description": "Test category",
        "tools": [
            {
                "name": "test-tool",
                "package": "test-pkg",
                "binary": "testbin",
                "description": "A test tool",
                "homepage": "https://example.com",
                "license": "MIT",
                "install_methods": [
                    {"method": "apt", "package": "test-pkg"},
                    {"method": "brew", "package": "test-brew"},
                ],
                "openclaw_usage": {
                    "replace": "old-tool",
                    "examples": [
                        "testbin --flag        # do something",
                        "testbin -h            # help",
                    ],
                    "benefits": "Test benefits",
                },
                "config": [],
            }
        ],
    }
    yaml_file = tmp_path / "test-cat.yaml"
    with open(yaml_file, "w") as f:
        yaml.dump(tool_def, f)
    return yaml_file


@pytest.fixture
def sample_config_yaml(tmp_path):
    """Create a minimal config.yaml."""
    config = {
        "installation": {
            "package_manager_priority": ["apt", "brew"],
        },
        "categories": {
            "search": {
                "enabled": True,
                "tools": {"ripgrep": {"enabled": True}, "fd": {"enabled": False}},
            },
            "disabled-cat": {"enabled": False, "tools": {}},
        },
    }
    config_file = tmp_path / "config.yaml"
    with open(config_file, "w") as f:
        yaml.dump(config, f)
    return config_file


@pytest.fixture
def all_tool_yamls():
    """Return list of all tool YAML files in the project."""
    return sorted(TOOLS_DIR.glob("*.yaml"))


@pytest.fixture
def temp_output_file(tmp_path):
    """Return a temporary output file path."""
    return tmp_path / "test-output.yaml"
