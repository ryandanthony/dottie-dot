---
name: dottie-install
description: "Install software packages (apt, aptRepos, github releases, snaps, fonts, scripts) for a dottie profile in this repo. Use when the user asks to install packages, set up a new machine, upgrade managed tools, or provision software from dottie.yaml."
---

# /dottie-install

Installs software from a profile's `install:` block: GitHub-release binaries → APT packages → APT repos → scripts → fonts → snaps, in that order.

## Usage

```bash
dottie install -p <profile>            # install using a profile (default: "default")
dottie install -p <profile> --dry-run  # preview without making changes
```

## Available profiles in this repo

- `minimal` — CLI tools (git, curl, jq, gh, starship, copilot-cli), fonts, GitHub CLI repo
- `desktop` — extends `minimal`, adds KDE apps, VM tooling (QEMU/libvirt), Chrome, Spotify, Typora, Insync, Joplin, Obsidian
- `dev` — extends `desktop`, adds Docker, .NET, Kubernetes tooling, Azure CLI, Terraform, Helm, JetBrains, VS Code extensions
- `alt-dev` — extends `dev`, adds Rust and Go toolchains
- `default` — alias for `dev`

## Steps

1. `cd ~/.dottie`
2. Preview first: `dottie install -p <profile> --dry-run`, and show the summary (succeeded/skipped/would-install/would-upgrade counts).
3. Confirm with the user before running for real if this touches `sudo`-gated APT/repo installs on a machine they didn't explicitly ask to provision.
4. Run for real: `dottie install -p <profile>`
5. Report the install summary. If anything failed, show the `Failed Installations` section verbatim and diagnose (common causes: asset filename pattern changed upstream, wrong `${ARCH}`/`${MS_ARCH}` variable, pinned `version` no longer exists).

## Notes on behavior

- Re-running `install` is safe: already-installed APT packages are skipped, GitHub-release binaries and snaps are upgraded when newer versions are available (unless pinned via `version:`).
- Binaries from `install.github` land in `~/bin/` — make sure that's on `PATH`.
- Scripts run from the repo root and must live inside `~/.dottie` (no external scripts allowed).

## Related

- `/dottie-validate` — check config before installing
- `/dottie-link` — symlink dotfiles (no software changes)
- `/dottie-apply` — link + install together
- `/dottie-update-cli` — update the `dottie` binary itself
