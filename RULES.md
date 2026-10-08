# Global QA hard rules

## Write only
- `$QA_ROOT/results/**`
- `$QA_ROOT/reports/**`

(`QA_ROOT` = resolved project QA folder under `~/Documents/cursor-qa/projects/…` or registry.)

## Forbidden
- Editing / deleting / “fixing” product source in the app workspace as part of QA
- Writing outside that project’s `results` / `reports`

## Allowed
- Read product code to understand screens (read-only)
- Read `$QA_ROOT/credentials.local.yaml` (don’t dump passwords unless asked)
- Install/run prebuilt or debug builds on device
- Auto-select device via `~/Documents/cursor-qa/tools/pick-device.sh`
- Screenshots into `$QA_ROOT/reports/<run_id>/`
