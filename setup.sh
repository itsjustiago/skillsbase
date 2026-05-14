#!/usr/bin/env bash
# skillsbase — one-shot bootstrap for a fresh Claude Code machine.
#
# Usage:
#   git clone https://github.com/itsjustiago/skillsbase.git
#   cd skillsbase
#   bash setup.sh
#
# Idempotent: safe to re-run. Skips what's already in place.

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "╔══════════════════════════════════════════════╗"
echo "║   skillsbase bootstrap                       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── Preflight ────────────────────────────────────────────────
echo "==> Preflight checks..."
MISSING=""
command -v claude >/dev/null 2>&1 || MISSING="$MISSING claude"
command -v git    >/dev/null 2>&1 || MISSING="$MISSING git"
command -v curl   >/dev/null 2>&1 || MISSING="$MISSING curl"
command -v node   >/dev/null 2>&1 || MISSING="$MISSING node"
command -v npx    >/dev/null 2>&1 || MISSING="$MISSING npx"
if [ -n "$MISSING" ]; then
  echo "  ✗ Missing required tools:$MISSING"
  echo "    claude/git/curl are required; node+npx are needed for plugin + MCP installs."
  echo "    Install them first, then re-run."
  exit 1
fi
echo "  v claude, git, curl, node, npx present"
mkdir -p "$CLAUDE_DIR"

# ── Step 1: core plugins + global skills + commands ──────────
echo ""
echo "==> Step 1/3 — core plugins, global skills, slash commands"
bash "$REPO_ROOT/setup/install-plugins.sh"

# ── Step 2: global configs ───────────────────────────────────
echo ""
echo "==> Step 2/3 — global configs"

# CLAUDE.md — never clobber blindly; back up if it exists and differs
if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && ! cmp -s "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; then
  cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.pre-skillsbase.bak"
  echo "  ! existing CLAUDE.md backed up to CLAUDE.md.pre-skillsbase.bak"
fi
cp "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  v CLAUDE.md"

# settings.json — back up if exists; the user may have local-only keys to merge
if [ -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.pre-skillsbase.bak"
  echo "  ! existing settings.json backed up to settings.json.pre-skillsbase.bak"
  echo "    → review setup/settings.json and merge enabledPlugins + extraKnownMarketplaces by hand"
  echo "      (local keys like voice/theme/env are preserved in the .bak)"
else
  cp "$REPO_ROOT/setup/settings.json" "$CLAUDE_DIR/settings.json"
  echo "  v settings.json"
fi

cp "$REPO_ROOT/setup/statusline.sh" "$CLAUDE_DIR/statusline.sh"
echo "  v statusline.sh"

# ── Step 3: done — point at the rest ─────────────────────────
echo ""
echo "==> Step 3/3 — done. Remaining steps need you:"
echo ""
echo "  1. RESTART Claude Code so plugins + CLAUDE.md load."
echo ""
echo "  2. MCP servers (9 total — magic, shadcn-ui, designlang, github, firebase,"
echo "     supabase, vercel, n8n, playwright):  see setup/mcps.md"
echo ""
echo "  3. (Optional) Extra CLIs — graphify, browser-harness:  see setup/install-extras.md"
echo ""
echo "  4. In any project, run  /skills-suggest  — the matchmaker proposes"
echo "     project-relevant skills from the catalog and installs them locally."
echo ""
echo "Bootstrap complete."
