#!/bin/bash
# Install multiple .NET SDK versions using the official dotnet-install script
# Usage: ./scripts/install-dotnet-sdk.sh
# Environment: DOTNET_VERSIONS="10.0.302 9.0.100 8.0.404" (space-separated list)
# Supports Major.Minor.Patch format (e.g., 10.0.302) or Major.Minor (e.g., 10.0)

set -euo pipefail

# Allow versions to be specified via env var, default to these versions
DOTNET_VERSIONS_STR="${DOTNET_VERSIONS:-10.0.302 9.0.100}"
IFS=' ' read -r -a DOTNET_VERSIONS <<< "$DOTNET_VERSIONS_STR"

log() {
    echo "[.NET SDK Install]" "$@"
}

log "Installing .NET SDK versions: ${DOTNET_VERSIONS[*]}"

# Download the official dotnet-install script
INSTALL_SCRIPT=$(mktemp)
trap "rm -f $INSTALL_SCRIPT" EXIT

log "Downloading dotnet-install.sh..."
curl -sSL https://dot.net/v1/dotnet-install.sh -o "$INSTALL_SCRIPT"
chmod +x "$INSTALL_SCRIPT"

# Install each SDK version
for version in "${DOTNET_VERSIONS[@]}"; do
    log "Installing .NET SDK $version..."
    "$INSTALL_SCRIPT" --version "$version" --install-dir "$HOME/.dotnet" --no-path
done

# Add .dotnet to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.dotnet:"* ]]; then
    log "Adding ~/.dotnet to PATH..."
    mkdir -p ~/.bashrc.d
    cat > ~/.bashrc.d/dotnet-path.sh << 'EOF'
export PATH="$HOME/.dotnet:$PATH"
EOF
    chmod +x ~/.bashrc.d/dotnet-path.sh
    log "Added to ~/.bashrc.d/dotnet-path.sh"
fi

# Verify installation
log "Installed .NET SDK versions:"
"$HOME/.dotnet/dotnet" --list-sdks

log "Done!"
