#!/usr/bin/env bash
# Install jcode from GitHub releases.
# Handled by a script because the release tarball names the binary
# jcode-linux-<arch>, and dottie's github installer cannot rename it.
set -euo pipefail

REPO="1jehuang/jcode"
DEST="$HOME/bin"

case "$(uname -m)" in
    x86_64)  ARCH="x86_64" ;;
    aarch64) ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $(uname -m), skipping jcode install"; exit 0 ;;
esac

# Fetch latest version from GitHub API
echo "Fetching latest jcode release..."
LATEST_JSON=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")
VERSION=$(echo "$LATEST_JSON" | grep -oP '"tag_name":\s*"\K[^"]+' | head -1)

if [[ -z "$VERSION" ]]; then
    echo "Error: Could not determine latest jcode version"
    echo "Debug: $LATEST_JSON" | head -5
    exit 1
fi

if [[ -x "$DEST/jcode" ]] && "$DEST/jcode" --version 2>/dev/null | grep -q "${VERSION#v}"; then
    echo "✓ jcode ${VERSION} already installed"
    exit 0
fi

ASSET="jcode-linux-${ARCH}.tar.gz"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Installing jcode ${VERSION}..."
curl -fsSL -o "$TMP/$ASSET" \
    "https://github.com/${REPO}/releases/download/${VERSION}/${ASSET}"
tar -xzf "$TMP/$ASSET" -C "$TMP"

mkdir -p "$DEST"
install -m 755 "$TMP/jcode-linux-${ARCH}" "$DEST/jcode"
# The launcher expects its payload alongside it.
install -m 755 "$TMP/jcode-linux-${ARCH}.bin" "$DEST/jcode-linux-${ARCH}.bin"

echo "✓ jcode installed to $DEST/jcode"
