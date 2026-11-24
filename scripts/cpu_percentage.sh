#!/usr/bin/env bash
top -l 1 -n 0 2>/dev/null | awk '/CPU usage/ {printf "CPU: %s", $3}'
