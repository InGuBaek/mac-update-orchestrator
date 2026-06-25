# mac-update-orchestrator quickstart (ja-JP)

Audience: Japan / Japanese

This is a short entry point. For the complete source of truth, read:

- `../../README.md`
- `../../README.ko.md`
- `../../AGENTS.md`
- `../../CONTRIBUTING.md`

## インストール

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

## 確認のみ

```bash
mac-update-all --check
```

## 実行

```bash
mac-update-all
```

## 安全性

このツールは強制再起動を行わず、単体アプリを勝手に置き換えません。

Important safety rules:

- no forced macOS restart
- no sudo mutation of Apple-managed system tools
- no blind replacement of standalone `.app` bundles
- logs are written to `~/Library/Logs/mac-update-orchestrator/`

## Contributing

All agents and contributors should read `../../AGENTS.md` first. Meaningful changes require documentation impact checks and independent review.
