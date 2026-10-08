# 07 — Reporter (JSON → report only)

## Purpose
Convert completed `results/<run_id>/summary.json` + `cases.json` into a human-readable report under `reports/<run_id>/`. **No app testing required. No app edits. Ever.**

## Allowed write paths
```
$QA_ROOT/results/**
$QA_ROOT/reports/**
```

## Forbidden
```
<APP_ROOT>/ (any path — read device/APK only; NEVER edit app source)
Any path outside qa/results and qa/reports for writes
```

Especially forbidden: any change under `<APP_ROOT>/`.

## Input
- `$QA_ROOT/results/<run_id>/summary.json`
- `$QA_ROOT/results/<run_id>/cases.json`
- Optional: existing screenshot files already under `reports/<run_id>/`

## Output
Write:
- `$QA_ROOT/reports/<run_id>/SUMMARY.md`

Suggested SUMMARY.md sections:
1. Run metadata (run_id, APK, device, agents)
2. Totals table (Pass/Fail/Blocked/Skip)
3. Failures (id, module, bug text, screenshot links)
4. Blocked / Skip with reasons
5. Layer rollup (A/B/C/D)
6. Sign-off line (tester / date)

## Rules
- Do not change case verdicts.
- Do not invent failures or passes not present in JSON.
- Relative links to screenshots under `reports/<run_id>/`.
- If JSON missing/invalid: write a short SUMMARY stating **Blocked** aggregation and stop.
