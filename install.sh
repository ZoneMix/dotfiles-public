#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
export DOTFILES

usage() {
  echo "Usage: ./install.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --help       Show this help message"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: This install script is macOS only."
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "WARNING: Not Apple Silicon — Homebrew paths may differ."
fi

echo "==> Phase 1: Bootstrap (Xcode CLT, Homebrew, stow)"
source "$DOTFILES/scripts/bootstrap.sh"

echo "==> Phase 2: Brew packages"
source "$DOTFILES/scripts/brew.sh"

echo "==> Phase 3: Post-install (OMZ, p10k, TPM, nvim plugins)"
source "$DOTFILES/scripts/post-install.sh"

echo "==> Phase 4: Symlinks (stow)"
source "$DOTFILES/scripts/link.sh"

echo "==> Phase 5: System scripts (launchd, local-bin)"
source "$DOTFILES/scripts/install-system.sh"

echo "==> Phase 6: Verification"
source "$DOTFILES/scripts/verify.sh"

echo ""
echo "=========================================="
echo " Installation complete."
echo " Open a new terminal to activate zsh."
echo "=========================================="
echo ""
echo " REQUIRED MANUAL STEPS:"
echo " 1. Set your name and email in ~/.gitconfig (git/.gitconfig in this repo)"
echo " 2. Put secrets and machine-specific exports in ~/.profile.local"
echo " 3. gh auth login (if on a fresh machine)"
echo ""
