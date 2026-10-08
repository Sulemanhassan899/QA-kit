# QA Hard Rules (kit-wide)

## Write boundaries
Test-run agents may only write under:
- `$QA_ROOT/results/**`
- `$QA_ROOT/reports/**`

Learn agent (`09-learn`) may also write:
- `$QA_ROOT/catalog/drafts/**`

Official catalog changes only via human `promote-draft.sh`.

## Forbidden
- Editing product app source
- Fake Pass / Fail→Pass without re-run
- Counting drafts in release totals before promote
- Sharing one punch/leave account across parallel workers

## Parallelism
- Up to 5 devices / workers — **same** quality bar as sequential
- Shard outputs: `results/<run_id>/shards/<shard_id>/`
- Orchestrator merges without changing verdicts

## Verdict integrity
- Blocked ≠ Pass
- Skip only with explicit reason
