#!/usr/bin/env bash
# Fail when behavior-affecting changes do not include documentation updates.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

BASE="${DOC_CHECK_BASE:-origin/main}"

say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*"; }

if [[ "${DOC_CHECK_SKIP:-0}" == "1" ]]; then
  warn "DOC_CHECK_SKIP=1 set; skipping documentation impact check."
  exit 0
fi

if ! git rev-parse --verify "$BASE" >/dev/null 2>&1; then
  warn "Base '$BASE' not available; falling back to HEAD~1."
  BASE="HEAD~1"
fi

changed="$(git diff --name-only "$BASE"...HEAD 2>/dev/null || git diff --name-only "$BASE" 2>/dev/null || true)"

# Include uncommitted/untracked files for local pre-commit usage.
if [[ "${DOC_CHECK_INCLUDE_WORKTREE:-1}" == "1" ]]; then
  changed="$changed
$(git diff --cached --name-only 2>/dev/null || true)
$(git diff --name-only 2>/dev/null || true)
$(git ls-files --others --exclude-standard 2>/dev/null || true)"
fi

changed="$(printf '%s\n' "$changed" | sed '/^$/d' | sort -u)"

if [[ -z "$changed" ]]; then
  say "No changed files detected for doc-impact check."
  exit 0
fi

behavior_regex='^(bin/.*\.command|install\.sh|scripts/.*\.sh|\.github/workflows/.*\.ya?ml)$'
doc_regex='^(README\.md|README\.ko\.md|AGENTS\.md|CONTRIBUTING\.md|docs/.*\.md|\.github/pull_request_template\.md)$'

behavior_changes="$(printf '%s\n' "$changed" | grep -E "$behavior_regex" || true)"
doc_changes="$(printf '%s\n' "$changed" \
  | grep -E "$doc_regex" \
  | grep -Ev '^docs/reviews/codex-review-[0-9]{8}-[0-9]{6}\.md$' \
  || true)"

say "Documentation impact check"
echo "Base: $BASE"
echo
printf 'Changed behavior/workflow files:\n%s\n' "${behavior_changes:-<none>}"
echo
printf 'Changed documentation files:\n%s\n' "${doc_changes:-<none>}"

if [[ -n "$behavior_changes" && -z "$doc_changes" ]]; then
  echo
  echo "FAIL: behavior/workflow files changed but no documentation changed."
  echo "Update README/AGENTS/CONTRIBUTING/docs, or set DOC_CHECK_SKIP=1 only for local, explicitly-reviewed exceptions."
  exit 1
fi

say "OK: documentation impact check passed."
