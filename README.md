# QA Kit — Automated Cursor QA Agents

Reusable **QA agent kit** for Cursor. Wake agents with simple phrases to test **release** builds or **debug** screens — without editing product code.

Supports **parallel shards** (up to 5 agents / 5 devices), run **profiles** (`smoke` / `changed` / `full`), and a **learn → human promote** loop for new scenarios.

Works across projects and machines. Profile: [Sulemanhassan899](https://github.com/Sulemanhassan899).

## Wake phrases

**Release / full suite**
```text
make a apk release build and wake up the QA agent
```

Optional: `profile: smoke|changed|full`, `devices: s1,s2,...`

**Debug / one screen**
```text
wake up the agent and QA this screen and its widgets (login_pass.dart) (ui, functionality)
```

**Promote draft (human)**
```text
promote QA draft DRAFT-YYYYMMDD-001
```

## Install on a new Mac / device

```bash
git clone https://github.com/Sulemanhassan899/QA-kit.git ~/Documents/QA-kit
cd ~/Documents/QA-kit

mkdir -p ~/.cursor/rules
cp cursor-rules/qa-wake-global.mdc ~/.cursor/rules/

# Optional compat path
ln -sfn ~/Documents/QA-kit ~/Documents/cursor-qa

bash tools/init-project-qa.sh /path/to/your/app

cp templates/credentials.example.yaml \
  ~/Documents/QA-kit/projects/<your-app-name>/credentials.local.yaml
# edit emails/passwords (+ employee_a / employee_b for parallel)
```

Full steps: [CONNECT.md](./CONNECT.md)

## Parallel model

| Role | Job |
|------|-----|
| Orchestrator | plan-run, smoke-lead, merge, report |
| Workers (×4) | clock / attendance / auth-more-quality / manager |
| Learn | draft new cases → **you** promote |

Tools: `pick-devices.sh`, `plan-run.sh`, `filter-catalog.mjs`, `merge-shards.mjs`, `promote-draft.sh`.

## Layout

```text
QA-kit/
  WAKE.md RULES.md README.md
  agents/          # orchestrator, reporter, screen-debug, learn, shard-worker
  tools/           # init, resolve, pick-device(s), plan, filter, merge, promote
  templates/       # credentials + catalog shards/profiles/drafts
  cursor-rules/    # copy into ~/.cursor/rules/
  projects/        # per-app data (local; gitignored except registry)
```

## Safety

- `credentials.local.yaml` is **gitignored**
- QA agents do not edit product source
- Drafts never count as Pass/Fail until promoted
