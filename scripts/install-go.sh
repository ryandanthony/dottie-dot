#!/usr/bin/env bash
# Install Go (latest stable) from official tarball
set -euo pipefail

GO_INSTALL_DIR="/usr/local"

if command -v go &>/dev/null; then
    CURRENT_VERSION=$(go version | grep -oP 'go\d+\.\d+(\.\d+)?' || true)
    echo "✓ Go already installed ($CURRENT_VERSION)"
    exit 0
fi

echo "Installing Go..."

# Get latest stable version
GO_VERSION=$(curl -fsSL "https://go.dev/VERSION?m=text" | head -1)

if [ -z "$GO_VERSION" ]; then
    echo "✗ Failed to determine latest Go version"
    exit 1
fi

echo "  Latest version: $GO_VERSION"

ARCH=$(dpkg --print-architecture 2>/dev/null || echo "amd64")
TARBALL="${GO_VERSION}.linux-${ARCH}.tar.gz"
URL="https://go.dev/dl/${TARBALL}"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "  Downloading $URL"
curl -fsSL "$URL" -o "$TMPDIR/$TARBALL"

echo "  Extracting to $GO_INSTALL_DIR"
sudo rm -rf "$GO_INSTALL_DIR/go"
sudo tar -C "$GO_INSTALL_DIR" -xzf "$TMPDIR/$TARBALL"

export PATH=$PATH:/usr/local/go/bin
echo "✓ Go installed: $(/usr/local/go/bin/go version)"
