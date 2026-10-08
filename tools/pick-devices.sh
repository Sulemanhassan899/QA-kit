#!/usr/bin/env bash
# List up to N ready adb devices (one per line). Optional preferred serials after count.
# Usage: pick-devices.sh [count] [preferred_serial ...]
set -euo pipefail

COUNT="${1:-5}"
if [ "$#" -gt 0 ]; then shift; fi

if ! command -v adb >/dev/null 2>&1; then
  echo "ERROR: adb not found" >&2
  exit 1
fi

READY="$(adb devices | awk 'NR>1 && $2=="device" {print $1}')"
if [ -z "$READY" ]; then
  echo "ERROR: no adb device online" >&2
  exit 2
fi

SELECTED=""
append_unique() {
  local id="$1"
  echo "$SELECTED" | grep -qxF "$id" && return 0
  if [ -z "$SELECTED" ]; then
    SELECTED="$id"
  else
    SELECTED="$SELECTED
$id"
  fi
}

for pref in "$@"; do
  [ -z "$pref" ] && continue
  echo "$READY" | grep -qxF "$pref" && append_unique "$pref"
done

while IFS= read -r d; do
  [ -z "$d" ] && continue
  cur="$(printf '%s\n' "$SELECTED" | sed '/^$/d' | wc -l | tr -d ' ')"
  [ "$cur" -ge "$COUNT" ] && break
  append_unique "$d"
done <<EOF
$READY
EOF

printed=0
while IFS= read -r d; do
  [ -z "$d" ] && continue
  [ "$printed" -ge "$COUNT" ] && break
  echo "$d"
  printed=$((printed + 1))
done <<EOF
$SELECTED
EOF

if [ "$printed" -eq 0 ]; then
  echo "ERROR: no adb device online" >&2
  exit 2
fi
