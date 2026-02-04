#!/bin/bash
# Install PowerShell (pwsh) on Ubuntu/Debian-based systems
# https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu

set -e

echo "Installing PowerShell..."

# Update package lists
sudo apt-get update

# Install dependencies
sudo apt-get install -y wget apt-transport-https software-properties-common

# Get Ubuntu version
source /etc/os-release
UBUNTU_VERSION=$VERSION_ID

# Download and register Microsoft GPG key
wget -q "https://packages.microsoft.com/config/ubuntu/$UBUNTU_VERSION/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
sudo dpkg -i /tmp/packages-microsoft-prod.deb
rm /tmp/packages-microsoft-prod.deb

# Update package lists again
sudo apt-get update

# Install PowerShell
sudo apt-get install -y powershell

echo ""
echo "PowerShell installation complete!"
echo "Version: $(pwsh --version)"
