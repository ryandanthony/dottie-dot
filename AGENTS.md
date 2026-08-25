# AGENTS.md — dottie config repo (`~/.dottie`)

This repo is **not** the dottie CLI source (that's `ryandanthony/dottie` on
GitHub, docs at https://github.com/ryandanthony/dottie/tree/main/docs). This
repo is Ryan's personal `dottie.yaml` configuration plus the dotfiles and
scripts it references — the input consumed by the `dottie` CLI to set up this
machine (KDE Neon / Ubuntu-based).

## What's here

- `dottie.yaml` — the single config file: profiles (`minimal` → `desktop` →
  `dev` → `alt-dev`, plus `default` = alias for `dev`), each with `dotfiles:`
  (symlink mappings) and `install:` (apt/aptRepos/github/scripts/fonts/snaps).
- `dotfiles/` — actual dotfile contents that get symlinked into `$HOME`
  (`.bashrc`, `starship.toml`, KDE config, VS Code settings, etc).
- `scripts/` — install/setup scripts referenced from `install.scripts` in
  `dottie.yaml`. Must stay inside this repo (dottie forbids external script
  paths).
- `virt/` — VM management helpers, unrelated to dottie itself.
- `update-dottie.sh` — reinstalls/updates the `dottie` CLI binary.
- `Dockerfile`, `test-setup.sh`, `run-integration.ps1`, `TEST-README.md` —
  Docker-based integration test harness that applies this config on a clean
  Ubuntu 24.04 container.

## Skills

Local skills live in `.jcode/skills/*/SKILL.md` and cover the standard
workflow. Prefer these over ad hoc shell commands:

- `/dottie-validate` — validate `dottie.yaml` for a profile
- `/dottie-link` — create/refresh dotfile symlinks (dry-run + force support)
- `/dottie-install` — install software from a profile's `install:` block
- `/dottie-status` — check current link/install state
- `/dottie-apply` — validate + link + install in one step
- `/dottie-update-cli` — update the `dottie` binary itself
- `/dottie-test` — run the Docker integration test suite

## Working conventions

1. **Always validate after editing `dottie.yaml`**: `dottie validate <profile>`.
   Never hand-edit and assume it's correct — inheritance, variable
   substitution (`${ARCH}`, `${MS_ARCH}`, `${ID}`, `${VERSION_CODENAME}`,
   deferred `${RELEASE_VERSION}` / `${SIGNING_FILE}`), and required fields are
   easy to get wrong.
2. **Dry-run before applying** on this or any real machine:
   `dottie link --dry-run`, `dottie install --dry-run`, `dottie apply --dry-run`.
3. **Profile inheritance is additive and single-parent.** Child `dotfiles`
   and `install` entries merge with the parent; same-target entries in the
   child win. Only one `extends:` per profile, no circular chains.
4. **New dotfiles**: add the file under `dotfiles/`, then add a
   `source`/`target` entry to the right profile in `dottie.yaml`. Prefer
   adding to the most specific profile that needs it, not `default`, unless
   it's genuinely universal.
5. **New packages**: prefer `apt` for anything in the Ubuntu repos; use
   `github` for binaries not packaged for apt (set `binary:` and an
   architecture-aware `asset:` pattern using `${ARCH}`/`${MS_ARCH}`); use
   `aptRepos` for third-party apt sources (Docker, VS Code, GitHub CLI, etc);
   use `scripts` only when nothing else fits, and only for logic dottie can't
   express declaratively (see `scripts/install-jcode.sh` for why: the release
   asset name can't be mapped to a fixed `binary:` name).
6. **Never commit secrets** into `dottie.yaml`, scripts, or dotfiles here —
   this repo mirrors what's public/synced.
7. Before telling the user a change is done, run `/dottie-validate` on the
   affected profile at minimum; run `/dottie-test` for anything touching
   install ordering, new apt repos, or GitHub release asset patterns.

## Reference

- Full docs: https://github.com/ryandanthony/dottie/tree/main/docs
  - Commands: `validate`, `link`, `install`, `status` (in dev), `apply`
  - Configuration: `overview`, `profiles`, `dotfiles`, `install-blocks`, `variables`
  - Guides: `apt-repos`, `fonts`, `github-releases`, `profile-inheritance`, `scripts`
- CLI help is also authoritative and may be ahead of docs: `dottie --help`,
  `dottie <command> --help`.
