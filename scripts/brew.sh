#!/usr/bin/env bash

if ! command -v brew &>/dev/null; then
  echo "  ERROR: Homebrew not found. Run bootstrap.sh first."
  return 1
fi

export HOMEBREW_CASK_OPTS="--adopt"

wanted_taps=()
for bf in "$DOTFILES"/Brewfile; do
  [[ -f "$bf" ]] || continue
  while IFS= read -r tap; do
    wanted_taps+=("$tap")
  done < <(grep '^tap ' "$bf" | sed 's/tap "\([^"]*\)".*/\1/')
done

while IFS= read -r tap; do
  [[ "$tap" == homebrew/* ]] && continue
  wanted=0
  for w in "${wanted_taps[@]}"; do
    [[ "$tap" == "$w" ]] && { wanted=1; break; }
  done
  if [[ "$wanted" == "0" ]]; then
    if ! brew list --full-name 2>/dev/null | grep -q "^${tap}/"; then
      echo "  Removing stale tap: $tap"
      brew untap "$tap" 2>/dev/null || true
    else
      echo "  Keeping $tap (has installed formulae)"
    fi
  fi
done < <(brew tap 2>/dev/null)

if [[ -f "$DOTFILES/Brewfile" ]]; then
  echo "  Installing core packages from Brewfile..."
  if ! brew bundle --file="$DOTFILES/Brewfile" --no-upgrade; then
    echo "  Some cask installs were skipped (apps already exist with different versions)."
    echo "  This is normal — run 'brew upgrade --cask' to update them."
  fi
  echo "  Core packages complete."
else
  echo "  WARNING: No Brewfile found at $DOTFILES/Brewfile"
fi

