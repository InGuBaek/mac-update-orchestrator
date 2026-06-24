# 개선 사항 기록

## 2026-06-25 초기 정리

처음 목표는 “맥북에 설치된 모든 업데이트를 한 번에 확인/다운로드/실행하는 스크립트”였습니다.

작업 중 실제 요구가 더 명확해졌습니다.

- 사용자가 원하는 것은 커맨드 하나입니다.
- 업데이트 결과는 CLI와 로그 파일로 보여야 합니다.
- macOS 시스템 업데이트와 일상 SW 업데이트는 내부적으로 분리되어야 합니다.
- 하지만 사용자는 `mac-update-all` 하나만 실행하면 됩니다.
- public GitHub repo에 저장하고 누구나 받아 설치할 수 있어야 합니다.

## 구조

- `bin/mac-update-all.command`
  - 단일 진입점
  - SW 업데이트 후 시스템 업데이트 흐름 실행
- `bin/software-update.command`
  - 자주 실행하는 일상 SW 업데이트
- `bin/system-update.command`
  - macOS 시스템 업데이트 전용
- `bin/update-everything.command`
  - 호환용 래퍼
- `install.sh`
  - `~/.local/bin`에 명령 설치

## 추가된 업데이트 범위

### Node 계열

- nvm 감지
- 최신 LTS 설치 및 npm 최신화
- 설치된 Node major 라인을 최신 patch로 갱신
- npm global package outdated 확인 및 업데이트
- npm/corepack 최신화
- pnpm/yarn corepack 활성화
- bun 자체 및 bun global package 업데이트
- Pi CLI 감지

### Python 계열

- Homebrew Python은 brew에서 처리
- uv tool 업데이트
- pipx 업데이트
- Python user package outdated 확인 및 일괄 업데이트
- pip/setuptools/wheel 업데이트
- pyenv 자체 업데이트 감지

### AI/dev CLI

- Claude Code: `claude update`
- Hermes: `hermes update --yes`
- OpenCode: `opencode upgrade`
- Codex: brew 관리 대상이면 brew에서 처리
- Pi: npm global package면 npm update에서 처리
- Ollama: CLI/App 감지, 모델 pull은 옵션화

## 안전 정책

다음은 일부러 자동화하지 않았습니다.

1. macOS 시스템 업데이트 강제 재시작
   - `softwareupdate --restart`는 사용하지 않음

2. standalone GUI 앱 번들 강제 교체
   - LM Studio, Ollama, Claude 같은 `.dmg`/`.pkg` 설치 앱은 서명/권한/실행 중 교체 문제가 있음
   - Homebrew cask/App Store 관리 대상이면 자동 업데이트
   - 그렇지 않으면 앱 자체 updater 또는 공식 다운로드 안내

3. 시스템 Python/RubyGems에 sudo 사용
   - `/usr/bin/python3`, `/usr/bin/gem`은 macOS 시스템 영역
   - user package 또는 Homebrew 관리 경로만 업데이트

4. pyenv Python 새 버전 자동 설치
   - 프로젝트별 호환성을 깨기 쉬움
   - pyenv 자체 업데이트까지만 자동화

## 로컬 검증에서 확인된 환경 유형

구체적인 사용자 홈 디렉토리나 계정명은 저장소에 기록하지 않습니다. 검증 기록은 재현에 필요한 설치 유형만 남깁니다.

- Apple Silicon macOS
- Homebrew 기반 패키지 관리자
- Claude Code CLI
- Codex CLI, Homebrew cask 관리
- Pi CLI, Node global package 경로에서 감지
- OpenCode CLI, bun global 경로에서 감지
- Hermes CLI
- Ollama CLI/App, standalone 설치 유형으로 감지
- LM Studio GUI 앱
- Node/npm: bundled Node symlink와 nvm 환경이 함께 존재하는 유형
- Python: Homebrew Python과 macOS system Python이 함께 존재하는 유형

## 향후 개선 후보

- `--dry-run` JSON 리포트 출력
- launchd 주기 실행 plist 생성
- Slack/Telegram 알림 연동
- standalone GUI 앱의 Sparkle feed 감지
- `mise`/`asdf`/`volta` 감지 추가
- 업데이트 실패 항목만 재시도하는 `--retry-failed`
- 마지막 성공 버전 스냅샷 저장 및 diff 출력
- Homebrew Bundle `Brewfile` export/import 지원
