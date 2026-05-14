---
name: skill-matchmaker
description: |
  Use to install project-relevant skills from the skillsbase GitHub catalog
  into the current project's .claude/skills/ folder. Invoke when:
  (1) entering plan mode in a project that has no .claude/skills/ yet,
  (2) the user runs /skills-suggest, or
  (3) you realise a needed capability might exist in the catalog and the
  user has not been offered the chance to install it.
  Always confirms with the user before fetching or writing files.
---

# skill-matchmaker

You install Claude Code skills from the central catalog at `github.com/itsjustiago/skillsbase` into the **current project's** `.claude/skills/` directory, so they load only for that project — keeping global startup lean.

## When to invoke yourself

Trigger conditions (any one is enough):

1. **Plan mode entered AND** `<cwd>/.claude/skills/` does not exist or is empty.
2. **User invoked `/skills-suggest`** explicitly.
3. **Reactive:** during a normal turn, you (the calling agent) identified a capability gap — e.g. user asked about a framework you don't have patterns for, or wants an output format you have no skill for — and the catalog might have it.

Do **not** invoke unprompted outside these conditions. Do **not** auto-install without user approval.

## The protocol

### Step 1 — Project fingerprint

Read the project root to identify stack. Cheapest signals first:

| Signal | What to extract |
|---|---|
| `package.json` | `dependencies` + `devDependencies` keys. Look for: `next`, `react`, `vue`, `svelte`, `vite`, `astro`, `expo`, `@supabase/*`, `firebase`, `prisma`, `drizzle-orm`, `tailwindcss`. |
| `tsconfig.json` exists | `typescript` |
| `next.config.*` exists | `nextjs` (confirm beyond `package.json`) |
| `public/manifest.json` or `app/manifest.ts` | `pwa` |
| `Cargo.toml` | `rust` + crate names |
| `pubspec.yaml` | `flutter` / `dart` |
| `*.csproj`, `*.sln` | `dotnet` / `csharp` |
| `go.mod` | `go` + module imports |
| `pyproject.toml`, `requirements.txt` | `python` + framework (`django`, `fastapi`, `flask`) |
| `supabase/config.toml` or `supabase/migrations/` | `supabase` |
| Vercel/Netlify config | deployment platform |

Build a fingerprint object:

```ts
{
  languages: string[],        // e.g. ["typescript"]
  frameworks: string[],       // e.g. ["nextjs", "react"]
  libraries: string[],        // e.g. ["supabase", "tailwindcss"]
  features: string[],         // e.g. ["pwa", "ssr"]
  project_types: string[],    // normalized: e.g. ["nextjs"]
}
```

A `Project type:` line may already be present in the session context (from the SessionStart hook output) — use it as a hint but verify by reading files.

### Step 2 — Fetch the catalog

```
WebFetch https://raw.githubusercontent.com/itsjustiago/skillsbase/main/catalog.json
```

Parse as JSON. Shape:

```json
{
  "version": "1",
  "updated_at": "YYYY-MM-DD",
  "skills": [
    { "name": "...", "path": "skills/<name>/SKILL.md",
      "description": "...", "tags": [...], "project_types": [...],
      "cost_tokens": 1500 }
  ],
  "profiles": { "<name>": [ "skill-a", "skill-b" ] }
}
```

If the WebFetch fails (offline, 404, malformed JSON):
- **Graceful fallback:** if a local clone of the `skillsbase` repo exists (commonly `~/Desktop/skillsbase/` or wherever the user keeps it), read `catalog.json` from there instead — it's the same file.
- If no local clone is reachable, tell the user clearly and stop. **Do not invent a catalog.**

### Step 3 — Score each skill

**Before scoring — normalize the fingerprint tokens.** Package names rarely match
catalog tags exactly. Build a normalized set: lowercase, strip `@scope/` prefixes,
strip common suffixes (`-orm`, `-js`, `-ts`, `-react`, `-core`), and ALSO keep the
raw token. So `drizzle-orm` → `{drizzle-orm, drizzle}`, `@vercel/blob` →
`{@vercel/blob, vercel/blob, vercel, blob}`. Match catalog tags against this
expanded set, both directions (a catalog tag is a hit if it equals OR is a
substring of any normalized token, or vice versa).

For each `skill` in the catalog:

```
score = 0
for pt in skill.project_types:
  if pt in fingerprint.project_types:            score += 10
  elif pt == "any-web" and fingerprint.is_web:   score += 3
  elif pt == "any":                              score += 2   # universal-skill baseline
for tag in skill.tags:
  if tag matches any normalized fingerprint token:  score += 3
```

The `any` baseline (+2) ensures universally-useful skills (`git-workflow`,
`code-review`, `postgres-patterns`, etc.) still surface on stacks where no tag
matches — e.g. a Rust or Python project. Without it they'd score 0 and vanish.

**Thresholds (canonical — must match README and Step 5):**
- `score ≥ 10` → **recommended** (default-selected in the proposal)
- `6 ≤ score < 10` → **optional** (only surfaced if the user picks "let me see everything")
- `score < 6` → not surfaced

**Mismatch demotion (apply after scoring):** if a skill's *primary* tag names a
specific product/framework that is **absent** from the fingerprint — e.g.
`supabase-typescript` (primary tag `supabase`) on a project with no `supabase`
dependency — drop it out of "recommended" into "mismatch", even if its
`project_types` match pushed the score ≥ 10. A `project_types: [nextjs]` match
means "relevant to Next.js projects", not "this specific product is in use". Surface
mismatches only as a one-line "the catalog has this but it's not for you" note.

Also: if a `profile` in `catalog.profiles` matches the fingerprint, surface it as a
"starter pack" — but still run per-skill scoring on top; the profile is a baseline,
not the final answer (a profile may bundle a skill that mismatch-demotion rejects).

### Step 4 — Already-installed check

List `<cwd>/.claude/skills/` and remove any candidates that are already installed there. If a candidate has the same name as a globally-installed skill (in `~/.claude/skills/`), warn the user — local will shadow global.

### Step 5 — Recommend (don't enumerate)

**Critical UX rule:** the user does not know what these skills do, and does not want to learn before deciding. They trust you to make the call. Your job is to **recommend a specific subset and justify it in concrete project terms**, then ask for a simple yes/no.

Never present skills as a flat menu of options for the user to evaluate. Never use the abstract description from the catalog — translate it into "what you'll use this for in *this* project".

#### Partition the scored skills

- **Recomendadas** (score ≥ 10): confident match. Default to install.
- **Opcionais** (score 6–9): plausible, not certain. Do **not** default-include — only mention if user picks "let me see everything".
- **Mismatch / warning**: a skill that appears in a profile or has a tag overlap but the fingerprint shows it doesn't fit (e.g. catalog has `supabase-typescript` but project uses Drizzle). Mention briefly as a "the catalog has this but it's not for you" line.

#### Output format

Lead with a short paragraph in the user's language explaining what you found, then a justification per recommended skill **anchored in real artifacts from this project** (specific files, dependencies, config you saw during fingerprint).

Example for a Next.js + PWA + Drizzle project:

> Olhei para o projeto: Next.js 16, PWA com `manifest.ts` e service worker, Drizzle ORM em cima de Neon. Recomendo instalar **2** skills:
>
> 1. **`nextjs-app-router`** — vais usar isto no dia-a-dia. Cobre server components, server actions, route handlers, layouts e o boundary `use client`/`use server`. Toda a tua pasta `app/` depende destes padrões.
>
> 2. **`pwa-deployment`** — tens `app/manifest.ts` e registo do service worker, e o app já instala em mobile. Cobre os gotchas do iOS (splash screens, status bar, jar separada de cookies), ícones maskable para Android, e o ciclo de update do service worker.
>
> Há uma terceira no catálogo (`supabase-typescript`) que **não recomendo** porque o teu projeto usa Drizzle+Neon, não Supabase. Só fazia sentido se planeares migrar.
>
> Custo: ~2900 tokens adicionados ao startup do `lift`. Ficam só neste projeto (`.claude/skills/`), não afetam mais nada.

#### Ask one question, three options

Use `AskUserQuestion` with **one** question (not a multi-select menu). Options:

1. **"Sim, instala as recomendadas"** — default path, one click and done.
2. **"Quero ver tudo e escolher"** — only then fall back to the multi-select menu with all candidates (recommended + optional + mismatch, with the warning intact).
3. **"Não, agora não"** — exit gracefully.

If the user picks option 2, present the full multi-select with the recommended ones pre-justified. Still **never** dump a flat list without per-project explanations.

### Step 6 — Install

For each approved skill:

1. WebFetch `https://raw.githubusercontent.com/itsjustiago/skillsbase/main/<path>` (the `path` field from catalog).
2. Write to `<cwd>/.claude/skills/<name>/SKILL.md` (create dirs as needed).
3. Confirm each write.

After all writes succeed, output the install summary **followed by a prominent restart banner** — this is non-negotiable. Skills installed in `.claude/skills/` only load at session startup. If the user keeps using the current session, the new skills do nothing.

Use this exact format (the banner block must be present, can't be omitted or softened):

```
✅ Skills instaladas em .claude/skills/:
  - nextjs-app-router
  - pwa-deployment
  - supabase-typescript

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  RESTART OBRIGATÓRIO

Fecha e abre o Claude Code para as skills ficarem ativas.
As skills SÓ carregam no arranque da sessão — sem restart,
foram só ficheiros escritos no disco, o Claude não as conhece.

Depois do restart: skills disponíveis em todas as sessões
futuras neste projeto (só precisas reiniciar 1 vez).
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Versionamento (opcional):
  • Commit em .claude/skills/  → team partilha as skills
  • Add a .gitignore           → fica pessoal
```

**Do NOT** soften the warning. **Do NOT** put it in italics or hide it in a paragraph. **Do NOT** add "if you have time" or "when convenient" — the banner must be the visual climax of the output, because users who skip it will think the matchmaker did nothing.

### Step 7 — Git advice (only on first install)

If `<cwd>/.claude/skills/` was empty before this run and `<cwd>/.git/` exists, ask the user whether they want the skills committed (team-shared) or git-ignored (personal). On their choice:

- **Commit:** do nothing — files are tracked by default.
- **Ignore:** append `.claude/skills/` to `<cwd>/.gitignore` (create if missing).

Do not run `git add` / `git commit` automatically — leave that to the user.

## Failure modes

| Situation | What to do |
|---|---|
| Catalog fetch fails | Show URL + error; stop. Do not fall back to a hardcoded list. |
| Fingerprint is empty (no detectable config files) | Tell the user, ask what stack they're targeting, let them pick from full catalog. |
| All candidates already installed | Say "no new recommendations" and exit. Optionally show `/skills-suggest` for manual browsing. |
| User rejects everything | Acknowledge, exit. Do not retry the same proposal next session — once per session is enough. |
| Skill in catalog has same name as global skill | Warn before install. If user proceeds, local file shadows global. |

## Hard rules

- **Never write outside `<cwd>/.claude/skills/`** — not even with user approval. If they want a global skill, they install it themselves.
- **Never invoke yourself in a loop** — one proposal per session, max.
- **Never edit existing local skills** without explicit confirmation — only create new ones or skip.
- **Never fabricate skill content** — if a fetch fails or returns 404, report it; don't write a placeholder.
- **Confirm before fetching** the SKILL.md bodies — the catalog fetch is fine without confirmation, but individual skill downloads + writes need approval.
- **Always end with the RESTART banner** — the install is incomplete in the user's mind until they restart Claude Code. If you skip or soften the banner, the user assumes the new skills are already active and gets confused when nothing changes. The exact format in Step 6 is mandatory.
