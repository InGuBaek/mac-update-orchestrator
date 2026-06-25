#!/usr/bin/env bash
# Run repository test suite.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }

say "Shell syntax"
bash -n bin/*.command install.sh scripts/*.sh tests/*.sh

say "Security scan"
scripts/security-scan.sh

say "Documentation impact tests"
tests/doc-impact-check.test.sh

say "Documentation impact check"
scripts/doc-impact-check.sh

say "E2E smoke check"
scripts/e2e-check.sh

say "OK: all tests passed."
