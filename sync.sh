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
# Source-of-truth order for installed-plugin detection:
#   1. PRIMARY: parse ~/.claude/settings.json with a real JSON parser (jq or python3).
#      This is authoritative — the file is written by the Claude CLI itself, its schema
#      is stable (enabledPlugins keys are "name@marketplace"), and it works offline.
#   2. FALLBACK: `claude plugin list` output, tried only when the JSON parse fails.
#      We check for multiple possible list-marker characters (❯ ✓ * and a leading
#      two-space indent) so the check survives minor CLI output format changes.
#   Rationale for reversing the old order: grep'ing for ❯ silently returns nothing
#   if the CLI ever changes its decoration, making sync think zero plugins are
#   installed. The old settings.json fallback was also broken — grep -oE '"x@y":'
#   matched any key whose value contained @, producing false positives on env vars
#   with emails or user@host URLs.
_plugins_from_json() {
  local f="$CLAUDE_DIR/settings.json"
  [ -f "$f" ] || return 1
  # NOTE: pipe through `tr -d '\r'` because jq on Git Bash for Windows emits
  # CRLF line endings, which leaves a trailing \r on every key except the last.
  # That \r breaks exact-string matches against CORE_PLUGINS later — all but
  # the alphabetically-last core plugin would be misclassified as "extras"
  # and queued for removal. Normalize line endings here, once, at the source.
  if command -v jq >/dev/null 2>&1; then
    jq -r '.enabledPlugins // {} | keys[]' "$f" 2>/dev/null | tr -d '\r'
  elif command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json, sys
with open(sys.argv[1]) as fh:
    d = json.load(fh)
for k in d.get('enabledPlugins', {}).keys():
    print(k)
" "$f" 2>/dev/null | tr -d '\r'
  else
    return 1
  fi
}
INSTALLED_PLUGINS=$(_plugins_from_json)
if [ -z "$INSTALLED_PLUGINS" ]; then
  if ! [ -f "$CLAUDE_DIR/settings.json" ] || { ! command -v jq >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; }; then
    echo "  (note: no JSON parser available — falling back to 'claude plugin list')"
  else
    echo "  (note: settings.json parse returned nothing — falling back to 'claude plugin list')"
  fi
  # Fallback: accept any of the common list-marker characters the CLI uses.
  # `tr -d '\r'` at the end normalizes CRLF (Git Bash on Windows emits CRLF) —
  # without it, trailing \r breaks exact-string matches against CORE_PLUGINS.
  INSTALLED_PLUGINS=$(claude plugin list 2>/dev/null \
    | grep -E '(❯|✓|\*|^  [a-zA-Z])' \
    | sed -E 's/^[[:space:]]*(❯|✓|\*)[[:space:]]*//' \
    | awk '{print $1}' \
    | grep '@' \
    | tr -d '\r')
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
