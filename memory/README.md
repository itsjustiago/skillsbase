# Memory System

Claude Code has a persistent, file-based memory system at `~/.claude/projects/<project>/memory/`. Memory from previous conversations gets loaded automatically at the start of each new session.

---

## Memory Types

| Type | What it stores |
|---|---|
| **user** | Who you are — role, expertise, preferences |
| **feedback** | How you like to work — corrections and confirmed approaches |
| **project** | Active work — goals, decisions, deadlines |
| **reference** | Where to find things — Linear, Grafana, Slack channels, etc. |

---

## How it works

Each memory is a `.md` file with frontmatter:
```markdown
---
name: memory name
description: one-line description used to decide relevance
type: user | feedback | project | reference
---

Memory content here.
```

An index file `MEMORY.md` lists all memories as one-liners:
```markdown
- [Title](file.md) — one-line hook
```

---

## Where memories live

- **Global memories** (apply everywhere): `~/.claude/projects/<project>/memory/`
- **Project-scoped**: same location, but scoped by project path

---

## What NOT to save in memory

- Code patterns or file paths — read the code instead
- Git history — use `git log`
- Temporary/in-progress work — use tasks instead
- Anything already in CLAUDE.md
