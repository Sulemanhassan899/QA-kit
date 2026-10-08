# QA Kit — Automated Cursor QA Agents

Reusable **QA agent kit** for Cursor. Wake agents with simple phrases to test **release** builds or **debug** screens — without editing product code.

Works across projects and machines. Profile: [Sulemanhassan899](https://github.com/Sulemanhassan899).

## Wake phrases

**Release / full suite**
```text
make a apk release build and wake up the QA agent
```

**Debug / one screen**
```text
wake up the agent and QA this screen and its widgets (login_pass.dart) (ui, functionality)
```

Optional overrides in the same message:
```text
employee: user@example.com / password
manager: admin@example.com / password
device: emulator-5554
```

## Install on a new Mac / device

```bash
# 1) Clone
git clone https://github.com/Sulemanhassan899/QA-kit.git ~/Documents/QA-kit
cd ~/Documents/QA-kit

# 2) Install Cursor wake rule (all projects)
mkdir -p ~/.cursor/rules
cp cursor-rules/qa-wake-global.mdc ~/.cursor/rules/

# 3) Optional: also keep a copy at the older path some docs use
ln -sfn ~/Documents/QA-kit ~/Documents/cursor-qa

# 4) Connect a project
bash tools/init-project-qa.sh /path/to/your/app

# 5) Add logins (never commit this file)
cp templates/credentials.example.yaml \
  ~/Documents/QA-kit/projects/<your-app-name>/credentials.local.yaml
# edit emails/passwords
```

Full steps: [CONNECT.md](./CONNECT.md)

## Layout

```text
QA-kit/
  WAKE.md                 # wake phrases
  RULES.md                # hard rules (QA never edits app code)
  agents/                 # orchestrator, screen-debug, reporter
  tools/                  # init / resolve / pick-device
  templates/              # credentials.example.yaml
  cursor-rules/           # copy into ~/.cursor/rules/
  projects/               # per-app data (local; gitignored except registry template)
```

## Safety

- `credentials.local.yaml` is **gitignored** — do not commit passwords.
- QA agents write only under that project’s `results/` and `reports/`.
