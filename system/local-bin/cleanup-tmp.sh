#!/bin/bash
set -euo pipefail

TMP_DIR="$HOME/tmp"
LOG="$HOME/.local/share/cleanup-tmp.log"
DAYS_OLD=30

mkdir -p "$(dirname "$LOG")"

NOW=$(date "+%Y-%m-%d %H:%M:%S")
log() { echo "[$NOW] $1" >> "$LOG"; }
log "tmp cleanup started"

if [[ -d "$TMP_DIR" ]]; then
    find "$TMP_DIR" -maxdepth 1 -mindepth 1 -mtime +${DAYS_OLD} | while read -r f; do
        basename_f=$(basename "$f")
        if command -v trash &>/dev/null; then
            trash "$f"
        else
            mv "$f" "$HOME/.Trash/"
        fi
        log "TRASHED (${DAYS_OLD}d old) $basename_f"
    done
fi

if [[ -f "$LOG" ]]; then
    tail -200 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi

log "tmp cleanup complete"
