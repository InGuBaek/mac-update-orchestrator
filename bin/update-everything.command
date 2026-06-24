#!/usr/bin/env bash
# Compatibility wrapper. Prefer bin/software-update.command and bin/system-update.command.

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'USAGE'
사용법:
  bin/update-everything.command --software [software options]
  bin/update-everything.command --system   [system options]

기본값은 --software.
예:
  bin/update-everything.command --check
  bin/update-everything.command --software --update --install-helpers
  bin/update-everything.command --system --download
USAGE
}

TARGET="software"
if [[ $# -gt 0 ]]; then
  case "$1" in
    --software) TARGET="software"; shift ;;
    --system) TARGET="system"; shift ;;
    -h|--help) usage; exit 0 ;;
  esac
fi

case "$TARGET" in
  software) exec "$DIR/software-update.command" "$@" ;;
  system) exec "$DIR/system-update.command" "$@" ;;
  *) usage; exit 2 ;;
esac
