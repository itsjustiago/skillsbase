#!/usr/bin/env bash
# sync.sh — reconcilia a camada GLOBAL (~/.claude) desta máquina com o repo.
#
# setup.sh é aditivo; sync.sh é o reconcile completo:
#   - remove skills globais que NÃO pertencem à build (nem próprias nem externas)
#   - atualiza as próprias a partir de global-skills/ e os comandos de commands/
#   - re-corre install-externals.sh (traz/atualiza as 9 externas)
#   - copia o CLAUDE.md global se diferir
#   - NUNCA toca em settings.json (chaves locais) nem em <projeto>/.claude/
#
# DRY-RUN por defeito. `bash sync.sh --apply` para executar (faz backup antes).

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
APPLY=false
[ "$1" = "--apply" ] && APPLY=true

# Externas geridas por setup/install-externals.sh — manter em sync com esse script
EXTERNAL_SKILLS=(frontend-design impeccable emil-design-eng review-animations
  supabase supabase-postgres-best-practices systematic-debugging
  verification-before-completion ui-ux-pro-max)

in_list() { local n="$1"; shift; for x in "$@"; do [ "$x" = "$n" ] && return 0; done; return 1; }

echo "╔══════════════════════════════════════════════╗"
if $APPLY; then echo "║   sync.sh — APPLY (vai alterar ~/.claude)    ║"
else            echo "║   sync.sh — DRY RUN (não altera nada)        ║"; fi
echo "╚══════════════════════════════════════════════╝"
echo ""

if $APPLY; then
  TS=$(date +%Y-%m-%d-%H%M%S)
  BAK="$CLAUDE_DIR/backups/sync-$TS"
  mkdir -p "$BAK"
  [ -d "$CLAUDE_DIR/skills" ]   && cp -r "$CLAUDE_DIR/skills"   "$BAK/skills"   2>/dev/null || true
  [ -d "$CLAUDE_DIR/commands" ] && cp -r "$CLAUDE_DIR/commands" "$BAK/commands" 2>/dev/null || true
  [ -f "$CLAUDE_DIR/CLAUDE.md" ] && cp "$CLAUDE_DIR/CLAUDE.md" "$BAK/" 2>/dev/null || true
  echo "Backup → $BAK"
  echo ""
fi

OWN_SKILLS=()
for d in "$REPO_ROOT"/global-skills/*/; do OWN_SKILLS+=("$(basename "$d")"); done

# ── Skills a mais ────────────────────────────────────────────
echo "==> Skills globais"
if [ -d "$CLAUDE_DIR/skills" ]; then
  for d in "$CLAUDE_DIR"/skills/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    if ! in_list "$name" "${OWN_SKILLS[@]}" && ! in_list "$name" "${EXTERNAL_SKILLS[@]}"; then
      echo "  - REMOVER: $name (não pertence à build)"
      $APPLY && rm -rf "$d"
    fi
  done
fi

# ── Próprias: copiar/atualizar ───────────────────────────────
for name in "${OWN_SKILLS[@]}"; do
  if [ ! -d "$CLAUDE_DIR/skills/$name" ]; then
    echo "  + INSTALAR: $name"
  elif ! diff -rq "$REPO_ROOT/global-skills/$name" "$CLAUDE_DIR/skills/$name" >/dev/null 2>&1; then
    echo "  ~ ATUALIZAR: $name"
  else
    echo "  = ok: $name"
    continue
  fi
  if $APPLY; then
    rm -rf "${CLAUDE_DIR:?}/skills/$name"
    cp -r "$REPO_ROOT/global-skills/$name" "$CLAUDE_DIR/skills/$name"
  fi
done

# ── Externas: presença (conteúdo é gerido pelo installer) ────
MISSING_EXT=0
for name in "${EXTERNAL_SKILLS[@]}"; do
  if [ ! -d "$CLAUDE_DIR/skills/$name" ]; then
    echo "  + EXTERNA em falta: $name"
    MISSING_EXT=1
  fi
done
if $APPLY; then
  echo ""
  echo "==> Externas — a correr install-externals.sh (traz/atualiza as 9)"
  CLAUDE_DIR="$CLAUDE_DIR" bash "$REPO_ROOT/setup/install-externals.sh"
elif [ "$MISSING_EXT" = "1" ]; then
  echo "    (--apply corre o install-externals.sh e resolve)"
fi

# ── Comandos ─────────────────────────────────────────────────
echo ""
echo "==> Slash commands"
for f in "$REPO_ROOT"/commands/*.md; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  if [ ! -f "$CLAUDE_DIR/commands/$base" ] || ! cmp -s "$f" "$CLAUDE_DIR/commands/$base"; then
    echo "  ~ $base"
    $APPLY && mkdir -p "$CLAUDE_DIR/commands" && cp "$f" "$CLAUDE_DIR/commands/$base"
  else
    echo "  = ok: $base"
  fi
done

# ── CLAUDE.md ────────────────────────────────────────────────
echo ""
echo "==> CLAUDE.md global"
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ] || ! cmp -s "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; then
  echo "  ~ difere do repo → seria copiado"
  $APPLY && cp "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" && echo "    copiado"
else
  echo "  = ok"
fi

echo ""
echo "settings.json: nunca tocado pelo sync (chaves locais da máquina)."
if $APPLY; then echo "Reconcile completo. REINICIA o Claude Code."; else echo "Dry-run terminado. Corre com --apply para aplicar."; fi
