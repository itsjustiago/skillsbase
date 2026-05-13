# skillsbase

Catalog of Claude Code skills, installed per-project by the [`skill-matchmaker`](#how-the-matchmaker-works) skill.

> Your Claude has **two layers** of skills:
> - 🌍 **Global** — always loaded in every project, no install needed.
> - 📦 **Per-project** — picked from this catalog by the matchmaker. Only loads in projects that need them.

---

# 🌍 Global skills (always-on)

Just type the trigger word in any chat. No install, no setup.

### Workflow

- **"brainstorm X"** → talks through intent + requirements before any code
- **"make a plan for X"** → builds a structured plan, you approve before edits
- **"debug X"** → systematic diagnosis (repro → isolate → root cause)
- **"verify"** → forces evidence before claiming "done"

### PRs & shipping

- **"ship and merge"** (or `/ship-merge`) → commit → PR → CI → merge → cleanup, in one shot
- **"wrap up session"** → end-of-session handoff summary for the next agent
- **`/skills-suggest`** → propose project-relevant skills from this catalog

### Design polish (after UI is built)

- **`/critique`** → UX review
- **`/audit`** → accessibility + performance check
- **`/polish`** → final pass on alignment, spacing, micro-detail
- **`/animate`** · **`/typeset`** · **`/colorize`** · **`/distill`** · *[+ 10 more](#impeccable-design-commands)*

### Context & video

- **`/clear-context`** → auto-saves + spawns continuation at 80% context
- **`/watch <url>`** → downloads + transcribes a video, answers questions about it

---

# 📦 Per-project skills (on-demand)

When you open a project, run:

```
/skills-suggest
```

The **matchmaker** reads your `package.json` (or `Cargo.toml`, `pyproject.toml`, etc.), picks skills from this catalog that match your stack, and installs them into `<project>/.claude/skills/`. They only load in that project.

Restart Claude once after install — done. Future sessions in that project automatically have those skills.

---
---

<details>
<summary><b>📚 Reference (for the Claude agent reading this)</b> — full catalog, schemas, and scoring algorithm</summary>

## Catalog — 59 skills

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

---

## How the matchmaker works

1. User runs `/skills-suggest` (or enters plan mode in a fresh project).
2. Matchmaker fingerprints the project — reads `package.json`, lockfiles, framework configs, `app/manifest.ts`, etc.
3. WebFetches the catalog:
   ```
   https://raw.githubusercontent.com/itsjustiago/skillsbase/main/catalog.json
   ```
4. Scores each skill:
   - `project_types` exact match → **+10**
   - `any-web` + project is web → **+3**
   - Each tag in common with fingerprint → **+3**
5. Buckets:
   - `score ≥ 10` → **recommended** (default-selected)
   - `6 ≤ score < 10` → **optional** (surfaced if user picks "let me see all")
   - `score < 6` → not surfaced
6. User approves → matchmaker WebFetches each SKILL.md → writes to `<project>/.claude/skills/<name>/SKILL.md`
7. User restarts Claude once. Skills now load in that project only.

The matchmaker **never invents skills**, **never fabricates frontmatter**, and **never writes outside `.claude/skills/`**. If the project uses Drizzle, it won't propose Supabase. If there are no Python files, it won't propose `django-patterns`.

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

Full list referenced from the global section:

| Command | What it does |
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
| `/adapt` | Add responsive breakpoints + touch targets |
| `/delight` | Add personality / unexpected joy |
| `/bolder` | Make safe designs more visually confident |
| `/quieter` | Tone down overstimulating designs |
| `/overdrive` | Push into shaders / spring physics / 60fps |
| `/optimize` | Fix UI perf — rendering, bundle, images |
| `/shape` | Plan UX + UI for a feature **before** code |
| `/impeccable` | Run the whole suite end-to-end |

---

## Related

- [itsjustiago/claude-skills](https://github.com/itsjustiago/claude-skills) — bootstrap repo (new machine setup, MCP auth, global CLAUDE.md)
- [Claude Code docs — Skills](https://docs.anthropic.com/claude-code/skills)

## License

Skills migrated from upstream plugins retain their original authorship and licenses. The catalog structure (frontmatter schema, build script, matchmaker integration) is MIT.

</details>
