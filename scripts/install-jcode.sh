#!/usr/bin/env bash
# Install jcode from GitHub releases.
# Handled by a script because the release tarball names the binary
# jcode-linux-<arch>, and dottie's github installer cannot rename it.
set -euo pipefail

VERSION="v0.61.1"
REPO="1jehuang/jcode"
DEST="$HOME/bin"

case "$(uname -m)" in
    x86_64)  ARCH="x86_64" ;;
    aarch64) ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $(uname -m), skipping jcode install"; exit 0 ;;
esac

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
