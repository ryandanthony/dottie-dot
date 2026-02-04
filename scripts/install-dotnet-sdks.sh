#!/bin/bash
# Install .NET SDK versions
# This script installs multiple .NET SDK versions using the official Microsoft script

set -e

echo "Installing .NET SDKs..."

# Download the install script
curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh

# Install .NET 8
echo "Installing .NET 8 SDK..."
/tmp/dotnet-install.sh --channel 8.0 --install-dir ~/.dotnet

# Install .NET 9
echo "Installing .NET 9 SDK..."
/tmp/dotnet-install.sh --channel 9.0 --install-dir ~/.dotnet

# Install .NET 10
echo "Installing .NET 10 SDK..."
/tmp/dotnet-install.sh --channel 10.0 --install-dir ~/.dotnet

# Cleanup
rm /tmp/dotnet-install.sh

echo ""
echo ".NET SDK installation complete!"
echo "Note: DOTNET_ROOT is configured in your managed .bashrc"
echo "Installed versions:"
~/.dotnet/dotnet --list-sdks
