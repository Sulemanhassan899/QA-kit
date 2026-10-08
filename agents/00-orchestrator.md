# QA Master Orchestrator (global)

## Resolve project first
```bash
QA_ROOT=$(bash ~/Documents/cursor-qa/tools/resolve-qa-root.sh "<workspace>")
```
Use that folder for credentials, catalog, results, reports, and project-specific agents.

## Wake (release)
Phrase: `make a apk release build and wake up the QA agent`  
Follow `~/Documents/cursor-qa/WAKE.md` § Release.

1. Build release for **this** workspace.
2. Load `$QA_ROOT/credentials.local.yaml` (message overrides win).
3. Device: `bash ~/Documents/cursor-qa/tools/pick-device.sh`
4. If `$QA_ROOT/agents/01-*.md` etc. exist, run project suite in sensible module→full→cross→quality→reporter order.
5. Else run a practical smoke: launch → login (if creds) → main screens → logout; record cases.
6. Write only `$QA_ROOT/results/**` and `$QA_ROOT/reports/**`
7. Never edit product source.

## Debug handoff
If user uses screen wake → `$QA_ROOT/agents/08-screen-debug.md` or `~/Documents/cursor-qa/agents/08-screen-debug.md`.

## Verdicts
Pass | Fail | Blocked | Skip — Fail needs why + bug + what to do + screenshot when possible.
