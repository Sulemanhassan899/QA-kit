# QA Kit — Cursor QA Agents (simple guide)

This kit lets **Cursor AI agents** test your mobile app like a real QA team.

You say a short wake phrase.  
The agents build/install (when needed), run test cases, write Pass/Fail results, and make reports.

They **never change your app source code**.

GitHub: https://github.com/Sulemanhassan899/QA-kit  
Author: [Sulemanhassan899](https://github.com/Sulemanhassan899)

---

## What this kit does

| Feature | Meaning |
|--------|---------|
| Wake phrases | Simple chat commands to start QA |
| Release testing | Full app test after a release build |
| Debug testing | Test one screen while you code |
| Parallel agents | Up to **5 agents** on up to **5 devices** at once |
| Profiles | `smoke` (fast), `changed` (only touched areas), `full` (everything) |
| Learn + promote | Agents can suggest new tests; **you** approve them |
| Safe writes | Results go only to that project’s QA folder |

**Quality stays high:** parallel means *more devices working together*, not fewer tests or weaker Pass/Fail rules.

---

## How it works (big picture)

1. You open your app project in Cursor.
2. You say a wake phrase.
3. The agent finds your project’s **QA_ROOT** (where catalog, logins, and results live).
4. It picks device(s), runs the right test profile, and saves results.
5. If many devices are connected, several worker agents run different modules at the same time.
6. One orchestrator **merges** all results into one report.
7. Optional: agents draft new test ideas → you promote them when you agree.

```text
You (wake phrase)
    → Orchestrator (plan + merge + report)
        → Worker: Clock
        → Worker: Attendance
        → Worker: Auth / More / Quality
        → Worker: Manager
        → (Cross flows after, if needed)
```

---

## Install (first time on a Mac)

```bash
# 1) Clone
git clone https://github.com/Sulemanhassan899/QA-kit.git ~/Documents/QA-kit
cd ~/Documents/QA-kit

# 2) Install Cursor wake rule (works in all projects)
mkdir -p ~/.cursor/rules
cp cursor-rules/qa-wake-global.mdc ~/.cursor/rules/

# 3) Optional: old path some docs use
ln -sfn ~/Documents/QA-kit ~/Documents/cursor-qa

# 4) Connect your app
bash tools/init-project-qa.sh /absolute/path/to/your/app

# 5) Add logins (never commit this file)
cp templates/credentials.example.yaml \
  ~/Documents/QA-kit/projects/<your-app-name>/credentials.local.yaml
# Edit emails / passwords
```

Restart Cursor (or open a new Agent chat) so the wake rule loads.

More install notes: [CONNECT.md](./CONNECT.md)

---

## Update the kit later

```bash
cd ~/Documents/QA-kit && git pull
cp cursor-rules/qa-wake-global.mdc ~/.cursor/rules/qa-wake-global.mdc
```

---

## Wake phrases (copy / paste)

### 1) Release / full app test

```text
make a apk release build and wake up the QA agent
```

What happens:

1. Builds the release APK for the current project (Flutter: `flutter build apk --release`, or your project’s usual command).
2. Loads logins from `credentials.local.yaml`.
3. Picks connected devices (up to 5).
4. Runs the orchestrator with the chosen profile (default: **full**).
5. Writes results under that project’s `results/` and `reports/` only.
6. Does **not** edit app source.

### 2) Debug / one screen (while coding)

```text
wake up the agent and QA this screen and its widgets (login_pass.dart) (ui, functionality)
```

- Uses **debug** mode (no release build required).
- Tests only that screen/file and the focuses you listed (`ui`, `functionality`, etc.).

### 3) Promote a new test draft (human only)

```text
promote QA draft DRAFT-YYYYMMDD-001
```

Drafts are suggestions only. They become official catalog cases **after you promote them**.

---

## Optional lines in the same message

```text
make a apk release build and wake up the QA agent

profile: smoke
devices: emulator-5554,emulator-5556,emulator-5558,emulator-5560,emulator-5562
employee: user@example.com / password
manager: admin@example.com / password
changed_modules: Clock Module, Attendance Module
```

| Option | What it does |
|--------|----------------|
| `profile: smoke` | Fast check after a new build |
| `profile: changed` | Only modules you list |
| `profile: full` | Whole official catalog |
| `devices: ...` | Which phones/emulators to use |
| `employee:` / `manager:` | Override saved logins for this run |
| `changed_modules:` | For `changed` profile |

If you omit employee/manager → uses `credentials.local.yaml`.  
If you omit devices → auto-picks ready `adb` devices.

---

## Run profiles (speed without cutting quality)

| Profile | What it tests | Rough time (with 5 devices) |
|---------|----------------|-----------------------------|
| **smoke** | Splash, login, main tabs, 1 punch, key screens | **10–30 min** |
| **changed** | Only modules you changed / listed | **30–60 min** |
| **full** | Entire official catalog | **1–1.5 hours** |

“100% quality” means: **100% of the cases in that profile**, with real Pass/Fail evidence — not skipping rules to go faster.

With **1 device**, the same cases still run, but mostly one after another (slower).

---

## Parallel agents (5 agents + 5 devices)

Best setup: **one worker agent per device**.

| Agent | Job | Typical account |
|-------|-----|-----------------|
| Orchestrator | Plan, install APK, smoke lead, merge, report | `employee_primary` |
| Worker | Clock module | `employee_a` |
| Worker | Attendance / alerts | `employee_b` |
| Worker | Auth, More, quality checks | `employee_primary` |
| Worker | Manager modules | `manager_primary` |

Cross-role flows usually run **after** the main workers so accounts do not fight each other.

### Why separate accounts?

If two agents punch in/out on the **same** login at once, results get messy.  
Use different employee accounts for Clock vs Attendance when you can.

Put them in `credentials.local.yaml` with aliases like:

- `employee_primary`
- `employee_a`
- `employee_b`
- `manager_primary`

See `templates/credentials.example.yaml`.

---

## What needs your approval?

| Step | Need you? |
|------|-----------|
| Start a normal QA run (wake phrase) | No — just say the phrase |
| Pass / Fail on official cases | No — agents decide from what they see |
| Excel / summary report | No — created after the run |
| **New** draft cases from learn agent | **Yes** — you promote |
| Changing app source | QA must not do this |

Day-to-day testing can run without babysitting.  
Your approval is mainly the **gate for new scenarios**.

---

## Learn loop (self-improve, safely)

1. After fails or gaps, agent `09-learn` may write drafts under `catalog/drafts/`.
2. Drafts are **not** counted in Pass/Fail totals.
3. Max about **10** open drafts; max a few new ones per run.
4. When you like a draft:

```bash
bash ~/Documents/QA-kit/tools/promote-draft.sh "$QA_ROOT" DRAFT-YYYYMMDD-001
```

or say: `promote QA draft DRAFT-YYYYMMDD-001`

That copies it into the official `catalog/scenarios.json`.

---

## Folder layout

```text
QA-kit/
  README.md                 ← this file
  WAKE.md                   ← wake phrase details
  RULES.md                  ← hard safety rules
  CONNECT.md                ← connect more apps / machines
  agents/
    00-orchestrator.md      ← plans run, merges, reports
    07-reporter.md          ← JSON → human summary
    08-screen-debug.md      ← one-screen debug QA
    09-learn.md             ← proposes draft cases
    10-shard-worker.md      ← parallel module worker
  tools/
    init-project-qa.sh      ← connect a new app
    resolve-qa-root.sh      ← find this app’s QA folder
    pick-device.sh          ← pick 1 device
    pick-devices.sh         ← pick up to 5 devices
    plan-run.sh             ← build plan.json (profile + shards)
    filter-catalog.mjs      ← filter cases by profile/shard
    merge-shards.mjs        ← merge worker results
    promote-draft.sh        ← human approve draft → catalog
  templates/
    credentials.example.yaml
    catalog/
      shards.json / shards.yaml
      profiles/profiles.yaml
      drafts/…              ← draft template + index
  cursor-rules/
    qa-wake-global.mdc      ← copy into ~/.cursor/rules/
  projects/                 ← per-app data (mostly local / gitignored)
    registry.yaml           ← shared template (usually empty in git)
    registry.local.yaml     ← your machine paths (gitignored)
```

Each connected app gets something like:

```text
projects/<app-name>/
  credentials.local.yaml    ← secrets (gitignored)
  catalog/scenarios.json    ← official test cases
  agents/ tools/ results/ reports/
```

---

## Important files inside a project QA_ROOT

| Path | Role |
|------|------|
| `credentials.local.yaml` | Logins (local only) |
| `catalog/scenarios.json` | Official test catalog |
| `catalog/profiles/profiles.yaml` | smoke / changed / full rules |
| `catalog/shards.json` | How work is split across agents |
| `catalog/drafts/` | Proposed cases (not official yet) |
| `results/<run_id>/` | Raw case JSON + plan + shards |
| `reports/<run_id>/` | Summary, screenshots, Excel (if tools exist) |

---

## Tools you may run by hand

```bash
QA_ROOT=$(bash ~/Documents/QA-kit/tools/resolve-qa-root.sh /path/to/app)

# Plan a run
bash "$QA_ROOT/tools/plan-run.sh" "$QA_ROOT" 20261009-1200-smoke smoke

# Filter cases
node "$QA_ROOT/tools/filter-catalog.mjs" "$QA_ROOT" smoke
node "$QA_ROOT/tools/filter-catalog.mjs" "$QA_ROOT" full clock

# Merge parallel shards
node "$QA_ROOT/tools/merge-shards.mjs" "$QA_ROOT" 20261009-1200-smoke

# Promote a draft
bash "$QA_ROOT/tools/promote-draft.sh" "$QA_ROOT" DRAFT-20261009-001
```

Some projects (like Obecno) also have Excel + live guide scripts under their own QA_ROOT.

---

## Safety rules (must follow)

1. **Never edit product app source** as part of QA.
2. Write only under that project’s `results/` and `reports/` (learn agent may write `catalog/drafts/`).
3. Never mark **Pass** without really running the case.
4. **Blocked** is not Pass. **Skip** needs a clear reason.
5. Do not commit `credentials.local.yaml`.
6. Do not count drafts in release totals until promoted.

Full rules: [RULES.md](./RULES.md)

---

## Obecno project note

Obecno’s full catalog, Excel, and live guide live at:

```text
~/Documents/obecno-archify/qa
```

On this machine, resolve prefers that folder for the Obecno app workspace.

For another computer, put a local mapping in:

```text
~/Documents/QA-kit/projects/registry.local.yaml
```

Example:

```yaml
projects:
  obecno:
    workspace_paths:
      - /Users/YOU/Downloads/obecno
    qa_root: /Users/YOU/Documents/obecno-archify/qa
```

`registry.local.yaml` is gitignored so personal paths stay on your machine.

---

## After a run — what you get

1. `results/<run_id>/plan.json` — profile, devices, shard assignments  
2. `results/<run_id>/shards/<name>/cases.json` — each worker’s cases  
3. `results/<run_id>/cases.json` + `summary.json` — merged totals  
4. `reports/<run_id>/SUMMARY.md` — human-readable report  
5. Excel / live guide — if that project’s tools exist  

---

## Quick FAQ

**Can I use this on other apps?**  
Yes. Run `init-project-qa.sh` on each app and fill credentials + catalog.

**Do I need 5 devices?**  
No. 1 device still works (slower). 5 devices is the fast path.

**Will agents invent Pass?**  
They must not. Rules forbid fake Pass. Drafts never count until you promote them.

**Where do passwords live?**  
Only in `credentials.local.yaml` on your machine (gitignored).

**What is QA_ROOT?**  
The folder for that app’s QA data (catalog, credentials, results). Resolved by `tools/resolve-qa-root.sh`.

---

## Related docs

| File | Contents |
|------|----------|
| [WAKE.md](./WAKE.md) | Wake phrases in detail |
| [RULES.md](./RULES.md) | Hard safety rules |
| [CONNECT.md](./CONNECT.md) | Connect more apps / devices |

---

## License / use

Use this kit for your own projects and team QA flows.  
Keep secrets out of git. Keep app source read-only during QA.

---

## Related: Archify Kit

Architecture + Live Guide for every project:

https://github.com/Sulemanhassan899/Archify-kit

Wake: `Make the archify of this project`

---

## Prefer the combined repo

**Cursor-kits** (QA + Archify together, one wake):

https://github.com/Sulemanhassan899/Cursor-kits

QA wake automatically runs Archify and opens Live Guide. No separate Archify command.

