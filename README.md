# skillsbase

The Claude Code build of itsjustiago, as files: **21 global skills, 8 agents, 1 hook and the global instructions.** Clone it on a new machine and Claude is configured. No plugins to install: the build is plain files.

Why it looks this way (and what was removed): [`DECISIONS.md`](DECISIONS.md).

## Layout

```
README.md  DECISIONS.md  setup.sh  sync.sh
setup/          AGENT-INSTALL.md  CLAUDE.md  settings.json  install-externals.sh  mcps.md
global-skills/  the 5 own skills (vendored)
agents/         8 subagents
hooks/          bloquear_kill_por_nome.py
site/           the showcase site (Next.js, deployed separately)
```

## Skills (21)

**Own (5)**, vendored in `global-skills/`:

| Skill | What it does |
|---|---|
| `ship` | commit, push, PR in one shot |
| `ship-merge` | ship + CI wait, light review, squash-merge, cleanup |
| `session-handoff` | end-of-session summary to continue after `/clear` |
| `skill-scout` | discover skills, plugins and MCP servers in the wider ecosystem |
| `watch-youtube` | transcript + key frames from YouTube videos |

**External (16)**, never vendored: `setup/install-externals.sh` clones each upstream at install time and applies the patches in `DECISIONS.md`. They keep their authors and licenses.

| Skill | Source | License |
|---|---|---|
| `frontend-design` | anthropics/skills | Apache-2.0 |
| `impeccable` | pbakaus/impeccable | Apache-2.0 |
| `emil-design-eng`, `review-animations` | emilkowalski/skills | MIT |
| `supabase`, `supabase-postgres-best-practices` | supabase/agent-skills | MIT |
| `systematic-debugging`, `verification-before-completion` | obra/superpowers | MIT |
| `ui-ux-pro-max` | nextlevelbuilder/ui-ux-pro-max-skill | MIT |
| `browser-testing-with-devtools`, `security-and-hardening` | addyosmani/agent-skills | MIT |
| `core-web-vitals`, `web-accessibility` | addyosmani/web-quality-skills | MIT |
| `semgrep`, `differential-review`, `supply-chain-risk-auditor` | trailofbits/skills | CC-BY-SA-4.0 |

## Agents (8)

`engenheiro` (writes code from a brief), `explorador` (locates code), `investigador` (research), `revisor` (code review), `testador` (QA in a running app), `design` (read-only UI critique), `seguranca` (read-only security audit), `financas` (Portuguese tax and investing research).

## Hook, instructions

- **Hook:** `hooks/bloquear_kill_por_nome.py`, a `PreToolUse` hook on `Bash` that blocks killing processes by name. Registered in `setup/settings.json`; needs `python3`.
- **Instructions:** `setup/CLAUDE.md` is the global `~/.claude/CLAUDE.md` (language, git and ship rules, orchestrator mode).
- **MCP:** only Supabase is documented, with placeholders: [`setup/mcps.md`](setup/mcps.md).

`setup/settings.json` includes the owner's own preferences (dark theme, Remote Control off, stop-review off), plus the hook and one plugin (`security-guidance`). It is create-only: an existing `settings.json` is never touched.

## Install

Paste this into Claude Code and answer its one question:

> Set up the itsjustiago Claude Code build: clone https://github.com/itsjustiago/skillsbase and follow setup/AGENT-INSTALL.md — check what I already have in ~/.claude, show me the options, and install the one I pick.

Or by hand (on Windows, run in Git Bash):

```bash
git clone https://github.com/itsjustiago/skillsbase.git
cd skillsbase
bash setup.sh                  # everything
bash setup.sh --skills         # skills, agents, hook files (no config)
bash setup.sh --instructions   # only the global CLAUDE.md (with backup)
bash sync.sh                   # dry-run: what would be removed/updated
bash sync.sh --apply           # reconcile ~/.claude with the build (with backup)
```

**Security note:** `setup/install-externals.sh` clones the HEAD of the upstream repos (no pin, by design: "updates = re-run"), so review it, and what it pulls, before running it. Items you already have with the same name are replaced, with a backup in `~/.claude/backups/`.

`setup.sh` is additive and idempotent; re-running also updates the external skills. `sync.sh` never removes plugins and never touches `settings.json`. Requires git and node; python3 for the hook. Test in a sandbox with `CLAUDE_DIR=/some/dir bash setup.sh`.

## License

External skills are not vendored here and keep their authors' licenses (table above); `semgrep`, `differential-review` and `supply-chain-risk-auditor` are CC-BY-SA-4.0 (share-alike if you redistribute a modified copy).
