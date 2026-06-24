# Code Review Pipeline

This repository uses an independent review gate:

> Claude Code or another agent may implement changes, but OpenAI Codex reviews them before push or release.

The goal is not model tribalism. The goal is separation of duties. One agent writes; another agent reviews.

## Required review command

Before pushing meaningful changes, run:

```bash
scripts/codex-review.sh
```

By default this reviews staged, unstaged, and untracked changes via:

```bash
codex review --uncommitted
```

To review a branch against `main`:

```bash
scripts/codex-review.sh --base main
```

To review a specific commit:

```bash
scripts/codex-review.sh --commit <sha>
```

Review reports are written to:

```text
docs/reviews/codex-review-YYYYMMDD-HHMMSS.md
```

Commit the review report when it documents a release, behavior change, security-sensitive change, installer change, or workflow change.

## Mandatory checklist

Every update should be reviewed against this checklist:

1. One-command UX
   - `mac-update-all` remains the primary user path.
   - Specialized commands remain available but secondary.

2. macOS-only scope
   - Do not add Windows/Linux compatibility work unless the project goal changes.

3. Logging and auditability
   - CLI output shows what ran.
   - Log files show what ran, what failed, and where to inspect details.

4. Safety constraints
   - No forced macOS restart.
   - No sudo mutation of Apple-managed Python/Ruby/system tooling.
   - No blind replacement of standalone `.app` bundles.
   - No pyenv Python auto-installs without compatibility checks.

5. Privacy/security
   - No personal home paths.
   - No private emails.
   - No API keys, tokens, credentials, or secret-like strings.
   - `scripts/security-scan.sh` passes before push.

6. Installability
   - One-line curl install remains valid.
   - `install.sh` remains idempotent.
   - `~/.local/bin` symlinks remain sane.

7. Shell quality
   - Variables are quoted.
   - Failures are visible.
   - Dangerous operations are explicit.
   - Scripts pass `bash -n`.

8. Documentation parity
   - `README.md` and `README.ko.md` stay consistent for user-facing behavior.
   - `CLAUDE.md` / `AGENTS.md` stay aligned with the workflow.

## Release / push expectation

A normal change should follow this order:

```bash
bash -n bin/*.command install.sh scripts/*.sh
scripts/security-scan.sh
scripts/codex-review.sh
git status --short
git add ...
git commit -m "..."
git push
```

If Codex returns `FAIL`, do not push until the blocking issues are fixed or explicitly documented as accepted risk.
