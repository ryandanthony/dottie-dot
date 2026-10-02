#!/usr/bin/env bash
# Install ghostlay (automated terminal layout tool) into ~/bin.
# https://github.com/PavelLoparev/ghostlay
# Handled by a script because upstream publishes no GitHub releases, just a
# single bash script on the master branch. Runtime dependency `wtype` is
# installed via apt in the desktop profile.
set -euo pipefail

URL="https://raw.githubusercontent.com/PavelLoparev/ghostlay/master/ghostlay"
DEST="$HOME/bin"
TARGET="$DEST/ghostlay"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

echo "Fetching ghostlay..."
curl -fsSL -o "$TMP" "$URL"

if ! head -1 "$TMP" | grep -q '^#!'; then
    echo "Error: downloaded ghostlay does not look like a script"
    exit 1
fi

if [[ -f "$TARGET" ]] && cmp -s "$TMP" "$TARGET"; then
    echo "✓ ghostlay already up to date"
    exit 0
fi

mkdir -p "$DEST"
install -m 755 "$TMP" "$TARGET"
echo "✓ ghostlay installed to $TARGET"
