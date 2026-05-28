#!/usr/bin/env bash
# Core plugin installer for the skillsbase lean Claude Code setup.
#
# Philosophy: keep the global layer tiny (8 plugins + a handful of skills).
# Each project pulls its own skills from the skillsbase catalog via /skills-suggest.
#
# Run from the repo root: bash setup/install-plugins.sh
# Or via the orchestrator: bash setup.sh

set -e
set -o pipefail

# Resolve repo root regardless of where this is called from
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Preflight — claude plugin install shells out to npm/npx under the hood
for tool in claude node npx; do
  command -v "$tool" >/dev/null 2>&1 || { echo "✗ Missing required tool: $tool — install it and re-run."; exit 1; }
done

echo "==> Adding marketplaces..."
claude plugin marketplace add obra/superpowers
claude plugin marketplace add pbakaus/impeccable
claude plugin marketplace add athola/claude-night-market
claude plugin marketplace add bradautomates/claude-video
claude plugin marketplace add anthropics/claude-code

echo ""
echo "==> Installing core plugins (8)..."
core_plugins=(
  "superpowers@superpowers-dev"          # brainstorming, TDD, debug, plans, git worktrees
  "sanctum@claude-night-market"          # ship-merge PR workflow
  "leyline@claude-night-market"          # required dependency of sanctum
  "abstract@claude-night-market"         # required dependency of sanctum
  "conserve@claude-night-market"         # context-optimization, clear-context
  "impeccable@impeccable"                # design polish (critique/polish/audit) — v3+ live browser editing
  "frontend-design@claude-code-plugins"  # Anthropic anti-AI-slop floor
  "watch@claude-video"                   # video clips (yt-dlp + ffmpeg + Whisper)
)

FAILED=()
for plugin in "${core_plugins[@]}"; do
  # Capture stdout+stderr into a variable so we can inspect both the exit code of
  # the install command itself *and* the output text — piping directly would mask
  # the install's exit code behind grep's (and set -e / pipefail wouldn't help).
  install_out=$(claude plugin install "$plugin" --scope user 2>&1)
  install_exit=$?
  if [ $install_exit -eq 0 ] && echo "$install_out" | grep -qiE "Successfully|already installed"; then
    echo "  v $plugin"
  else
    echo "  x $plugin (install failed)"
    FAILED+=("$plugin")
  fi
done
if [ ${#FAILED[@]} -gt 0 ]; then
  echo ""
  echo "╔══════════════════════════════════════════════╗"
  echo "║           PLUGIN INSTALL FAILURES            ║"
  echo "╚══════════════════════════════════════════════╝"
  echo ""
  echo "  ${#FAILED[@]} plugin(s) did NOT install successfully:"
  for f in "${FAILED[@]}"; do
    echo "    • $f"
  done
  echo ""
  echo "  Fix the errors above, then re-run (the script is idempotent)."
  echo "  Usually a transient network error or a missing marketplace."
  exit 1
fi

echo ""
echo "==> Installing global skills into ~/.claude/skills/ ..."
mkdir -p ~/.claude/skills
for skill_dir in "$REPO_ROOT"/global-skills/*/; do
  name="$(basename "$skill_dir")"
  mkdir -p ~/.claude/skills/"$name"
  cp "$skill_dir/SKILL.md" ~/.claude/skills/"$name"/SKILL.md
  echo "  v $name"
done

echo ""
echo "==> Installing slash commands into ~/.claude/commands/ ..."
mkdir -p ~/.claude/commands
for cmd in "$REPO_ROOT"/commands/*.md; do
  name="$(basename "$cmd")"
  cp "$cmd" ~/.claude/commands/"$name"
  echo "  v /$(basename "$name" .md)"
done

echo ""
echo "Core plugins + global skills installed."
echo "Next: copy configs (settings.json, CLAUDE.md, statusline.sh) — see setup.sh or README."
