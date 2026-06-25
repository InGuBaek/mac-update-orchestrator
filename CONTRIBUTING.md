# Contributing

Thanks for contributing. This project is intentionally public-agent friendly: Claude Code, OpenAI Codex, OpenCode, Hermes, OpenClaw, Copilot, and other automation can all contribute as long as they follow the same rules.

Read `AGENTS.md` first. It is the canonical operating guide.

## Normal workflow

1. Create a branch from `main`.
2. Make a focused change.
3. Run local checks:

```bash
bash -n bin/*.command install.sh scripts/*.sh tests/*.sh
scripts/security-scan.sh
scripts/doc-impact-check.sh
tests/run.sh
```

4. For meaningful behavior, installer, security, workflow, or documentation changes, run:

```bash
scripts/codex-review.sh
```

5. Commit in logical units.
6. Open a pull request.
7. Fill out the PR template, including the Codex review report path or summary when applicable.
8. Wait for CI and maintainer approval.

## Required review model

One agent may implement, but OpenAI Codex reviews meaningful changes before push or release.

This separation is intentional. It catches mistakes from the implementing agent and creates a stable review habit for public contributions.

## Main branch

`main` is protected. Do not expect direct pushes to work. Changes should enter through pull requests with required maintainer approval.

## Do not commit secrets or personal paths

Do not commit:

- local home directories
- private emails
- API keys
- tokens
- credentials
- generated logs with local environment details

Run:

```bash
scripts/security-scan.sh
```

If a leak appears in git history, rewrite history before pushing.
