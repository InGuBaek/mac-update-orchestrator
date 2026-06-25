# mac-update-orchestrator quickstart (ko-KR)

Audience: South Korea / Korean

This is a short entry point. For the complete source of truth, read:

- `../../README.md`
- `../../README.ko.md`
- `../../AGENTS.md`
- `../../CONTRIBUTING.md`

## 설치

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

## 확인만

```bash
mac-update-all --check
```

## 실행

```bash
mac-update-all
```

## 안전

이 도구는 강제 재시작을 하지 않고 standalone 앱을 임의로 교체하지 않습니다.

Important safety rules:

- no forced macOS restart
- no sudo mutation of Apple-managed system tools
- no blind replacement of standalone `.app` bundles
- logs are written to `~/Library/Logs/mac-update-orchestrator/`

## Contributing

All agents and contributors should read `../../AGENTS.md` first. Meaningful changes require documentation impact checks and independent review.
