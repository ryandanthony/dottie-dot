#!/usr/bin/env bash
# Install Aspire CLI from source (Microsoft/aspire repository)
# Uses git clone and dotnet tooling to build and install the CLI

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ASPIRE_REPO="https://github.com/microsoft/aspire.git"
INSTALL_DIR="${HOME}/.aspire-cli"
BIN_LINK="${HOME}/bin/aspire"
CLONE_DIR="${INSTALL_DIR}/repo"

echo -e "${YELLOW}Installing Aspire CLI from source...${NC}"

# Check if dotnet is available
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}Error: dotnet is not installed. Please install .NET SDK first.${NC}"
    exit 1
fi

# Clone or update the repository
if [ -d "${CLONE_DIR}" ]; then
    echo -e "${YELLOW}Updating existing Aspire repository...${NC}"
    cd "${CLONE_DIR}"
    git pull origin main
else
    echo -e "${YELLOW}Cloning Aspire repository...${NC}"
    mkdir -p "${INSTALL_DIR}"
    git clone "${ASPIRE_REPO}" "${CLONE_DIR}"
fi

# Build the Aspire CLI
echo -e "${YELLOW}Building Aspire CLI...${NC}"
cd "${CLONE_DIR}"
dotnet publish src/Aspire.Cli/Aspire.Cli.csproj \
    --configuration Release \
    --output "${INSTALL_DIR}/build" \
    --self-contained false \
    --no-restore

# Create a wrapper script that calls the published binary
WRAPPER_SCRIPT="${INSTALL_DIR}/aspire"
mkdir -p "$(dirname "${BIN_LINK}")"

cat > "${WRAPPER_SCRIPT}" << 'EOF'
#!/usr/bin/env bash
exec dotnet "$ASPIRE_CLI_PATH" "$@"
EOF

chmod +x "${WRAPPER_SCRIPT}"

# Create symlink in ~/bin
ln -sf "${WRAPPER_SCRIPT}" "${BIN_LINK}"

# Set the path for the wrapper to find the compiled binary
export ASPIRE_CLI_PATH="${INSTALL_DIR}/build/Aspire.Cli.dll"

# Verify installation
if [ -x "${BIN_LINK}" ]; then
    echo -e "${GREEN}Aspire CLI installed successfully!${NC}"
    ${BIN_LINK} --version
else
    echo -e "${RED}Installation failed: ${BIN_LINK} is not executable${NC}"
    exit 1
fi
