#!/usr/bin/env bash
# Non-mutating E2E checks for local and CI use.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT"

TMP_HOME="$(mktemp -d)"
TMP_BIN="$TMP_HOME/bin"
TMP_SHARE="$TMP_HOME/share/mac-update-orchestrator"
TMP_LOGS="$TMP_HOME/logs"
INSTALL_SMOKE_LOG="$TMP_HOME/install-smoke.log"
UPDATE_CHECK_LOG="$TMP_HOME/mac-update-all-check.log"
trap 'rm -rf "$TMP_HOME"' EXIT

say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }

say "Syntax checks"
bash -n bin/*.command install.sh scripts/*.sh

say "Help output checks"
MAC_UPDATE_LOG_DIR="$TMP_LOGS" bin/mac-update-all.command --help | grep -q 'mac-update-all'
MAC_UPDATE_LOG_DIR="$TMP_LOGS" bin/software-update.command --help | grep -q 'software-update.command'
MAC_UPDATE_LOG_DIR="$TMP_LOGS" bin/system-update.command --help | grep -q 'system-update.command'

say "Installer smoke test into temporary prefix"
MAC_UPDATE_INSTALL_DIR="$TMP_SHARE" MAC_UPDATE_BIN_DIR="$TMP_BIN" ./install.sh >"$INSTALL_SMOKE_LOG"

test -x "$TMP_BIN/mac-update-all"
test -x "$TMP_BIN/mac-software-update"
test -x "$TMP_BIN/mac-system-update"
test -x "$TMP_BIN/mac-update-everything"

MAC_UPDATE_LOG_DIR="$TMP_LOGS" "$TMP_BIN/mac-update-all" --help | grep -q 'mac-update-all'
MAC_UPDATE_LOG_DIR="$TMP_LOGS" "$TMP_BIN/mac-software-update" --help | grep -q 'software-update.command'
MAC_UPDATE_LOG_DIR="$TMP_LOGS" "$TMP_BIN/mac-system-update" --help | grep -q 'system-update.command'

say "Non-mutating check mode"
if [[ "$(uname -s)" == "Darwin" ]]; then
  MAC_UPDATE_LOG_DIR="$TMP_LOGS" bin/mac-update-all.command --check --no-install-helpers >"$UPDATE_CHECK_LOG" || true
  grep -q 'Software mode: check' "$UPDATE_CHECK_LOG"
  grep -q 'System mode: check' "$UPDATE_CHECK_LOG"
else
  echo "Non-Darwin host: skipping macOS-specific --check execution."
fi

say "OK: E2E smoke checks passed."
