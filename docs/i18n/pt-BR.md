# mac-update-orchestrator quickstart (pt-BR)

Audience: Brazil / Brazilian Portuguese

This is a short entry point. For the complete source of truth, read:

- `../../README.md`
- `../../README.ko.md`
- `../../AGENTS.md`
- `../../CONTRIBUTING.md`

## Instalar

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

## Apenas verificar

```bash
mac-update-all --check
```

## Executar

```bash
mac-update-all
```

## Segurança

Esta ferramenta não força reinicialização e não substitui apps independentes sem controle explícito.

Important safety rules:

- no forced macOS restart
- no sudo mutation of Apple-managed system tools
- no blind replacement of standalone `.app` bundles
- logs are written to `~/Library/Logs/mac-update-orchestrator/`

## Contributing

All agents and contributors should read `../../AGENTS.md` first. Meaningful changes require documentation impact checks and independent review.
