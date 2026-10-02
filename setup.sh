#!/usr/bin/env bash
# skillsbase — bootstrap de uma máquina nova para a build Claude Code do Tiago.
#
# Uso:
#   git clone https://github.com/itsjustiago/skillsbase.git
#   cd skillsbase
#   bash setup.sh
#
# Idempotente: seguro re-correr (também serve para ATUALIZAR as skills externas).
# A build é 100% ficheiros (skills, agentes, hooks, CLAUDE.md, settings). Porquê: ver DECISIONS.md.
# Ordem: primeiro o que não precisa de rede (próprias, agentes, hooks,
# CLAUDE.md, settings), por último as externas (clonam o HEAD dos upstreams).
# Sandbox/teste: CLAUDE_DIR=/tmp/teste bash setup.sh

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
TS="$(date +%Y-%m-%d-%H%M%S)"
# Itens existentes com o mesmo nome (e diferentes) são copiados para aqui antes de serem substituídos
export SKILLSBASE_BAK="$CLAUDE_DIR/backups/skillsbase-$TS"

# ── Modo (default = tudo) ────────────────────────────────────
#   (sem args)       tudo: skills + externas + agentes + hooks + CLAUDE.md (+ settings)
#   --skills         só skills próprias + externas + agentes + hooks (não toca em config)
#   --instructions   só o CLAUDE.md global (com backup)
MODE="all"
case "${1:-}" in
  --skills)       MODE="skills" ;;
  --instructions) MODE="instructions" ;;
  ""|--all)       MODE="all" ;;
  *) echo "Uso: bash setup.sh [--skills | --instructions]"; exit 1 ;;
esac
do_skills() { [ "$MODE" = "all" ] || [ "$MODE" = "skills" ]; }
do_config() { [ "$MODE" = "all" ] || [ "$MODE" = "instructions" ]; }

echo "╔══════════════════════════════════════════════╗"
echo "║   skillsbase bootstrap (build atual)          ║"
echo "╚══════════════════════════════════════════════╝"
echo "    destino: $CLAUDE_DIR"
echo "    modo:    $MODE"
echo ""

# ── Preflight (só o que o modo precisa) ──────────────────────
if do_skills; then
  echo "==> Preflight..."
  MISSING=""
  command -v git  >/dev/null 2>&1 || MISSING="$MISSING git"
  command -v node >/dev/null 2>&1 || MISSING="$MISSING node"
  if [ -n "$MISSING" ]; then
    echo "  ✗ Falta:$MISSING — instala primeiro e volta a correr."
    exit 1
  fi
  echo "  v git, node"
  if python3 --version >/dev/null 2>&1; then
    echo "  v python3"
  else
    echo "  ! python3 não funciona (no Windows pode ser o stub da Microsoft Store): os hooks"
    echo "    não correm até instalares Python 3 (e o ui-ux-pro-max também precisa)."
    echo "    A instalação continua."
  fi
fi
mkdir -p "$CLAUDE_DIR"
if do_skills; then mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks"; fi

# put <origem> <pasta-destino> <categoria> — copia ficheiro/pasta; se já existir com o mesmo
# nome e for diferente, faz backup em $SKILLSBASE_BAK/<categoria>/ antes de substituir.
put() {
  local src="${1%/}" destdir="$2" cat="$3" base dst
  base="$(basename "$src")"; dst="$destdir/$base"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -d "$src" ] && [ -d "$dst" ] && [ ! -L "$dst" ] && diff -rq "$src" "$dst" >/dev/null 2>&1; then
      echo "  = $base"; return 0
    fi
    if [ -f "$src" ] && [ -f "$dst" ] && cmp -s "$src" "$dst"; then
      echo "  = $base"; return 0
    fi
    mkdir -p "$SKILLSBASE_BAK/$cat"
    [ -e "$SKILLSBASE_BAK/$cat/$base" ] || cp -R -P "$dst" "$SKILLSBASE_BAK/$cat/$base"
    rm -rf "${dst:?}"
    echo "  ~ $base (versão anterior em backups/skillsbase-$TS/$cat/)"
  else
    echo "  v $base"
  fi
  cp -R "$src" "$destdir/"
}

print_hook_excerpt() {
  node -e '
const s = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
console.log(JSON.stringify({ hooks: s.hooks }, null, 2).replace(/^/gm, "        "));
' "$REPO_ROOT/setup/settings.json"
}
# Os ficheiros dos hooks são copiados, mas só o settings.json os regista.
hook_note() {
  local sf="$CLAUDE_DIR/settings.json" f b missing=""
  for f in "$REPO_ROOT"/hooks/*.py; do
    b="$(basename "$f" .py)"
    { [ -f "$sf" ] && grep -qF "$b" "$sf"; } || missing="$missing $b"
  done
  if [ -z "$missing" ]; then
    echo "  = hooks já registados no settings.json"
    return 0
  fi
  echo "  ! por registar:$missing — NÃO ficam ativos até estarem no settings.json. Funde isto em"
  echo "    \"hooks\" do teu settings.json (o AGENT-INSTALL.md trata, com OK do utilizador):"
  print_hook_excerpt
}

# ── Step 1: skills próprias + agentes + hooks (sem rede) ──
if do_skills; then
  echo ""
  echo "==> skills próprias (global-skills/)"
  for d in "$REPO_ROOT"/global-skills/*/; do put "$d" "$CLAUDE_DIR/skills" skills; done
  echo ""
  echo "==> agentes (agents/)"
  for f in "$REPO_ROOT"/agents/*.md; do [ -f "$f" ] && put "$f" "$CLAUDE_DIR/agents" agents; done
  echo ""
  echo "==> hooks (hooks/ — só os ficheiros; o registo vive no settings.json)"
  for f in "$REPO_ROOT"/hooks/*; do [ -f "$f" ] && put "$f" "$CLAUDE_DIR/hooks" hooks; done
  chmod +x "$CLAUDE_DIR"/hooks/*.py 2>/dev/null || true
fi

# ── Step 2: configs globais (sem rede) ───────────────────────
if do_config; then
  echo ""
  echo "==> config — CLAUDE.md global"
  if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && ! cmp -s "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; then
    BAKFILE="$CLAUDE_DIR/CLAUDE.md.pre-skillsbase.bak"
    # nunca sobrescrever um backup anterior (guarda o original)
    [ -e "$BAKFILE" ] && BAKFILE="$CLAUDE_DIR/CLAUDE.md.pre-skillsbase-$TS.bak"
    cp "$CLAUDE_DIR/CLAUDE.md" "$BAKFILE"
    echo "  ! CLAUDE.md existente diferia → backup em $(basename "$BAKFILE")"
  fi
  cp "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  echo "  v CLAUDE.md"
fi

# settings.json só no bootstrap completo — create-only, nunca sobrescreve (chaves locais)
if [ "$MODE" = "all" ]; then
  if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    cp "$REPO_ROOT/setup/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  v settings.json (criado, com os hooks registados)"
  else
    echo "  = settings.json já existe — mantido (pode ter chaves locais da máquina)"
    hook_note
  fi
elif [ "$MODE" = "skills" ]; then
  echo ""
  echo "==> hooks"
  hook_note
fi

if [ "$MODE" = "instructions" ]; then
  echo ""
  echo "CLAUDE.md instalado. Reinicia o Claude Code para o carregar."
  exit 0
fi

# ── Step 3: skills externas (rede; por último, para não bloquear o resto) ──
EXT_FAIL=0
echo ""
echo "==> skills externas (clonadas dos upstreams — HEAD atual, nunca vendorizadas)"
if ! CLAUDE_DIR="$CLAUDE_DIR" bash "$REPO_ROOT/setup/install-externals.sh"; then EXT_FAIL=1; fi

# ── Done ─────────────────────────────────────────────────────
echo ""
if [ "$EXT_FAIL" = "1" ]; then
  echo "Bootstrap INCOMPLETO: o que não precisa de rede ficou instalado, mas há skills"
  echo "externas em falta (ver acima). Re-corre 'bash setup.sh --skills' com rede."
else
  echo "Bootstrap completo."
fi
echo "Passos manuais:"
echo ""
echo "  1. REINICIA o Claude Code para as skills, agentes e o CLAUDE.md carregarem."
echo "  2. Supabase (só se usares): conector OAuth no desktop app, ou o MCP por CLI — ver setup/mcps.md."
if [ -d "$SKILLSBASE_BAK" ]; then echo "  3. Versões anteriores substituídas: $SKILLSBASE_BAK"; fi
echo ""
echo "────────────────────────────────────────────────────────────"
echo " 📋 Triggers desta build (skills):"
echo "────────────────────────────────────────────────────────────"
echo "  Projeto novo (ritual de kickoff)"
echo "    /ui-ux-pro-max <descrição>   direção de design (estilo+paleta+fontes)"
echo "    /impeccable init             fixa a direção em PRODUCT.md/DESIGN.md"
echo ""
echo "  Design (durante/depois do build)"
echo "    frontend-design + emil-design-eng   automáticas em trabalho de UI"
echo "    /impeccable critique|audit|polish|…  (23 comandos — /impeccable lista)"
echo "    /review-animations           review rigorosa de motion (manual)"
echo ""
echo "  Engenharia"
echo "    \"debug X\"                  root cause sistemático antes de fixes"
echo "    \"verify\"                   evidência antes de declarar feito"
echo "    supabase/*                  automáticas em trabalho Supabase/Postgres"
echo ""
echo "  Ship & sessões"
echo "    /ship                       commit → push → PR"
echo "    /ship-merge                 commit → PR → CI → squash-merge → cleanup"
echo "    \"wrap up session\"          handoff antes de /clear"
echo "    /preclear                   guarda o estado e limpa o chat (o hook retoma-o)"
echo ""
echo "  Agentes (subagentes, no CLAUDE.md global)"
echo "    engenheiro · explorador · investigador · revisor · testador"
echo "    design · seguranca · financas"
echo "────────────────────────────────────────────────────────────"
[ "$EXT_FAIL" = "0" ] || exit 1
