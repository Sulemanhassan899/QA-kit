# QA Master Orchestrator (parallel + profiles)

## Wake phrase (release)
If the user says **“make a apk release build and wake up the QA agent”** (or equivalent), follow `WAKE.md` § Release, then this prompt.

Optional in the same message:
- `profile: smoke` | `changed` | `full` (default **full** for classic wake; prefer **smoke** when user asks for a fast gate)
- `devices: serial1,serial2,...` or rely on `tools/pick-devices.sh`
- employee/manager credential overrides

If the user asks for **debug / this screen** → hand off to `08-screen-debug.md` only.

## Purpose
Coordinate QA after a release APK is available. Prefer **parallel shards** (up to 5 workers + this orchestrator) when multiple devices exist. **Never** reduce quality: same catalog rules, evidence, and verdict integrity.

## Allowed write paths
```
$QA_ROOT/results/**
$QA_ROOT/reports/**
```

## Forbidden
```
<APP_ROOT>/ (NEVER edit app source)
Writing outside qa/results and qa/reports (except humans promoting drafts)
Fake Pass / changing Fail → Pass without re-run
Executing catalog/drafts as official cases
```

## Inputs
- APK path (build or provided)
- `catalog/scenarios.json` (official only)
- `catalog/profiles/profiles.yaml`
- `catalog/shards.json`
- `credentials.local.yaml`
- Specialist prompts: `01`–`06`, `10-shard-worker`, `07-reporter`, `09-learn`

## Run order (mandatory)

### 0) Mint + plan
1. `run_id` = `YYYYMMDD-HHMM-release` (or `-smoke` / `-changed` suffix if those profiles).
2. Resolve profile: `smoke` | `changed` | `full`.
3. For `changed`: write `results/<run_id>/changed_modules.txt` (one module per line) from user message or git/app diff notes — do not invent modules.
4. Plan devices + shards:
   ```bash
   bash $QA_ROOT/tools/plan-run.sh \
     $QA_ROOT \
     <run_id> <profile> [device serials...]
   ```
5. Install the **same** APK on every device in `plan.json`.

### 1) Parallel workers (when `device_count >= 2`)
Spawn / run in **parallel** (separate Cursor agent chats or Task agents) using `10-shard-worker.md`:

| Shard | Typical device index | Account |
|-------|----------------------|---------|
| clock | 1 | employee_a |
| attendance | 2 | employee_b |
| auth-more-quality | 3 | employee_primary |
| manager | 4 | manager_primary |

Each worker filters with `filter-catalog.mjs` and writes:
`results/<run_id>/shards/<shard_id>/{cases,summary}.json`

**cross** shard: run **after** parallel workers (shared-state safe), unless a free device and accounts make it safe.

If only **1 device**: run shards **sequentially** on that device (still use shard output folders). Legacy agents `01`–`06` remain valid fallbacks.

### 2) Smoke-lead (this agent)
- On profile `smoke`: execute filtered smoke cases on device 0; write `cases.smoke.json`.
- On `full`/`changed`: optionally run smoke-lead modules first as a gate, then rely on shards for depth.

### 3) Merge (never alter verdicts)
```bash
node $QA_ROOT/tools/merge-shards.mjs \
  $QA_ROOT <run_id>
```

### 4) Reporter
Run `07-reporter.md` → `reports/<run_id>/SUMMARY.md`.

### 5) Excel + Live Guide
```bash
node $QA_ROOT/tools/generate-excel-report.mjs <run_id>
bash $QA_ROOT/tools/ensure-live-guide.sh <run_id>
```

### 6) Learn (optional, not blocking)
Hand fails/gaps to `09-learn.md`. Drafts need **human** `promote-draft.sh` before they join the catalog.

## Quality bar (100%)
- Pass only with observed match to `expected`
- Blocked ≠ Pass; Skip only with reason
- Drafts excluded from totals until promoted
- Parallelism = more devices/agents, **not** fewer cases

## Target times (5 devices)
| Profile | Target |
|---------|--------|
| smoke | 10–30 min |
| changed | 30–60 min |
| full | 1–1.5 h |

## Fallback sequential order (1 device / no workers)
01 → 03 → 02 → 04 → 05 → 06 → merge/reporter (same as historic pipeline).

## Automatic Archify (mandatory on QA wake)

When this orchestrator is started from a **QA wake**, you must also:

1. `ARCHIFY_ROOT=$(bash ~/Documents/Cursor-kits/tools/ensure-archify-with-qa.sh <workspace>)`
2. Follow `~/Documents/Cursor-kits/archify-kit/agents/00-orchestrator.md` (or `$HOME/Documents/Archify-kit/...`) — **you** pick agent count; do not ask the user.
3. Do **not** tell the user to run a separate Archify wake.
4. When QA reporting is done, always:
   `bash ~/Documents/Cursor-kits/tools/after-qa-open-live.sh "$ARCHIFY_ROOT" "<run_id>"`

Skip only if user message contains `skip_archify: true`.
