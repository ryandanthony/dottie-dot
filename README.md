# dottie-dot

My personal dotfiles and development environment setup, managed by [dottie](https://github.com/ryandanthony/dottie).

## Overview

This repository contains my dotfiles and system configuration for KDE Neon (Ubuntu-based Linux). It uses `dottie` to manage dotfile symlinks and software installation.

## Profiles

### `minimal`

Essential CLI tools and shell configuration:

- **CLI Tools**: jq, git, gh (GitHub CLI), az (Azure CLI), helm, terraform
- **Shell**: Bash with custom aliases and [Starship](https://starship.rs) prompt
- **Fonts**: JetBrains Mono + JetBrains Mono Nerd Font
- **PowerShell**: pwsh (PowerShell Core for Linux)

### `dev`

Full development environment (extends `minimal`):

- **IDEs**: JetBrains Rider, VS Code, DataGrip
- **Containers**: Docker, Docker Compose
- **Runtimes**: .NET SDK 8, 9, and 10
- **Apps**: Google Chrome, draw.io, Typora
- **Shell**: PowerShell profile with Starship integration

### `default`

Alias for the `dev` profile.

## Quick Start

### 1. Install dottie

```bash
curl -s https://raw.githubusercontent.com/ryandanthony/dottie/main/scripts/install-linux.sh | bash
export PATH="$HOME/bin:$PATH"
```

### 2. Clone this repository

```bash
git clone https://github.com/ryandanthony/dottie-dot.git ~/.dottie
cd ~/.dottie
```

### 3. Validate the configuration

```bash
# Validate minimal profile
dottie validate

```

### 4. Apply the configuration

```bash
# For minimal setup
dottie install -p minimal
dottie link -p minimal

# For full dev setup
dottie install -p dev
dottie link -p dev
```

## What Gets Installed

### Minimal Profile

| Category | Tools                                    |
| -------- | ---------------------------------------- |
| CLI      | jq, git, curl, wget, htop, tree          |
| GitHub   | gh (GitHub CLI)                          |
| Cloud    | az (Azure CLI), terraform, helm          |
| Shell    | pwsh (PowerShell), Starship prompt       |
| Fonts    | JetBrains Mono, JetBrains Mono Nerd Font |

### Dev Profile (includes minimal)

| Category   | Tools                              |
| ---------- | ---------------------------------- |
| Containers | Docker, Docker Compose             |
| IDEs       | JetBrains Rider, VS Code, DataGrip |
| Runtimes   | .NET SDK 8, 9, 10                  |
| Apps       | Google Chrome, draw.io, Typora     |

## Dotfiles

| File                                        | Target                                                  | Description                                  |
| ------------------------------------------- | ------------------------------------------------------- | -------------------------------------------- |
| `dotfiles/.bashrc`                          | `~/.bashrc`                                             | Bash configuration with aliases and Starship |
| `dotfiles/starship.toml`                    | `~/.config/starship.toml`                               | Starship prompt configuration                |
| `dotfiles/Microsoft.PowerShell_profile.ps1` | `~/.config/powershell/Microsoft.PowerShell_profile.ps1` | PowerShell profile with Starship             |

## Shell Features

Both bash and PowerShell profiles include:

- **Starship prompt** with git, .NET, Docker, Kubernetes, Azure, and Terraform modules
- **Common aliases** for git, docker, kubectl, az, and dotnet
- **Tab completion** for kubectl, helm, gh, and az
- **Consistent experience** across bash and PowerShell

### Aliases Available

| Alias | Command                 | Description         |
| ----- | ----------------------- | ------------------- |
| `gs`  | `git status`            | Git status          |
| `ga`  | `git add`               | Git add             |
| `gc`  | `git commit`            | Git commit          |
| `gp`  | `git push`              | Git push            |
| `gl`  | `git log --oneline -10` | Git log             |
| `dc`  | `docker compose`        | Docker Compose      |
| `dps` | `docker ps`             | Docker process list |
| `k`   | `kubectl`               | Kubernetes CLI      |
| `azl` | `az login`              | Azure login         |
| `dn`  | `dotnet`                | .NET CLI            |
| `dnr` | `dotnet run`            | .NET run            |
| `dnb` | `dotnet build`          | .NET build          |
| `dnt` | `dotnet test`           | .NET test           |

## Post-Installation

After running `dottie install`, you may need to:

1. **Log out and back in** for Docker group membership to take effect
2. **Restart your terminal** to load the new shell configuration
3. **Configure your terminal** to use JetBrains Mono Nerd Font for proper Starship icons

## License

MIT License - see [LICENSE](LICENSE) for details.
