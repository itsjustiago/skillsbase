# skillsbase

The single source of truth for itsjustiago's Claude Code setup — **machine bootstrap + per-project skill catalog in one repo.**

Clone this on any new machine and Claude is fully configured: 14 global skills (file-based, **no plugins, no hooks**), the global CLAUDE.md, the skill-matchmaker engine, and a 62-skill catalog that installs per-project on demand.

> Your Claude has **two layers** of skills:
> - 🌍 **Global** — always available in every project: 5 own skills (vendored in `global-skills/`) + 9 external skills (pulled from their original sources by `setup/install-externals.sh` — never vendored here). Set up once by `setup.sh`.
> - 📦 **Per-project** — picked from this catalog by the `skill-matchmaker`. Only loads in projects that need them.

**Why this build looks the way it does** (no plugins, no hooks, which skills got cut and why): [`DECISIONS.md`](DECISIONS.md) — read it before re-adding anything that was removed.

---

# 🚀 New machine setup

```bash
git clone https://github.com/itsjustiago/skillsbase.git
cd skillsbase
bash setup.sh        # Windows: correr no Git Bash
```

`setup.sh` is idempotent (safe to re-run — re-running also **updates** the external skills). It:
1. Copies own skills (`global-skills/` → `~/.claude/skills/`) and slash commands (`commands/` → `~/.claude/commands/`)
2. Runs `setup/install-externals.sh` — clones the 9 external skills from their upstreams (Anthropic, pbakaus, Emil Kowalski, Supabase, obra/superpowers, nextlevelbuilder) and applies the patches documented in `DECISIONS.md`
3. Installs global configs (`setup/CLAUDE.md`, `setup/settings.json`) — backs up any existing CLAUDE.md that differs

**Requires:** git + node on PATH. Python 3 only for `ui-ux-pro-max` search (install when needed). The `claude` CLI is NOT required — this build works on the desktop app.

**After `setup.sh`:**
- **Restart Claude Code** so skills + CLAUDE.md load
- Desktop app: **Settings → Connectors → Supabase** (the only connector this build uses — see [`setup/mcps.md`](setup/mcps.md))
- **Per project**: run `/skills-suggest` — the matchmaker installs project-relevant catalog skills locally

Manual fallback (what the script does, step by step): [`setup/install.md`](setup/install.md)

## Syncing an existing machine

`setup.sh` is **additive**. To make a machine match this repo **exactly** (remove global skills that don't belong, update the rest):

```bash
bash sync.sh            # DRY RUN — shows the diff, changes nothing
bash sync.sh --apply    # reconcile: remove extras, install/update missing, copy CLAUDE.md
```

`sync.sh`:
- Only touches the **global layer** (`~/.claude/`) — never per-project `.claude/skills/`
- Backs up `~/.claude/{skills,commands,CLAUDE.md}` to `~/.claude/backups/sync-<ts>/` before applying
- **Never** touches `settings.json` (machine-local keys)

**Telling Claude to do it:** "põe esta máquina igual ao skillsbase" → Claude runs the dry run, shows you the diff, and applies only on your OK.

Repo layout:

| Dir | Purpose |
|---|---|
| `setup.sh` / `sync.sh` | Bootstrap (additive) / exact reconcile (dry-run first) |
| `setup/` | `install-externals.sh`, config templates (CLAUDE.md, settings.json), MCP notes, manual fallback |
| `global-skills/` | The 5 **own** skills copied into `~/.claude/skills/` — ship, ship-merge, session-handoff, matchmaker, scout |
| `commands/` | Slash commands copied into `~/.claude/commands/` |
| `DECISIONS.md` | Why the build is like this — audit findings, what was cut and why, patches applied |
| `skills/` | The 62-skill **per-project catalog** (consumed by the matchmaker, never auto-installed globally) |
| `profiles/` | Curated starter packs (e.g. `nextjs-pwa`) |
| `scripts/` | `build-catalog.mjs` — regenerates `catalog.json` from `skills/` |
| `guides/` | Workflow docs — design stack, git, security, multi-agent |
| `mcp/` · `memory/` | MCP conceptual guide · how Claude's memory works |
| `catalog.json` | Machine-readable index of the per-project catalog |

---

# 🌍 Global skills (always available)

### Kickoff de projeto novo

- **`/ui-ux-pro-max <descrição>`** → design direction from a real database (67 styles, 161 palettes, 57 font pairs). Manual-only by design — see DECISIONS.md
- **`/impeccable init`** → writes PRODUCT.md + DESIGN.md; every design command respects them from then on

### Design (auto + on demand)

- **frontend-design** + **emil-design-eng** → fire automatically on UI work (aesthetic direction; motion/polish)
- **`/impeccable critique|audit|polish|…`** → 23 refinement commands (run `/impeccable` for the suite)
- **`/review-animations`** → strict motion review (manual)
- Full design workflow: [`guides/design.md`](guides/design.md)

### Engineering

- **"debug X"** → systematic root-cause before any fix (superpowers cherry-pick)
- **"verify"** → evidence before claiming done (superpowers cherry-pick)
- **supabase / supabase-postgres-best-practices** → fire automatically on Supabase/Postgres work (official skills)

### Ship & sessions

- **`/ship`** → commit → push → PR, one shot
- **`/ship-merge`** → commit → PR → CI wait → light review → squash-merge → cleanup
- **"wrap up session"** → end-of-session handoff before `/clear`
- **`/skills-suggest`** → propose project-relevant skills from this catalog
- **skill-scout** → find NEW skills/plugins/MCPs in the wider ecosystem

---

# 📦 Per-project skills (on-demand)

When you open a project, run:

```
/skills-suggest
```

The **matchmaker** reads your `package.json` (or `Cargo.toml`, `pyproject.toml`, etc.), picks skills from this catalog that match your stack, and installs them into `<project>/.claude/skills/`. They only load in that project.

Restart Claude once after install — done. Future sessions in that project automatically have those skills.

---

# 🛟 Troubleshooting

| Symptom | Fix |
|---|---|
| `setup.sh` stopped partway | Re-run it — idempotent, picks up where it left off |
| New skills don't show up | **Restart Claude Code** — skills load at session start |
| `ui-ux-pro-max` never fires on its own | By design (manual-only patch). Invoke with `/ui-ux-pro-max` at project kickoff |
| impeccable/ui-ux-pro-max ask permission to run scripts | Normal — their detectors/search run local scripts on demand |
| External skill looks outdated | Re-run `bash setup/install-externals.sh` (or `setup.sh`) — pulls latest upstream |
| Startup feels heavy / too many tokens | `bash sync.sh` (dry run) — see what doesn't belong; also check connected MCP connectors (`setup/mcps.md`) |
| "Is this `setup.sh` or `sync.sh`?" | `setup.sh` = first-time + update, additive. `sync.sh` = make machine match repo exactly |
| Want a skill that's not in the catalog | Ask the agent to run `skill-scout` — it searches the wider ecosystem |

# 📖 Glossary

| Term | Meaning |
|---|---|
| **Global layer** | The 14 skills + CLAUDE.md in `~/.claude/` available in *every* session (file-based — this build uses no plugins) |
| **Per-project layer** | Skills in `<project>/.claude/skills/` that load only in that one project |
| **Own vs external skills** | Own (5) live in `global-skills/` here; external (9) are pulled from their upstream repos at install time — never vendored |
| **skill-matchmaker** | Global skill — searches *this catalog* and installs project-relevant skills locally |
| **skill-scout** | Global skill — searches the *wider ecosystem* (GitHub, marketplaces) for skills you don't have |
| **MCP** | Model Context Protocol server — gives Claude a live tool (browser, DB). Distinct from a skill (which is instructions) |
| **catalog** | `catalog.json` + `skills/` — the 62-skill per-project library the matchmaker reads from |
| **profile** | A named bundle of catalog skills for a common stack (e.g. `nextjs-pwa`) |

> **Adding a skill to the catalog?** See [Adding / modifying / removing a skill](#adding--modifying--removing-a-skill) in the reference section below.

---
---

<details>
<summary><b>📚 Reference (for the Claude agent reading this)</b> — full catalog, schemas, and scoring algorithm</summary>

## Catalog — 62 skills

Click a skill name to read its full body. Each row: tags · project types · one-line purpose.

### Stack: Next.js / React / TypeScript

| Skill | Tags | Project types | Purpose |
|---|---|---|---|
| [`nextjs-app-router`](./skills/nextjs-app-router/SKILL.md) | nextjs, react, app-router, ssr | nextjs | Server components, server actions, route handlers, layouts, streaming |
| [`nextjs-turbopack`](./skills/nextjs-turbopack/SKILL.md) | nextjs, turbopack, performance | nextjs, react, vite | Next.js 16+ Turbopack — incremental bundling, HMR |
| [`react-19-patterns`](./skills/react-19-patterns/SKILL.md) | react-19, hooks, actions | nextjs, vite, any-web | `useActionState`, `useOptimistic`, `use()`, ref-as-prop, document metadata |
| [`frontend-patterns`](./skills/frontend-patterns/SKILL.md) | react, nextjs, hooks, state | nextjs, react, vite | State management, performance, accessibility, component patterns |
| [`tailwindcss-v4`](./skills/tailwindcss-v4/SKILL.md) | tailwind, css, postcss | nextjs, vite, any-web | v4 rewrite — CSS-first config, `@theme`, breaking changes from v3 |
| [`pwa-deployment`](./skills/pwa-deployment/SKILL.md) | pwa, service-worker, manifest, ios | nextjs, vite, any-web | Manifest, SW registration, install prompt, iOS quirks |

### Database / Backend / Auth / Storage

| Skill | Tags | Project types | Purpose |
|---|---|---|---|
| [`drizzle-neon-typescript`](./skills/drizzle-neon-typescript/SKILL.md) | drizzle, neon, postgres | nextjs, any-web | Drizzle on Neon — schema, queries, migrations, HTTP vs WebSocket driver |
| [`supabase-typescript`](./skills/supabase-typescript/SKILL.md) | supabase, postgres, auth, rls | nextjs, vite, any-web | Typed client, RLS-friendly queries, SSR cookies, realtime |
| [`postgres-patterns`](./skills/postgres-patterns/SKILL.md) | postgres, sql, indexing | any | Query optimization, schema design, indexing strategies |
| [`database-migrations`](./skills/database-migrations/SKILL.md) | migration, drizzle, prisma, sql | any | Schema changes, data migrations, rollback procedures |
| [`vercel-blob-storage`](./skills/vercel-blob-storage/SKILL.md) | vercel, blob, uploads, cdn | nextjs, any-web | `put`/`del`/`list`/`head`, client uploads >4.5 MB, path conventions |
| [`custom-jwt-auth-jose`](./skills/custom-jwt-auth-jose/SKILL.md) | jwt, jose, bcrypt, middleware | nextjs, any-web | Edge-compatible JWT auth, httpOnly cookies, middleware gate |
| [`backend-patterns`](./skills/backend-patterns/SKILL.md) | nodejs, express, architecture | nextjs, any-web | Repository/service layers, caching, REST/GraphQL, auth |
| [`api-design`](./skills/api-design/SKILL.md) | api, rest, http, pagination | nextjs, any-web | Resource naming, status codes, versioning, rate-limiting |

### Runtime / Deploy / Infra

| Skill | Tags | Project types | Purpose |
|---|---|---|---|
| [`bun-runtime`](./skills/bun-runtime/SKILL.md) | bun, javascript, runtime | nextjs, any-web, any | Bun as all-in-one runtime + package manager + bundler |
| [`docker-patterns`](./skills/docker-patterns/SKILL.md) | docker, container, security | any | Multi-stage builds, Compose, container security, network isolation |
| [`deployment-patterns`](./skills/deployment-patterns/SKILL.md) | deploy, ci-cd, vercel | any-web | CI/CD pipelines, health checks, rollback procedures |

### Testing

| Skill | Tags | Project types | Purpose |
|---|---|---|---|
| [`tdd-workflow`](./skills/tdd-workflow/SKILL.md) | tdd, jest, vitest, playwright | nextjs, react, any-web, any | Red-green-refactor with 80%+ coverage |
| [`e2e-testing`](./skills/e2e-testing/SKILL.md) | e2e, playwright | any-web | Playwright patterns, Page Object Model, CI integration |
| [`browser-qa`](./skills/browser-qa/SKILL.md) | qa, visual-testing, browser | any-web | Visual testing, UI interaction verification, screenshot diffs |
| [`benchmark`](./skills/benchmark/SKILL.md) | performance, baselines | any-web | Perf baselines, regression detection PR-by-PR |
| [`mutation-testing`](./skills/mutation-testing/SKILL.md) | mutation, coverage | any | Verify tests actually catch bugs via mewt/muton campaigns |
| [`property-based-testing`](./skills/property-based-testing/SKILL.md) | property, fuzzing | any | Generative testing for invariants |

### Security & Audit

| Skill | Tags | Project types | Purpose |
|---|---|---|---|
| [`semgrep`](./skills/semgrep/SKILL.md) | sast, static-analysis | any | Semgrep scans — pattern matching, taint analysis |
| [`codeql`](./skills/codeql/SKILL.md) | sast, dataflow | any | CodeQL interprocedural data flow + taint tracking |
| [`sarif-parsing`](./skills/sarif-parsing/SKILL.md) | sarif, scanning | any | Parse / dedupe / aggregate static analysis findings |
| [`audit-context-building`](./skills/audit-context-building/SKILL.md) | audit, architecture | any | Build deep architectural context before vuln hunting |
| [`insecure-defaults`](./skills/insecure-defaults/SKILL.md) | secrets, config | any | Detect fail-open defaults — hardcoded secrets, weak auth |
| [`variant-analysis`](./skills/variant-analysis/SKILL.md) | bug-hunting, patterns | any | Find similar vulnerabilities after one is found |
| [`supply-chain-risk-auditor`](./skills/supply-chain-risk-auditor/SKILL.md) | supply-chain, deps | any | Dependency risk — exploitation, takeover, health |
| [`second-opinion`](./skills/second-opinion/SKILL.md) | review, codex, gemini | any | External LLM review via Codex / Gemini CLI |

### Claude / Agents / AI

| Skill | Tags | Project types | Purpose |
|---|---|---|---|
| [`claude-api`](./skills/claude-api/SKILL.md) | claude-api, anthropic, caching | any-web | Messages API, streaming, tool use, prompt caching |
| [`mcp-server-patterns`](./skills/mcp-server-patterns/SKILL.md) | mcp, sdk, zod | any | Build MCP servers — tools, resources, prompts |
| [`agentic-engineering`](./skills/agentic-engineering/SKILL.md) | agent, eval-first | any | Eval-first execution, decomposition, model routing |
| [`agent-harness-construction`](./skills/agent-harness-construction/SKILL.md) | agent, harness | any | Action spaces, tool definitions, observation formatting |
| [`agent-introspection-debugging`](./skills/agent-introspection-debugging/SKILL.md) | agent, debugging | any | Capture → diagnose → recovery → introspection report |
| [`claude-devfleet`](./skills/claude-devfleet/SKILL.md) | agent, multi-agent | any | Orchestrate parallel coding agents |
| [`prompt-optimizer`](./skills/prompt-optimizer/SKILL.md) | prompt, optimization | any | Analyze raw prompts, surface gaps |
| [`eval-harness`](./skills/eval-harness/SKILL.md) | eval, testing | any | Eval-driven dev — pass/fail criteria before features |
| [`continuous-learning`](./skills/continuous-learning/SKILL.md) | learning, patterns | any | Extract patterns from sessions to global/project memory |
| [`iterative-retrieval`](./skills/iterative-retrieval/SKILL.md) | retrieval, rag | any | Progressive context refinement for subagent context |
| [`deep-research`](./skills/deep-research/SKILL.md) | research, firecrawl, exa | any | Multi-source research synthesis |
| [`exa-search`](./skills/exa-search/SKILL.md) | search, exa, neural | any | Neural web/code/people search via Exa MCP |

### Code review / Git

| Skill | Tags | Project types | Purpose |
|---|---|---|---|
| [`code-review`](./skills/code-review/SKILL.md) | review, quality | any | Multi-language review — patterns, security, perf |
| [`git-workflow`](./skills/git-workflow/SKILL.md) | git, branches, commits | any | Branching, commit conventions, merge strategies |

### Output templates (single-file HTML)

| Skill | Purpose |
|---|---|
| [`dashboard`](./skills/dashboard/SKILL.md) | Admin/analytics — sidebar nav, KPIs, charts |
| [`live-dashboard`](./skills/live-dashboard/SKILL.md) | Notion-style team dashboard — sparkline, activity feed, task table |
| [`blog-post`](./skills/blog-post/SKILL.md) | Long-form article — masthead, hero, pull quotes |
| [`email-marketing`](./skills/email-marketing/SKILL.md) | Brand launch email — hero, headline lockup, CTA |
| [`saas-landing`](./skills/saas-landing/SKILL.md) | SaaS landing — hero, features, social proof, pricing |
| [`pricing-page`](./skills/pricing-page/SKILL.md) | Pricing tiers, comparison, FAQ |
| [`invoice`](./skills/invoice/SKILL.md) | Printable invoice — line items, tax, payment |
| [`social-carousel`](./skills/social-carousel/SKILL.md) | 1080×1080 three-card carousel |
| [`html-ppt-pitch-deck`](./skills/html-ppt-pitch-deck/SKILL.md) | Investor 10-slide deck — blue→purple gradient |
| [`html-ppt-product-launch`](./skills/html-ppt-product-launch/SKILL.md) | Launch keynote — orange→peach accent |
| [`html-ppt-tech-sharing`](./skills/html-ppt-tech-sharing/SKILL.md) | Conference talk deck — GitHub-dark, JetBrains Mono |
| [`html-ppt-zhangzara-monochrome`](./skills/html-ppt-zhangzara-monochrome/SKILL.md) | Monochrome ledger — Lora serif, no color |
| [`web-prototype`](./skills/web-prototype/SKILL.md) | Desktop web prototype — landing / marketing / docs |
| [`video-shortform`](./skills/video-shortform/SKILL.md) | 3–10 second clips — product reveals, motion tests |
| [`wireframe-sketch`](./skills/wireframe-sketch/SKILL.md) | Hand-drawn lo-fi wireframes — graph-paper background, marker tones, annotation |
| [`design-brief`](./skills/design-brief/SKILL.md) | Parse natural-language briefs into structured specs — palette, type, layout, mood |
| [`kami-deck`](./skills/kami-deck/SKILL.md) | Print-grade slide deck — warm parchment, serif type, ink-blue accent, editorial |

---

## How the matchmaker works

1. User runs `/skills-suggest` (or enters plan mode in a fresh project).
2. Matchmaker fingerprints the project — reads `package.json`, lockfiles, framework configs, `app/manifest.ts`, etc.
3. WebFetches the catalog:
   ```
   https://raw.githubusercontent.com/itsjustiago/skillsbase/main/catalog.json
   ```
4. Normalizes fingerprint tokens (`drizzle-orm` → also matches `drizzle`, `@vercel/blob` → `vercel`, `blob`).
5. Scores each skill:
   - `project_types` exact match → **+10**
   - `any-web` + project is web → **+3**
   - `any` (universal skill) → **+2** baseline so git/security/etc. still surface on any stack
   - Each tag matching a normalized fingerprint token → **+3**
6. Buckets:
   - `score ≥ 10` → **recommended** (default-selected)
   - `6 ≤ score < 10` → **optional** (surfaced if user picks "let me see all")
   - `score < 6` → not surfaced
7. **Mismatch demotion:** a skill whose primary tag names a specific product absent from the project (e.g. `supabase-typescript` on a Drizzle project) is dropped out of "recommended" even if `project_types` pushed its score up — surfaced only as a "not for you" note.
8. User approves → matchmaker WebFetches each SKILL.md → writes to `<project>/.claude/skills/<name>/SKILL.md`
9. User restarts Claude once. Skills now load in that project only.

The matchmaker **never invents skills**, **never fabricates frontmatter**, and **never writes outside `.claude/skills/`**. If the project uses Drizzle, it won't recommend Supabase. If there are no Python files, it won't recommend `django-patterns`.

---

## `catalog.json` shape

```jsonc
{
  "version": "1",
  "updated_at": "YYYY-MM-DD",
  "skills": [
    {
      "name": "nextjs-app-router",
      "path": "skills/nextjs-app-router/SKILL.md",
      "description": "One-line ≤200 char purpose",
      "tags": ["nextjs", "react", "app-router"],
      "project_types": ["nextjs"],
      "cost_tokens": 1500
    }
  ],
  "profiles": {
    "nextjs-pwa": ["nextjs-app-router", "pwa-deployment", "supabase-typescript"]
  }
}
```

## `SKILL.md` frontmatter contract

```yaml
---
name: skill-name              # must match dir name
description: One-line ≤200 char purpose
tags: [tag1, tag2, tag3]      # free-form, used for matching
project_types: [nextjs, any-web, any]
when_to_use: |
  1-3 sentences. Concrete trigger conditions.
cost_tokens: 1500             # rough chars/4, rounded to 100
---

# Skill body in markdown
```

### `project_types` taxonomy

| Value | Meaning |
|---|---|
| `nextjs` | Next.js (any version) |
| `react` | React but not Next.js |
| `vite` | Vite-based |
| `vue`, `svelte`, `astro` | Other web frameworks |
| `rust`, `go`, `python`, `dotnet`, `kotlin`, `flutter`, `swift` | Non-JS stacks |
| `django`, `flask`, `fastapi`, `laravel`, `nestjs` | Server frameworks |
| `any-web` | Web regardless of framework |
| `any` | Framework-agnostic (git, security, etc.) |

---

## Profiles (starter packs)

Located in [`profiles/`](./profiles/). Used as baseline suggestions for common stacks.

| Profile | Skills |
|---|---|
| `nextjs-pwa` | `nextjs-app-router`, `pwa-deployment`, `supabase-typescript` |

The per-skill scoring still runs on top of a profile — additions and removals based on actual project fingerprint.

---

## Adding / modifying / removing a skill

```bash
# Add
mkdir skills/my-new-skill
$EDITOR skills/my-new-skill/SKILL.md
node scripts/build-catalog.mjs
git add skills/my-new-skill catalog.json && git commit -m "Add: my-new-skill" && git push

# Modify
$EDITOR skills/<name>/SKILL.md
node scripts/build-catalog.mjs
git add ... && git commit ... && git push
# Note: existing per-project installs do NOT auto-update (they're snapshots)

# Remove
rm -rf skills/<name>
node scripts/build-catalog.mjs
git add -A && git commit ... && git push
# Per-project installs are unaffected
```

Matchmaker reads from `main` branch, so changes are live after push.

---

## Impeccable design commands

Full list (v3.9 — 23 commands, all via `/impeccable <command> [target]`):

| Command | What it does |
|---|---|
| `init` | Setup — writes PRODUCT.md + DESIGN.md from a codebase crawl (run once per project) |
| `document` | Generate/refresh DESIGN.md from existing code |
| `craft` | Build a UI end-to-end with the full quality loop |
| `shape` | Plan UX + UI for a feature **before** code |
| `critique` | UX evaluation — visual hierarchy, cognitive load, anti-patterns, scored |
| `audit` | Technical pass — a11y, performance, theming, responsive, P0–P3 severity |
| `polish` | Final pass — alignment, spacing, consistency micro-details |
| `extract` | Consolidate repeated patterns into design-system primitives + tokens |
| `harden` | Edge cases — long text, empty/error states, i18n, slow network |
| `animate` | Add purposeful motion + micro-interactions |
| `colorize` | Inject strategic color when too monochrome |
| `typeset` | Improve type — fonts, hierarchy, sizing, readability |
| `distill` | Strip noise — simpler, cleaner, more focused |
| `clarify` | Improve unclear copy, errors, microcopy |
| `layout` | Fix spacing, rhythm, alignment, hierarchy |
| `adapt` | Add responsive breakpoints + touch targets |
| `delight` | Add personality / unexpected joy |
| `bolder` | Make safe designs more visually confident |
| `quieter` | Tone down overstimulating designs |
| `overdrive` | Push into shaders / spring physics / 60fps |
| `optimize` | Fix UI perf — rendering, bundle, images |
| `onboard` | Design onboarding/first-run flows |
| `live` | Live browser iteration — variant mode on the running app |

---

## Related

- [itsjustiago/claude-skills](https://github.com/itsjustiago/claude-skills) — the predecessor repo, now **superseded** by this one (kept for history only)
- [Claude Code docs — Skills](https://docs.anthropic.com/claude-code/skills)

## License

External skills are **never vendored** in this repo — `setup/install-externals.sh` pulls them from their original sources at install time, and they keep their own authorship and licenses (Apache-2.0, MIT, …). The own skills, catalog structure and scripts here are MIT.

</details>
