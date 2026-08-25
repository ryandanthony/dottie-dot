---
name: dottie-apply
description: "Run dottie's full apply (validate + link + install) for a profile in this repo in one step. Use when the user wants to fully provision or update a machine from dottie.yaml without running each command separately."
---

# /dottie-apply

Combines `link` and `install` into one operation for a profile: creates all dotfile symlinks, then installs/upgrades all configured software.

## Usage

```bash
dottie apply -p <profile>            # apply a profile (default: "default")
dottie apply -p <profile> --dry-run  # preview everything, no changes
dottie apply -p <profile> --force    # back up conflicting dotfiles and overwrite
```

`--dry-run` and `--force` are mutually exclusive.

## Steps

1. `cd ~/.dottie`
2. `dottie validate -p <profile>` — confirm the config is valid first.
3. `dottie apply -p <profile> --dry-run` — preview the full set of dotfile + software changes.
4. Review with the user, especially any file conflicts or destructive-looking installs (aptRepos, VM/libvirt setup, Docker group changes).
5. Run for real: `dottie apply -p <profile>` (add `--force` only if conflicts were reviewed and approved).
6. Report the combined link + install summary, and any post-install steps (e.g. log out/in for Docker group, restart terminal for shell config, set terminal font to a Nerd Font).

## Equivalent manual steps

```bash
dottie validate -p <profile>
dottie link -p <profile>
dottie install -p <profile>
```

## Related

- `/dottie-validate`, `/dottie-link`, `/dottie-install` — run phases individually
- `/dottie-status` — check current state before/after
