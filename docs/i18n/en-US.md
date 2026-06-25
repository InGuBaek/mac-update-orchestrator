# mac-update-orchestrator quickstart (en-US)

Audience: United States / English

This is a short entry point. For the complete source of truth, read:

- `../../README.md`
- `../../README.ko.md`
- `../../AGENTS.md`
- `../../CONTRIBUTING.md`

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

## Check only

```bash
mac-update-all --check
```

## Run

```bash
mac-update-all
```

## Safety

This tool does not force restart and does not replace standalone apps blindly.

Important safety rules:

- no forced macOS restart
- no sudo mutation of Apple-managed system tools
- no blind replacement of standalone `.app` bundles
- logs are written to `~/Library/Logs/mac-update-orchestrator/`

## Contributing

All agents and contributors should read `../../AGENTS.md` first. Meaningful changes require documentation impact checks and independent review.
