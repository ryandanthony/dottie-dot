#!/usr/bin/env bash
# Install nvm (Node Version Manager)
set -uo pipefail

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [ -d "$NVM_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    source "$NVM_DIR/nvm.sh" || true
    echo "✓ nvm already installed ($(nvm --version))"
    exit 0
fi

echo "Installing nvm..."

# Install nvm using official install script
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Source nvm for current session
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" || true

echo "✓ nvm installed: $(nvm --version)"

# Install latest LTS version of Node.js
echo "Installing Node.js LTS..."
nvm install --lts
nvm use --lts
nvm alias default lts/*

echo "✓ Node.js installed: $(node --version)"
echo "  npm: $(npm --version)"
