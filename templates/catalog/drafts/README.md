# Draft scenarios (not official)

Agents may **propose** new cases here after fails or gaps (`09-learn.md`).

## Rules
- Drafts are **never** executed as part of Pass/Fail totals for release until promoted.
- Max **10** open drafts at a time (orchestrator / learn agent must stop proposing if over cap).
- Human must promote: `bash tools/promote-draft.sh <draft-id>`.

## Layout
```text
catalog/drafts/<DRAFT-ID>.json   # single scenario object (same shape as catalog)
catalog/drafts/index.json        # list of open drafts + status
```

Status values: `proposed` → `approved` (copied into `scenarios.json`) or `rejected`.
