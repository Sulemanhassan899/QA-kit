# Global QA wake phrases (all Cursor projects)

The agent resolves **QA_ROOT** for the current workspace (see `tools/resolve-qa-root.sh`), then runs there.

---

## 1) Release / full suite (parallel when devices allow)

```
make a apk release build and wake up the QA agent
```

1. Build release artifact for **this** project.
2. Load `$QA_ROOT/credentials.local.yaml` (message overrides win).
3. Pick devices: `tools/pick-devices.sh` (up to 5) or `device:` / `devices:` overrides.
4. Use `$QA_ROOT/agents/00-orchestrator.md` if present, else kit `agents/00-orchestrator.md`.
5. Prefer **parallel shards** (`10-shard-worker`) when 2+ devices are online; merge with `merge-shards.mjs`.
6. Write only under `$QA_ROOT/results/` and `$QA_ROOT/reports/`.
7. Do **not** edit product source as part of QA.

### Optional overrides
```
make a apk release build and wake up the QA agent

profile: smoke
devices: emulator-5554,emulator-5556
employee: user@example.com / password
manager: admin@example.com / password
```

| Profile | Meaning |
|---------|---------|
| smoke | Fast gate (login, nav, 1 punch) |
| changed | Modules listed via `changed_modules:` |
| full | Entire official catalog (default) |

---

## 2) Debug / this screen

```
wake up the agent and QA this screen and its widgets (FILE_NAME) (WHAT_TO_QA)
```

1. **Debug** mode — no release build required.
2. Same credentials + device rules.
3. Use `$QA_ROOT/agents/08-screen-debug.md` if present, else kit agent.
4. Write under `$QA_ROOT/results/` + `$QA_ROOT/reports/`.
5. Do **not** edit product source.

---

## 3) Promote a draft (human gate)

```
promote QA draft DRAFT-YYYYMMDD-001
```

```bash
bash "$KIT/tools/promote-draft.sh" "$QA_ROOT" DRAFT-YYYYMMDD-001
```

Drafts under `catalog/drafts/` are **not** official until promoted.

---

## After any run

- Merge shards if needed: `node $QA_ROOT/tools/merge-shards.mjs "$QA_ROOT" <run_id>`
- Prefer project Excel tool if present
- If `$QA_ROOT/tools/ensure-live-guide.sh` exists, run it with `run_id`
