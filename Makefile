.PHONY: lint test test-python test-shell check clean generate install dry-run

# Shell lint
lint:
	shellcheck -s bash install.sh uninstall.sh src/*.sh src/methods/*.sh tests/*.sh 2>/dev/null || true
	python3 -m ruff check src/ 2>/dev/null || true

# Tests
test: test-shell test-python

test-python:
	python3 -m pytest tests/python/ -v --tb=short

test-shell:
	@bash tests/test_install.sh
	@bash tests/test_structure.sh

# Full check
check: lint test

# Generate openclaw-tools.yaml
generate:
	python3 src/generator.py

# Convenience targets
install:
	./install.sh

dry-run:
	./install.sh --dry-run

# Clean artifacts
clean:
	rm -f openclaw-tools.yaml
	rm -rf __pycache__ .ruff_cache .pytest_cache tests/python/__pycache__
	find . -name '*.pyc' -delete
