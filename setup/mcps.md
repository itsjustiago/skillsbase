# MCP servers — full install reference

The 9 MCP servers in this setup. `setup.sh` does **not** install these (they need
per-user auth / API keys) — run the ones you want from here after the core bootstrap.

Commands are written without the `cmd /c` prefix — Claude Code adds it automatically
on Windows. They work as-is on macOS/Linux too.

---

## Tier 1 — install these (no auth, work immediately)

```bash
# Magic (21st.dev) — visual UI component gallery + generation
claude mcp add --scope user magic -- npx -y @21st-dev/magic@latest

# Playwright (Chrome/Firefox) — browser automation, e2e, screenshots
claude mcp add --scope user playwright-chrome -- npx @playwright/mcp@latest --browser firefox

# shadcn/ui — real component source code (never invent the API)
claude mcp add --scope user shadcn-ui -- npx -y @heilgar/shadcn-ui-mcp-server

# designlang — extract design tokens (Tailwind/shadcn config) from any URL
claude mcp add --scope user designlang -- npx -y designlang mcp

# n8n-mcp — documentation for all 1650 n8n workflow nodes (doc-only mode)
claude mcp add --scope user n8n-mcp \
  -e MCP_MODE=stdio -e LOG_LEVEL=error -e DISABLE_CONSOLE_OUTPUT=true \
  -- npx n8n-mcp
```

## Tier 2 — install + auth required

```bash
# GitHub — issues, PRs, repos, code search
claude mcp add --scope user github -- npx -y @modelcontextprotocol/server-github
```
**Auth:** generate a PAT at https://github.com/settings/tokens, then add to `~/.claude/settings.json`:
```json
"env": { "GITHUB_TOKEN": "ghp_yourtoken" }
```

```bash
# Firebase — Firebase project tooling (Firestore, Auth, Hosting, etc.)
claude mcp add --scope user firebase -- npx -y firebase-tools@latest experimental:mcp
```
**Auth:** runs `firebase login` flow on first use. Install firebase-tools globally first if prompted: `npm i -g firebase-tools`.

## Tier 3 — install + browser OAuth (do when you first need them)

```bash
# Supabase — DB, auth, RLS, edge functions, migrations
claude mcp add --scope user --transport http supabase https://mcp.supabase.com/mcp

# Vercel — deployments, env vars, project management
claude mcp add --scope user --transport http vercel https://mcp.vercel.com
```
**Auth:** both prompt a browser OAuth flow the first time Claude calls them. Just approve in the browser. Or trigger manually with `/mcp` inside Claude Code.

---

## Verify

```bash
claude mcp list
```

Expected after installing all 9:
```
magic              ✓ Connected
github             ✓ Connected
playwright-chrome  ✓ Connected
firebase           ✓ Connected
shadcn-ui          ✓ Connected
n8n-mcp            ✓ Connected
designlang         ✓ Connected
supabase           ! Needs authentication   (until first OAuth)
vercel             ! Needs authentication   (until first OAuth)
```

---

## What each one is for

| MCP | Used by / when |
|---|---|
| `magic` | `design-auto-pipeline` — visual component inspiration during UI builds |
| `shadcn-ui` | `design-auto-pipeline` — real shadcn component source during builds |
| `designlang` | `design-auto-pipeline` path D — "make it like vercel.com" extracts tokens |
| `playwright-chrome` | e2e testing, browser QA, screenshot verification |
| `github` | issues, PRs, code search — pairs with `sanctum` ship workflow |
| `firebase` | any project on Firebase |
| `supabase` | any project on Supabase |
| `vercel` | deploy previews, env management |
| `n8n-mcp` | building or debugging n8n automation workflows |

The `design-auto-pipeline` skill auto-uses magic / shadcn-ui / designlang — you don't invoke them by name.
