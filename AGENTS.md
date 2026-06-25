# AGENTS.md

This is the canonical operating guide for all agents and automation working in this repository.

Read this first whether you are Claude Code, OpenAI Codex, OpenCode, Hermes, OpenClaw, Copilot, a CI harness, or another agentic coding tool. Tool-specific files such as `CLAUDE.md` must stay thin and defer to this file.

## Project mission

`mac-update-orchestrator` is a macOS-only update orchestrator.

The user-facing goal is simple:

> One command, `mac-update-all`, should update as much as possible on a MacBook and leave a clear CLI + log-file audit trail of what ran, what changed, and what failed.

Windows and Linux support are intentionally out of scope.

## Public repository priorities

This repository is public and should be safe for broad agent contribution.

Priorities, in order:

1. Preserve user trust and machine safety.
2. Keep `mac-update-all` as the primary one-command UX.
3. Make every update auditable through terminal output and log files.
4. Keep install and contribution paths simple for public users.
5. Require independent review before changes enter `main`.
6. Avoid leaking local paths, private emails, tokens, API keys, or credentials.

## Architecture

- `bin/mac-update-all.command`
  - Main one-command entry point.
  - Runs software updates first, then the macOS system update flow.
- `bin/software-update.command`
  - Frequent software updates: Homebrew, App Store, Node/npm/nvm/bun/corepack, Python/uv/pipx/pip user packages, and AI/dev CLIs.
- `bin/system-update.command`
  - macOS `softwareupdate` only.
- `bin/update-everything.command`
  - Compatibility wrapper.
- `install.sh`
  - Installs symlinks into `~/.local/bin`.
- `scripts/security-scan.sh`
  - Scans tracked, untracked, and historical content for obvious personal paths and secrets.
- `scripts/codex-review.sh`
  - Runs the mandatory general OpenAI Codex review gate.
- `scripts/doc-impact-check.sh`
  - Fails when behavior/workflow files change without matching documentation updates.
- `scripts/e2e-check.sh`
  - Runs non-mutating end-to-end smoke checks.
- `tests/`
  - Local shell tests for governance and smoke checks.
- `docs/code-review.md`
  - Review process and checklist.
- `docs/improvements.md`
  - Design evolution and future improvements.
- `docs/research-and-roadmap.md`
  - Comparable project research and AI-era development plan.
- `docs/i18n/`
  - Localized quickstart entry points for major GitHub/developer audiences.
- `docs/reviews/`
  - Codex review reports for release, installer, security-sensitive, or workflow changes.
- `.github/CODEOWNERS`
  - Maintainer ownership for protected branch review.
- `.github/workflows/checks.yml`
  - Public CI checks that can run without private credentials.

## Safety constraints

Do not add behavior that:

- forces macOS restart with `softwareupdate --restart`
- uses `sudo` to mutate Apple-managed system tooling such as `/usr/bin/python3` or `/usr/bin/gem`
- blindly replaces standalone `.app` bundles installed through `.dmg` / `.pkg`
- automatically installs new pyenv Python versions without project compatibility checks
- hides update failures
- removes logging or makes failures silent

Prefer package-manager-owned update paths:

- Homebrew
- Mac App Store / `mas`
- npm / nvm / corepack / bun
- uv / pipx / Python user packages
- individual CLI self-updaters when they exist

## Privacy and secret handling

Never commit:

- personal home directories, for example OS-specific absolute home paths
- private emails
- API keys
- OAuth tokens
- credentials
- private keys
- secret-like strings
- generated logs that contain local environment details

Before public push, run:

```bash
scripts/security-scan.sh
```

If a suspicious value exists in git history, fixing only the current file is not enough. Rewrite history before pushing.

## Required local checks

Run these before committing meaningful changes:

```bash
bash -n bin/*.command install.sh scripts/*.sh
scripts/security-scan.sh
scripts/doc-impact-check.sh
tests/run.sh
```

For behavior changes, also run:

```bash
bin/software-update.command --check
bin/system-update.command --check
mac-update-all --check --no-install-helpers
./install.sh
mac-update-all --help
```

Do not run full update commands in CI. Full updates mutate the host machine and belong to local/manual execution.

## Independent review gate

Implementation may be done by Claude Code, OpenCode, Hermes, OpenClaw, Codex, or another agent.

Meaningful changes must be reviewed independently by OpenAI Codex before push or release:

```bash
scripts/codex-review.sh
```

If Codex returns `FAIL`, do not push until blocking issues are fixed or explicitly documented as accepted risk.

The review checklist lives in `docs/code-review.md`. Update it whenever the review criteria change. `README.md` and `README.ko.md` must mention review workflow changes that affect contributors.

## Documentation impact check

When code, CLI behavior, installer behavior, CI, or workflow rules change, update the relevant docs in the same branch.

Run:

```bash
scripts/doc-impact-check.sh
```

This is a mechanical drift guard, not a replacement for maintainer judgement. Keep review infrastructure lightweight so it does not distract from the updater itself.

## GitHub workflow

`main` is protected.

Expected contribution path:

1. Create a branch.
2. Make a focused change.
3. Run local checks.
4. Run `scripts/codex-review.sh` for meaningful changes.
5. Commit in logical units.
6. Open a pull request.
7. Include the Codex review summary or report path in the PR.
8. Wait for required maintainer approval and CI.
9. Merge only after branch protection passes.

Direct pushes to `main` are not the normal workflow after branch protection is enabled.

## Documentation policy

- `README.md` is English and is the default public README.
- `README.ko.md` is Korean and must link back to `README.md`.
- `docs/i18n/` contains short localized quickstarts for major GitHub/developer audiences. These are entry points, not replacements for canonical docs.
- `CLAUDE.md` is intentionally thin and points Claude Code to this file.
- Keep public-facing behavior documented in both READMEs.
- Keep implementation/review rules in this file and `docs/code-review.md`.

## Commit discipline

Use small, logical commits:

1. Scripts / behavior
2. Installer
3. Docs
4. Workflow / CI
5. Verification or cleanup

Commit messages should be concise and descriptive.

## Agent-specific notes

- Claude Code: read `CLAUDE.md`, then follow this file.
- Codex: use this file plus `docs/code-review.md` for review context.
- Hermes/OpenCode/OpenClaw/other agents: treat this file as the source of truth.
- CI/harnesses: run only non-mutating checks unless explicitly configured otherwise.
