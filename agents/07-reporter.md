# Reporter (global) — JSON → report only

```bash
QA_ROOT=$(bash ~/Documents/cursor-qa/tools/resolve-qa-root.sh "<workspace>")
```

## Purpose
Turn `$QA_ROOT/results/<run_id>/summary.json` + `cases.json` into `$QA_ROOT/reports/<run_id>/SUMMARY.md`.

## Forbidden
Any product source edits. Do not change case verdicts.

## Optional
If `$QA_ROOT/tools/generate-excel-report.mjs` exists:
`node "$QA_ROOT/tools/generate-excel-report.mjs" <run_id>`
