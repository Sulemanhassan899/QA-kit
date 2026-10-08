#!/usr/bin/env bash
set -euo pipefail
WS="${1:-}"
if [ -z "$WS" ] || [ ! -d "$WS" ]; then
  echo "Usage: init-project-qa.sh /path/to/workspace" >&2
  exit 1
fi
WS="$(cd "$WS" && pwd)"
NAME="$(basename "$WS")"

if [ -d "$HOME/Documents/QA-kit" ]; then
  KIT="$HOME/Documents/QA-kit"
elif [ -d "$HOME/Documents/cursor-qa" ]; then
  KIT="$HOME/Documents/cursor-qa"
else
  KIT="$HOME/Documents/QA-kit"
fi

DEST="$KIT/projects/$NAME"
REG="$KIT/projects/registry.yaml"

mkdir -p "$DEST"/{agents,catalog,results,reports,tools}
if [ ! -f "$DEST/credentials.local.yaml" ]; then
  cp "$KIT/templates/credentials.example.yaml" "$DEST/credentials.local.yaml"
fi
if [ ! -f "$DEST/credentials.example.yaml" ]; then
  cp "$KIT/templates/credentials.example.yaml" "$DEST/credentials.example.yaml"
fi
if [ ! -f "$DEST/catalog/scenarios.json" ]; then
  echo '[]' > "$DEST/catalog/scenarios.json"
fi
for f in 00-orchestrator.md 08-screen-debug.md 07-reporter.md; do
  if [ ! -f "$DEST/agents/$f" ]; then
    cp "$KIT/agents/$f" "$DEST/agents/$f"
  fi
done
if [ ! -f "$DEST/WAKE.md" ]; then
  cp "$KIT/WAKE.md" "$DEST/WAKE.md"
fi
if [ ! -f "$DEST/RULES.md" ]; then
  cp "$KIT/RULES.md" "$DEST/RULES.md"
fi
if [ ! -f "$DEST/tools/pick-device.sh" ]; then
  cp "$KIT/tools/pick-device.sh" "$DEST/tools/pick-device.sh"
  chmod +x "$DEST/tools/pick-device.sh"
fi

if [ -f "$REG" ] && ! grep -q "$WS" "$REG" 2>/dev/null; then
  if grep -q 'projects: {}' "$REG"; then
    cat > "$REG" <<YAML
# Maps workspace folders → QA data roots.
projects:
  ${NAME}:
    workspace_paths:
      - ${WS}
    qa_root: ${DEST}
YAML
  else
    cat >> "$REG" <<YAML

  ${NAME}:
    workspace_paths:
      - ${WS}
    qa_root: ${DEST}
YAML
  fi
fi

echo "QA_ROOT=$DEST"
echo "Edit credentials: $DEST/credentials.local.yaml"
