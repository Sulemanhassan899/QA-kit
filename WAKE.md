# Global QA wake phrases (all Cursor projects)

The agent resolves **QA_ROOT** for the current workspace (see `tools/resolve-qa-root.sh`), then runs there.

---

## 1) Release / full suite

```
make a apk release build and wake up the QA agent
```

1. Build release artifact for **this** project (Flutter → `flutter build apk --release`, or the project’s usual release command).
2. Load `$QA_ROOT/credentials.local.yaml` (message overrides win).
3. Auto-pick device: `bash ~/Documents/cursor-qa/tools/pick-device.sh`
4. Use `$QA_ROOT/agents/00-orchestrator.md` if present, else `~/Documents/cursor-qa/agents/00-orchestrator.md`
5. Write only under `$QA_ROOT/results/` and `$QA_ROOT/reports/`
6. Do **not** edit product source as part of QA

### Optional overrides
```
make a apk release build and wake up the QA agent

employee: user@example.com / password
manager: admin@example.com / password
device: emulator-5554
```

---

## 2) Debug / this screen

```
wake up the agent and QA this screen and its widgets (FILE_NAME) (WHAT_TO_QA)
```

Examples:
```
wake up the agent and QA this screen and its widgets (login_pass.dart) (ui, functionality)
```

1. **Debug** mode — no release build required
2. Same credentials + device rules as release
3. Use `$QA_ROOT/agents/08-screen-debug.md` if present, else `~/Documents/cursor-qa/agents/08-screen-debug.md`
4. Scope = that file/screen + widgets; focuses from the message
5. Write under `$QA_ROOT/results/` + `$QA_ROOT/reports/`
6. Do **not** edit product source

---

## After any run

- Prefer project Excel tool if present: `$QA_ROOT/tools/generate-excel-report.mjs`
- Else skip Excel or use project instructions in `$QA_ROOT/HOW_TO_RUN.md`
- If `$QA_ROOT/tools/ensure-live-guide.sh` exists, run it with `run_id`
