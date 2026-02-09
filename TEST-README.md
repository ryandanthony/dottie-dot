# Dottie Test Setup

This directory contains Docker-based testing infrastructure for the dottie configuration.

## Files

- **Dockerfile** - Ubuntu 24.04 based image that installs dottie
- **test-setup.sh** - Main test script that installs packages and verifies versions
- **run-integration.ps1** - PowerShell script to build and run the test container

## Usage

### Run the full test suite:

```powershell
.\run-integration.ps1
```

Or manually:

```bash
# Build the image
docker build -t dottie-test .

# Run the tests
docker run --rm dottie-test
```

## What it tests

1. Installs dottie using `update-dottie.sh`
2. Applies the dottie configuration (`dottie apply`)
3. Verifies installation of all tools by checking versions:
   - Core utilities (git, curl, wget, htop, tree)
   - GitHub releases (jq, starship, gh)
   - Docker and Docker Compose
   - Microsoft packages (.NET, PowerShell, Azure CLI)
   - VS Code
   - Helm
   - Terraform
   - Desktop apps (Chrome, Spotify, Typora)

## Output

The test script reports:
- ✓ Success for each installed tool
- ✗ Failure for missing tools
- Final summary with success/fail counts
