#!/usr/bin/env bash
# Install QA Kit into Cursor (run from the cloned repo root).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$HOME/.cursor/rules"
cp "$ROOT/cursor-rules/qa-wake-global.mdc" "$HOME/.cursor/rules/qa-wake-global.mdc"
ln -sfn "$ROOT" "$HOME/Documents/cursor-qa"

echo "Installed Cursor rule → ~/.cursor/rules/qa-wake-global.mdc"
echo "Symlink → ~/Documents/cursor-qa → $ROOT"
echo "Next: bash tools/init-project-qa.sh /path/to/your/app"
