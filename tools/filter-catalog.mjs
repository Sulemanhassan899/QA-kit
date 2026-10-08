#!/usr/bin/env node
/**
 * Filter official catalog for a profile + optional shard.
 * Usage:
 *   node filter-catalog.mjs <QA_ROOT> <profile> [shard_id] [run_id]
 * Writes JSON array to stdout.
 */
import fs from "fs";
import path from "path";

const [qaRoot, profile = "full", shardId = "", runId = ""] = process.argv.slice(2);
if (!qaRoot) {
  console.error("Usage: filter-catalog.mjs <QA_ROOT> <profile> [shard_id] [run_id]");
  process.exit(1);
}

const catalog = JSON.parse(
  fs.readFileSync(path.join(qaRoot, "catalog/scenarios.json"), "utf8")
);
const shards = JSON.parse(
  fs.readFileSync(path.join(qaRoot, "catalog/shards.json"), "utf8")
);

function loadProfiles() {
  const p = path.join(qaRoot, "catalog/profiles/profiles.yaml");
  const text = fs.readFileSync(p, "utf8");
  // tiny YAML subset for our profiles file
  const profiles = { smoke: {}, changed: {}, full: { include_all: true } };
  let cur = null;
  for (const line of text.split("\n")) {
    if (/^[a-z]+:\s*$/.test(line)) {
      cur = line.replace(":", "").trim();
      profiles[cur] = profiles[cur] || {};
      continue;
    }
    if (!cur) continue;
    const mList = line.match(/^\s+-\s+(.+)\s*$/);
    const mKey = line.match(/^\s+([a-z_]+):\s*(.*)$/);
    if (mKey && !mList) {
      const k = mKey[1];
      let v = mKey[2].trim();
      if (v === "") {
        profiles[cur][k] = profiles[cur][k] || [];
        profiles[cur]._listKey = k;
      } else if (v === "true") profiles[cur][k] = true;
      else if (v === "false") profiles[cur][k] = false;
      else if (/^\[/.test(v)) {
        profiles[cur][k] = v
          .replace(/[\[\]]/g, "")
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean);
      } else if (/^\d+$/.test(v)) profiles[cur][k] = Number(v);
      else profiles[cur][k] = v.replace(/^"|"$/g, "");
    } else if (mList) {
      const key = profiles[cur]._listKey || "case_ids";
      if (!Array.isArray(profiles[cur][key])) profiles[cur][key] = [];
      profiles[cur][key].push(mList[1].replace(/^"|"$/g, ""));
    }
  }
  return profiles;
}

const profiles = loadProfiles();
const conf = profiles[profile] || profiles.full;

let selected = catalog.slice();

if (profile === "smoke") {
  const ids = new Set(conf.case_ids || []);
  const mods = new Set(conf.modules || []);
  selected = catalog.filter(
    (c) => ids.has(c.id) || (ids.size === 0 && mods.has(c.module))
  );
  // If ids missing from catalog, fall back to first matching modules
  if (selected.length === 0) {
    selected = catalog.filter((c) => mods.has(c.module));
  }
  const max = conf.max_cases || 12;
  // Prefer listed ids order
  if (ids.size) {
    const byId = new Map(selected.map((c) => [c.id, c]));
    const ordered = [];
    for (const id of conf.case_ids || []) {
      if (byId.has(id)) ordered.push(byId.get(id));
    }
    for (const c of selected) {
      if (!ordered.find((x) => x.id === c.id)) ordered.push(c);
    }
    selected = ordered.slice(0, max);
  } else {
    selected = selected.slice(0, max);
  }
} else if (profile === "changed") {
  let modules = [];
  if (runId) {
    const f = path.join(qaRoot, "results", runId, "changed_modules.txt");
    if (fs.existsSync(f)) {
      modules = fs
        .readFileSync(f, "utf8")
        .split("\n")
        .map((s) => s.trim())
        .filter(Boolean);
    }
  }
  if (modules.length) {
    const set = new Set(modules);
    selected = catalog.filter((c) => set.has(c.module));
    if (conf.include_related_quality) {
      const quality = catalog.filter((c) => c.module === "Quality");
      const have = new Set(selected.map((c) => c.id));
      for (const q of quality) {
        if (!have.has(q.id)) selected.push(q);
      }
    }
  } else {
    // Safe fallback: layer A employee+manager+shared (not full D spam)
    selected = catalog.filter(
      (c) =>
        (c.layer === "A" || c.layer === "B") &&
        ["employee", "manager", "shared"].includes(c.role)
    );
  }
} else {
  // full — entire official catalog
  selected = catalog.slice();
}

if (shardId && shardId !== "smoke-lead") {
  const shard = (shards.shards || []).find((s) => s.id === shardId);
  if (shard) {
    const mods = new Set(shard.modules || []);
    const layers = shard.layers ? new Set(shard.layers) : null;
    selected = selected.filter((c) => {
      if (!mods.has(c.module)) return false;
      if (layers && c.layer && !layers.has(c.layer)) return false;
      return true;
    });
  }
} else if (shardId === "smoke-lead" && profile === "smoke") {
  // keep smoke selection as-is
} else if (shardId === "smoke-lead" && profile !== "smoke") {
  const shard = (shards.shards || []).find((s) => s.id === "smoke-lead");
  const mods = new Set(shard?.modules || []);
  selected = selected.filter((c) => mods.has(c.module));
}

process.stdout.write(JSON.stringify(selected, null, 2));
