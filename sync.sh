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
  "abstract@claude-night-market"
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
# Primary: parse `claude plugin list`. Fallback: read enabledPlugins keys from
# ~/.claude/settings.json (in case the CLI output format changes).
INSTALLED_PLUGINS=$(claude plugin list 2>/dev/null | grep "❯" | sed 's/.*❯ //' | tr -d ' ')
if [ -z "$INSTALLED_PLUGINS" ] && [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo "  (note: 'claude plugin list' returned nothing — falling back to settings.json)"
  INSTALLED_PLUGINS=$(grep -oE '"[^"]+@[^"]+"[[:space:]]*:' "$CLAUDE_DIR/settings.json" | sed 's/[":]//g' | tr -d ' ')
fi
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
  src="$REPO_ROOT/global-skills/$name/SKILL.md"
  dst="$CLAUDE_DIR/skills/$name/SKILL.md"
  if [ ! -f "$dst" ]; then
    echo "  INSTALL $name"
    CHANGES=$((CHANGES+1))
  elif ! cmp -s "$src" "$dst"; then
    echo "  UPDATE  $name (content differs)"
    CHANGES=$((CHANGES+1))
  else
    continue   # identical — nothing to do
  fi
  if $APPLY; then
    mkdir -p "$CLAUDE_DIR/skills/$name"
    cp "$src" "$dst"
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
  src="$REPO_ROOT/commands/$name"
  dst="$CLAUDE_DIR/commands/$name"
  if [ ! -f "$dst" ]; then
    echo "  INSTALL /$(basename "$name" .md)"
    CHANGES=$((CHANGES+1))
  elif ! cmp -s "$src" "$dst"; then
    echo "  UPDATE  /$(basename "$name" .md) (content differs)"
    CHANGES=$((CHANGES+1))
  else
    continue   # identical — nothing to do
  fi
  if $APPLY; then
    mkdir -p "$CLAUDE_DIR/commands"
    cp "$src" "$dst"
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
  echo ""
  echo "  To undo everything:"
  echo "    rm -rf $CLAUDE_DIR/skills $CLAUDE_DIR/commands"
  echo "    cp -r $BAK/skills $BAK/commands $CLAUDE_DIR/  2>/dev/null"
  echo "    cp $BAK/settings.json $BAK/CLAUDE.md $CLAUDE_DIR/  2>/dev/null"
else
  echo "$CHANGES change(s) would be made. Re-run with --apply to execute:"
  echo "    bash sync.sh --apply"
fi
