# Project Status

Last updated: 2026-06-25

## Current direction

This repository is being structured as a public, multi-agent-friendly macOS update orchestrator.

Core decisions:

- `AGENTS.md` is the canonical operating guide for all agents and automation.
- `CLAUDE.md` is intentionally thin and points Claude Code to `AGENTS.md`.
- Claude Code, OpenAI Codex, OpenCode, Hermes, OpenClaw, Copilot, CI harnesses, and other agents should all be able to contribute through the same public rules.
- `mac-update-all` remains the primary one-command UX.
- Meaningful changes require independent Codex review before push or release, unless quota constraints are explicitly recorded and review is deferred.
- `main` is intended to be protected by GitHub branch protection: PR required, maintainer/code-owner approval required, CI required, no force push.

## Key files

- `AGENTS.md`: canonical agent guide
- `CLAUDE.md`: thin Claude Code pointer to `AGENTS.md`
- `CONTRIBUTING.md`: public contributor workflow
- `docs/code-review.md`: Codex review checklist and process
- `.github/CODEOWNERS`: maintainer review ownership
- `.github/pull_request_template.md`: PR checklist
- `.github/workflows/checks.yml`: public CI checks

## Local verification commands

```bash
bash -n bin/*.command install.sh scripts/*.sh
scripts/security-scan.sh
scripts/codex-review.sh
```

Due to current Codex quota constraints, prefer `claude -p` for additional review/work and preserve Codex for mandatory review gates or after quota refresh.
