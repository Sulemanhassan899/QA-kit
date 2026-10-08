# Connect QA Kit to other projects & devices

## A) First time on a new device

```bash
git clone https://github.com/Sulemanhassan899/QA-kit.git ~/Documents/QA-kit
cd ~/Documents/QA-kit

mkdir -p ~/.cursor/rules
cp cursor-rules/qa-wake-global.mdc ~/.cursor/rules/qa-wake-global.mdc

# Compat symlink (scripts resolve ~/Documents/cursor-qa OR ~/Documents/QA-kit)
ln -sfn ~/Documents/QA-kit ~/Documents/cursor-qa
```

Restart Cursor (or open a new Agent chat) so the global rule loads.

## B) Connect one app project

```bash
bash ~/Documents/QA-kit/tools/init-project-qa.sh /absolute/path/to/your/app
```

This creates:

`~/Documents/QA-kit/projects/<app-folder-name>/`

with agents, empty catalog, results/reports folders, and registers the workspace in `projects/registry.yaml`.

Then:

```bash
cp ~/Documents/QA-kit/templates/credentials.example.yaml \
  ~/Documents/QA-kit/projects/<app-folder-name>/credentials.local.yaml
```

Edit `credentials.local.yaml` with that app’s test accounts.

## C) Use it

In that app’s Cursor workspace, say:

```text
make a apk release build and wake up the QA agent
```

or:

```text
wake up the agent and QA this screen and its widgets (MyScreen.dart) (ui, functionality)
```

## D) Update kit on any device

```bash
cd ~/Documents/QA-kit && git pull
cp cursor-rules/qa-wake-global.mdc ~/.cursor/rules/qa-wake-global.mdc
```

## E) Obecno note

Obecno’s rich catalog / live guide can stay at:

`~/Documents/obecno-archify/qa`

Register it in `projects/registry.yaml` (example):

```yaml
projects:
  obecno:
    workspace_paths:
      - /Users/YOU/Downloads/obecno
    qa_root: /Users/YOU/Documents/obecno-archify/qa
```

Or run `init-project-qa.sh` and copy/symlink that data in.
