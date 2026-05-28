#!/usr/bin/env node
// Validate catalog.json against the SKILL.md catalog contract.
// Assertions:
//   1. Every entry has description.length <= 200
//   2. Every entry's path points to a SKILL.md that exists on disk
//   3. No duplicate name values
//
// Usage: node scripts/validate-catalog.mjs
// Exits 1 if any assertion fails; 0 on success.

import { readFile, stat } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const CATALOG = join(ROOT, 'catalog.json');

async function main() {
  const raw = await readFile(CATALOG, 'utf8');
  const catalog = JSON.parse(raw);
  const skills = catalog.skills ?? [];

  const errors = [];

  // Check 1: description length
  for (const skill of skills) {
    const len = (skill.description ?? '').length;
    if (len > 200) {
      errors.push(`[description-length] "${skill.name}": ${len} chars (max 200)`);
    }
  }

  // Check 2: path exists on disk
  for (const skill of skills) {
    const fullPath = join(ROOT, skill.path);
    try {
      const s = await stat(fullPath);
      if (!s.isFile()) {
        errors.push(`[path-not-file] "${skill.name}": ${skill.path} is not a file`);
      }
    } catch {
      errors.push(`[path-missing] "${skill.name}": ${skill.path} does not exist on disk`);
    }
  }

  // Check 3: no duplicate names
  const seen = new Map();
  for (const skill of skills) {
    if (seen.has(skill.name)) {
      errors.push(`[duplicate-name] "${skill.name}" appears more than once`);
    }
    seen.set(skill.name, true);
  }

  if (errors.length > 0) {
    console.error(`catalog validation failed — ${errors.length} error(s):\n`);
    for (const e of errors) {
      console.error(`  ${e}`);
    }
    process.exit(1);
  }

  console.log(`catalog.json valid — ${skills.length} skills, all checks passed.`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
