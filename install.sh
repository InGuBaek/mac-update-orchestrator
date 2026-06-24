#!/usr/bin/env bash
# Install mac-update-orchestrator commands into ~/.local/bin.

set -euo pipefail

REPO_URL="${MAC_UPDATE_REPO_URL:-https://github.com/InGuBaek/mac-update-orchestrator.git}"
INSTALL_DIR="${MAC_UPDATE_INSTALL_DIR:-$HOME/.local/share/mac-update-orchestrator}"
BIN_DIR="${MAC_UPDATE_BIN_DIR:-$HOME/.local/bin}"

say() { printf '\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mWARN: %s\033[0m\n' "$*"; }

mkdir -p "$BIN_DIR" "$(dirname "$INSTALL_DIR")"

if [[ -d "$INSTALL_DIR/.git" ]]; then
  say "Updating existing install: $INSTALL_DIR"
  git -C "$INSTALL_DIR" pull --ff-only
elif [[ -f "$(pwd)/bin/mac-update-all.command" ]]; then
  say "Installing from local checkout to $INSTALL_DIR"
  rm -rf "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  tar --exclude='.git' --exclude='logs' -cf - . | tar -C "$INSTALL_DIR" -xf -
else
  say "Cloning $REPO_URL to $INSTALL_DIR"
  if [[ -e "$INSTALL_DIR" ]]; then
    warn "Existing non-git install found at $INSTALL_DIR; replacing it"
    rm -rf "$INSTALL_DIR"
  fi
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR"/bin/*.command

ln -sf "$INSTALL_DIR/bin/mac-update-all.command" "$BIN_DIR/mac-update-all"
ln -sf "$INSTALL_DIR/bin/software-update.command" "$BIN_DIR/mac-software-update"
ln -sf "$INSTALL_DIR/bin/system-update.command" "$BIN_DIR/mac-system-update"
ln -sf "$INSTALL_DIR/bin/update-everything.command" "$BIN_DIR/mac-update-everything"

say "Installed commands"
printf '  %s\n' "$BIN_DIR/mac-update-all" "$BIN_DIR/mac-software-update" "$BIN_DIR/mac-system-update" "$BIN_DIR/mac-update-everything"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) warn "$BIN_DIR is not in PATH. Add this to your shell profile: export PATH=\"$BIN_DIR:\$PATH\"" ;;
esac

say "Try: mac-update-all --help"
