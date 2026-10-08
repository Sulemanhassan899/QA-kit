#!/usr/bin/env bash
# Promote an approved draft into the official catalog (HUMAN gate).
# Usage: promote-draft.sh <QA_ROOT> <DRAFT-ID>
set -euo pipefail

QA_ROOT="${1:?QA_ROOT required}"
DRAFT_ID="${2:?DRAFT-ID required}"

DRAFT_FILE="$QA_ROOT/catalog/drafts/${DRAFT_ID}.json"
INDEX="$QA_ROOT/catalog/drafts/index.json"
CATALOG="$QA_ROOT/catalog/scenarios.json"

if [ ! -f "$DRAFT_FILE" ]; then
  echo "ERROR: missing $DRAFT_FILE" >&2
  exit 1
fi

node <<NODE
const fs = require('fs');
const draftPath = ${JSON.stringify("$DRAFT_FILE")};
const catalogPath = ${JSON.stringify("$CATALOG")};
const indexPath = ${JSON.stringify("$INDEX")};
const draftId = ${JSON.stringify("$DRAFT_ID")};

const draft = JSON.parse(fs.readFileSync(draftPath, 'utf8'));
const scenario = draft.scenario || draft;
if (!scenario.id || !scenario.steps || !scenario.expected) {
  console.error('ERROR: draft missing id/steps/expected');
  process.exit(1);
}
// Strip draft-only fields
delete scenario.draft;
delete scenario.status;
delete scenario.proposed_by;
delete scenario.proposed_at;

const catalog = JSON.parse(fs.readFileSync(catalogPath, 'utf8'));
if (catalog.some((c) => c.id === scenario.id)) {
  console.error('ERROR: id already in catalog: ' + scenario.id);
  process.exit(1);
}
catalog.push(scenario);
fs.writeFileSync(catalogPath, JSON.stringify(catalog, null, 2) + '\n');

let index = { drafts: [], max_open: 10 };
try { index = JSON.parse(fs.readFileSync(indexPath, 'utf8')); } catch {}
index.drafts = (index.drafts || []).map((d) => {
  if (d.id === draftId || d.id === scenario.id) {
    return { ...d, status: 'approved', promoted_at: new Date().toISOString(), catalog_id: scenario.id };
  }
  return d;
});
index.updated_at = new Date().toISOString();
fs.writeFileSync(indexPath, JSON.stringify(index, null, 2) + '\n');

// Mark draft file
draft.status = 'approved';
draft.promoted_at = new Date().toISOString();
fs.writeFileSync(draftPath, JSON.stringify(draft, null, 2) + '\n');
console.log('Promoted', scenario.id, 'into catalog. Total cases:', catalog.length);
NODE
