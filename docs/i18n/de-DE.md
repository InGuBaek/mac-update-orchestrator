# mac-update-orchestrator quickstart (de-DE)

Audience: Germany / German

This is a short entry point. For the complete source of truth, read:

- `../../README.md`
- `../../README.ko.md`
- `../../AGENTS.md`
- `../../CONTRIBUTING.md`

## Installieren

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

## Nur prüfen

```bash
mac-update-all --check
```

## Ausführen

```bash
mac-update-all
```

## Sicherheit

Dieses Tool erzwingt keinen Neustart und ersetzt keine eigenständigen Apps blind.

Important safety rules:

- no forced macOS restart
- no sudo mutation of Apple-managed system tools
- no blind replacement of standalone `.app` bundles
- logs are written to `~/Library/Logs/mac-update-orchestrator/`

## Contributing

All agents and contributors should read `../../AGENTS.md` first. Meaningful changes require documentation impact checks and independent review.
