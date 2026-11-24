#!/bin/bash
set -euo pipefail

DESKTOP="$HOME/Desktop"
LOG="$HOME/.local/share/cleanup-desktop.log"
DAYS_OLD=14

mkdir -p "$(dirname "$LOG")"

NOW=$(date "+%Y-%m-%d %H:%M:%S")
log() { echo "[$NOW] $1" >> "$LOG"; }
log "Desktop cleanup started"

skip_pattern="\.DS_Store|\.localized"

# Move aged files and directories to macOS Trash
find "$DESKTOP" -maxdepth 1 -mindepth 1 -mtime +${DAYS_OLD} | while read -r f; do
    basename_f=$(basename "$f")
    if echo "$basename_f" | grep -qE "$skip_pattern"; then
        continue
    fi
    if command -v trash &>/dev/null; then
        trash "$f"
    else
        mv "$f" "$HOME/.Trash/"
    fi
    log "TRASHED (${DAYS_OLD}d old) $basename_f"
done

# Remove empty 0-byte files older than 7 days
find "$DESKTOP" -maxdepth 1 -type f -empty -mtime +7 | while read -r f; do
    basename_f=$(basename "$f")
    if echo "$basename_f" | grep -qE "$skip_pattern"; then
        continue
    fi
    rm "$f"
    log "DELETED (empty) $basename_f"
done

if [[ -f "$LOG" ]]; then
    tail -300 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi

log "Desktop cleanup complete"
