#!/usr/bin/env bash
set -euo pipefail
PREFERRED="${1:-}"

if ! command -v adb >/dev/null 2>&1; then
  echo "ERROR: adb not found" >&2
  exit 1
fi

FIRST=""
# adb devices lines: "<serial><tabs/spaces>device ..."
while IFS= read -r line; do
  case "$line" in
    ""|"List of devices attached") continue ;;
  esac
  id=$(printf '%s' "$line" | awk '{print $1}')
  state=$(printf '%s' "$line" | awk '{print $2}')
  [ -z "$id" ] && continue
  [ "$state" != "device" ] && continue
  if [ -n "$PREFERRED" ] && [ "$id" = "$PREFERRED" ]; then
    echo "$id"
    exit 0
  fi
  if [ -z "$FIRST" ]; then
    FIRST="$id"
  fi
done <<ADBOUT
$(adb devices)
ADBOUT

if [ -n "$FIRST" ]; then
  echo "$FIRST"
  exit 0
fi

echo "ERROR: no adb device online" >&2
exit 2
