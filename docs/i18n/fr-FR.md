# mac-update-orchestrator quickstart (fr-FR)

Audience: France / French

This is a short entry point. For the complete source of truth, read:

- `../../README.md`
- `../../README.ko.md`
- `../../AGENTS.md`
- `../../CONTRIBUTING.md`

## Installer

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

## Vérifier seulement

```bash
mac-update-all --check
```

## Exécuter

```bash
mac-update-all
```

## Sécurité

Cet outil ne force pas le redémarrage et ne remplace pas aveuglément les applications autonomes.

Important safety rules:

- no forced macOS restart
- no sudo mutation of Apple-managed system tools
- no blind replacement of standalone `.app` bundles
- logs are written to `~/Library/Logs/mac-update-orchestrator/`

## Contributing

All agents and contributors should read `../../AGENTS.md` first. Meaningful changes require documentation impact checks and independent review.
