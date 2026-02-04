#!/bin/bash
# Install Starship prompt
# This script installs Starship using the official installer

set -e

echo "Installing Starship prompt..."

# Check if starship is already installed
if command -v starship &> /dev/null; then
    echo "Starship is already installed: $(starship --version)"
    echo "Updating to latest version..."
fi

# Install using official script
curl -sS https://starship.rs/install.sh | sh -s -- -y

echo "Starship installation complete!"
echo "Version: $(starship --version)"
