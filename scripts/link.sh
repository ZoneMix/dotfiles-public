#!/usr/bin/env bash

if [[ -z "${DOTFILES:-}" ]]; then
  DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
  export DOTFILES
fi

# Ensure Homebrew is in PATH (needed when run standalone outside install.sh)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

PACKAGES=(shell zsh git tmux kitty wm nvim cmux ghostty)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
STOW_FAILURES=0
BACKED_UP=0

for pkg in "${PACKAGES[@]}"; do
  if [[ ! -d "$DOTFILES/$pkg" ]]; then
    echo "  Skipping $pkg (not found)"
    continue
  fi

  echo "  Stowing $pkg..."

  # Back up non-symlink files that would conflict with stow.
  # Uses process substitution to avoid subshell issues with piped while loops.
  while IFS= read -r file; do
    target="$HOME/${file#./}"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "    Backing up $target"
      mkdir -p "$(dirname "$BACKUP_DIR/${file#./}")"
      mv "$target" "$BACKUP_DIR/${file#./}"
      BACKED_UP=1
    fi
  done < <(cd "$DOTFILES/$pkg" && find . -type f)

  # Stow the package. Continue on failure so remaining packages still get stowed.
  if ! stow --no-folding --dir="$DOTFILES" --target="$HOME" --restow "$pkg" 2>&1; then
    echo "  WARNING: stow failed for $pkg"
    ((STOW_FAILURES++)) || true
  fi
done

chmod +x "$HOME/.config/yabai/yabairc" 2>/dev/null || true
chmod +x "$HOME/.config/skhd/skhdrc" 2>/dev/null || true
chmod +x "$HOME/.config/spacebar/spacebarrc" 2>/dev/null || true

if [[ "$BACKED_UP" -eq 1 ]]; then
  echo "  Conflicting files backed up to $BACKUP_DIR"
fi

if [[ "$STOW_FAILURES" -gt 0 ]]; then
  echo "  WARNING: $STOW_FAILURES package(s) failed to stow — run verify.sh for details"
else
  echo "  Symlinks created."
fi
