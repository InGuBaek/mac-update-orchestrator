#!/usr/bin/env bash
# Lightweight tests for doc-impact-check.sh behavior.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCRIPT="$ROOT/scripts/doc-impact-check.sh"
TMP="$(mktemp -d)"
LOG_DIR="$TMP/logs"
trap 'rm -rf "$TMP"' EXIT

say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }

copy_min_repo() {
  mkdir -p "$TMP/repo/bin" "$TMP/repo/scripts" "$TMP/repo/docs" "$TMP/repo/.github/workflows" "$LOG_DIR"
  cp "$SCRIPT" "$TMP/repo/scripts/doc-impact-check.sh"
  cat > "$TMP/repo/bin/tool.command" <<'EOF'
#!/usr/bin/env bash
echo old
EOF
  cat > "$TMP/repo/README.md" <<'EOF'
# Test
EOF
  (cd "$TMP/repo" && git init -q && git config user.email test@example.invalid && git config user.name Test && git add . && git commit -q -m initial)
}

copy_min_repo

say "Fails when behavior changes without docs"
(
  cd "$TMP/repo"
  echo 'echo changed' >> bin/tool.command
  if DOC_CHECK_BASE=HEAD DOC_CHECK_INCLUDE_WORKTREE=1 scripts/doc-impact-check.sh >"$LOG_DIR/doc-impact-fail.log" 2>&1; then
    echo "Expected doc-impact check to fail"
    cat "$LOG_DIR/doc-impact-fail.log"
    exit 1
  fi
)

say "Passes when behavior and docs change together"
(
  cd "$TMP/repo"
  echo 'docs changed' >> README.md
  DOC_CHECK_BASE=HEAD DOC_CHECK_INCLUDE_WORKTREE=1 scripts/doc-impact-check.sh >"$LOG_DIR/doc-impact-pass.log"
)

say "Passes when skip env is set"
(
  cd "$TMP/repo"
  DOC_CHECK_SKIP=1 DOC_CHECK_BASE=HEAD scripts/doc-impact-check.sh >"$LOG_DIR/doc-impact-skip.log"
)

say "Fails on staged behavior changes without docs"
(
  cd "$TMP/repo"
  git reset --hard -q HEAD
  echo 'echo staged-change' >> bin/tool.command
  git add bin/tool.command
  if DOC_CHECK_BASE=HEAD DOC_CHECK_INCLUDE_WORKTREE=1 scripts/doc-impact-check.sh >"$LOG_DIR/doc-impact-staged-fail.log" 2>&1; then
    echo "Expected staged doc-impact check to fail"
    cat "$LOG_DIR/doc-impact-staged-fail.log"
    exit 1
  fi
)

say "Generated review reports do not satisfy doc-impact"
(
  cd "$TMP/repo"
  git reset --hard -q HEAD
  mkdir -p docs/reviews
  echo 'echo behavior-only' >> bin/tool.command
  cat > docs/reviews/codex-review-20260625-000000.md <<'EOF'
# generated review
EOF
  if DOC_CHECK_BASE=HEAD DOC_CHECK_INCLUDE_WORKTREE=1 scripts/doc-impact-check.sh >"$LOG_DIR/doc-impact-generated-report-fail.log" 2>&1; then
    echo "Expected generated report not to satisfy doc-impact check"
    cat "$LOG_DIR/doc-impact-generated-report-fail.log"
    exit 1
  fi
)

say "OK: doc-impact tests passed."
