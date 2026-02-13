#!/usr/bin/env bash
# Install VS Code extensions from extensions list
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/../dotfiles/Code/extensions.txt"

if ! command -v code &>/dev/null; then
    echo "VS Code (code) not found in PATH, skipping extension install"
    exit 0
fi

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "Extensions file not found: $EXTENSIONS_FILE"
    exit 1
fi

echo "Installing VS Code extensions..."
while IFS= read -r ext || [ -n "$ext" ]; do
    ext="$(echo "$ext" | xargs)"
    [ -z "$ext" ] && continue
    [[ "$ext" == \#* ]] && continue
    if code --list-extensions | grep -qi "^${ext}$"; then
        echo "  ✓ Already installed: $ext"
    else
        echo "  Installing: $ext"
        code --install-extension "$ext" --force 2>/dev/null || echo "  ✗ Failed: $ext"
    fi
done < "$EXTENSIONS_FILE"
echo "VS Code extensions install complete."
