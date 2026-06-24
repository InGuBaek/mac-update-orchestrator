#!/usr/bin/env bash
# Conservative repository privacy/security scan.
# Scans tracked + untracked worktree files and, when available, git history
# for obvious secrets and personal paths.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

PATTERN='(/Users/[A-Za-z0-9._-]+|/home/[A-Za-z0-9._-]+|gho_[A-Za-z0-9_]+|ghp_[A-Za-z0-9_]+|github_pat_[A-Za-z0-9_]+|OPENAI_API_KEY|ANTHROPIC_API_KEY|API_KEY|SECRET|PASSWORD|TOKEN|Bearer[[:space:]]+[A-Za-z0-9._~+/=-]+|sk-[A-Za-z0-9]{20,}|xox[baprs]-[A-Za-z0-9-]+|AKIA[0-9A-Z]{16}|BEGIN[[:space:]]+[A-Z ]*PRIVATE KEY)'

fail=0

echo "==> Scanning tracked and untracked worktree files"
match_file="$(mktemp)"
while IFS= read -r -d '' file; do
  [[ "$file" == "scripts/security-scan.sh" ]] && continue
  [[ -f "$file" ]] || continue
  if grep -nHE -I "$PATTERN" "$file" >>"$match_file" 2>/dev/null; then
    true
  fi
done < <(git ls-files -z --cached --others --exclude-standard)

if [[ -s "$match_file" ]]; then
  cat "$match_file"
  fail=1
else
  echo "No suspicious strings in worktree files."
fi
rm -f "$match_file"

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
