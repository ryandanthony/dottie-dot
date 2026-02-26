#!/usr/bin/env bash
# Install JetBrains Toolbox - manages Rider, DataGrip, and other JetBrains IDEs
set -euo pipefail

INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox"

if [ -d "$INSTALL_DIR" ] && [ -f "$HOME/.local/bin/jetbrains-toolbox" ]; then
    echo "✓ JetBrains Toolbox already installed"
    exit 0
fi

echo "Installing JetBrains Toolbox..."

# Get latest download URL
TOOLBOX_URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
    | grep -oP '"linux"\s*:\s*\{\s*"link"\s*:\s*"\K[^"]+' | head -1)

if [ -z "$TOOLBOX_URL" ] || [ "$TOOLBOX_URL" = "null" ]; then
    echo "✗ Failed to determine JetBrains Toolbox download URL"
    exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "  Downloading from $TOOLBOX_URL"
curl -fsSL "$TOOLBOX_URL" -o "$TMPDIR/toolbox.tar.gz"

tar -xzf "$TMPDIR/toolbox.tar.gz" -C "$TMPDIR"

# Find the extracted binary
TOOLBOX_BIN=$(find "$TMPDIR" -name "jetbrains-toolbox" -type f | head -1)

if [ -z "$TOOLBOX_BIN" ]; then
    echo "✗ Could not find jetbrains-toolbox binary in archive"
    exit 1
fi

mkdir -p "$HOME/.local/bin"
cp "$TOOLBOX_BIN" "$HOME/.local/bin/jetbrains-toolbox"
chmod +x "$HOME/.local/bin/jetbrains-toolbox"

echo "✓ JetBrains Toolbox installed to ~/.local/bin/jetbrains-toolbox"
echo "  Run 'jetbrains-toolbox' to install Rider, DataGrip, and other IDEs"
