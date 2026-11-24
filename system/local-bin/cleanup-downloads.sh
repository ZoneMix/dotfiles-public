#!/bin/bash
# cleanup-downloads.sh — Auto-clean ~/Downloads on a schedule
# Deletes files older than 30 days. Add your own auto-move rules in Phase 1.

set -euo pipefail

DOWNLOADS="$HOME/Downloads"
LOG="$HOME/.local/share/cleanup-downloads.log"
mkdir -p "$(dirname "$LOG")"

DAYS_OLD=30
NOW=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$NOW] Cleanup started" >> "$LOG"

deleted=0
moved=0

# Skip list (never touch these)
skip_pattern="CLAUDE\.md|\.DS_Store|\.localized"

# --- Phase 1: Auto-move known file types ---

# .ics calendar files older than 7 days → delete
find "$DOWNLOADS" -maxdepth 1 -type f -name "*.ics" -mtime +7 -exec rm {} \; -exec sh -c 'echo "[$0] DELETED $(basename $1)" >> "$2"' "$NOW" {} "$LOG" \;

# .dmg installers older than 7 days → delete (already installed)
find "$DOWNLOADS" -maxdepth 1 -type f -name "*.dmg" -mtime +7 -exec rm {} \; -exec sh -c 'echo "[$0] DELETED $(basename $1)" >> "$2"' "$NOW" {} "$LOG" \;

# .exe files older than 7 days → delete (wrong platform or already used)
find "$DOWNLOADS" -maxdepth 1 -type f -name "*.exe" -mtime +7 -exec rm {} \; -exec sh -c 'echo "[$0] DELETED $(basename $1)" >> "$2"' "$NOW" {} "$LOG" \;

# .pkpass files older than 7 days → delete (expired passes)
find "$DOWNLOADS" -maxdepth 1 -type f -name "*.pkpass" -mtime +7 -exec rm {} \; -exec sh -c 'echo "[$0] DELETED $(basename $1)" >> "$2"' "$NOW" {} "$LOG" \;

# --- Phase 2: Delete anything older than 30 days ---

find "$DOWNLOADS" -maxdepth 1 -mindepth 1 -mtime +${DAYS_OLD} | while read -r f; do
    basename_f=$(basename "$f")
    # Skip protected files
    if echo "$basename_f" | grep -qE "$skip_pattern"; then
        continue
    fi
    rm -rf "$f"
    echo "[$NOW] DELETED (${DAYS_OLD}d old) $basename_f" >> "$LOG"
    ((deleted++)) || true
done

# --- Phase 3: Remove empty 0-byte files (broken downloads) ---

find "$DOWNLOADS" -maxdepth 1 -type f -empty | while read -r f; do
    basename_f=$(basename "$f")
    if echo "$basename_f" | grep -qE "$skip_pattern"; then
        continue
    fi
    rm "$f"
    echo "[$NOW] DELETED (empty) $basename_f" >> "$LOG"
    ((deleted++)) || true
done

# --- Phase 4: Deduplicate "(1)" style files ---

find "$DOWNLOADS" -maxdepth 1 -type f -name "* (1)*" -o -name "* (2)*" -o -name "* (3)*" -o -name "* (4)*" -o -name "* (5)*" | while read -r f; do
    basename_f=$(basename "$f")
    # Only delete if older than 7 days (give user time to pick the right one)
    if [[ $(find "$f" -mtime +7 -print) ]]; then
        rm "$f"
        echo "[$NOW] DELETED (duplicate) $basename_f" >> "$LOG"
        ((deleted++)) || true
    fi
done

# Trim log to last 500 lines
if [[ -f "$LOG" ]]; then
    tail -500 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi

echo "[$NOW] Cleanup complete" >> "$LOG"
