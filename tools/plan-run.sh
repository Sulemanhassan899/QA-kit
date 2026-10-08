#!/usr/bin/env bash
# Create results/<run_id>/plan.json — profile, devices, shard assignments.
# Usage:
#   plan-run.sh <QA_ROOT> <run_id> <profile:smoke|changed|full> [device_serial ...]
set -euo pipefail

QA_ROOT="${1:?QA_ROOT required}"
RUN_ID="${2:?run_id required}"
PROFILE="${3:-full}"
shift 3 || true

OUT_DIR="$QA_ROOT/results/$RUN_ID"
mkdir -p "$OUT_DIR/shards"

DEVICES_FILE="$OUT_DIR/devices.txt"
if [ "$#" -gt 0 ]; then
  printf '%s\n' "$@" >"$DEVICES_FILE"
else
  if ! bash "$QA_ROOT/tools/pick-devices.sh" 5 >"$DEVICES_FILE" 2>/dev/null; then
    bash "$QA_ROOT/tools/pick-device.sh" >"$DEVICES_FILE"
  fi
fi

DEVICES_CSV="$(tr '\n' ',' <"$DEVICES_FILE" | sed 's/,$//')"

QA_ROOT="$QA_ROOT" RUN_ID="$RUN_ID" PROFILE="$PROFILE" OUT_DIR="$OUT_DIR" DEVICES_CSV="$DEVICES_CSV" node <<'NODE'
const fs = require('fs');
const path = require('path');
const qaRoot = process.env.QA_ROOT;
const runId = process.env.RUN_ID;
const profile = process.env.PROFILE;
const outDir = process.env.OUT_DIR;
const devices = (process.env.DEVICES_CSV || '').split(',').filter(Boolean);

const shardIds = ['clock', 'attendance', 'auth-more-quality', 'manager', 'cross'];

const assignments = [];
assignments.push({
  shard_id: 'smoke-lead',
  device: devices[0] || null,
  account: 'employee_primary',
  agent: '00-orchestrator',
  parallel: false,
});

function deviceFor(sid) {
  if (!devices.length) return null;
  if (devices.length >= 5) {
    const map = {
      clock: devices[1],
      attendance: devices[2],
      'auth-more-quality': devices[3],
      manager: devices[4],
      cross: devices[1],
    };
    return map[sid] || devices[0];
  }
  return devices[shardIds.indexOf(sid) % devices.length];
}

function accountFor(sid) {
  if (sid === 'manager' || sid === 'cross') return 'manager_primary';
  if (sid === 'attendance') return 'employee_b';
  if (sid === 'clock') return 'employee_a';
  return 'employee_primary';
}

for (const sid of shardIds) {
  assignments.push({
    shard_id: sid,
    device: deviceFor(sid),
    account: accountFor(sid),
    agent: '10-shard-worker',
    parallel: sid !== 'cross',
  });
}

const plan = {
  run_id: runId,
  profile,
  created_at: new Date().toISOString(),
  devices,
  device_count: devices.length,
  parallel: devices.length > 1,
  assignments,
  notes: [
    'Workers write results/<run_id>/shards/<shard_id>/cases.json',
    'Orchestrator merges via tools/merge-shards.mjs before reporter',
    'Drafts are never included in totals until promoted',
  ],
};

const out = path.join(outDir, 'plan.json');
fs.writeFileSync(out, JSON.stringify(plan, null, 2));
console.log(out);
NODE
