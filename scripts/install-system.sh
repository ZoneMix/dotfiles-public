#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "$0")/.." && pwd)}"

echo "  Installing system scripts..."

mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES/system/local-bin"/*.sh; do
  [[ -f "$script" ]] || continue
  name="$(basename "$script")"
  dest="$HOME/.local/bin/$name"
  if ! cmp -s "$script" "$dest" 2>/dev/null; then
    cp "$script" "$dest"
    chmod +x "$dest"
    echo "    Updated $name"
  else
    echo "    $name already up to date."
  fi
done

mkdir -p "$HOME/Library/LaunchAgents"
for plist in "$DOTFILES/system/launchd"/*.plist; do
  [[ -f "$plist" ]] || continue
  name="$(basename "$plist")"
  dest="$HOME/Library/LaunchAgents/$name"
  transformed="$(sed "s|__HOME__|${HOME}|g" "$plist")"
  if [[ -f "$dest" ]] && echo "$transformed" | cmp -s "$dest" - 2>/dev/null; then
    echo "    $name already up to date."
  else
    echo "$transformed" > "$dest"
    launchctl bootout "gui/$(id -u)/$name" 2>/dev/null || true
    launchctl load "$dest" 2>/dev/null || true
    echo "    Installed $name"
  fi
done

echo "  System scripts installed."
