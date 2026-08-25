---
name: dottie-status
description: "Check the current state of dottie-managed dotfiles and installed software in this repo (which symlinks/packages are applied vs missing). Use when the user asks what's installed, what's linked, or wants a pre-flight check before running link/install."
---

# /dottie-status

Shows current dotfile link state and software install state for a profile, so the user can see what's already applied vs what `link`/`install` would still need to do.

## Usage

```bash
dottie status -p <profile>
```

## Steps

1. `cd ~/.dottie`
2. Run `dottie status -p <profile>` (default profile if unspecified).
3. Summarize: which dotfiles are linked / not linked / linked to the wrong target, and which software entries are installed / missing.
4. If something is missing or wrong, point the user at `/dottie-link` or `/dottie-install` to fix it rather than fixing it silently.

## Note

This command is under active development upstream (dottie repo). If `dottie status` errors or behaves unexpectedly, fall back to:

```bash
dottie validate -p <profile>           # check the config itself
dottie link -p <profile> --dry-run     # see pending dotfile changes
dottie install -p <profile> --dry-run  # see pending software changes
```

## Related

- `/dottie-validate` — validate config correctness
- `/dottie-link`, `/dottie-install` — apply what's missing
