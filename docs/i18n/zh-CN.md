# mac-update-orchestrator quickstart (zh-CN)

Audience: China / Simplified Chinese

This is a short entry point. For the complete source of truth, read:

- `../../README.md`
- `../../README.ko.md`
- `../../AGENTS.md`
- `../../CONTRIBUTING.md`

## 安装

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

## 仅检查

```bash
mac-update-all --check
```

## 运行

```bash
mac-update-all
```

## 安全

此工具不会强制重启，也不会盲目替换独立安装的应用。

Important safety rules:

- no forced macOS restart
- no sudo mutation of Apple-managed system tools
- no blind replacement of standalone `.app` bundles
- logs are written to `~/Library/Logs/mac-update-orchestrator/`

## Contributing

All agents and contributors should read `../../AGENTS.md` first. Meaningful changes require documentation impact checks and independent review.
