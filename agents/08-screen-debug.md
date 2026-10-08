# QA Screen / Debug agent (global)

## Resolve project first
```bash
QA_ROOT=$(bash ~/Documents/cursor-qa/tools/resolve-qa-root.sh "<workspace>")
```

## Wake
```
wake up the agent and QA this screen and its widgets (FILE_NAME) (WHAT_TO_QA)
```

## Mode
- Debug (no release build required)
- Scope: named file/screen + its widgets only
- Focuses from message; default ui + functionality + interactions

## Credentials / device
- `$QA_ROOT/credentials.local.yaml` (overrides in message win)
- `bash ~/Documents/cursor-qa/tools/pick-device.sh`

## Writes only
- `$QA_ROOT/results/<run_id>/summary.json` + `cases.json`
- `$QA_ROOT/reports/<run_id>/` screenshots

`run_id`: `YYYYMMDD-HHMM-debug-<screen>`

## Forbidden
Edit / fix product source. Do not expand to full release suite unless asked.
