# mac-update-orchestrator

[한국어](README.ko.md)

A macOS-only update orchestrator that runs as many updates as possible with one command and shows what happened in both the CLI and timestamped log files.

Windows is intentionally out of scope. This project targets local macOS development machines.

## Why this exists

macOS updates are scattered across too many channels:

- System Settings / `softwareupdate`
- Mac App Store
- Homebrew formulae and casks
- npm global packages / nvm
- bun global packages
- uv tools
- pipx
- Python user packages
- individual CLI self-updaters: Claude Code, Hermes, OpenCode, and others
- standalone `.dmg` / `.pkg` GUI apps: LM Studio, Ollama, and others

`mac-update-all` walks those paths, runs the updates it can safely run, and leaves an audit trail in the terminal and log files.

## Install

### One-line install

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

### Install from GitHub manually

```bash
git clone https://github.com/InGuBaek/mac-update-orchestrator.git
cd mac-update-orchestrator
./install.sh
```

Installed commands:

```bash
mac-update-all
mac-software-update
mac-system-update
mac-update-everything
```

If `~/.local/bin` is not in your `PATH`, add it to your shell profile:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Run from a local checkout

```bash
chmod +x bin/*.command install.sh
bin/mac-update-all.command --help
```

## Main commands

Run the full update flow:

```bash
mac-update-all
```

Check everything without updating:

```bash
mac-update-all --check
```

Answer yes where possible:

```bash
mac-update-all --yes
```

Also pull all installed Ollama models:

```bash
mac-update-all --ollama-models
```

Also run Homebrew cleanup:

```bash
mac-update-all --cleanup
```

Run software updates, but only check macOS system updates:

```bash
mac-update-all --system-check
```

Skip macOS system updates entirely and only run software updates:

```bash
mac-update-all --skip-system
```

## Logs

Default log directory:

```text
~/Library/Logs/mac-update-orchestrator/
```

Each run creates timestamped log files:

- `mac-update-all-YYYYMMDD-HHMMSS.log`
- `software-update-YYYYMMDD-HHMMSS.log`
- `system-update-YYYYMMDD-HHMMSS.log`

To override the log directory:

```bash
MAC_UPDATE_LOG_DIR="$HOME/Desktop/update-logs" mac-update-all
```

## Command layout

### `mac-update-all`

The main one-command entry point.

Default flow:

1. Run daily software updates.
2. Run the macOS system update flow.
3. Print each step to the CLI and log files.

It does not force a restart. If macOS or a CLI needs approval, the running command asks for it normally.

### `mac-software-update`

Runs the frequent software update path only.

```bash
mac-software-update --check
mac-software-update --update --install-helpers
```

Coverage:

- Homebrew
  - `brew update`
  - `brew upgrade --greedy`
  - optional `brew cleanup`
- Mac App Store
  - `mas outdated`
  - `mas upgrade`
  - `--install-helpers` can install `mas` with Homebrew if missing
- Node ecosystem
  - detects nvm
  - installs the latest LTS and latest npm
  - updates installed Node major lines to their latest patch versions
  - updates npm global packages
  - updates npm/corepack
  - activates latest pnpm and stable yarn through corepack
  - updates bun and bun global packages
- Python ecosystem
  - Homebrew Python is handled by Homebrew
  - upgrades uv tools
  - upgrades pipx packages
  - checks and upgrades Python user packages
  - upgrades pip/setuptools/wheel in the user site
  - detects and updates pyenv itself
- AI/dev CLIs
  - Claude Code: `claude update`
  - Hermes: `hermes update --yes`
  - OpenCode: `opencode upgrade`
  - Codex: handled by Homebrew when installed as a Homebrew package
  - Pi: handled by `npm update -g` when installed as an npm global package
  - Ollama: detects CLI/app; model pulling is opt-in with `--ollama-models`

### `mac-system-update`

Dedicated macOS system update command.

```bash
mac-system-update --check
mac-system-update --download
mac-system-update --install
```

It uses:

- `softwareupdate -l`
- `softwareupdate --download --all`
- `softwareupdate --install --all`

It does not use a forced restart flag.

## Safety policy

The tool automates aggressively, but it should not trash a development machine.

It does not:

- force restarts with `softwareupdate --restart`
- use `sudo` to mutate Apple-managed system tools like `/usr/bin/python3` or `/usr/bin/gem`
- replace standalone GUI app bundles installed via `.dmg` / `.pkg`
- automatically install new pyenv Python versions without project compatibility checks

It does:

- update package-manager-owned software through Homebrew, App Store, npm, pipx, uv, bun, and similar managers
- detect standalone apps and log them
- let macOS or the relevant CLI ask for permission during execution when needed

## Development

Syntax check:

```bash
bash -n bin/*.command install.sh
```

Privacy/security scan for personal paths, API keys, and tokens:

```bash
scripts/security-scan.sh
```

This scan must pass before public pushes. If a value is found in git history, fixing the current file is not enough; rewrite the history before pushing.

Independent Codex review gate:

```bash
scripts/codex-review.sh
```

Project rule: Claude Code or another agent may implement changes, but OpenAI Codex must review meaningful updates before push or release. Review reports are written under `docs/reviews/`. The review checklist is maintained in [`docs/code-review.md`](docs/code-review.md) and should be updated whenever the review criteria change.

Contribution workflow:

- Read [`AGENTS.md`](AGENTS.md) first. It is the canonical guide for Claude Code, Codex, OpenCode, Hermes, OpenClaw, and other agents.
- Use pull requests for changes to `main`.
- `main` is protected with required maintainer approval and CI checks.
- See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the public contribution flow.

Check runs:

```bash
bin/software-update.command --check
bin/system-update.command --check
```

Install test:

```bash
./install.sh
mac-update-all --help
```

## License

MIT
