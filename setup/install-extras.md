# Extras — CLIs beyond the core

Opt-in command-line tools that significantly improve Claude's capabilities but aren't
part of the core bootstrap (they need `uv` / system installs).

> **MCP servers** moved to their own doc — see [`setup/mcps.md`](mcps.md) for all 9.

Run these **after** `bash setup.sh` finishes.

---

## graphify — local knowledge graph for any codebase

Maps an entire project (code + SQL + PDFs + images + videos) into a queryable graph.
Self-installs as a Claude Code skill, then invoke with `/graphify .` in any project.

```bash
# Install uv if you don't have it (Windows)
winget install astral-sh.uv          # macOS/Linux: curl -LsSf https://astral.sh/uv/install.sh | sh

# Install graphify (the PyPI package is "graphifyy" with double-y)
uv tool install graphifyy

# Self-install the Claude Code skill (appends a section to ~/.claude/CLAUDE.md)
graphify install --platform windows  # or --platform macos / linux
```

Optional deps for full feature set:
- **ffmpeg** — already installed if you use `/watch`
- **Poppler** — for PDF parsing: `winget install poppler` (optional)

---

## browser-harness — self-improving browser agent

Browser agent that connects to Chrome via CDP, executes coordinate-based tasks, and
rewrites its own helpers between runs. Useful for scraping, automation, e2e testing.

```bash
git clone https://github.com/browser-use/browser-harness ~/Developer/browser-harness
cd ~/Developer/browser-harness
uv tool install -e .
```

Then register the skill globally — add this line to `~/.claude/CLAUDE.md`:
```
@~/Developer/browser-harness/SKILL.md
```

First run needs Chrome with remote debugging enabled (it'll prompt you).

---

## Verification

Restart Claude Code, then:

```bash
claude plugin list          # impeccable@impeccable should be 3.1.0+
```

In Claude Code:
```
/graphify --help            # confirms graphify skill registered
```

browser-harness shows up in the skill index after restart (loaded via the `@import` in CLAUDE.md).

---

## What each gives you

| Tool | Daily use case |
|---|---|
| **graphify** | Onboarding to a large codebase — get a queryable map in one command |
| **browser-harness** | Anything that needs the agent to drive a real browser session |
| **impeccable v3** | Live browser-side editing of generated UI — click a component, swap variants |

For MCP servers (magic, shadcn-ui, designlang, github, firebase, supabase, vercel, n8n, playwright) → [`setup/mcps.md`](mcps.md).
