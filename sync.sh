#!/usr/bin/env bash
# sync.sh — reconcile this machine's GLOBAL Claude Code setup to match this repo exactly.
#
# Unlike setup.sh (purely additive), sync.sh is a full reconcile:
#   - uninstalls plugins NOT in the core set
#   - removes global skills NOT in global-skills/ (except externally-managed ones)
#   - removes slash commands NOT in commands/
#   - installs/copies anything missing
#   - copies global configs
#
# DRY-RUN BY DEFAULT. Shows the diff, changes nothing. Pass --apply to execute.
# On --apply it backs up ~/.claude/{skills,commands,settings.json,CLAUDE.md} first.
#
# Only touches the GLOBAL layer (~/.claude/). Never touches <project>/.claude/skills/.
#
# Usage:
#   bash sync.sh            # dry-run — preview what would change
#   bash sync.sh --apply    # actually reconcile

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
APPLY=false
[ "$1" = "--apply" ] && APPLY=true

# ── Desired state (keep in sync with setup/install-plugins.sh) ──
CORE_PLUGINS=(
  "superpowers@superpowers-dev"
  "sanctum@claude-night-market"
  "leyline@claude-night-market"
  "conserve@claude-night-market"
  "impeccable@impeccable"
  "frontend-design@claude-code-plugins"
  "watch@claude-video"
)
# Skills installed/managed by external tools — sync must NOT remove these
EXTERNAL_SKILLS=("graphify")

in_list() { local needle="$1"; shift; for x in "$@"; do [ "$x" = "$needle" ] && return 0; done; return 1; }

echo "╔══════════════════════════════════════════════╗"
if $APPLY; then
echo "║   sync.sh — APPLY MODE (will make changes)   ║"
else
echo "║   sync.sh — DRY RUN (no changes)             ║"
fi
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── Backup before any destructive change ───────────────────
if $APPLY; then
  TS=$(date +%Y-%m-%d-%H%M%S)
  BAK="$CLAUDE_DIR/backups/sync-$TS"
  mkdir -p "$BAK"
  [ -d "$CLAUDE_DIR/skills" ]   && cp -r "$CLAUDE_DIR/skills"   "$BAK/skills"   2>/dev/null || true
  [ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$BAK/commands" 2>/dev/null || true
  [ -f "$CLAUDE_DIR/settings.json" ] && cp "$CLAUDE_DIR/settings.json" "$BAK/" 2>/dev/null || true
  [ -f "$CLAUDE_DIR/CLAUDE.md" ]     && cp "$CLAUDE_DIR/CLAUDE.md"     "$BAK/" 2>/dev/null || true
  echo "Backup → $BAK"
  echo ""
fi

CHANGES=0

# ── 1. Plugins ──────────────────────────────────────────────
echo "── Plugins ──────────────────────────────────"
INSTALLED_PLUGINS=$(claude plugin list 2>/dev/null | grep "❯" | sed 's/.*❯ //' | tr -d ' ')
for p in $INSTALLED_PLUGINS; do
  if ! in_list "$p" "${CORE_PLUGINS[@]}"; then
    echo "  REMOVE  $p"
    CHANGES=$((CHANGES+1))
    $APPLY && claude plugin uninstall "$p" >/dev/null 2>&1 && echo "          ✓ uninstalled"
  fi
done
for p in "${CORE_PLUGINS[@]}"; do
  if ! echo "$INSTALLED_PLUGINS" | grep -qx "$p"; then
    echo "  INSTALL $p"
    CHANGES=$((CHANGES+1))
    $APPLY && claude plugin install "$p" --scope user >/dev/null 2>&1 && echo "          ✓ installed"
  fi
done

# ── 2. Global skills ────────────────────────────────────────
echo ""
echo "── Global skills (~/.claude/skills/) ────────"
DESIRED_SKILLS=$(ls "$REPO_ROOT/global-skills" 2>/dev/null)
if [ -d "$CLAUDE_DIR/skills" ]; then
  for d in "$CLAUDE_DIR"/skills/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    if ! echo "$DESIRED_SKILLS" | grep -qx "$name" && ! in_list "$name" "${EXTERNAL_SKILLS[@]}"; then
      echo "  REMOVE  $name"
      CHANGES=$((CHANGES+1))
      $APPLY && rm -rf "$d" && echo "          ✓ removed"
    fi
  done
fi
for name in $DESIRED_SKILLS; do
  if [ ! -f "$CLAUDE_DIR/skills/$name/SKILL.md" ]; then
    echo "  INSTALL $name"
    CHANGES=$((CHANGES+1))
  fi
  if $APPLY; then
    mkdir -p "$CLAUDE_DIR/skills/$name"
    cp "$REPO_ROOT/global-skills/$name/SKILL.md" "$CLAUDE_DIR/skills/$name/SKILL.md"
  fi
done

# ── 3. Slash commands ───────────────────────────────────────
echo ""
echo "── Slash commands (~/.claude/commands/) ─────"
DESIRED_CMDS=$(ls "$REPO_ROOT/commands" 2>/dev/null)
if [ -d "$CLAUDE_DIR/commands" ]; then
  for f in "$CLAUDE_DIR"/commands/*.md; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    if ! echo "$DESIRED_CMDS" | grep -qx "$name"; then
      echo "  REMOVE  /$(basename "$name" .md)"
      CHANGES=$((CHANGES+1))
      $APPLY && rm "$f" && echo "          ✓ removed"
    fi
  done
fi
for name in $DESIRED_CMDS; do
  if [ ! -f "$CLAUDE_DIR/commands/$name" ]; then
    echo "  INSTALL /$(basename "$name" .md)"
    CHANGES=$((CHANGES+1))
  fi
  if $APPLY; then
    mkdir -p "$CLAUDE_DIR/commands"
    cp "$REPO_ROOT/commands/$name" "$CLAUDE_DIR/commands/$name"
  fi
done

# ── 4. Configs ──────────────────────────────────────────────
echo ""
echo "── Global configs ───────────────────────────"
# statusline.sh: pure script, repo version is canonical — safe to overwrite
if ! cmp -s "$REPO_ROOT/setup/statusline.sh" "$CLAUDE_DIR/statusline.sh" 2>/dev/null; then
  echo "  UPDATE  statusline.sh"
  CHANGES=$((CHANGES+1))
  $APPLY && cp "$REPO_ROOT/setup/statusline.sh" "$CLAUDE_DIR/statusline.sh" && echo "          ✓ updated"
fi
# CLAUDE.md: never auto-overwrite — installers append machine-local sections
#   (graphify, browser-harness) that aren't in the template.
if ! cmp -s "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
  echo "  REVIEW  CLAUDE.md differs — diff against setup/CLAUDE.md by hand."
  echo "          The template is the BASE; graphify + browser-harness sections are"
  echo "          appended by their installers and should be preserved."
fi
# settings.json: never auto-overwrite — it has machine-local keys (voice, theme, env)
if ! cmp -s "$REPO_ROOT/setup/settings.json" "$CLAUDE_DIR/settings.json" 2>/dev/null; then
  echo "  REVIEW  settings.json differs — merge enabledPlugins + extraKnownMarketplaces by hand"
  echo "          (local keys like voice/theme/env must be preserved)"
fi

# ── Summary ─────────────────────────────────────────────────
echo ""
echo "─────────────────────────────────────────────"
if [ "$CHANGES" -eq 0 ]; then
  echo "✓ Already in sync with the repo. Nothing to do."
elif $APPLY; then
  echo "✓ Applied $CHANGES change(s). Backup: $BAK"
  echo "  RESTART Claude Code so the new state loads."
else
  echo "$CHANGES change(s) would be made. Re-run with --apply to execute:"
  echo "    bash sync.sh --apply"
fi
