# AGENTS.md

이 저장소는 macOS 전용 업데이트 오케스트레이터입니다.

## 목표

사용자가 `mac-update-all` 하나로 맥북에 설치된 가능한 모든 업데이트를 실행하고, 결과를 CLI와 로그 파일에서 확인할 수 있어야 합니다.

## 원칙

1. macOS만 지원합니다. Windows/Linux 호환성에 시간을 쓰지 않습니다.
2. 안전한 package manager 경로를 우선합니다.
   - Homebrew
   - Mac App Store / mas
   - npm/nvm/corepack/bun
   - uv/pipx/pip user packages
   - 개별 CLI updater
3. macOS 시스템 영역을 sudo로 억지 수정하지 않습니다.
4. standalone `.dmg`/`.pkg` GUI 앱 번들을 임의로 교체하지 않습니다.
5. 실행 결과는 반드시 터미널과 로그에 남깁니다.
6. 변경 단위마다 git commit을 남깁니다.
7. 개인 홈 디렉토리, 계정명, 이메일, API key, token, secret-like 문자열을 커밋하지 않습니다.
8. public push 전 `scripts/security-scan.sh`를 실행하고, 문제가 있으면 수정뿐 아니라 git history도 정리합니다.

## 검증

변경 후 최소 검증:

```bash
bash -n bin/*.command install.sh
scripts/security-scan.sh
bin/software-update.command --check
bin/system-update.command --check
./install.sh
mac-update-all --help
```

실제 업데이트 실행은 로컬 머신 상태를 변경합니다. 필요하면 `--check`부터 확인하세요.

## 파일 구조

- `bin/mac-update-all.command`: 단일 진입점
- `bin/software-update.command`: App Store, Brew, Python, Node, AI/dev CLI 등 일상 SW 업데이트
- `bin/system-update.command`: macOS 시스템 업데이트
- `bin/update-everything.command`: 호환용 래퍼
- `install.sh`: `~/.local/bin`에 명령 설치
- `docs/improvements.md`: 설계 변화와 향후 개선 기록

## 문서 스타일

한국어를 기본으로 작성합니다. 명령어, 파일명, 경로, 환경변수는 원문 그대로 둡니다.
