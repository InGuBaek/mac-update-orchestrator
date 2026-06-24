#!/usr/bin/env bash
# Run the mandatory OpenAI Codex review gate.
# Intended workflow: Claude Code (or another agent) may implement changes, but Codex reviews before push/release.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

REVIEW_DIR="${CODEX_REVIEW_DIR:-docs/reviews}"
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT_FILE="$REVIEW_DIR/codex-review-$STAMP.md"
MODE_ARGS=("$@")

if [[ ${#MODE_ARGS[@]} -eq 0 ]]; then
  MODE_ARGS=(--uncommitted)
fi

mkdir -p "$REVIEW_DIR"

say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*"; }

sanitize_output() {
  # Codex output can include local absolute paths. Review reports are committed
  # for workflow changes, so sanitize home directories before writing them.
  sed -E "s#${HOME}#~#g; s#/Users/[A-Za-z0-9._-]+#~#g; s#/home/[A-Za-z0-9._-]+#~#g"
}

if ! command -v codex >/dev/null 2>&1; then
  echo "FAIL: codex CLI is not installed or not in PATH." >&2
  echo "Install/login to OpenAI Codex CLI, then rerun this review gate." >&2
  exit 127
fi

say "Pre-review local checks"
bash -n bin/*.command install.sh scripts/*.sh
scripts/security-scan.sh

say "Running OpenAI Codex review"
echo "Review output: $OUT_FILE"

{
  echo "# Codex Review - $STAMP"
  echo
  echo "Command: codex review ${MODE_ARGS[*]}"
  echo
  echo "## Required review checklist"
  echo
  sed -n '/^## Mandatory checklist/,$p' docs/code-review.md
  echo
  echo "## Output"
  echo
  # Codex CLI's `review --uncommitted` currently rejects a custom prompt on this install,
  # so the checklist is written into the report and the project instructions live in
  # CLAUDE.md / AGENTS.md / docs/code-review.md for Codex to read from the repository.
  codex review "${MODE_ARGS[@]}"
} 2>&1 | sanitize_output | tee "$OUT_FILE"

say "Codex review complete"
echo "$OUT_FILE"
