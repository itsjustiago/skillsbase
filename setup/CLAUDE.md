# Global Claude Code Instructions

## Skills architecture (read this first)

This machine runs a **two-layer skill system**:

- **Global layer** — a small core that loads in every session: 7 plugins (superpowers, sanctum+leyline, conserve, impeccable, frontend-design, watch) + a handful of user skills in `~/.claude/skills/` (`skill-matchmaker`, `skill-scout`, `design-auto-pipeline`, `taste-skill`, `redesign-skill`, `output-skill`, `session-handoff`, `graphify`). Keep this lean — it's startup token cost on every session.
- **Per-project layer** — installed on demand into `<project>/.claude/skills/` by the `skill-matchmaker` skill, pulling from the catalog at https://github.com/itsjustiago/skillsbase.

**Two discovery skills, different scope:**
- `skill-matchmaker` — searches the user's **own catalog** (skillsbase). "What do I have for this?"
- `skill-scout` — searches the **wider public ecosystem** (GitHub, awesome-lists, marketplaces, MCP registry). "What exists out there I don't know about?" Use when the user asks "find me a skill/plugin for X" or when the matchmaker comes up empty.

**When the user says "install a skill":**
- If it's a stack/task-specific skill → it belongs in the project. Use `skill-matchmaker` to pull it from the skillsbase catalog into `<project>/.claude/skills/`. If it's not in the catalog yet, add it to the catalog first (see below), then install.
- If it's a genuinely global capability (used in *every* project) → install to `~/.claude/skills/` and confirm it's now global. Be conservative — global is expensive.

**The single source of truth is the `skillsbase` repo** (https://github.com/itsjustiago/skillsbase). It contains both the skill catalog AND the machine bootstrap (setup scripts, configs, MCP guides). After meaningfully changing skills/setup, update that repo: add/edit the `skills/<name>/SKILL.md`, run `node scripts/build-catalog.mjs`, commit, push.

**When the user wants this machine to match the repo** ("make this machine match skillsbase", "reconcile this PC", "I have a different setup here, fix it"):
1. Clone/pull `skillsbase` if not already local.
2. Run `bash sync.sh` (dry run) — it prints exactly what would be uninstalled/installed/updated.
3. Show the user the diff. On their confirmation, run `bash sync.sh --apply`.
4. `sync.sh` backs up `~/.claude/` first and only touches the global layer — never per-project skills.
5. Tell the user to restart Claude Code.

## Per-project skills on demand (skillsbase)
There is a central catalog of project-specific skills at https://github.com/itsjustiago/skillsbase. The global skill `skill-matchmaker` consults that catalog and installs project-relevant skills into `<project>/.claude/skills/`. Trigger it in these cases:

1. **First time entering plan mode in a project** where `<project>/.claude/skills/` doesn't exist or is empty — propose to the user that you run `skill-matchmaker` before diving into Phase 1 exploration.
2. **User runs `/skills-suggest`** — invoke immediately.
3. **Reactive:** during normal work, if you realize the user wants something where a catalog skill could help (e.g. a framework you don't have patterns for, or an unfamiliar output format), propose `skill-matchmaker`. Don't invoke without confirmation. Don't loop — once per session is plenty.

The skill installs locally to `<project>/.claude/skills/`, then the user must restart Claude once for the skills to load. After that the project has those skills permanently.

## Design work — autonomous pipeline (mandatory)

Whenever the user asks you to **build / design / make / create / refine / improve / redesign** any UI surface (component, page, layout, dashboard, landing, modal, form, styling), invoke the `design-auto-pipeline` skill **immediately**, without waiting for a separate user prompt. It orchestrates `taste-skill`, `frontend-design`, `redesign-skill`, `output-skill`, and the 17 `impeccable` commands in the correct sequence.

Hard rules:
- Run the pipeline's closeout (`/critique` → fix → `/polish` → `/audit`) **before** declaring any UI work "done".
- Do not ask the user to confirm each gate individually — run them and report once at the end.
- One pipeline run per coherent task. Don't loop.
- For pure non-UI tasks (server actions, types, DB schema, scripts), the pipeline does not apply — skip it.

## Task approach
Before non-trivial coding tasks, briefly check installed skills for one that applies — invoke it via the `Skill` tool if there's a clear match. Skip the check for one-liners and trivial edits.

For grunt work (file searches, reading large outputs, simple lookups, parallel checks), dispatch to subagents via the `Agent` tool with a smaller model: `model: "haiku"` for searches/reads, `model: "sonnet"` for mid-complexity work. Stay in Opus for orchestration, planning, and complex reasoning. Don't analyze every task to pick a model — just default to Opus and override only when grunt work is well-bounded.

<!--
  Two more sections get appended to ~/.claude/CLAUDE.md automatically by their installers
  (not part of this template — they're machine-specific paths):

  # graphify         — added by `graphify install` (see setup/install-extras.md)
  # browser-harness  — added when you install browser-harness (see setup/install-extras.md)
-->
