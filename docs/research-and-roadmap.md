# Research and AI-era Roadmap

Last updated: 2026-06-25

## Comparable projects reviewed

GitHub search and targeted repository checks found these relevant projects:

| Project | Role | Notes for this repository |
| --- | --- | --- |
| `welcoMattic/kymsu` | macOS multi-updater | Closest direct reference: “Keep Your macOS Stuff Updated”. Confirms demand for one-command macOS update aggregation. |
| `cansurmeli/system-updater` | macOS update script | Older shell approach covering MAS, Homebrew, pip, Ruby. Shows this problem is recurring but many repos become stale. |
| `CubWatson/true-mac-updater` | Homebrew/App Store/macOS updater | Recent minimal one-command approach. Reinforces simple UX. |
| `seeingred/mac-update` | Personal macOS updater | Similar package-manager-only safety posture. |
| `bigas-ch/macOSUpdater` | Security-first updater | More privileged/backend-heavy. Useful contrast: this repo should avoid privileged complexity unless clearly needed. |
| `topgrade-rs/topgrade` | Cross-platform “upgrade all the things” | Mature general updater. This repo differentiates by being macOS-only, safer, and agent-governed. |
| `Homebrew/brew` | Package manager | Source of truth for formula/cask update behavior. |
| `mas-cli/mas` | App Store CLI | Source of truth for Mac App Store automation. |
| `Macjutsu/super` | macOS software update UX | Mature macOS update workflow; useful for restart/user-deferral ideas. |
| `munki/munki` / `Installomator/Installomator` | Managed Mac software deployment | Enterprise-grade references. Too heavy for this repo’s current local-user scope. |

## Positioning

This repository should not try to out-Topgrade Topgrade or become enterprise MDM.

The better niche:

> A public, macOS-only, local-user update orchestrator with strong safety defaults, auditable logs, agent-friendly contribution rules, documentation impact checks, and independent Codex review.

## AI-era gaps to close

1. Documentation drift
   - CLI behavior changes faster than README examples.
   - Agents can modify code without updating docs unless enforced.

2. Unsafe automation pressure
   - “Update everything” tools tend to grow destructive behavior.
   - Guardrails must be executable, not just written.

3. Public agent contribution quality
   - Many agents can contribute, but they need one canonical policy and mechanical checks.

4. Testability
   - Real updates mutate machines, so CI must test syntax, planning, help text, install behavior, doc gates, and non-mutating E2E paths.

5. Localization
   - A public GitHub repo should make the first-read path accessible beyond English/Korean without promising perfect full translation for every page.

## Development plan

### Phase 1 — executable governance

- Add `scripts/doc-impact-check.sh`.
- Add `scripts/e2e-check.sh`.
- Add shell tests under `tests/`.
- Wire checks into GitHub Actions.

### Phase 2 — docs and localization

- Add `docs/i18n/` with a language index and quickstart pages for the top GitHub-heavy countries/languages.
- Keep README canonical in English and Korean README as the strongest secondary doc.
- Treat other localized quickstarts as entry points that link back to canonical docs.

### Phase 3 — stronger non-mutating plan mode

Future work:

- Add structured `--dry-run` or `--plan` output to each command.
- Make CI verify the plan output instead of only help/syntax.
- Consider JSON output for tools and future dashboards.

### Phase 4 — release discipline

Future work:

- Add `CHANGELOG.md`.
- Add GitHub release checklist.
- Add version command or embedded version reporting.

## Current implementation target for this branch

This branch implements Phase 1 and the initial Phase 2 docs structure. Phase 3/4 are documented but intentionally not overbuilt yet.
