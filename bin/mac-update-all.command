#!/usr/bin/env bash
# One-command macOS updater.
# Runs daily software updates first, then macOS system update flow.

set -u

SCRIPT_VERSION="2026-06-25"
ASSUME_YES=0
INSTALL_HELPERS=1
INCLUDE_OLLAMA_MODELS=0
RUN_CLEANUP=0
SYSTEM_MODE="install"       # check | download | install | skip
SOFTWARE_MODE="update"      # check | update
LOG_DIR="${MAC_UPDATE_LOG_DIR:-$HOME/Library/Logs/mac-update-orchestrator}"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/mac-update-all-$(date +%Y%m%d-%H%M%S).log"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec > >(tee -a "$LOG_FILE") 2>&1

usage() {
  cat <<'USAGE'
사용법:
  mac-update-all [options]
  bin/mac-update-all.command [options]

기본 동작:
  1. 일상 SW 업데이트 실행
     - App Store, Homebrew, npm/nvm/bun/corepack, Python/uv/pipx/pip user packages,
       Claude/Codex/Pi/OpenCode/Hermes/Ollama 감지
  2. macOS 시스템 업데이트 설치 시도
     - 강제 재시작은 하지 않음
     - 설치 권한/재시작 동의는 실행 중 사용자에게 받음

옵션:
  --check                  SW/시스템 업데이트 모두 확인만
  -y, --yes                 가능한 확인 질문에 yes
  --no-install-helpers      mas 같은 helper 자동 설치 안 함
  --ollama-models           Ollama 모델까지 모두 pull
  --cleanup                 brew cleanup 실행
  --system-check            시스템 업데이트는 확인만
  --system-download         시스템 업데이트는 다운로드만
  --skip-system             시스템 업데이트 생략
  -h, --help                도움말

로그:
  ~/Library/Logs/mac-update-orchestrator/
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) ASSUME_YES=1 ;;
    --check) SOFTWARE_MODE="check"; SYSTEM_MODE="check" ;;
    --no-install-helpers) INSTALL_HELPERS=0 ;;
    --ollama-models) INCLUDE_OLLAMA_MODELS=1 ;;
    --cleanup) RUN_CLEANUP=1 ;;
    --system-check) SYSTEM_MODE="check" ;;
    --system-download) SYSTEM_MODE="download" ;;
    --skip-system) SYSTEM_MODE="skip" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "알 수 없는 옵션: $1"; usage; exit 2 ;;
  esac
  shift
done

say_step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
say_warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*"; }

run_child() {
  local label="$1"
  shift
  say_step "$label"
  echo "+ $*"
  "$@"
  local code=$?
  if [[ $code -ne 0 ]]; then
    say_warn "$label failed with exit $code. 다음 단계는 계속 진행함. 로그 확인 필요."
  fi
  return 0
}

software_args=(--"$SOFTWARE_MODE")
[[ "$ASSUME_YES" == 1 ]] && software_args+=(--yes)
[[ "$INSTALL_HELPERS" == 1 ]] && software_args+=(--install-helpers)
[[ "$INCLUDE_OLLAMA_MODELS" == 1 ]] && software_args+=(--ollama-models)
[[ "$RUN_CLEANUP" == 1 ]] && software_args+=(--cleanup)

system_args=()
case "$SYSTEM_MODE" in
  check) system_args+=(--check) ;;
  download) system_args+=(--download) ;;
  install) system_args+=(--install) ;;
  skip) ;;
  *) echo "invalid SYSTEM_MODE: $SYSTEM_MODE"; exit 2 ;;
esac
[[ "$ASSUME_YES" == 1 ]] && system_args+=(--yes)

say_step "mac-update-all 시작"
echo "Script: $SCRIPT_VERSION"
echo "Log: $LOG_FILE"
echo "Software helpers: $INSTALL_HELPERS"
echo "Ollama models: $INCLUDE_OLLAMA_MODELS"
echo "Brew cleanup: $RUN_CLEANUP"
echo "System mode: $SYSTEM_MODE"
echo "Software mode: $SOFTWARE_MODE"

run_child "일상 SW 업데이트" "$DIR/software-update.command" "${software_args[@]}"

if [[ "$SYSTEM_MODE" == "skip" ]]; then
  say_warn "시스템 업데이트 생략 (--skip-system)"
else
  run_child "macOS 시스템 업데이트" "$DIR/system-update.command" "${system_args[@]}"
fi

say_step "전체 완료"
echo "통합 로그: $LOG_FILE"
echo "세부 로그도 같은 폴더에 저장됨: $LOG_DIR"
