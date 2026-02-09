#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Dottie Test Setup - Ubuntu 24.04"
echo "=========================================="
echo ""

# Function to check version
check_version() {
    local name=$1
    local cmd=$2
    echo -n "Checking $name... "
    if output=$($cmd 2>&1); then
        echo -e "${GREEN}✓${NC} $output"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Function to check if command exists
check_command() {
    local name=$1
    local cmd=$2
    echo -n "Checking $name... "
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}✓ Found${NC}"
        return 0
    else
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
}

# Track success/failure counts
SUCCESS_COUNT=0
FAIL_COUNT=0

echo "Step 1: Installing Dottie"
echo "=========================================="
cd /home/testuser/.dottie
./update-dottie.sh
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dottie installation successful${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}✗ Dottie installation failed${NC}"
    ((FAIL_COUNT++))
    exit 1
fi

# Add dottie to PATH
export PATH="$HOME/bin:$PATH"
echo ""

echo "Step 2: Applying Dottie Configuration"
echo "=========================================="
dottie apply --force
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dottie apply successful${NC}"
    ((SUCCESS_COUNT++))
else
    echo -e "${RED}✗ Dottie apply failed${NC}"
    ((FAIL_COUNT++))
fi
echo ""

echo "Step 3: Verifying Installed Tools"
echo "=========================================="

# Core tools
check_version "Git" "git --version" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "Curl" "curl --version | head -n1" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "Wget" "wget --version | head -n1" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "htop" "htop --version" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "tree" "tree --version | head -n1" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# GitHub releases
check_version "jq" "jq --version" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "Starship" "starship --version" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "GitHub CLI" "gh --version | head -n1" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Docker
check_version "Docker" "docker --version" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "Docker Compose" "docker compose version" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Microsoft packages
check_version ".NET SDK" "dotnet --version" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "PowerShell" "pwsh --version" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_version "Azure CLI" "az --version | head -n1" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# VS Code (check if package installed, won't run in container)
check_command "VS Code" "code" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Helm
check_version "Helm" "helm version --short" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Terraform
check_version "Terraform" "terraform --version | head -n1" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

# Desktop apps (check if packages installed)
check_command "Google Chrome" "google-chrome" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_command "Spotify" "spotify" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
check_command "Typora" "typora" && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "${GREEN}Successful:${NC} $SUCCESS_COUNT"
echo -e "${RED}Failed:${NC} $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}Some tests failed. Review the output above.${NC}"
    exit 1
fi
