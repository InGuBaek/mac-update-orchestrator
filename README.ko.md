# mac-update-orchestrator

[English](README.md)

커맨드 하나로 맥북에 설치된 업데이트를 최대한 한 번에 처리하고, 무엇이 업데이트됐는지 터미널 출력과 로그 파일로 확인하기 위한 macOS 전용 업데이트 오케스트레이터입니다.

윈도우는 신경 쓰지 않습니다. macOS 로컬 개발 머신을 대상으로 합니다.

## 목표

macOS에서 업데이트 경로는 너무 많이 갈라져 있습니다.

- System Settings / `softwareupdate`
- Mac App Store
- Homebrew formula/cask
- npm global / nvm
- bun global
- uv tools
- pipx
- Python user packages
- 개별 CLI 자체 updater: Claude Code, Hermes, OpenCode 등
- standalone `.dmg`/`.pkg` GUI 앱: LM Studio, Ollama 등

`mac-update-all`은 이 경로들을 한 번에 훑고, 가능한 업데이트를 실행하며, CLI와 로그 파일에 결과를 남깁니다.

## 설치

### 한 줄 설치

```bash
curl -fsSL https://raw.githubusercontent.com/InGuBaek/mac-update-orchestrator/main/install.sh | bash
```

### GitHub에서 직접 설치

```bash
git clone https://github.com/InGuBaek/mac-update-orchestrator.git
cd mac-update-orchestrator
./install.sh
```

설치 후 사용할 수 있는 명령:

```bash
mac-update-all
mac-software-update
mac-system-update
mac-update-everything
```

`~/.local/bin`이 PATH에 없다면 셸 설정에 추가하세요.

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 로컬 체크아웃에서 바로 실행

```bash
chmod +x bin/*.command install.sh
bin/mac-update-all.command --help
```

## 가장 중요한 명령

전체 업데이트:

```bash
mac-update-all
```

전체 업데이트 가능 항목 확인만:

```bash
mac-update-all --check
```

확인 질문에 가능한 한 yes로 답하고 진행:

```bash
mac-update-all --yes
```

확인/업데이트 중 `mas` 같은 helper tool을 자동 설치하지 않기:

```bash
mac-update-all --check --no-install-helpers
```

Ollama 모델까지 모두 pull:

```bash
mac-update-all --ollama-models
```

Homebrew cleanup까지 포함:

```bash
mac-update-all --cleanup
```

시스템 업데이트는 확인만 하고 SW 업데이트만 실제 실행:

```bash
mac-update-all --system-check
```

시스템 업데이트를 완전히 건너뛰고 SW만 업데이트:

```bash
mac-update-all --skip-system
```

## 로그

기본 로그 위치:

```text
~/Library/Logs/mac-update-orchestrator/
```

각 실행마다 타임스탬프가 붙은 로그 파일이 생성됩니다.

- `mac-update-all-YYYYMMDD-HHMMSS.log`
- `software-update-YYYYMMDD-HHMMSS.log`
- `system-update-YYYYMMDD-HHMMSS.log`

로그 위치를 바꾸려면:

```bash
MAC_UPDATE_LOG_DIR="$HOME/Desktop/update-logs" mac-update-all
```

## 명령 구성

### `mac-update-all`

사용자가 주로 쓰는 단일 진입점입니다.

기본 동작:

1. 일상 SW 업데이트 실행
2. macOS 시스템 업데이트 설치 시도
3. 각 단계 결과를 CLI와 로그에 출력

강제 재시작은 하지 않습니다. macOS 설치나 권한 승인이 필요하면 실행 중 macOS 또는 CLI가 사용자 동의를 요청합니다.

### `mac-software-update`

자주 실행할 SW 업데이트만 처리합니다.

```bash
mac-software-update --check
mac-software-update --update --install-helpers
```

포함 범위:

- Homebrew
  - `brew update`
  - `brew upgrade --greedy`
  - 선택적으로 `brew cleanup`
- Mac App Store
  - `mas outdated`
  - `mas upgrade`
  - `mas`가 없으면 `--install-helpers`로 설치 가능
- Node 계열
  - nvm 감지
  - 최신 LTS 설치 및 npm 최신화
  - 설치된 Node major 라인 최신 patch 갱신
  - npm global package 업데이트
  - npm/corepack 최신화
  - pnpm/yarn corepack 활성화
  - bun 자체 및 bun global package 업데이트
- Python 계열
  - Homebrew Python은 brew에서 처리
  - uv tools 업데이트
  - pipx 업데이트
  - Python user package outdated 확인 및 일괄 업데이트
  - pip/setuptools/wheel 업데이트
  - pyenv 자체 업데이트 감지
- AI/dev CLI
  - Claude Code: `claude update`
  - Hermes: `hermes update --yes`
  - OpenCode: `opencode upgrade`
  - Codex: Homebrew 관리 대상이면 brew에서 처리
  - Pi: npm global package면 npm update에서 처리
  - Ollama: CLI/App 감지, 모델 pull은 옵션화

### `mac-system-update`

macOS 시스템 업데이트 전용입니다.

```bash
mac-system-update --check
mac-system-update --download
mac-system-update --install
```

내부적으로 다음을 사용합니다.

- `softwareupdate -l`
- `softwareupdate --download --all`
- `softwareupdate --install --all`

강제 재시작 옵션은 쓰지 않습니다.

## 안전 정책

자동화하되, 개발 환경을 망가뜨리지 않는 쪽을 우선합니다.

하지 않는 것:

- `softwareupdate --restart`로 강제 재시작
- `/usr/bin/python3`나 `/usr/bin/gem` 같은 macOS 시스템 영역을 sudo로 강제 수정
- `.dmg`/`.pkg`로 설치된 GUI 앱 번들을 임의 교체
- pyenv Python 새 버전을 프로젝트 호환성 검증 없이 자동 설치

대신 하는 것:

- Homebrew/App Store/npm/pipx/uv/bun처럼 package manager가 책임지는 경로를 업데이트
- standalone 앱은 감지하고 로그에 남김
- 필요한 권한 요청은 실행 중 사용자 동의로 처리

## 개발

문법 검사:

```bash
bash -n bin/*.command install.sh
```

개인 경로/API key/token 유출 검사:

```bash
scripts/security-scan.sh
```

public push 전에는 반드시 이 검사를 통과해야 합니다. 현재 파일만 고치는 것으로 부족하고, git history에 남은 경우 history도 정리해야 합니다.

독립 Codex 리뷰 게이트:

```bash
scripts/codex-review.sh
```

프로젝트 규칙: Claude Code 또는 다른 에이전트가 변경을 구현할 수 있지만, 의미 있는 업데이트는 push 또는 release 전에 OpenAI Codex가 독립 리뷰해야 합니다. 리뷰 리포트는 `docs/reviews/` 아래에 저장됩니다. 리뷰 체크리스트는 [`docs/code-review.md`](docs/code-review.md)에 유지하며, 리뷰 기준이 바뀔 때마다 함께 업데이트해야 합니다.

기여 워크플로우:

- 먼저 [`AGENTS.md`](AGENTS.md)를 읽으세요. Claude Code, Codex, OpenCode, Hermes, OpenClaw 및 기타 에이전트를 위한 canonical 가이드입니다.
- `main` 변경은 pull request를 사용합니다.
- `main`은 maintainer approval과 CI check가 필요한 protected branch입니다.
- 공개 기여 흐름은 [`CONTRIBUTING.md`](CONTRIBUTING.md)를 참고하세요.
- 짧은 다국어 quickstart는 [`docs/i18n/`](docs/i18n/) 아래에 있습니다.
- 코드 변경이 README 동작 설명에 영향을 주면 `scripts/doc-impact-check.sh`를 실행해 문서 drift를 잡습니다.
- 의미 있는 변경은 push 또는 release 전에 독립 Codex review를 받는 것을 원칙으로 합니다. 리뷰 리포트는 필요하면 `docs/reviews/` 아래에 저장하고, 체크리스트는 [`docs/code-review.md`](docs/code-review.md)에 둡니다.

체크 실행:

```bash
bin/software-update.command --check
bin/system-update.command --check
```

설치 테스트:

```bash
./install.sh
mac-update-all --help
```

## 라이선스

MIT
