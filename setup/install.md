# New Computer Setup Guide

Full Claude Code setup from scratch.

## 1. Install Claude Code
```bash
npm install -g @anthropic-ai/claude-code
```

## 2. Copy Config Files
```bash
# Global instructions — loaded in every conversation
cp CLAUDE.md ~/.claude/CLAUDE.md

# Statusline with progress bars
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

To activate the statusline, add this to your Claude Code settings or run:
```bash
claude config set statusCommand ~/.claude/statusline.sh
```

## 3. Install All Plugins

Run this script to add all marketplaces and install all plugins at once:
```bash
bash install-plugins.sh
```

Or manually — add marketplaces first:
```bash
claude plugin marketplace add obra/superpowers
claude plugin marketplace add muratcankoylan/Agent-Skills-for-Context-Engineering
claude plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill
claude plugin marketplace add pbakaus/impeccable
claude plugin marketplace add anthropics/claude-code
claude plugin marketplace add wshobson/agents
claude plugin marketplace add athola/claude-night-market
claude plugin marketplace add alirezarezvani/claude-skills
claude plugin marketplace add trailofbits/skills
claude plugin marketplace add affaan-m/everything-claude-code
```

Then install plugins:
```bash
# Design
claude plugin install frontend-design@claude-code-plugins --scope user
claude plugin install ui-ux-pro-max@ui-ux-pro-max-skill --scope user
claude plugin install impeccable@impeccable --scope user
claude plugin install superpowers@superpowers-dev --scope user

# Dev workflow (wshobson)
claude plugin install backend-development@claude-code-workflows --scope user
claude plugin install full-stack-orchestration@claude-code-workflows --scope user
claude plugin install database-design@claude-code-workflows --scope user
claude plugin install database-migrations@claude-code-workflows --scope user
claude plugin install api-scaffolding@claude-code-workflows --scope user
claude plugin install git-pr-workflows@claude-code-workflows --scope user
claude plugin install agent-orchestration@claude-code-workflows --scope user
claude plugin install debugging-toolkit@claude-code-workflows --scope user
claude plugin install unit-testing@claude-code-workflows --scope user
claude plugin install tdd-workflows@claude-code-workflows --scope user
claude plugin install deployment-strategies@claude-code-workflows --scope user
claude plugin install documentation-generation@claude-code-workflows --scope user
claude plugin install security-scanning@claude-code-workflows --scope user
claude plugin install agent-teams@claude-code-workflows --scope user
claude plugin install frontend-mobile-development@claude-code-workflows --scope user

# Night market
claude plugin install attune@claude-night-market --scope user
claude plugin install sanctum@claude-night-market --scope user
claude plugin install minister@claude-night-market --scope user
claude plugin install scribe@claude-night-market --scope user
claude plugin install memory-palace@claude-night-market --scope user
claude plugin install conjure@claude-night-market --scope user
claude plugin install conserve@claude-night-market --scope user
claude plugin install hookify@claude-night-market --scope user

# Engineering (alirezarezvani)
claude plugin install engineering-skills@claude-code-skills --scope user
claude plugin install engineering-advanced-skills@claude-code-skills --scope user
claude plugin install fullstack-engineer@claude-code-skills --scope user
claude plugin install skill-security-auditor@claude-code-skills --scope user
claude plugin install docker-development@claude-code-skills --scope user
claude plugin install aws-architect@claude-code-skills --scope user
claude plugin install product-manager@claude-code-skills --scope user

# Security (Trail of Bits)
claude plugin install supply-chain-risk-auditor@trailofbits --scope user
claude plugin install static-analysis@trailofbits --scope user
claude plugin install variant-analysis@trailofbits --scope user
claude plugin install semgrep-rule-creator@trailofbits --scope user
claude plugin install second-opinion@trailofbits --scope user
claude plugin install insecure-defaults@trailofbits --scope user
claude plugin install mutation-testing@trailofbits --scope user
claude plugin install property-based-testing@trailofbits --scope user
claude plugin install audit-context-building@trailofbits --scope user

# AI / Agents
claude plugin install context-engineering@context-engineering-marketplace --scope user
claude plugin install ecc@ecc --scope user
```

## 4. Install Taste-Skill (manual — not a plugin)
```bash
# These are standalone SKILL.md files, not plugins
# Fetch from GitHub and copy to ~/.claude/skills/

for skill in taste-skill soft-skill minimalist-skill brutalist-skill redesign-skill output-skill stitch-skill; do
  mkdir -p ~/.claude/skills/$skill
  curl -sL "https://raw.githubusercontent.com/Leonxlnx/taste-skill/main/skills/$skill/SKILL.md" \
    -o ~/.claude/skills/$skill/SKILL.md
done
```

## 5. Auth MCP Servers
See [../mcp/README.md](../mcp/README.md) for MCP server setup.

Each one requires browser-based OAuth — you do it once and the token is saved.

## 6. Copy settings.json (optional shortcut)
If you want to skip the marketplace + install commands above, you can copy the settings file directly — Claude Code will sync the plugins automatically on next launch:
```bash
cp settings.json ~/.claude/settings.json
```
> Note: this copies the plugin list and marketplace sources but NOT any tokens. You'll still need to auth MCP servers manually.
