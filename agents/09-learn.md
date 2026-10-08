# 09 — Learn / draft (human promote gate)

## Purpose
After a run (or mid-run fails), propose **new** scenario drafts from real gaps. Improve coverage over time **without** lowering Pass/Fail integrity.

## Allowed write paths
```
$QA_ROOT/catalog/drafts/**
$QA_ROOT/results/<run_id>/learn/**
```

Also may update `catalog/drafts/index.json`.

## Forbidden
- Editing `<APP_ROOT>/`
- Editing official `catalog/scenarios.json` (only humans via `promote-draft.sh`)
- Counting drafts in release Pass/Fail totals
- Inventing Pass for cases that were not run
- More than **10** open (`proposed`) drafts in `index.json`

## When to draft
- Repeated Fail with a clear missing regression case
- Gap vs app screens discovered during QA
- Flaky area that needs a tighter expected/steps

## Draft file shape
Write `catalog/drafts/<DRAFT-ID>.json`:
```json
{
  "id": "DRAFT-20261009-001",
  "status": "proposed",
  "proposed_by": "09-learn",
  "proposed_at": "ISO-8601",
  "reason": "why this case",
  "source_run_id": "<run_id>",
  "source_case_ids": ["EMP-CLK-001"],
  "scenario": {
    "id": "EMP-CLK-0xx",
    "role": "employee",
    "module": "Clock Module",
    "screen": "...",
    "functionality": "...",
    "online": true,
    "offline": false,
    "layer": "A",
    "tags": ["regression"],
    "steps": ["..."],
    "expected": "..."
  }
}
```

Update `catalog/drafts/index.json` with the new entry (`status: proposed`).

## Human approval (required)
Drafts stay **unofficial** until:
```bash
bash $QA_ROOT/tools/promote-draft.sh \
  $QA_ROOT <DRAFT-ID>
```

Do **not** promote yourself unless the user explicitly asks to promote a draft.

## Caps
- Max 10 open `proposed` drafts
- Max 5 new drafts per run
- Reject duplicates of existing catalog ids / near-identical steps
