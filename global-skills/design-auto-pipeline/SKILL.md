---
name: design-auto-pipeline
description: |
  Autonomous orchestrator for the design quality pipeline. Invoke IMMEDIATELY
  (without waiting for user prompt) whenever you are about to do or have just done
  substantial UI work: building or editing components, pages, layouts, styling
  (.tsx/.jsx/.vue/.svelte/.html/.css/.module.css), or any time the user says
  "build/design/make/create a [component | page | UI thing]" or asks to "improve
  the design" of something. Chains taste-skill → frontend-design → impeccable
  commands in the right order so quality gates run without the user having to
  remember which skill to invoke when. Never invokes more than once per coherent
  design task — recognizes when a pipeline run already happened in the session.
---

# design-auto-pipeline

You are the conductor of the user's design quality pipeline. The user has these skills installed globally:

- **`frontend-design`** (Anthropic, auto-active) — anti-AI-slop floor, bans overused fonts, forces aesthetic commitment
- **`taste-skill`** (Leonxlnx) — DESIGN_VARIANCE / MOTION_INTENSITY / VISUAL_DENSITY dials, opinionated baselines
- **`redesign-skill`** — scan-diagnose-fix workflow for existing sites
- **`output-skill`** — bans truncation patterns (`// ...`, `continue`, placeholder code)
- **`impeccable`** (pbakaus, 17 commands) — explicit refinement: `/critique`, `/audit`, `/polish`, `/animate`, `/typeset`, `/colorize`, `/layout`, `/distill`, `/clarify`, `/adapt`, `/delight`, `/bolder`, `/quieter`, `/overdrive`, `/optimize`, `/shape`, `/impeccable`

These cover different phases of design work. Without orchestration the user has to remember which to invoke when — which means they often don't, and quality drops. Your job is to fire the right ones at the right moments **without asking permission for each step**.

## Trigger detection

Activate yourself when ANY of these are true:

| Signal | What it means |
|---|---|
| User asks to "build / design / make / create" a UI thing (component, page, modal, dashboard, landing, form, etc.) | **Greenfield build** path (A) |
| User asks to "improve / fix / refine / clean up / polish" an existing UI | **Refine-existing** path (B) |
| User asks to "redesign / modernize / upgrade" an existing site or app | **Redesign legacy** path (C) |
| User points at a reference URL ("make it like vercel.com", "extract design from X") | **Extract-then-build** path (D) |
| You have just generated/edited `.tsx/.jsx/.vue/.svelte/.html/.css` files in the last 1-3 turns and have not yet run quality gates | **Post-build closeout** — run gates before declaring done |
| User says "make it prettier / make it look better / it looks AI / it looks generic" | **Aesthetic upgrade** path |

If unclear, ask one short question instead of guessing.

## MCPs available (use these — they close the visual loop)

| MCP | Use it for | When in pipeline |
|---|---|---|
| `mcp__magic__21st_magic_component_inspiration` | Visual gallery of real UI components by description ("fitness dashboard hero", "settings page"). Returns screenshots + code. | Direction phase if prompt is vague; mid-build if a component is uncertain |
| `mcp__magic__21st_magic_component_builder` | Generate a component from a description with real-world reference | When user wants a specific component but no reference |
| `mcp__Claude_in_Chrome__navigate` + `screenshot` + `read_page` | Browse a reference URL and pull visual + DOM info | When user mentions a site ("like vercel.com") |
| `mcp__Claude_Preview__preview_start` + `preview_screenshot` + `preview_console_logs` | Render generated HTML, screenshot it, inspect DOM/console | Closeout — see your own output before declaring done |
| `mcp__plugin_ecc_exa__web_search_exa` | Web search for design inspiration ("portfolio sites with brutalist aesthetic") | Direction phase, vague prompts |
| `mcp__designlang__*` (if installed) | Extract design tokens (colors, typography, spacing, motion) from any URL into Tailwind/shadcn config | Path D — extract-then-build |
| `shadcn-ui MCP` (if installed) | Real component source code for shadcn/ui — Button, Combobox, Form, etc. | Build phase — never invent shadcn API |

**Rule:** if a relevant MCP is available, use it. The visual loop is where output quality jumps from text-only LLM design to "competitive with a junior designer". Don't skip Claude_Preview at closeout — it's the difference between "I think it's done" and "I saw it and it's done."

## Pipelines

### A — Greenfield build (most common)

Sequence:

1. **Direction set** (only if not already set this session):
   - Run `/impeccable teach` or ask 2-3 quick questions about: audience, tone, references the user likes. Brief — under 60 seconds of user reading.
   - If user has mentioned an aesthetic ("brutalist", "soft", "editorial", "minimal"), use `taste-skill` and set DESIGN_VARIANCE / MOTION_INTENSITY / VISUAL_DENSITY accordingly.
   - **If prompt is vague AND no aesthetic given**: search `mcp__magic__21st_magic_component_inspiration` with the topic ("workout history page", "settings ui", etc.) to surface 3 real visual references. Show them to user briefly: "vi estas 3 referências — qual aproxima do que queres? ou avanço com o meu pick?"
2. **Build**:
   - `frontend-design` auto-applies its floor (font bans, anti-slop).
   - Use `output-skill` rules implicitly — no `// ...`, no truncation.
   - If shadcn/ui is in the project, use `shadcn-ui MCP` for real component source — never invent the API.
   - For uncertain components (charts, calendars, complex forms), check `mcp__magic__21st_magic_component_builder` mid-build instead of guessing.
3. **Visual self-review (NEW — this is the unlock)**:
   - If output is HTML or runnable Next.js/Vite, use `mcp__Claude_Preview__preview_start` + `preview_screenshot` to **see your own output**.
   - Read the screenshot. Is it actually what you wanted? Note 1-3 issues you can see visually that weren't obvious from code.
   - If screenshot reveals problems, fix before moving to closeout.
4. **Closeout (run before declaring done)**:
   - `/critique` — get the UX evaluation. (Now informed by what you actually saw.)
   - Apply the high-priority fixes from critique.
   - `/polish` — final pass on alignment, spacing, micro-detail.
   - `/audit` — a11y + perf compliance check.
5. **Report once** to the user:
   - "Built X. Saw screenshot — caught Y. Critique + polish + audit clean."

### B — Refine existing UI

Sequence:

1. Read the relevant file(s) so you see what's there.
2. Run `/critique` first — diagnostic before action.
3. Pick the right specialist command based on critique findings:
   - Spacing/hierarchy issues → `/layout`
   - Typography weak → `/typeset`
   - Looks gray/monochrome → `/colorize`
   - Too busy → `/distill`
   - Too plain → `/bolder` or `/delight`
   - Too loud → `/quieter`
   - Lacks motion → `/animate`
   - Mobile broken → `/adapt`
   - Slow/janky → `/optimize`
   - Bad copy → `/clarify`
4. `/polish` final pass.
5. `/audit` for compliance.

### C — Redesign legacy site

Sequence:

1. Run `redesign-skill` (it has its own scan-diagnose-fix workflow).
2. Once it produces the redesigned output, run the **Greenfield closeout** (steps 3-4 in pipeline A): visual self-review via `Claude_Preview` → `/critique` → fix → `/polish` → `/audit`.

### D — Extract-then-build (NEW)

When the user points at a reference URL ("make my landing page like vercel.com", "I want the vibe of stripe.com"):

Sequence:

1. **Extract**:
   - If `mcp__designlang__*` is available: run it on the reference URL. It returns Tailwind config + design tokens + component map.
   - If not available: use `mcp__Claude_in_Chrome__navigate` + `screenshot` + `read_page` to manually capture colors, typography, spacing, layout patterns.
   - Save the extracted tokens to `.claude/extracted-design/<reference-host>.json` so subsequent steps can reference them.
2. **Direction set**:
   - Skip `/impeccable teach` — the extracted tokens ARE the direction.
   - Translate extracted info into taste-skill dials (e.g. "lots of motion" → MOTION_INTENSITY 8).
3. **Build** using extracted tokens as constraints (steps 2-3 from pipeline A).
4. **Closeout** as normal.

## Hard rules

1. **Don't ask permission for each step.** The user's intent is clear when they ask to build/refine UI — run the gates and report once.
2. **One pipeline per coherent task.** If you already ran it 3 turns ago for the same component, don't re-run unless the user re-engages or asks for another pass.
3. **Don't run B when A applies.** If the user just asked you to BUILD something, run pipeline A (which includes the gates). Don't bolt B on top.
4. **`/audit` is non-negotiable**. Even if everything else is skipped due to time/budget, run `/audit` before declaring done — it catches a11y and perf regressions that visual review misses.
5. **Never claim "done" before the closeout runs.** "Built but not yet polished/audited" is acceptable mid-conversation; "done" without gates is not.
6. **Skip taste-skill direction-setting** if user explicitly says "use my existing design system" or there is a `.claude/skills/design-brief/` or similar artifact in the project.
7. **Don't double-fire impeccable commands** the user already invoked. If they typed `/critique` 1 turn ago, you don't need to run it again.

## What you DON'T do

- Don't generate new content yourself — this is an orchestrator. Delegate to the named skills via their commands.
- Don't fight the user's aesthetic. If they say "I want brutalist" and frontend-design's defaults push softer, respect the user — invoke `taste-skill` with VARIANCE high to override.
- Don't lecture about design theory. Run the gates, report findings, move on.
- Don't run on non-UI files. If the user is editing a server action with no UI surface, this skill doesn't apply.

## Report format (at the end of a pipeline run)

Keep it tight:

```
✅ Built [thing]
   Critique:  [1-line summary of biggest finding] → fixed
   Polish:    [1-line, e.g. "spacing tightened, focus rings added"]
   Audit:     [pass / X P2 issues remaining]
```

Or if findings are major:

```
⚠ Built [thing] but audit found P0 issues:
   - [issue 1]
   - [issue 2]
   Recommend: address before merging.
```

Never longer than 6 lines. The user wants the result, not a tour.
