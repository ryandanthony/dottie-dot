---
name: dottie-link
description: "Create/refresh dotfile symlinks for a dottie profile in this repo, with dry-run preview and conflict handling. Use when the user asks to link dotfiles, symlink configs, or apply dotfile changes without installing software."
---

# /dottie-link

Creates symbolic links from `~/.dottie/dotfiles/...` to their target locations (e.g. `~/.bashrc`) for a given profile.

## Usage

```bash
dottie link -p <profile>            # link using a profile (default: "default")
dottie link -p <profile> --dry-run  # preview only, no changes
dottie link -p <profile> --force    # backup conflicting files (.bak) and overwrite
```

`--dry-run` and `--force` are mutually exclusive.

## Steps

1. `cd ~/.dottie`
2. Always preview first: `dottie link -p <profile> --dry-run`
3. Show the user what would be created/skipped.
4. If there are conflicts (existing real files/wrong symlinks) and the user wants to proceed, re-run with `--force` to back up (`.bak`) and overwrite. Do not use `--force` silently — conflicts mean real files could be overwritten; confirm with the user first unless they already asked for `--force`.
5. Run the real link: `dottie link -p <profile>`
6. Report what was created vs skipped (already-linked files are skipped safely).

## Conflict behavior

| Scenario | Default | With `--force` |
|---|---|---|
| Regular file exists at target | Error, stop | Backup to `.bak`, then link |
| Wrong symlink exists | Error, stop | Remove, then link |
| Correct symlink already exists | Skip | Skip |

## Related

- `/dottie-validate` — check config before linking
- `/dottie-install` — install software (no dotfile changes)
- `/dottie-apply` — link + install together
