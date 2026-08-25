---
name: dottie-test
description: "Run the Docker-based integration test suite for this dottie config repo, which builds an Ubuntu 24.04 container, installs dottie, and applies the config to verify all tools install correctly. Use when the user asks to test dottie changes before pushing/using them, or wants to verify dottie.yaml in a clean environment."
---

# /dottie-test

Runs the local Docker-based test harness for `~/.dottie`: builds an Ubuntu 24.04 image, installs `dottie`, runs `dottie apply`, and verifies tool versions.

## Usage

```bash
cd ~/.dottie
docker build -t dottie-test .
docker run --rm dottie-test
```

Or on Windows/PowerShell:

```powershell
./run-integration.ps1          # normal build
./run-integration.ps1 -NoCache # force a clean rebuild
```

## What it does (see `TEST-README.md`)

1. Installs dottie via `update-dottie.sh` inside the container
2. Runs `dottie apply` against this repo's config
3. Verifies versions of installed tools: git/curl/wget/htop/tree, jq/starship/gh, Docker + Compose, .NET/PowerShell/Azure CLI, VS Code, Helm, Terraform, etc.

## Steps

1. Confirm Docker is available: `docker version`
2. `cd ~/.dottie && docker build -t dottie-test .`
3. `docker run --rm dottie-test`
4. Report pass/fail per tool from the script output. On failure, cross-reference the failing entry in `dottie.yaml` (wrong asset pattern, wrong `${ARCH}`/`${MS_ARCH}`, stale pinned `version`) and propose a fix.
5. Re-run the container after any `dottie.yaml` fix to confirm.

## Related

- `/dottie-validate` — fast config check without spinning up Docker
- `/dottie-apply` — what the container runs internally
