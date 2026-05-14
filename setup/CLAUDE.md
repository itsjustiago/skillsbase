# Global Claude Code Instructions

## Skill Installation
Whenever the user says "install a skill", "add a skill", or similar — always install it **globally** to `~/.claude/settings.json` (not project-level, not session-only), unless the user explicitly says "install this just for this project" or "install just for this session."

After installing globally, confirm to the user that the skill is now available across all their projects.

## Skill Organization
When a single skill installation brings in multiple sub-skills (e.g. a bundle or package), document them grouped under the parent skill name — not as a flat list. Use this format in any skill inventory or documentation:

```
## <parent-skill-name>
- sub-skill-1
- sub-skill-2
- sub-skill-3
...
```

This way it's always clear which skills came from which parent, and the user can remove or reference a whole group by its parent name.

## GitHub Skills Repository
After every skill installation, update the GitHub repo at https://github.com/itsjustiago/claude-skills by cloning/pulling it to a temp directory, making changes, and pushing:

1. **README.md** — add the skill to the relevant section in the Installed Skills table.
2. **skills/<parent-skill-name>.md** — create or update with: source repo, install command, what it does, sub-skills list, and how to use it.
3. **guides/** — if the skill has a non-obvious workflow (e.g. a design pipeline, security audit steps, multi-step commands), create or update the relevant guide in `guides/`. Simple utility skills don't need a guide entry.
4. **setup/install-plugins.sh** — add the new plugin install command to the script so new machines get it automatically.
5. **setup/settings.json** — add the new plugin and its marketplace source.
6. Commit and push with message: `Add skill: <parent-skill-name>`.

### What counts as "needs a usage guide"
Write or update a guide in `guides/` when the skill:
- Has specific commands the user needs to know (e.g. `/audit`, `/polish`)
- Works as part of a multi-step workflow
- Has multiple modes or variants
- Requires the user to trigger it manually at the right moment

Simple auto-activating skills (background enhancers) don't need a guide entry.

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
