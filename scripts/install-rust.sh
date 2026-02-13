#!/usr/bin/env bash
# Install Rust via rustup
set -euo pipefail

if command -v rustup &>/dev/null; then
    echo "✓ Rust already installed ($(rustc --version 2>/dev/null || echo 'version unknown'))"
    echo "  Updating toolchain..."
    rustup update stable
    exit 0
fi

echo "Installing Rust via rustup..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Source cargo env for current session
source "$HOME/.cargo/env"

echo "✓ Rust installed: $(rustc --version)"
echo "  cargo: $(cargo --version)"
