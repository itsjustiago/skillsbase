# DECISIONS

Why this build looks the way it does. Read before re-adding anything that was removed.

## Still valid

- **Files, not plugins.** Skills, agents, and the hook are plain files in `~/.claude`. It works in the desktop app without the `claude` CLI on PATH, and updating means re-running a script.
- **Third-party skills are never vendored.** `setup/install-externals.sh` clones each upstream at install time (licenses stay with their authors; updates = re-run). The 16 externals and their sources are in the README.
- **Patches reapplied on install** by `install-externals.sh`:
  - `ui-ux-pro-max`: `disable-model-invocation: true` plus a kickoff prefix in the description. Upstream auto-triggers on any UI work (~12k tokens per invocation); now it only runs on `/ui-ux-pro-max`.
  - `systematic-debugging`: upstream test files (`test-*.md`, `CREATION-LOG.md`) removed.
  - `web-accessibility`: upstream calls it `accessibility`; folder and `name:` are renamed.
- **No impeccable PostToolUse hook, no `impeccable-manual-edit-applier` agent.** They add latency to every UI edit. Per project: `npx impeccable install`.
- **Rejected:** `superpowers` as a whole (ceremony; two skills are cherry-picked), `brand-guidelines` (applies Anthropic's own brand), and the old MCP set (magic, shadcn-ui, designlang, n8n, playwright, github, firebase, Vercel, Drive). Every MCP server fattens the startup context of every session.
- **Additive setup, careful sync.** `setup.sh` never removes anything. `sync.sh` is dry-run by default, removes only with `--apply` (with backup), never removes plugins and never edits `settings.json`. `settings.json` is create-only; an existing one gets a printed hook excerpt to merge by hand, with the user's OK.
- **Orchestrator model.** One main session briefs and reviews; the `engenheiro` agent writes code; read-only agents audit. See `setup/CLAUDE.md`.

## Changed in this rebuild

- **Removed:** the 62-skill per-project catalog, `catalog.json` and its build/validate scripts, the install profiles, the guides, the memory templates, the MCP folder, the catalog CI workflow, and the manual install doc.
- **Removed (later):** the `skill-matchmaker` skill, the `/skills-suggest` command and the "add to catalog" step of `skill-scout`. They depended on the catalog above, which no longer exists. The build has no slash commands and no `commands/` folder.
- **Added:** 7 more external skills (browser testing, security, web quality, static analysis), the own skill `watch-youtube`, 8 agents, the process-kill hook, and the owner's `CLAUDE.md` and `settings.json`.
