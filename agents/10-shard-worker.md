# 10 — Shard worker (parallel)

## Purpose
Execute **one shard** of the catalog on **one assigned device**, in parallel with other workers. Same Pass/Fail quality as sequential runs — **no shortcuts**.

## Allowed write paths
```
$QA_ROOT/results/**
$QA_ROOT/reports/**
```

## Forbidden
- Any edit under `<APP_ROOT>/`
- Writing outside `qa/results` and `qa/reports`
- Marking Pass without executing the case on the assigned device
- Running cases from `catalog/drafts/` (drafts are not official)

## Inputs (from orchestrator / plan.json)
- `run_id`
- `shard_id` (e.g. `clock`, `attendance`, `auth-more-quality`, `manager`, `cross`)
- `device` serial (adb `-s`)
- `account` key from credentials (`employee_a`, `employee_b`, `employee_primary`, `manager_primary`)
- `profile`: `smoke` | `changed` | `full`

## Setup
1. Read `$QA_ROOT/results/<run_id>/plan.json` — confirm your shard assignment.
2. Load credentials from `credentials.local.yaml` for your `account` (never print passwords).
3. Filter cases:
   ```bash
   node $QA_ROOT/tools/filter-catalog.mjs \
     $QA_ROOT \
     <profile> <shard_id> <run_id> > /tmp/shard-cases.json
   ```
4. Install/use the **same** release APK on **your** device only (`adb -s <device> ...`).

## Output (required)
Write **only your shard** files:
```
results/<run_id>/shards/<shard_id>/cases.json
results/<run_id>/shards/<shard_id>/summary.json
```

`summary.json` must include: `run_id`, `agent`=`10-shard-worker`, `shard_id`, `device`, `account`, `started_at`, `finished_at`, `totals`.

Do **not** overwrite root `cases.json` / `summary.json` — orchestrator merges.

## Parallel safety
- Use only your assigned device and account.
- Do not punch/edit attendance on an account another live shard owns.
- `cross` shard: wait until clock/attendance/manager shards finish if `plan.json` says `parallel: false` for cross.

## Pass | Fail | Blocked | Skip
Same as `RULES.md` / orchestrator — evidence on Fail/Blocked; screenshots under `reports/<run_id>/`.

## After your shard
Stop. Orchestrator runs `merge-shards.mjs` + reporter. Optionally propose drafts via `09-learn.md` (human promote required).
