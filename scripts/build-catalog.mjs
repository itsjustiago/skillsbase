#!/usr/bin/env node
// Regenerate catalog.json from skills/*/SKILL.md and profiles/*.json.
// Usage: node scripts/build-catalog.mjs
//
// No deps — uses Node 18+ fs/promises and a tiny YAML frontmatter parser.

import { readdir, readFile, writeFile, stat } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..');
const SKILLS_DIR = join(ROOT, 'skills');
const PROFILES_DIR = join(ROOT, 'profiles');
const OUT = join(ROOT, 'catalog.json');

function parseFrontmatter(md) {
  const m = md.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!m) throw new Error('missing frontmatter');
  const out = {};
  let key = null;
  let buf = '';
  let mode = null; // null | 'block-string' | 'block-list'
  for (const rawLine of m[1].split(/\r?\n/)) {
    if (mode === 'block-string') {
      if (/^\S/.test(rawLine)) {
        out[key] = buf.replace(/\n$/, '');
        mode = null;
      } else {
        buf += rawLine.replace(/^  /, '') + '\n';
        continue;
      }
    } else if (mode === 'block-list') {
      const item = rawLine.match(/^\s+-\s+(.+)$/);
      if (item) {
        out[key].push(item[1].trim().replace(/^['"]|['"]$/g, ''));
        continue;
      } else {
        mode = null;
        // fall through to parse new key
      }
    }
    const kv = rawLine.match(/^([a-z_]+):\s*(.*)$/);
    if (!kv) continue;
    key = kv[1];
    const value = kv[2];
    if (value === '|' || value === '>' || value === '|-' || value === '>-') {
      mode = 'block-string';
      buf = '';
    } else if (value === '') {
      // YAML block-list: tags:\n  - a\n  - b
      mode = 'block-list';
      out[key] = [];
    } else if (value.startsWith('[') && value.endsWith(']')) {
      out[key] = value.slice(1, -1).split(',').map(s => s.trim().replace(/^['"]|['"]$/g, '')).filter(Boolean);
    } else if (/^\d+$/.test(value)) {
      out[key] = parseInt(value, 10);
    } else {
      out[key] = value.replace(/^['"]|['"]$/g, '');
    }
  }
  if (mode === 'block-string') out[key] = buf.replace(/\n$/, '');
  return out;
}

async function main() {
  const skills = [];
  let dirs = [];
  try {
    dirs = await readdir(SKILLS_DIR);
  } catch {
    dirs = [];
  }
  for (const name of dirs) {
    const skillPath = join(SKILLS_DIR, name, 'SKILL.md');
    let s;
    try {
      s = await stat(skillPath);
    } catch {
      continue;
    }
    if (!s.isFile()) continue;
    const md = await readFile(skillPath, 'utf8');
    const fm = parseFrontmatter(md);
    skills.push({
      name: fm.name ?? name,
      path: `skills/${name}/SKILL.md`,
      description: fm.description ?? '',
      tags: Array.isArray(fm.tags) ? fm.tags : [],
      project_types: Array.isArray(fm.project_types) ? fm.project_types : [],
      cost_tokens: typeof fm.cost_tokens === 'number' ? fm.cost_tokens : null,
    });
  }

  const profiles = {};
  try {
    const profileFiles = await readdir(PROFILES_DIR);
    for (const f of profileFiles) {
      if (!f.endsWith('.json')) continue;
      const body = JSON.parse(await readFile(join(PROFILES_DIR, f), 'utf8'));
      profiles[f.replace(/\.json$/, '')] = body.skills ?? body;
    }
  } catch {
    // no profiles dir
  }

  const today = new Date().toISOString().slice(0, 10);
  const catalog = {
    version: '1',
    updated_at: today,
    skills: skills.sort((a, b) => a.name.localeCompare(b.name)),
    profiles,
  };

  await writeFile(OUT, JSON.stringify(catalog, null, 2) + '\n', 'utf8');
  console.log(`Wrote ${OUT} with ${skills.length} skills, ${Object.keys(profiles).length} profiles.`);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
