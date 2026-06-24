#!/usr/bin/env bash
# Conservative repository privacy/security scan.
# Scans tracked files and, when available, git history for obvious secrets and personal paths.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

PATTERN='(/Users/[A-Za-z0-9._-]+|/home/[A-Za-z0-9._-]+|gho_[A-Za-z0-9_]+|ghp_[A-Za-z0-9_]+|github_pat_[A-Za-z0-9_]+|OPENAI_API_KEY|ANTHROPIC_API_KEY|API_KEY|SECRET|PASSWORD|TOKEN|Bearer[[:space:]]+[A-Za-z0-9._~+/=-]+|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]+|AKIA[0-9A-Z]{16}|BEGIN[[:space:]]+[A-Z ]*PRIVATE KEY)'

fail=0

echo "==> Scanning tracked files"
if git grep -n -E -I "$PATTERN" -- . ':!scripts/security-scan.sh'; then
  fail=1
else
  echo "No suspicious strings in tracked files."
fi

echo
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "==> Scanning git history"
  if git log --all -p -- . ':!scripts/security-scan.sh' | grep -E "$PATTERN"; then
    fail=1
  else
    echo "No suspicious strings in git history."
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "FAIL: suspicious personal path or secret-like string found. Remove it and rewrite history before pushing."
  exit 1
fi

echo
 echo "OK: privacy/security scan passed."
