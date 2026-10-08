#!/usr/bin/env bash
set -euo pipefail
WS="${1:-$(pwd)}"
WS="$(cd "$WS" && pwd)"

if [ -d "$HOME/Documents/QA-kit" ]; then
  KIT="$HOME/Documents/QA-kit"
elif [ -d "$HOME/Documents/cursor-qa" ]; then
  KIT="$HOME/Documents/cursor-qa"
else
  KIT="$HOME/Documents/QA-kit"
fi

BASE="$KIT/projects"
NAME="$(basename "$WS")"

resolve_from_registry() {
  local REGISTRY="$1"
  [ -f "$REGISTRY" ] || return 1
  local IN_MATCH=""
  while IFS= read -r line; do
    case "$line" in
      *"qa_root:"*)
        if [ -n "${IN_MATCH:-}" ]; then
          ROOT=$(printf '%s' "$line" | sed 's/.*qa_root:[[:space:]]*//' | tr -d '"' | tr -d "'")
          ROOT="${ROOT/#\~/$HOME}"
          if [ -d "$ROOT" ]; then
            echo "$ROOT"
            return 0
          fi
        fi
        ;;
      *"- $WS"*|*"$WS"*)
        IN_MATCH=1
        ;;
      [a-zA-Z0-9_-]*:*)
        if printf '%s' "$line" | grep -qE '^[[:space:]]{2}[a-zA-Z0-9_-]+:[[:space:]]*$'; then
          IN_MATCH=""
        fi
        ;;
    esac
  done < "$REGISTRY"
  return 1
}

# Prefer machine-local override (not committed)
if ROOT=$(resolve_from_registry "$KIT/projects/registry.local.yaml"); then
  echo "$ROOT"
  exit 0
fi
if ROOT=$(resolve_from_registry "$KIT/projects/registry.yaml"); then
  echo "$ROOT"
  exit 0
fi

if [ -d "$BASE/$NAME" ]; then
  # Prefer external archify-style path if present for known apps
  if [ "$NAME" = "obecno" ] && [ -d "$HOME/Documents/obecno-archify/qa" ]; then
    echo "$HOME/Documents/obecno-archify/qa"
    exit 0
  fi
  echo "$BASE/$NAME"
  exit 0
fi

if [ -d "$WS/.qa" ]; then
  echo "$WS/.qa"
  exit 0
fi

bash "$KIT/tools/init-project-qa.sh" "$WS" >/dev/null
echo "$BASE/$NAME"
