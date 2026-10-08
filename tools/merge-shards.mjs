#!/usr/bin/env node
/**
 * Merge shard results into canonical cases.json + summary.json.
 * Never changes verdicts. Drops drafts. Dedupes by case id (first wins).
 *
 * Usage: node merge-shards.mjs <QA_ROOT> <run_id>
 */
import fs from "fs";
import path from "path";

const [qaRoot, runId] = process.argv.slice(2);
if (!qaRoot || !runId) {
  console.error("Usage: merge-shards.mjs <QA_ROOT> <run_id>");
  process.exit(1);
}

const runDir = path.join(qaRoot, "results", runId);
const shardsDir = path.join(runDir, "shards");

function readJson(p, fallback = null) {
  try {
    return JSON.parse(fs.readFileSync(p, "utf8"));
  } catch {
    return fallback;
  }
}

const byId = new Map();
const shardSummaries = [];

if (fs.existsSync(shardsDir)) {
  for (const name of fs.readdirSync(shardsDir)) {
    const dir = path.join(shardsDir, name);
    if (!fs.statSync(dir).isDirectory()) continue;
    const cases = readJson(path.join(dir, "cases.json"), []);
    const summary = readJson(path.join(dir, "summary.json"), null);
    if (summary) shardSummaries.push({ shard: name, ...summary });
    for (const row of cases || []) {
      if (!row || !row.id) continue;
      if (row.draft === true || String(row.id).startsWith("DRAFT-")) continue;
      if (!byId.has(row.id)) byId.set(row.id, { ...row, shard: name });
    }
  }
}

// Also accept a root cases.json partial (smoke) — shards win if same id already present? first wins already; merge root first
const rootCases = readJson(path.join(runDir, "cases.smoke.json"), []) || [];
for (const row of rootCases) {
  if (!row?.id) continue;
  if (!byId.has(row.id)) byId.set(row.id, row);
}

const cases = [...byId.values()];
const totals = { pass: 0, fail: 0, blocked: 0, skip: 0, total: cases.length };
for (const c of cases) {
  const v = String(c.verdict || c.status || "").toLowerCase();
  if (v === "pass") totals.pass++;
  else if (v === "fail") totals.fail++;
  else if (v === "blocked") totals.blocked++;
  else if (v === "skip") totals.skip++;
}

const plan = readJson(path.join(runDir, "plan.json"), {});
const summary = {
  run_id: runId,
  agent: "00-orchestrator+merge",
  profile: plan.profile || null,
  devices: plan.devices || [],
  parallel: !!plan.parallel,
  started_at: plan.created_at || null,
  finished_at: new Date().toISOString(),
  totals,
  shards: shardSummaries.map((s) => ({
    shard: s.shard,
    agent: s.agent,
    totals: s.totals,
    device: s.device,
  })),
  notes: [
    "Merged by merge-shards.mjs — verdicts unchanged",
    "Draft cases excluded from totals",
  ],
};

fs.writeFileSync(path.join(runDir, "cases.json"), JSON.stringify(cases, null, 2));
fs.writeFileSync(path.join(runDir, "summary.json"), JSON.stringify(summary, null, 2));
console.log(
  JSON.stringify(
    { run_id: runId, cases: cases.length, totals, shards: shardSummaries.length },
    null,
    2
  )
);
