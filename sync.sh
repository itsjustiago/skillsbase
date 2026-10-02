#!/usr/bin/env bash
# sync.sh — reconcilia a camada GLOBAL (~/.claude) desta máquina com o repo.
#
# setup.sh é aditivo; sync.sh é o reconcile completo:
#   - remove skills globais que NÃO pertencem à build (6 próprias + 16 externas)
#   - atualiza as próprias a partir de global-skills/ e os comandos de commands/
#   - reconcilia agents/ e hooks/ (remove os que não estão no repo — só com --apply)
#   - re-corre install-externals.sh (traz/atualiza as 16 externas)
#   - copia o CLAUDE.md global se diferir
#   - NUNCA remove plugins, nem toca em settings.json (chaves locais) nem em <projeto>/.claude/
#
# DRY-RUN por defeito (não escreve nada). `bash sync.sh --apply` para executar (faz backup antes).
# Com --apply as externas correm PRIMEIRO (rede); se alguma falhar não se remove
# nem se altera mais nada e o script sai != 0 — a reconciliação nunca fica a meio.

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
APPLY=false
[ "$1" = "--apply" ] && APPLY=true

# Externas geridas por setup/install-externals.sh — manter em sync com esse script
EXTERNAL_SKILLS=(frontend-design impeccable emil-design-eng review-animations
  supabase supabase-postgres-best-practices systematic-debugging
  verification-before-completion ui-ux-pro-max
  browser-testing-with-devtools security-and-hardening
  core-web-vitals web-accessibility
  semgrep differential-review supply-chain-risk-auditor)

in_list() { local n="$1"; shift; for x in "$@"; do [ "$x" = "$n" ] && return 0; done; return 1; }

echo "╔══════════════════════════════════════════════╗"
if $APPLY; then echo "║   sync.sh — APPLY (vai alterar ~/.claude)    ║"
else            echo "║   sync.sh — DRY RUN (não altera nada)        ║"; fi
echo "╚══════════════════════════════════════════════╝"
echo ""

if $APPLY; then
  TS=$(date +%Y-%m-%d-%H%M%S)
  BAK="$CLAUDE_DIR/backups/sync-$TS"
  backup_fail() { echo "✗ Backup falhou em $BAK — abortado ANTES de alterar fosse o que fosse."; exit 1; }
  mkdir -p "$BAK" || backup_fail
  for sub in skills commands agents hooks; do
    if [ -d "$CLAUDE_DIR/$sub" ]; then cp -R -P "$CLAUDE_DIR/$sub" "$BAK/$sub" || backup_fail; fi
  done
  if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then cp "$CLAUDE_DIR/CLAUDE.md" "$BAK/" || backup_fail; fi
  echo "Backup → $BAK"
  echo ""

  # Externas PRIMEIRO: se a rede/caminhos falharem, não se mexe em mais nada.
  echo "==> Externas — a correr install-externals.sh (traz/atualiza as ${#EXTERNAL_SKILLS[@]})"
  mkdir -p "$CLAUDE_DIR/skills"
  if ! SKILLSBASE_BAK="$BAK" CLAUDE_DIR="$CLAUDE_DIR" bash "$REPO_ROOT/setup/install-externals.sh"; then
    echo ""
    echo "✗ Externas falharam (ver acima). Nada foi removido nem reconciliado; as externas que já"
    echo "  foram atualizadas ficam (backup em $BAK)."
    echo "  Corrige a rede/caminho e volta a correr: bash sync.sh --apply"
    exit 1
  fi
  echo ""
fi

OWN_SKILLS=()
for d in "$REPO_ROOT"/global-skills/*/; do OWN_SKILLS+=("$(basename "$d")"); done

# ── Skills a mais ────────────────────────────────────────────
echo "==> Skills globais"
if [ -d "$CLAUDE_DIR/skills" ]; then
  for d in "$CLAUDE_DIR"/skills/*/; do
    [ -d "$d" ] || continue
    d="${d%/}"   # sem "/" final: num symlink, rm apaga o link e não o alvo
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
    cp -R "$REPO_ROOT/global-skills/$name" "$CLAUDE_DIR/skills/$name"
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
if ! $APPLY && [ "$MISSING_EXT" = "1" ]; then
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
    if $APPLY; then mkdir -p "$CLAUDE_DIR/commands" && cp "$f" "$CLAUDE_DIR/commands/$base"; fi
  else
    echo "  = ok: $base"
  fi
done

# ── Agentes e hooks ──────────────────────────────────────────
# reconcile_dir <rótulo> <dir-repo> <dir-destino> <glob> <protege-se-referenciado-no-settings:true|false>
reconcile_dir() {
  local label="$1" src="$2" dst="$3" glob="$4" protect="$5" f base
  echo ""
  echo "==> $label"
  for f in "$src"/$glob; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    if [ ! -f "$dst/$base" ] || ! cmp -s "$f" "$dst/$base"; then
      if [ -f "$dst/$base" ]; then echo "  ~ ATUALIZAR: $base"; else echo "  + INSTALAR: $base"; fi
      if $APPLY; then mkdir -p "$dst" && cp "$f" "$dst/$base"; fi
    else
      echo "  = ok: $base"
    fi
  done
  for f in "$dst"/$glob; do
    [ -f "$f" ] || [ -L "$f" ] || continue
    base="$(basename "$f")"
    [ -e "$src/$base" ] && continue
    if [ "$protect" = "true" ] && [ -f "$CLAUDE_DIR/settings.json" ] && grep -qF "$base" "$CLAUDE_DIR/settings.json"; then
      echo "  ! MANTIDO: $base (referenciado no settings.json — remove-o à mão se já não o queres)"
      continue
    fi
    echo "  - REMOVER: $base (não pertence à build)"
    if $APPLY; then rm -f "$f"; fi
  done
  return 0
}
reconcile_dir "Agentes" "$REPO_ROOT/agents" "$CLAUDE_DIR/agents" "*.md" false
reconcile_dir "Hooks (ficheiros; o registo vive no settings.json)" "$REPO_ROOT/hooks" "$CLAUDE_DIR/hooks" "*.py" true
if $APPLY; then chmod +x "$CLAUDE_DIR"/hooks/*.py 2>/dev/null || true; fi

# ── CLAUDE.md ────────────────────────────────────────────────
echo ""
echo "==> CLAUDE.md global"
if [ ! -f "$CLAUDE_DIR/CLAUDE.md" ] || ! cmp -s "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; then
  echo "  ~ difere do repo → seria copiado"
  if $APPLY; then cp "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md" && echo "    copiado"; fi
else
  echo "  = ok"
fi

echo ""
echo "settings.json: nunca tocado pelo sync (chaves locais da máquina) — o registo do hook faz-se à mão (ver setup/AGENT-INSTALL.md)."
if $APPLY; then echo "Reconcile completo. Backup em $BAK. REINICIA o Claude Code."; else echo "Dry-run terminado. Corre com --apply para aplicar."; fi
