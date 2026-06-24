#!/usr/bin/env bash
# macOS system updater. Deliberately separated from daily software updates.

set -u

SCRIPT_VERSION="2026-06-25"
MODE="interactive"          # interactive | check | download | install
ASSUME_YES=0
LOG_DIR="${MAC_UPDATE_LOG_DIR:-$HOME/Library/Logs/mac-update-orchestrator}"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/system-update-$(date +%Y%m%d-%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

usage() {
  cat <<'USAGE'
사용법:
  bin/system-update.command                  # 대화형 메뉴
  bin/system-update.command --check           # macOS 업데이트 확인
  bin/system-update.command --download        # macOS 업데이트 다운로드
  bin/system-update.command --install         # macOS 업데이트 설치. 재시작 필요할 수 있음.

옵션:
  -y, --yes      확인 질문에 기본 yes
  -h, --help     도움말

정책:
  - 강제 --restart를 쓰지 않는다.
  - 일상 SW 업데이트는 bin/software-update.command에서 처리한다.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) MODE="check" ;;
    --download) MODE="download" ;;
    --install) MODE="install" ;;
    -y|--yes) ASSUME_YES=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "알 수 없는 옵션: $1"; usage; exit 2 ;;
  esac
  shift
done

say_step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
say_warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*"; }
say_fail() { printf '\033[1;31mFAIL: %s\033[0m\n' "$*"; }

run() {
  echo "+ $*"
  "$@"
  local code=$?
  if [[ $code -ne 0 ]]; then say_fail "exit $code: $*"; fi
  return $code
}

confirm() {
  local prompt="$1"
  if [[ "$ASSUME_YES" == 1 ]]; then echo "$prompt [auto yes]"; return 0; fi
  read -r -p "$prompt [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

pick_mode_interactive() {
  cat <<MENU

macOS 시스템 업데이트 모드:
  1) check    - 확인만
  2) download - 다운로드만
  3) install  - 설치. 재시작 필요할 수 있음
MENU
  read -r -p "선택 [1/2/3, 기본 1]: " choice
  case "${choice:-1}" in
    1) MODE="check" ;;
    2) MODE="download" ;;
    3) MODE="install" ;;
    *) MODE="check" ;;
  esac
}

run_all() {
  [[ "$MODE" == "interactive" ]] && pick_mode_interactive

  say_step "시스템 요약"
  echo "Script: system-update $SCRIPT_VERSION"
  echo "Log: $LOG_FILE"
  echo "macOS: $(sw_vers -productVersion 2>/dev/null || echo unknown) ($(sw_vers -buildVersion 2>/dev/null || echo unknown))"
  echo "Arch: $(uname -m)"

  say_step "macOS Software Update"
  echo "+ softwareupdate -l"
  /usr/sbin/softwareupdate -l || true

  case "$MODE" in
    check)
      ;;
    download)
      run /usr/sbin/softwareupdate --download --all || true
      ;;
    install)
      say_warn "macOS 시스템 업데이트 설치를 시도함. 재시작이 필요할 수 있음. 강제 --restart는 사용하지 않음."
      if confirm "계속 설치할까?"; then
        run /usr/sbin/softwareupdate --install --all || true
      else
        say_warn "사용자 취소"
      fi
      ;;
  esac

  say_step "완료"
  echo "모드: $MODE"
  echo "로그: $LOG_FILE"
}

run_all

if [[ -t 0 && "$MODE" == "interactive" ]]; then
  echo
  read -r -p "Enter를 누르면 종료합니다..." _
fi
