# mac-update-orchestrator quickstart (hi-IN)

Audience: India / Hindi

This is a short entry point. For the complete source of truth, read:

- `../../README.md`
- `../../README.ko.md`
- `../../AGENTS.md`
- `../../CONTRIBUTING.md`

## इंस्टॉल करें

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

## सिर्फ जाँचें

```bash
mac-update-all --check
```

## चलाएँ

```bash
mac-update-all
```

## सुरक्षा

यह टूल forced restart नहीं करता और standalone apps को blindly replace नहीं करता.

Important safety rules:

- no forced macOS restart
- no sudo mutation of Apple-managed system tools
- no blind replacement of standalone `.app` bundles
- logs are written to `~/Library/Logs/mac-update-orchestrator/`

## Contributing

All agents and contributors should read `../../AGENTS.md` first. Meaningful changes require documentation impact checks and independent review.
