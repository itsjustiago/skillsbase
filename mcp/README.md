# MCP Servers — concepts & auth

What MCP servers are, which ones this setup uses, and how auth works.

> **For exact install commands → [`setup/mcps.md`](../setup/mcps.md)** — that's the canonical reference.
> This page is the conceptual overview.

---

## What MCPs are

MCP (Model Context Protocol) servers give Claude direct access to external services —
databases, browsers, design tools, APIs. Unlike skills (which are instructions),
MCPs are running processes Claude can call as tools.

In this setup MCPs are **not installed by `setup.sh`** — they need per-user API keys
or OAuth, so you install the ones you want from `setup/mcps.md` after the core bootstrap.

---

## Built-in Claude Code tools (no install)

Always available, nothing to configure: `WebSearch`, `WebFetch`, `Bash`, `Read/Write/Edit`.

---

## The 9 MCP servers

| MCP | What it does | Auth |
|---|---|---|
| **magic** (21st.dev) | Visual UI component gallery + generation | API key on first use |
| **shadcn-ui** | Real shadcn/ui component source code | None |
| **designlang** | Extract design tokens (Tailwind/shadcn config) from any URL | None |
| **playwright-chrome** | Browser automation, e2e, screenshots | None |
| **n8n-mcp** | Docs for all 1650 n8n workflow nodes | None |
| **github** | Issues, PRs, repos, code search | `GITHUB_TOKEN` env var |
| **firebase** | Firebase project tooling | `firebase login` flow |
| **supabase** | DB, auth, RLS, edge functions, migrations | Browser OAuth |
| **vercel** | Deployments, env vars, project management | Browser OAuth |

Install commands, tiered by auth needs: **[`setup/mcps.md`](../setup/mcps.md)**.

---

## Auth — how each kind works

**API key (env var)** — `github` needs `GITHUB_TOKEN`. Generate at
[github.com/settings/tokens](https://github.com/settings/tokens), add to
`~/.claude/settings.json` under an `"env"` block:
```json
"env": { "GITHUB_TOKEN": "ghp_yourtoken" }
```

**API key (prompted)** — `magic` prompts for a 21st.dev key on first run.

**CLI login flow** — `firebase` runs `firebase login` the first time Claude calls it.

**Browser OAuth** — `supabase` and `vercel` open a browser login the first time
they're used (or trigger manually with `/mcp`). Tokens land in
`~/.claude/.credentials.json` — **never commit that file.**

---

## Which MCPs the design pipeline uses

`design-auto-pipeline` auto-uses **magic** (component inspiration), **shadcn-ui**
(real component source), and **designlang** (extract tokens from a reference URL).
You don't invoke them by name — install them and the pipeline picks them up.

---

## Notes

- MCPs persist in `~/.claude.json` (`mcpServers` block) across all projects.
- `claude mcp list` shows status; `claude mcp get <name>` shows the config.
- A disconnected MCP doesn't break Claude — its tools just become unavailable.
