# MCP Servers

MCP (Model Context Protocol) servers give Claude direct access to external services. This page documents all MCP servers and built-in tools available in this setup.

---

## Built-in Claude Code Tools (No Install Needed)

These are native Claude Code capabilities — always available, nothing to configure:

| Tool | What it does |
|------|-------------|
| `WebSearch` | Search the web from within a conversation |
| `WebFetch` | Fetch and read any URL |
| `Bash` | Run shell commands |
| `Read / Write / Edit` | Work with files on disk |

---

## Plugin-Installed MCP Servers (Auto via `install-plugins.sh`)

These are installed automatically when you run `install-plugins.sh`. You only need to handle auth where noted.

### GitHub *(ecc plugin)*
**What it does:** Create issues, open PRs, push files, search code, comment on reviews — all from within the conversation.

**Auth required:** Yes — `GITHUB_TOKEN` env variable.
1. Go to [github.com/settings/tokens](https://github.com/settings/tokens) → generate a Personal Access Token
2. Add to `~/.claude/settings.json`:
```json
"env": {
  "GITHUB_TOKEN": "ghp_yourtoken"
}
```

---

### Context7 *(ecc plugin)*
**What it does:** Fetches up-to-date library documentation and code examples — so Claude always has current API references instead of stale training data.

**Auth required:** None.

---

### Exa *(ecc plugin)*
**What it does:** AI-powered semantic web search and URL fetching — better than keyword search for technical research.

**Auth required:** Yes — `EXA_API_KEY`. Get one at [exa.ai](https://exa.ai), then add to `~/.claude/settings.json`:
```json
"env": {
  "EXA_API_KEY": "your_key"
}
```

---

### Memory *(ecc plugin)*
**What it does:** Persistent knowledge graph — Claude can store and recall entities, relationships, and observations across sessions.

**Auth required:** None.

---

### Playwright *(ecc plugin)*
**What it does:** Full browser automation — navigate pages, click, fill forms, take screenshots, run E2E tests.

**Auth required:** None.

---

### Sequential Thinking *(ecc plugin)*
**What it does:** Structured step-by-step reasoning — helps Claude break down complex problems before responding.

**Auth required:** None.

---

### Markitdown *(claude-night-market plugin)*
**What it does:** Converts files (PDF, Word, Excel, PowerPoint, images) to Markdown so Claude can read them.

**Auth required:** None. Requires `uvx` — install with `pip install uv`.

---

## Manually Added MCP Servers

These were added manually via `claude mcp add` and require auth on each machine.

### Supabase
**What it does:** Direct access to Supabase — query databases, manage tables, auth, storage, and edge functions.

**How to auth:** Browser OAuth — just run a Supabase-related prompt and Claude will prompt you to log in.

**URL:** `https://mcp.supabase.com/mcp`

---

### Vercel
**What it does:** Deploy projects, check build status, view logs, manage domains — from within Claude.

**How to auth:** Browser OAuth — just run a Vercel-related prompt and Claude will prompt you to log in.

**URL:** `https://mcp.vercel.com`

---

### Magic (21st.dev)
**What it does:** Generates polished UI components from plain descriptions.

**How to set up:**
```bash
claude mcp add magic -- npx -y @21st-dev/magic@latest
# Enter your API key from 21st.dev when prompted
```

> **Windows note:** Both `magic` and `github` MCP servers require a `cmd /c` wrapper on Windows. In `~/.claude.json`, set `"command": "cmd"` and prepend `"/c"` and `"npx"` to the args array — e.g. `"args": ["/c", "npx", "-y", "@21st-dev/magic@latest"]`.

---

### Higgsfield
**What it does:** AI image and video generation — image-to-video with motion controls, character consistency, marketing studio, virality prediction. 16 tools: `generate_image`, `generate_video`, `balance`, `show_characters`, `show_generations`, `show_marketing_studio`, `virality_predictor`, plus workspace/media management.

**How to set up:**
```bash
claude mcp add --transport http --scope user higgsfield https://mcp.higgsfield.ai/mcp
```
Then trigger OAuth via the `/mcp` slash command (or just ask Claude to do something Higgsfield-related — the browser flow opens automatically).

**URL:** `https://mcp.higgsfield.ai/mcp`

---

## Notes

- `~/.claude/.credentials.json` holds OAuth tokens — **never commit this file**
- Plugin MCPs are defined in the plugin's `.mcp.json` — they activate automatically when the plugin is enabled
- Manually added MCPs persist in your global Claude config across projects
