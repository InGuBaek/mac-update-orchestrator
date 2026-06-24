# CLAUDE.md

This project is a macOS-only update orchestrator.

## Mission

Provide one command, `mac-update-all`, that updates as much as possible on a MacBook and writes clear CLI output plus timestamped log files.

Primary user need: software updates are scattered across App Store, Homebrew, npm/nvm, bun, uv, pipx, Python user packages, and individual AI/dev CLIs. The tool should collapse that into one command while staying safe.

## Commands

```bash
bash -n bin/*.command install.sh
scripts/security-scan.sh
bin/software-update.command --check
bin/system-update.command --check
./install.sh
mac-update-all --help
```

## Architecture

- `bin/mac-update-all.command`
  - Main one-command entry point.
  - Runs software updates first, then system update flow.
- `bin/software-update.command`
  - Daily SW updates: Homebrew, App Store, Node/npm/nvm/bun/corepack, Python/uv/pipx/pip user packages, AI/dev CLIs.
- `bin/system-update.command`
  - macOS `softwareupdate` only.
- `bin/update-everything.command`
  - Compatibility wrapper.
- `install.sh`
  - Installs symlinks into `~/.local/bin`.

## Safety constraints

Do not add behavior that:

- Forces macOS restart with `softwareupdate --restart`.
- Uses `sudo` to mutate `/usr/bin/python3`, `/usr/bin/gem`, or other Apple-managed system tooling.
- Replaces standalone `.app` bundles downloaded via `.dmg`/`.pkg` without explicit user control.
- Installs new pyenv Python versions automatically without compatibility checks.
- Hides update failures. Continue where reasonable, but print and log failures.

## Privacy/security gate

Never commit personal home directories, account names, private emails, API keys, tokens, credentials, or secret-like strings. Before any public push, run:

```bash
scripts/security-scan.sh
```

If a suspicious value is found in git history, fixing the current file is not enough. Rewrite the public history before pushing.

## Output requirements

Every run should make it obvious:

- What manager/tool was checked.
- What command ran.
- What failed.
- Where the logs are.

Default log directory:

```text
~/Library/Logs/mac-update-orchestrator/
```

## Commit discipline

Commit changes in logical units:

1. Scripts / behavior
2. Installer
3. Docs
4. Verification or cleanup

Use concise commit messages.
