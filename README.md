# skillsbase

> On-demand catalog of Claude Code skills, installed per-project by the [`skill-matchmaker`](#how-the-catalog-works) skill.
> Companion to [itsjustiago/claude-skills](https://github.com/itsjustiago/claude-skills) (the bootstrap repo for a new machine).

```
┌──────────────────────────────────────────────────────────────────────────┐
│  ~/.claude/   (GLOBAL — always loaded, ~5 plugins + 3 user skills)       │
│   ↓                                                                      │
│  skill-matchmaker (consulted in plan mode / via /skills-suggest)         │
│   ↓                                                                      │
│  github.com/itsjustiago/skillsbase   (this repo, 59 skills)              │
│   ↓                                                                      │
│  <project>/.claude/skills/   (selected per-project, restart Claude once) │
└──────────────────────────────────────────────────────────────────────────┘
```

Catalog: **59 skills**, 1 starter profile (`nextjs-pwa`). Live JSON index at [`catalog.json`](./catalog.json).

---

```
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║     🧰  CHEATSHEET — Global skills you always have (for the human)         ║
║                                                                            ║
║   These work in any project, no install needed. After Quick Start          ║
║   below, just type the trigger words and the right skill kicks in.         ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### Catalog & matchmaker

| Trigger / command | What happens | When to use |
|---|---|---|
| **`/skills-suggest`** | Matchmaker reads your `package.json` / `Cargo.toml` / etc., proposes skills from this catalog | First time opening any project, or when the project gains a new stack (added Supabase, etc.) |
| **`session-handoff`** ("wrap up session", "hand off") | Generates a single-fenced-block summary of the session — decisions, files changed, what's running, what to verify next — so a fresh agent picks up after `/clear` | Before `/clear` on a long session |
| **`/watch <url>`** | Downloads a video, extracts frames + transcript, answers questions about it | Analyzing tutorials, demos, or content clips |

### Workflow skills (`superpowers`)

| Trigger / command | What happens |
|---|---|
| **"brainstorm X"** / `superpowers:brainstorming` | Explores your intent + requirements *before* writing code. Asks the hard questions instead of guessing. |
| **`/plan-mode`** (or "make a plan for X") | Builds a structured plan in `~/.claude/plans/` for multi-step tasks. You approve before any edit. |
| **"debug X"** / `superpowers:systematic-debugging` | Methodical bug diagnosis — repro → isolate → root cause — instead of guessing fixes. |
| **`/tdd`** / `superpowers:test-driven-development` | Forces failing test → minimal pass → refactor. No implementation without a test. |
| **`worktree X`** / `superpowers:using-git-worktrees` | Creates an isolated git worktree before risky/destructive work. Lets you abandon cleanly. |
| **"verify"** / `superpowers:verification-before-completion` | Forces evidence (run the test, check the build) before claiming "done". |
| **`/code-review`** / `superpowers:requesting-code-review` | Requests a structured review against the plan + standards. |

### PR & shipping (`sanctum`)

| Trigger / command | What happens |
|---|---|
| **`/ship-merge`** (or "ship and merge", "dá ship e merge") | Full one-shot release: stage → commit → push → open PR → wait for CI → light review → squash-merge → cleanup branch. Doesn't run heavy gates. |
| **`/ship`** | Same but stops at "PR opened" — no auto-merge. |

### Design polish (`impeccable`)

After any UI is built. All of these read the current code and improve specific aspects.

| Trigger | What it does |
|---|---|
| `/critique` | UX evaluation — visual hierarchy, cognitive load, anti-patterns, scored |
| `/audit` | Technical pass — a11y, performance, theming, responsive, P0–P3 severity |
| `/polish` | Final pass — alignment, spacing, consistency micro-details |
| `/animate` | Add purposeful motion + micro-interactions |
| `/colorize` | Inject strategic color when too monochrome |
| `/typeset` | Improve type — fonts, hierarchy, sizing, readability |
| `/distill` | Strip noise — simpler, cleaner, more focused |
| `/clarify` | Improve unclear copy, errors, microcopy |
| `/layout` | Fix spacing, rhythm, alignment, hierarchy |
| `/adapt` | Add responsive breakpoints & touch targets |
| `/delight` | Add personality / unexpected joy |
| `/bolder` | Make safe designs more visually confident |
| `/quieter` | Tone down overstimulating designs |
| `/overdrive` | Push into shaders / spring physics / 60fps |
| `/optimize` | Fix UI perf — rendering, bundle, images |
| `/shape` | Plan UX + UI for a feature **before** code |
| `/impeccable` | Run the whole suite |

### Context management (`conserve`)

These guard the token budget on long sessions.

| Trigger | What it does |
|---|---|
| `/clear-context` | Auto-saves state + spawns a continuation subagent at 80% context |
| `/optimize-context` | MECW audit — what to keep, summarize, drop |
| `/token-conservation` | Token quota planning at session start |
| `/bloat-detector` | Find dead code, duplication, doc bloat in the project |
| `/ai-hygiene-audit` | Detect AI-generated bloat patterns (vibe coding, Tab spam, slop) |
| `/unbloat` | Remove the dead code with backup + per-step approval |

### One-shot starter

```bash
# In any new project:
/skills-suggest                # matchmaker proposes catalog skills for THIS project
# review proposal, accept, restart Claude → those skills load only here

# Daily work:
"brainstorm a workout history page"     # superpowers:brainstorming
/tdd                                     # tests first
# ... build it ...
/critique                                # impeccable design review
/polish                                  # final pass
/ship-merge                              # PR + merge in one shot

# End of session:
"wrap up session"                        # session-handoff produces a copy-paste block
/clear                                   # start clean next time
```

---

## How the catalog works

1. **You** open Claude in any project and run `/skills-suggest` (or just enter plan mode in a fresh repo).
2. **The `skill-matchmaker` skill** fingerprints the project by reading `package.json`, `Cargo.toml`, `pyproject.toml`, `next.config.*`, `app/manifest.ts`, lockfiles, etc.
3. **It WebFetches** [`catalog.json`](./catalog.json) from this repo.
4. **It scores** each catalog skill against your fingerprint:
   - `project_types` exact match → +10
   - `any-web` + your project is web → +3
   - Each tag in common with detected stack → +3
5. **It proposes** the top picks in plain language with a single Yes / Let-me-pick / No question. Skills that *would* match if your stack differed are flagged as warnings, not blindly recommended.
6. **On approval**, it WebFetches each selected SKILL.md and writes to `<project>/.claude/skills/<name>/SKILL.md`.
7. **You restart Claude** once. Those skills now load only for that project's future sessions.

The output is **deterministic** — the matchmaker never invents a skill, never fabricates frontmatter, and never writes outside `.claude/skills/`. If a project has Drizzle, it won't propose Supabase. If a project has no Python files, it won't propose `django-patterns`.

---

## Catalog (59 skills)

Grouped by topic. Each entry: name → tags + project types → one-line purpose. Click any skill name to read its full body.

### Stack: Next.js / React / TypeScript

| Skill | Tags | Purpose |
|---|---|---|
| [`nextjs-app-router`](./skills/nextjs-app-router/SKILL.md) | nextjs, react, app-router, ssr | Server components, server actions, route handlers, layouts, streaming, `use client`/`use server` boundary |
| [`nextjs-turbopack`](./skills/nextjs-turbopack/SKILL.md) | nextjs, turbopack, performance | Next.js 16+ Turbopack — incremental bundling, HMR, dev startup |
| [`react-19-patterns`](./skills/react-19-patterns/SKILL.md) | react-19, hooks, actions | Actions, `useActionState`, `useOptimistic`, `use()`, ref-as-prop, document metadata |
| [`frontend-patterns`](./skills/frontend-patterns/SKILL.md) | react, nextjs, hooks, state | React/Next.js patterns, state management, performance, accessibility |
| [`tailwindcss-v4`](./skills/tailwindcss-v4/SKILL.md) | tailwind, css, postcss | v4 is a rewrite — CSS-first config, `@theme`, breaking changes from v3 |
| [`pwa-deployment`](./skills/pwa-deployment/SKILL.md) | pwa, service-worker, manifest, ios | Manifest, SW registration, install prompt, iOS quirks, splash screens |

### Stack: Database / Backend / Storage

| Skill | Tags | Purpose |
|---|---|---|
| [`drizzle-neon-typescript`](./skills/drizzle-neon-typescript/SKILL.md) | drizzle, neon, postgres | Drizzle ORM on Neon — schema, queries, migrations, HTTP vs WebSocket driver |
| [`supabase-typescript`](./skills/supabase-typescript/SKILL.md) | supabase, postgres, auth, rls | Typed client, RLS-friendly queries, SSR cookies, realtime |
| [`postgres-patterns`](./skills/postgres-patterns/SKILL.md) | postgres, sql, indexing | Query optimization, schema design, indexing strategies |
| [`database-migrations`](./skills/database-migrations/SKILL.md) | migration, drizzle, prisma, sql | Schema changes, data migrations, rollback procedures |
| [`vercel-blob-storage`](./skills/vercel-blob-storage/SKILL.md) | vercel, blob, uploads, cdn | `put`/`del`/`list`/`head`, client uploads >4.5 MB, path conventions |
| [`custom-jwt-auth-jose`](./skills/custom-jwt-auth-jose/SKILL.md) | jwt, jose, bcrypt, middleware | Edge-compatible JWT, httpOnly cookies, middleware gate, login flow |
| [`backend-patterns`](./skills/backend-patterns/SKILL.md) | nodejs, express, architecture | Repository/service layers, caching, REST/GraphQL, auth |
| [`api-design`](./skills/api-design/SKILL.md) | api, rest, http, pagination | Resource naming, status codes, versioning, rate-limiting |

### Stack: Runtime / Deploy / Infra

| Skill | Tags | Purpose |
|---|---|---|
| [`bun-runtime`](./skills/bun-runtime/SKILL.md) | bun, javascript, runtime | Bun as all-in-one runtime, package manager, bundler |
| [`docker-patterns`](./skills/docker-patterns/SKILL.md) | docker, container, security | Multi-stage builds, Compose, container security, network isolation |
| [`deployment-patterns`](./skills/deployment-patterns/SKILL.md) | deploy, ci-cd, vercel | CI/CD pipelines, health checks, rollback procedures |

### Testing

| Skill | Tags | Purpose |
|---|---|---|
| [`tdd-workflow`](./skills/tdd-workflow/SKILL.md) | tdd, jest, vitest, playwright | Red-green-refactor with 80%+ coverage |
| [`e2e-testing`](./skills/e2e-testing/SKILL.md) | e2e, playwright, browser | Playwright patterns, Page Object Model, CI integration |
| [`browser-qa`](./skills/browser-qa/SKILL.md) | qa, visual-testing, browser | Visual testing, UI interaction verification, screenshot diffs |
| [`benchmark`](./skills/benchmark/SKILL.md) | performance, baselines | Establish perf baselines, detect regressions PR-by-PR |
| [`mutation-testing`](./skills/mutation-testing/SKILL.md) | mutation, coverage | Mewt/muton campaigns — verify your tests actually catch bugs |
| [`property-based-testing`](./skills/property-based-testing/SKILL.md) | property, fuzzing | Generative testing for invariants across input space |

### Security & Audit

| Skill | Tags | Purpose |
|---|---|---|
| [`semgrep`](./skills/semgrep/SKILL.md) | sast, static-analysis | Semgrep scans — pattern matching, taint analysis, "important only" mode |
| [`codeql`](./skills/codeql/SKILL.md) | sast, dataflow | CodeQL interprocedural data flow + taint tracking |
| [`sarif-parsing`](./skills/sarif-parsing/SKILL.md) | sarif, scanning | Parse / dedupe / aggregate static analysis findings |
| [`audit-context-building`](./skills/audit-context-building/SKILL.md) | audit, architecture | Build deep architectural context before vulnerability hunting |
| [`insecure-defaults`](./skills/insecure-defaults/SKILL.md) | secrets, config | Detect fail-open insecure defaults — hardcoded secrets, weak auth |
| [`variant-analysis`](./skills/variant-analysis/SKILL.md) | bug-hunting, patterns | Find similar vulnerabilities after one is found |
| [`supply-chain-risk-auditor`](./skills/supply-chain-risk-auditor/SKILL.md) | supply-chain, deps | Dependency risk — exploitation, takeover, maintenance health |
| [`second-opinion`](./skills/second-opinion/SKILL.md) | review, codex, gemini | External LLM code review via Codex / Gemini CLI |

### Claude / Agents / AI

| Skill | Tags | Purpose |
|---|---|---|
| [`claude-api`](./skills/claude-api/SKILL.md) | claude-api, anthropic, caching | Messages API, streaming, tool use, prompt caching |
| [`mcp-server-patterns`](./skills/mcp-server-patterns/SKILL.md) | mcp, sdk, zod | Build MCP servers — tools, resources, prompts, validation |
| [`agentic-engineering`](./skills/agentic-engineering/SKILL.md) | agent, eval-first | Operating model for eval-first execution, decomposition, model routing |
| [`agent-harness-construction`](./skills/agent-harness-construction/SKILL.md) | agent, harness | Action spaces, tool definitions, observation formatting |
| [`agent-introspection-debugging`](./skills/agent-introspection-debugging/SKILL.md) | agent, debugging | Capture → diagnose → recovery → introspection report |
| [`claude-devfleet`](./skills/claude-devfleet/SKILL.md) | agent, multi-agent | Orchestrate parallel coding agents — plan, dispatch, integrate |
| [`prompt-optimizer`](./skills/prompt-optimizer/SKILL.md) | prompt, optimization | Analyze raw prompts, match ECC components, surface gaps |
| [`eval-harness`](./skills/eval-harness/SKILL.md) | eval, testing | Eval-driven dev — pass/fail criteria before features |
| [`continuous-learning`](./skills/continuous-learning/SKILL.md) | learning, patterns | Extract patterns from sessions, save to global/project memory |
| [`iterative-retrieval`](./skills/iterative-retrieval/SKILL.md) | retrieval, rag | Progressive context refinement for subagent context |
| [`deep-research`](./skills/deep-research/SKILL.md) | research, firecrawl, exa | Multi-source research synthesis |
| [`exa-search`](./skills/exa-search/SKILL.md) | search, exa, neural | Neural web/code/companies/people search via Exa MCP |

### Code review / Git

| Skill | Tags | Purpose |
|---|---|---|
| [`code-review`](./skills/code-review/SKILL.md) | review, quality | Multi-language review focusing on patterns, security, perf |
| [`git-workflow`](./skills/git-workflow/SKILL.md) | git, branches, commits | Branching, commit conventions, merge strategies |

### Output templates (HTML)

These generate single-file HTML artifacts. Useful when you need a deliverable, not just code.

| Skill | What it generates |
|---|---|
| [`dashboard`](./skills/dashboard/SKILL.md) | Admin/analytics dashboard — sidebar nav, KPI cards, charts |
| [`live-dashboard`](./skills/live-dashboard/SKILL.md) | Notion-style team dashboard — sparkline, activity feed, task table |
| [`blog-post`](./skills/blog-post/SKILL.md) | Long-form article — masthead, hero, pull quotes, byline |
| [`email-marketing`](./skills/email-marketing/SKILL.md) | Brand product-launch email — hero, headline lockup, CTA |
| [`saas-landing`](./skills/saas-landing/SKILL.md) | SaaS landing — hero, features, social proof, pricing, CTA |
| [`pricing-page`](./skills/pricing-page/SKILL.md) | Pricing tiers, feature comparison, FAQ |
| [`invoice`](./skills/invoice/SKILL.md) | Printable invoice — line items, tax, payment instructions |
| [`social-carousel`](./skills/social-carousel/SKILL.md) | 1080×1080 three-card carousel with connected headline |
| [`html-ppt-pitch-deck`](./skills/html-ppt-pitch-deck/SKILL.md) | Investor 10-slide pitch deck — blue→purple gradient |
| [`html-ppt-product-launch`](./skills/html-ppt-product-launch/SKILL.md) | Launch keynote — orange→peach accent |
| [`html-ppt-tech-sharing`](./skills/html-ppt-tech-sharing/SKILL.md) | Conference talk deck — GitHub-dark, JetBrains Mono |
| [`html-ppt-zhangzara-monochrome`](./skills/html-ppt-zhangzara-monochrome/SKILL.md) | Monochrome ledger-paper deck — Lora serif, no color |
| [`web-prototype`](./skills/web-prototype/SKILL.md) | Desktop web prototype — landing/marketing/docs/SaaS |
| [`video-shortform`](./skills/video-shortform/SKILL.md) | 3–10 second clips — product reveals, motion tests |

---

## Profiles (starter packs)

Curated bundles for common project types, defined in [`profiles/`](./profiles/). The matchmaker uses them as a baseline when the fingerprint matches.

| Profile | Skills |
|---|---|
| `nextjs-pwa` | `nextjs-app-router`, `pwa-deployment`, `supabase-typescript` (baseline — matchmaker adds more based on actual stack) |

To add a profile: drop `profiles/<name>.json` with `{ "skills": ["a", "b", ...] }`, run `node scripts/build-catalog.mjs`, push.

---

## For Claude Code agents reading this

> This section is for an agent that has been pointed at this repo. The structure of every entry is designed to be cheap to parse.

### `catalog.json` shape

```jsonc
{
  "version": "1",
  "updated_at": "YYYY-MM-DD",
  "skills": [
    {
      "name": "nextjs-app-router",
      "path": "skills/nextjs-app-router/SKILL.md",
      "description": "One-line purpose, used for matching and surfaced to the user.",
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

Fetch URL (always main branch):
```
https://raw.githubusercontent.com/itsjustiago/skillsbase/main/catalog.json
```

### `SKILL.md` frontmatter contract

Every skill in [`skills/`](./skills/) has a YAML frontmatter block:

```yaml
---
name: skill-name              # must match dir name
description: One-line ≤200 char purpose
tags: [tag1, tag2, tag3]      # free-form, for matching
project_types: [nextjs, any-web, any]   # see below
when_to_use: |
  1-3 sentences in plain language. Concrete trigger conditions.
  What the agent should be working on when this fires.
cost_tokens: 1500             # rough estimate, chars/4 rounded to 100
---

# Skill body...
```

**`project_types` taxonomy:**

| Value | Meaning |
|---|---|
| `nextjs` | Project uses Next.js (any version) |
| `react` | Project uses React but not Next.js |
| `vite` | Vite-based project |
| `vue`, `svelte`, `astro` | Other web frameworks |
| `rust`, `go`, `python`, `dotnet`, `kotlin`, `flutter`, `swift` | Non-JS stacks |
| `django`, `flask`, `fastapi`, `laravel`, `nestjs` | Specific server frameworks |
| `any-web` | Web project regardless of framework |
| `any` | Truly framework-agnostic (e.g. git workflow, security audit) |

### Matchmaker scoring algorithm

```
for each skill in catalog.skills:
  score = 0
  for pt in skill.project_types:
    if pt in fingerprint.project_types:    score += 10
    elif pt == "any-web" and fingerprint.is_web: score += 3
  for tag in skill.tags:
    if tag in fingerprint.flat_tags:       score += 3
```

Thresholds:
- `score ≥ 10` → **recommend** (default-selected in install proposal)
- `6 ≤ score < 10` → **optional** (surfaced if user chooses "let me pick")
- `score < 6` → not surfaced unless explicitly browsing

### Adding a new skill

```bash
# 1. Create skill dir
mkdir skills/my-new-skill
$EDITOR skills/my-new-skill/SKILL.md   # write frontmatter + body

# 2. Regenerate catalog
node scripts/build-catalog.mjs

# 3. Verify
cat catalog.json | python -m json.tool | head -30

# 4. Commit + push
git add skills/my-new-skill catalog.json
git commit -m "Add skill: my-new-skill"
git push
```

The matchmaker reads from the `main` branch, so new skills are live after push.

### Modifying an existing skill

Edit `skills/<name>/SKILL.md`, run `node scripts/build-catalog.mjs`, push. **Existing per-project installs do NOT auto-update** — they're snapshots. A future `/skills-update` command might address that.

### Removing a skill

Delete the directory under `skills/`, run the build script, push. Per-project installs are unaffected (they have their own copy).

### Local development

```bash
git clone https://github.com/itsjustiago/skillsbase.git
cd skillsbase
node scripts/build-catalog.mjs        # builds catalog.json from skills/*
```

No dependencies beyond Node 18+. The build script is pure stdlib.

### Profile schema

```json
{
  "description": "Optional human description",
  "skills": ["skill-a", "skill-b"]
}
```

The matchmaker uses profiles as a **baseline suggestion**; the per-skill scoring still runs and may add or remove entries based on the actual project fingerprint.

---

## Related

- [itsjustiago/claude-skills](https://github.com/itsjustiago/claude-skills) — bootstrap repo (new machine setup, MCP auth, global CLAUDE.md)
- [Claude Code docs — Skills](https://docs.anthropic.com/claude-code/skills)
- [Claude Code docs — Plugins](https://docs.anthropic.com/claude-code/plugins)

---

## License

Skills migrated from upstream plugins (ecc, trailofbits, engineering-skills, etc.) retain their original authorship and licenses. This catalog structure (frontmatter schema, build script, matchmaker integration) is MIT.
