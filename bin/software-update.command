#!/usr/bin/env bash
# Daily software updater for macOS.
# Scope: App Store, Homebrew, Node/npm/nvm/bun/corepack, Python/uv/pipx/pip user packages,
# and common AI/dev CLIs. Excludes macOS system updates by design.

set -u

SCRIPT_VERSION="2026-06-25"
MODE="interactive"          # interactive | check | update
ASSUME_YES=0
INSTALL_HELPERS=0
INCLUDE_OLLAMA_MODELS=0
RUN_CLEANUP=0
LOG_DIR="${MAC_UPDATE_LOG_DIR:-$HOME/Library/Logs/mac-update-orchestrator}"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/software-update-$(date +%Y%m%d-%H%M%S).log"

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/.bun/bin:$HOME/.cargo/bin:$PATH"

exec > >(tee -a "$LOG_FILE") 2>&1

usage() {
  cat <<'USAGE'
사용법:
  bin/software-update.command                 # 대화형 메뉴
  bin/software-update.command --check          # 업데이트 가능 항목 확인
  bin/software-update.command --update         # SW 업데이트 실행

옵션:
  -y, --yes                 확인 질문에 기본 yes
  --install-helpers         mas(App Store CLI) 같은 보조 도구가 없으면 Homebrew로 설치
  --ollama-models           설치된 Ollama 모델도 전부 pull. 용량/시간 큼.
  --cleanup                 brew cleanup 실행
  -h, --help                도움말

범위:
  - App Store 앱: mas가 있을 때 mas upgrade
  - Homebrew: brew update + brew upgrade --greedy
  - Node: nvm, npm global, corepack, pnpm, yarn, bun global
  - Python: Homebrew Python, uv tools, pipx, pip --user packages, pyenv 자체
  - AI/dev CLI: Claude Code, Hermes, OpenCode, Codex, Pi, Ollama 감지
  - macOS 시스템 업데이트는 제외. bin/system-update.command 사용.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) MODE="check" ;;
    --update) MODE="update" ;;
    -y|--yes) ASSUME_YES=1 ;;
    --install-helpers) INSTALL_HELPERS=1 ;;
    --ollama-models) INCLUDE_OLLAMA_MODELS=1 ;;
    --cleanup) RUN_CLEANUP=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "알 수 없는 옵션: $1"; usage; exit 2 ;;
  esac
  shift
done

say_step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
say_warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*"; }
say_fail() { printf '\033[1;31mFAIL: %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

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

일상 SW 업데이트 모드:
  1) check  - 업데이트 가능 항목 확인만
  2) update - App Store/Brew/Node/Python/CLI 업데이트 실행
MENU
  read -r -p "선택 [1/2, 기본 1]: " choice
  case "${choice:-1}" in
    1) MODE="check" ;;
    2) MODE="update" ;;
    *) MODE="check" ;;
  esac
}

system_summary() {
  say_step "환경 요약"
  echo "Script: software-update $SCRIPT_VERSION"
  echo "Log: $LOG_FILE"
  echo "macOS: $(sw_vers -productVersion 2>/dev/null || echo unknown) ($(sw_vers -buildVersion 2>/dev/null || echo unknown))"
  echo "Arch: $(uname -m)"
  echo "PATH: $PATH"
  echo
  for c in brew mas claude codex pi opencode hermes ollama node npm npx corepack pnpm yarn bun uv uvx python3 pip3 pipx pyenv rustup cargo gem; do
    if have "$c"; then printf '%-16s %s\n' "$c" "$(command -v "$c")"; fi
  done
}

version_snapshot() {
  say_step "현재 버전 스냅샷"
  for c in node npm npx corepack pnpm yarn bun python3 pip3 pipx pyenv uv uvx claude codex pi opencode hermes ollama rustup cargo gem; do
    if have "$c"; then
      echo "--- $c ($(command -v "$c"))"
      ("$c" --version || "$c" version || true) 2>&1 | sed -n '1,6p'
    fi
  done
}

ensure_helper_tools() {
  if ! have brew; then say_warn "Homebrew가 없어 많은 업데이트를 건너뜀: https://brew.sh"; return 0; fi
  if ! have mas; then
    if [[ "$INSTALL_HELPERS" == 1 ]] || { [[ "$MODE" == "interactive" ]] && confirm "App Store 업데이트용 mas를 brew로 설치할까?"; }; then
      run brew install mas || true
    else
      say_warn "mas가 없어 App Store 업데이트를 건너뜀. 필요하면 --install-helpers 사용."
    fi
  fi
}

homebrew_updates() {
  say_step "Homebrew"
  if ! have brew; then say_warn "brew 없음"; return 0; fi
  if [[ "$MODE" == "check" ]]; then
    echo "+ brew outdated --greedy"
    brew outdated --greedy || true
    return 0
  fi
  run brew update || true
  echo "+ brew outdated --greedy"
  brew outdated --greedy || true
  run brew upgrade --greedy || true
  [[ "$RUN_CLEANUP" == 1 ]] && run brew cleanup || true
}

app_store_updates() {
  say_step "Mac App Store"
  if ! have mas; then say_warn "mas 없음: --install-helpers로 설치 가능"; return 0; fi
  echo "+ mas outdated"
  mas outdated || true
  [[ "$MODE" == "update" ]] && run mas upgrade || true
}

runtime_updates() {
  say_step "Python / Node / 패키지 매니저"

  if have brew; then
    echo "Homebrew 관리 런타임/패키지 매니저:"
    brew list --formula --versions 2>/dev/null | grep -E '^(python(@| )|node(@| )|uv |pipx |pyenv |nvm |pnpm |yarn |bun )' || true
    brew list --cask --versions 2>/dev/null | grep -E '^(node|python|bun)' || true
  fi

  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    echo
    echo "nvm 감지: $HOME/.nvm"
    # shellcheck disable=SC1091
    . "$HOME/.nvm/nvm.sh"
    nvm ls || true
    if [[ "$MODE" == "update" ]]; then
      run nvm install --lts --latest-npm || true
      run nvm alias default 'lts/*' || true
      nvm ls --no-colors 2>/dev/null | awk 'match($0,/v([0-9]+)\.[0-9]+\.[0-9]+/,m){print m[1]}' | sort -u | while read -r major; do
        [[ -z "$major" ]] && continue
        run nvm install "$major" --latest-npm || true
      done
      [[ -d "$HOME/.nvm/.git" ]] && run git -C "$HOME/.nvm" pull --ff-only || true
    fi
  fi

  if have node; then
    echo
    echo "Node: $(node --version 2>&1) ($(command -v node))"
    if [[ "$(command -v node)" == "$HOME/.hermes/node/"* || "$(readlink "$(command -v node)" 2>/dev/null || true)" == "$HOME/.hermes/node/"* ]]; then
      echo "현재 PATH의 node/npm은 Hermes 번들 symlink다. Hermes 업데이트에서 같이 관리된다."
    fi
  fi

  if have npm; then
    echo
    echo "npm global prefix: $(npm prefix -g 2>/dev/null || true)"
    echo "+ npm outdated -g --depth=0"
    npm outdated -g --depth=0 || true
    echo "+ npm list -g --depth=0"
    npm list -g --depth=0 2>/dev/null | sed -n '1,120p' || true
    if [[ "$MODE" == "update" ]]; then
      run npm update -g || true
      run npm install -g npm@latest corepack@latest || true
    fi
  fi

  if have corepack; then
    echo
    echo "corepack: $(corepack --version 2>/dev/null || true)"
    if [[ "$MODE" == "update" ]]; then
      run corepack enable || true
      run corepack prepare pnpm@latest --activate || true
      run corepack prepare yarn@stable --activate || true
    fi
  fi

  if have pnpm && [[ "$MODE" == "update" ]]; then
    run pnpm add -g pnpm@latest || true
    run pnpm update -g --latest || true
  fi

  if have yarn && [[ "$MODE" == "update" ]]; then
    run yarn set version stable || true
    run yarn global upgrade || true
  fi

  if have bun; then
    echo
    echo "bun: $(bun --version 2>/dev/null || true) ($(command -v bun))"
    bun pm ls -g 2>/dev/null | sed -n '1,120p' || true
    if [[ "$MODE" == "update" ]]; then
      run bun upgrade || true
      run bun update -g || true
    fi
  fi

  if have uv; then
    echo
    echo "uv: $(uv --version 2>/dev/null || true)"
    if [[ "$MODE" == "update" ]]; then
      if have brew && brew list --formula 2>/dev/null | grep -Fxq "uv"; then
        echo "uv는 Homebrew 관리 대상이라 brew upgrade에서 처리됨."
      else
        run uv self update || true
      fi
      run uv tool upgrade --all || true
    fi
  fi

  if have pyenv; then
    echo
    echo "pyenv: $(pyenv --version 2>/dev/null || true)"
    pyenv versions || true
    if [[ "$MODE" == "update" ]]; then
      if have brew && brew list --formula 2>/dev/null | grep -Fxq "pyenv"; then
        echo "pyenv는 Homebrew 관리 대상이라 brew upgrade에서 처리됨."
      elif [[ -d "${PYENV_ROOT:-$HOME/.pyenv}/.git" ]]; then
        run git -C "${PYENV_ROOT:-$HOME/.pyenv}" pull --ff-only || true
      fi
      say_warn "pyenv Python 새 버전 설치는 프로젝트 호환성을 깨기 쉬워 자동 설치하지 않음."
    fi
  fi

  if have python3; then
    echo
    echo "Python: $(python3 --version 2>&1) ($(command -v python3))"
    echo "+ python3 -m pip list --user --outdated"
    python3 -m pip list --user --outdated || true
    if [[ "$MODE" == "update" ]]; then
      run python3 -m pip install --user --upgrade pip setuptools wheel || true
      outdated_pkgs="$(python3 -m pip list --user --outdated --format=json 2>/dev/null | python3 -c 'import json,sys; print(" ".join(p["name"] for p in json.load(sys.stdin)))' 2>/dev/null || true)"
      if [[ -n "${outdated_pkgs:-}" ]]; then
        # shellcheck disable=SC2086
        run python3 -m pip install --user --upgrade $outdated_pkgs || true
      else
        echo "업데이트할 Python user package 없음"
      fi
    fi
  fi

  if have pipx; then
    echo
    echo "pipx: $(pipx --version 2>/dev/null || true)"
    pipx list || true
    [[ "$MODE" == "update" ]] && run pipx upgrade-all || true
  fi

  if have rustup; then
    echo
    echo "rustup: $(rustup --version 2>/dev/null | head -1 || true)"
    [[ "$MODE" == "update" ]] && run rustup update || true
  fi

  if have cargo; then
    echo
    echo "cargo: $(cargo --version 2>/dev/null || true)"
    if have cargo-install-update && [[ "$MODE" == "update" ]]; then
      run cargo install-update -a || true
    else
      echo "cargo-install-update 없음: cargo로 설치한 바이너리 자동 갱신은 건너뜀."
    fi
  fi

  if have gem; then
    echo
    echo "RubyGems: $(gem --version 2>/dev/null || true)"
    if [[ "$MODE" == "update" ]]; then
      if [[ "$(command -v gem)" == /usr/bin/gem ]]; then
        say_warn "시스템 RubyGems(/usr/bin/gem)는 sudo 없이 건드리지 않음."
      else
        run gem update --system || true
        run gem update || true
      fi
    fi
  fi
}

ai_cli_updates() {
  say_step "AI/dev 개별 CLI"

  if have claude; then
    echo "Claude Code: $(claude --version 2>&1 | head -1)"
    [[ "$MODE" == "update" ]] && run claude update || true
  fi

  if have hermes; then
    echo "Hermes: $(hermes --version 2>&1 | head -1)"
    if [[ "$MODE" == "check" ]]; then hermes update --check || true; fi
    [[ "$MODE" == "update" ]] && run hermes update --yes || true
  fi

  if have opencode; then
    echo "OpenCode: $(opencode --version 2>&1 | head -1)"
    if [[ "$MODE" == "update" ]]; then
      if have bun && [[ "$(command -v opencode)" == "$HOME/.bun/"* ]]; then run opencode upgrade --method bun || true; else run opencode upgrade || true; fi
    fi
  fi

  if have codex; then
    echo "Codex: $(codex --version 2>&1 | head -1)"
    if have brew && { brew list --formula 2>/dev/null | grep -Fxq "codex" || brew list --cask 2>/dev/null | grep -Fxq "codex"; }; then
      echo "Codex는 brew 관리 대상이라 brew upgrade --greedy에서 처리됨."
    fi
  fi

  if have pi; then
    echo "Pi: $(pi --version 2>&1 | head -1)"
    echo "Pi는 npm global package면 npm update -g에서 처리됨."
  fi

  if have ollama; then
    echo "Ollama: $(ollama --version 2>&1 | head -1)"
    if have brew && { brew list --formula 2>/dev/null | grep -Fxq "ollama" || brew list --cask 2>/dev/null | grep -Fxq "ollama"; }; then
      echo "Ollama는 brew 관리 대상이라 brew upgrade에서 처리됨."
    else
      say_warn "Ollama 앱/CLI가 Homebrew 관리가 아니면 앱 자체 업데이터 또는 https://ollama.com/download 필요."
    fi
    if [[ "$INCLUDE_OLLAMA_MODELS" == 1 && "$MODE" == "update" ]]; then
      say_warn "설치된 Ollama 모델을 모두 pull함. 시간이 오래 걸릴 수 있음."
      while read -r model _; do
        [[ -z "$model" || "$model" == "NAME" ]] && continue
        run ollama pull "$model" || true
      done < <(ollama list 2>/dev/null || true)
    fi
  fi
}

gui_inventory() {
  say_step "GUI 앱 관리 상태"
  for app in "LM Studio" "Ollama" "Claude" "Codex" "Hermes"; do
    [[ -d "/Applications/$app.app" ]] && echo "감지: /Applications/$app.app"
    [[ -d "$HOME/Applications/$app.app" ]] && echo "감지: $HOME/Applications/$app.app"
  done
  if have brew; then
    echo
    echo "관련 brew cask/formula:"
    (brew list --cask --versions 2>/dev/null; brew list --formula --versions 2>/dev/null) | grep -Ei 'lm-studio|ollama|claude|codex|hermes|opencode|open-code' || true
  fi
  say_warn "별도 .dmg/.pkg GUI 앱 번들은 임의 교체하지 않음. 서명/권한/실행 중 손상 리스크가 큼."
}

run_all() {
  [[ "$MODE" == "interactive" ]] && pick_mode_interactive
  system_summary
  version_snapshot
  ensure_helper_tools
  homebrew_updates
  app_store_updates
  runtime_updates
  ai_cli_updates
  gui_inventory
  say_step "완료"
  echo "모드: $MODE"
  echo "로그: $LOG_FILE"
}

run_all

if [[ -t 0 && "$MODE" == "interactive" ]]; then
  echo
  read -r -p "Enter를 누르면 종료합니다..." _
fi
