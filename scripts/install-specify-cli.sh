#!/usr/bin/env bash
# Install specify-cli via uv tool from spec-kit
set -euo pipefail

if ! command -v uv &>/dev/null; then
    echo "uv not found in PATH, skipping specify-cli install"
    exit 0
fi

if uv tool list 2>/dev/null | grep -q "specify-cli"; then
    echo "✓ specify-cli already installed"
    exit 0
fi

echo "Installing specify-cli via uv..."
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
echo "✓ specify-cli installed"
