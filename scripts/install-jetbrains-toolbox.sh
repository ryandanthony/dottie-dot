#!/usr/bin/env bash
# Install JetBrains Toolbox - manages Rider, DataGrip, and other JetBrains IDEs
set -euo pipefail

APP_DIR="$HOME/.local/lib/jetbrains-toolbox"

if [ -d "$APP_DIR" ] && [ -f "$HOME/.local/bin/jetbrains-toolbox" ]; then
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

# Find the extracted binary and its parent directory (contains jre/, lib/, etc.)
TOOLBOX_BIN=$(find "$TMPDIR" -name "jetbrains-toolbox" -type f | head -1)

if [ -z "$TOOLBOX_BIN" ]; then
    echo "✗ Could not find jetbrains-toolbox binary in archive"
    exit 1
fi

TOOLBOX_DIR=$(dirname "$TOOLBOX_BIN")

# Install the entire app directory (binary + jre + lib + jetbrainsd + askpass etc.)
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"
cp -r "$TOOLBOX_DIR"/. "$APP_DIR/"
chmod +x "$APP_DIR/jetbrains-toolbox"

# Clean up any previous partial installs in ~/.local/bin
rm -f "$HOME/.local/bin/jetbrains-toolbox"
rm -rf "$HOME/.local/bin/jre"

# Symlink the binary into PATH
mkdir -p "$HOME/.local/bin"
ln -sf "$APP_DIR/jetbrains-toolbox" "$HOME/.local/bin/jetbrains-toolbox"

echo "✓ JetBrains Toolbox installed to $APP_DIR"
echo "  Symlinked to ~/.local/bin/jetbrains-toolbox"
echo "  Run 'jetbrains-toolbox' to launch"
