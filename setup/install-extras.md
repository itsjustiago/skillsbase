# Extras — MCPs & advanced tools

Beyond the core 5-plugin install, these are extra MCPs and CLIs that significantly improve Claude's capabilities. Each is opt-in.

Run these **after** `bash setup/install-plugins.sh` finishes.

---

## 1. Design MCPs (visual loop + extraction)

These plug into the `design-auto-pipeline` skill automatically — once installed, the skill will use them. No code changes needed on your end.

### shadcn/ui MCP — real component source code

Use real shadcn/ui Button/Form/Combobox source instead of letting Claude invent the API.

```bash
claude mcp add --scope user --transport stdio shadcn-ui npx -y @heilgar/shadcn-ui-mcp-server
```

### design-extract (designlang) MCP — extract design system from any URL

Point at vercel.com → get Tailwind config + shadcn tokens + WCAG audit.

```bash
claude mcp add --scope user --transport stdio designlang -- npx -y designlang mcp
```

> Note: it's `designlang mcp` (subcommand), not `designlang --mcp` (flag). The flag form is rejected by the CLI.

---

## 2. n8n MCP — workflow automation reference

Documentation for all 1,650 n8n nodes. Useful if you build/use n8n workflows. Doc-only mode needs no n8n instance.

```bash
claude mcp add --scope user --transport stdio n8n-mcp \
  -e MCP_MODE=stdio \
  -e LOG_LEVEL=error \
  -e DISABLE_CONSOLE_OUTPUT=true \
  -- npx n8n-mcp
```

To add live n8n CRUD later, append `-e N8N_API_URL=... -e N8N_API_KEY=...` after editing.

---

## 3. graphify — local knowledge graph for any codebase

Maps an entire project (code + SQL + PDFs + images + videos) into a queryable graph. Self-installs as a Claude Code skill, then invoke with `/graphify .` in any project.

```bash
# Install uv if you don't have it (Windows)
winget install astral-sh.uv

# Install graphify (the PyPI package is "graphifyy" with double-y)
uv tool install graphifyy

# Self-install the Claude Code skill
graphify install --platform windows
```

After this, `/graphify .` works in any project. Optional dependencies for full feature set:

- **ffmpeg** — already installed (you use it for `/watch`)
- **Poppler** — for PDF parsing: `winget install poppler` (optional)

---

## 4. browser-harness — self-improving browser agent

Browser agent that connects to Chrome via CDP, executes coordinate-based tasks, and rewrites its own helpers between runs. Useful for scraping, automation, and e2e testing.

```bash
# Clone and install
git clone https://github.com/browser-use/browser-harness ~/Developer/browser-harness
cd ~/Developer/browser-harness
uv tool install -e .

# Register the skill globally — add this line to ~/.claude/CLAUDE.md:
#   @~/Developer/browser-harness/SKILL.md
```

After install, you need Chrome with remote debugging enabled the first time it runs (it'll prompt you).

---

## Verification

After running everything, restart Claude Code. Then:

```bash
claude mcp list           # should show: shadcn-ui, designlang, n8n-mcp
claude plugin list         # should show impeccable@impeccable @ 3.1.0+
```

In Claude Code:
```
/graphify --help           # confirms graphify skill registered
```

---

## What each gives you

| Tool | Daily use case |
|---|---|
| **shadcn-ui MCP** | Whenever Claude builds UI with shadcn — uses real component code, not invented |
| **designlang MCP** | "Make my landing page look like vercel.com" — extracts tokens automatically |
| **n8n-mcp** | Building or debugging n8n workflows |
| **graphify** | Onboarding to a large codebase — get a map in one command |
| **browser-harness** | Anything that needs the agent to drive a real browser session |
| **impeccable v3** | Live browser-side editing of generated UI — click a component, swap variants |
