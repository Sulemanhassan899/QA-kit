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
for f in 00-orchestrator.md 08-screen-debug.md 07-reporter.md 09-learn.md 10-shard-worker.md; do
  if [ -f "$KIT/agents/$f" ] && [ ! -f "$DEST/agents/$f" ]; then
    cp "$KIT/agents/$f" "$DEST/agents/$f"
  fi
done
if [ ! -f "$DEST/WAKE.md" ]; then
  cp "$KIT/WAKE.md" "$DEST/WAKE.md"
fi
if [ ! -f "$DEST/RULES.md" ]; then
  cp "$KIT/RULES.md" "$DEST/RULES.md"
fi

# Core + parallel tools
for t in pick-device.sh pick-devices.sh plan-run.sh promote-draft.sh filter-catalog.mjs merge-shards.mjs; do
  if [ -f "$KIT/tools/$t" ]; then
    cp -f "$KIT/tools/$t" "$DEST/tools/$t"
  fi
done
chmod +x "$DEST/tools/"*.sh 2>/dev/null || true

# Parallel / learn catalog templates
TEMPLATE_CATALOG="$KIT/templates/catalog"
if [ -d "$TEMPLATE_CATALOG" ]; then
  mkdir -p "$DEST/catalog/profiles" "$DEST/catalog/drafts"
  cp -n "$TEMPLATE_CATALOG/shards.json" "$DEST/catalog/" 2>/dev/null || true
  cp -n "$TEMPLATE_CATALOG/shards.yaml" "$DEST/catalog/" 2>/dev/null || true
  cp -n "$TEMPLATE_CATALOG/profiles/profiles.yaml" "$DEST/catalog/profiles/" 2>/dev/null || true
  cp -n "$TEMPLATE_CATALOG/drafts/README.md" "$DEST/catalog/drafts/" 2>/dev/null || true
  cp -n "$TEMPLATE_CATALOG/drafts/index.json" "$DEST/catalog/drafts/" 2>/dev/null || true
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
