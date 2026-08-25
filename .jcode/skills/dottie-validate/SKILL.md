---
name: dottie-validate
description: "Validate the dottie.yaml configuration in this repo for a given profile (or list available profiles). Use when the user asks to check, lint, or validate dottie config, or before linking/installing a profile for the first time."
---

# /dottie-validate

Validates `dottie.yaml` in this repo (`~/.dottie`) for a profile: YAML syntax, required fields, source file existence, and profile inheritance chains (no circular `extends`).

## Usage

```bash
dottie validate <profile>          # validate one profile
dottie validate                    # list available profiles
dottie validate <profile> -c <path>  # validate a config at a custom path
```

## Available profiles in this repo

- `minimal` — base shell + CLI tools
- `desktop` — extends `minimal`, adds KDE/desktop apps
- `dev` — extends `desktop`, adds full dev tooling (Docker, k8s, .NET, etc)
- `alt-dev` — extends `dev`, adds Rust/Go toolchains
- `default` — alias for `dev`

## Steps

1. `cd ~/.dottie`
2. Run `dottie validate <profile>` for the profile the user cares about (default to `default` if unspecified, or run bare `dottie validate` to enumerate profiles).
3. Report the pass/fail summary. On failure, show the specific line/field errors dottie prints and propose the fix directly in `dottie.yaml`.
4. After editing `dottie.yaml`, always re-run `dottie validate <profile>` to confirm the fix before telling the user it's done.

## Related

- `/dottie-link` — apply dotfile symlinks after validating
- `/dottie-install` — install software after validating
- `/dottie-apply` — do both link + install in one step
