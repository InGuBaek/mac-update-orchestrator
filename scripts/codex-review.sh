#!/usr/bin/env bash
# Run the independent OpenAI Codex review gate and save a public-safe report.

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

sanitize_output() {
  # Codex output can include local absolute paths. Review reports are public
  # artifacts, so keep them free of personal home directories and obvious tokens.
  sed -E \
    -e "s#${HOME}#~#g" \
    -e "s#/Users/[A-Za-z0-9._-]+#~#g" \
    -e "s#/home/[A-Za-z0-9._-]+#~#g" \
    -e "s#ghp_[A-Za-z0-9_]+#ghp_[REDACTED]#g" \
    -e "s#gho_[A-Za-z0-9_]+#gho_[REDACTED]#g" \
    -e "s#github_pat_[A-Za-z0-9_]+#github_pat_[REDACTED]#g" \
    -e "s#Bearer[[:space:]]+[A-Za-z0-9._~+/=-]+#Bearer [REDACTED]#g" \
    -e "s#sk-[A-Za-z0-9]{20,}#sk-[REDACTED]#g" \
    -e "s#xox[baprs]-[A-Za-z0-9-]+#xox[REDACTED]#g" \
    -e "s#AKIA[0-9A-Z]{16}#AKIA[REDACTED]#g" \
    -e "s#BEGIN[[:space:]]+[A-Z ]*PRIVATE KEY#BEGIN [REDACTED PRIVATE KEY LABEL]#g" \
    -e "s#[[:blank:]]+\$##g"
}

if ! command -v codex >/dev/null 2>&1; then
  echo "FAIL: codex CLI is not installed or not in PATH." >&2
  echo "Install/login to OpenAI Codex CLI, then rerun this review gate." >&2
  exit 127
fi

say "Pre-review local checks"
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
  cat docs/code-review.md
  echo
  echo "## Output"
  echo
  codex review "${MODE_ARGS[@]}"
} 2>&1 | sanitize_output | tee "$OUT_FILE"

say "Codex review complete"
echo "$OUT_FILE"
