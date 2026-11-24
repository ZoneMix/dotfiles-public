#!/usr/bin/env bash
pmset -g batt 2>/dev/null | awk '/InternalBattery/ {gsub(/;/,""); printf "BAT: %s", $3}'
