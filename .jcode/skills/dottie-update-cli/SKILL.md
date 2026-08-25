---
name: dottie-update-cli
description: "Update the dottie CLI binary itself to the latest release (not the dottie.yaml config). Use when the user asks to update/upgrade dottie, or when a command fails due to an old dottie version."
---

# /dottie-update-cli

Updates the `dottie` binary (installed to `~/bin`) to the latest release. This is separate from `dottie install`, which manages *other* software from `dottie.yaml`.

## Usage

```bash
~/.dottie/update-dottie.sh
```

Which runs:

```bash
curl -s https://raw.githubusercontent.com/ryandanthony/dottie/main/scripts/install-linux.sh | bash
```

## Steps

1. Check current version: `dottie --version`
2. Run `~/.dottie/update-dottie.sh` (or the raw curl command above).
3. Verify: `dottie --version` again, confirm it changed / is current.
4. If `~/bin` isn't on `PATH`, tell the user to add `export PATH="$HOME/bin:$PATH"` to their shell profile.

## Related

- `/dottie-validate` — sanity-check config still validates after an update
- Repo docs: https://github.com/ryandanthony/dottie/tree/main/docs
