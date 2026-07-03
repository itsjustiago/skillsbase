#!/usr/bin/env bash
# skillsbase — bootstrap de uma máquina nova para a build Claude Code do Tiago.
#
# Uso:
#   git clone https://github.com/itsjustiago/skillsbase.git
#   cd skillsbase
#   bash setup.sh
#
# Idempotente: seguro re-correr (também serve para ATUALIZAR as skills externas).
# Sem plugins, sem hooks — a build é 100% ficheiros. Porquê: ver DECISIONS.md.
# Sandbox/teste: CLAUDE_DIR=/tmp/teste bash setup.sh

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

echo "╔══════════════════════════════════════════════╗"
echo "║   skillsbase bootstrap (build jul/2026)      ║"
echo "╚══════════════════════════════════════════════╝"
echo "    destino: $CLAUDE_DIR"
echo ""

# ── Preflight ────────────────────────────────────────────────
echo "==> Preflight..."
MISSING=""
command -v git  >/dev/null 2>&1 || MISSING="$MISSING git"
command -v node >/dev/null 2>&1 || MISSING="$MISSING node"
if [ -n "$MISSING" ]; then
  echo "  ✗ Falta:$MISSING — instala primeiro e volta a correr."
  exit 1
fi
echo "  v git, node"
command -v python >/dev/null 2>&1 || command -v py >/dev/null 2>&1 || \
  echo "  ! python não encontrado — a pesquisa do ui-ux-pro-max precisa dele (instala quando fores usar)"
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/commands" "$CLAUDE_DIR/agents"

# ── Step 1: skills próprias + slash commands ─────────────────
echo ""
echo "==> 1/3 — skills próprias (global-skills/) + comandos"
for d in "$REPO_ROOT"/global-skills/*/; do
  name="$(basename "$d")"
  rm -rf "${CLAUDE_DIR:?}/skills/$name"
  cp -r "$d" "$CLAUDE_DIR/skills/$name"
  echo "  v $name"
done
if compgen -G "$REPO_ROOT/commands/*.md" >/dev/null; then
  cp "$REPO_ROOT"/commands/*.md "$CLAUDE_DIR/commands/"
  echo "  v commands/"
fi

# ── Step 2: skills externas (fontes originais) ───────────────
echo ""
echo "==> 2/3 — skills externas (clonadas dos upstreams, nunca vendorizadas)"
CLAUDE_DIR="$CLAUDE_DIR" bash "$REPO_ROOT/setup/install-externals.sh"

# ── Step 3: configs globais ──────────────────────────────────
echo ""
echo "==> 3/3 — configs globais"
if [ -f "$CLAUDE_DIR/CLAUDE.md" ] && ! cmp -s "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; then
  cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.pre-skillsbase.bak"
  echo "  ! CLAUDE.md existente diferia → backup em CLAUDE.md.pre-skillsbase.bak"
fi
cp "$REPO_ROOT/setup/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
echo "  v CLAUDE.md"

if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$REPO_ROOT/setup/settings.json" "$CLAUDE_DIR/settings.json"
  echo "  v settings.json"
else
  echo "  = settings.json já existe — mantido (pode ter chaves locais da máquina)"
fi

# ── Done ─────────────────────────────────────────────────────
echo ""
echo "Bootstrap completo. Passos manuais:"
echo ""
echo "  1. REINICIA o Claude Code para as skills e o CLAUDE.md carregarem."
echo "  2. No desktop app: Settings → Connectors → liga o SUPABASE (OAuth)."
echo "     Só esse — os restantes foram removidos de propósito (setup/mcps.md)."
echo ""
echo "────────────────────────────────────────────────────────────"
echo " 📋 Comandos & triggers desta build:"
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
echo "    /skills-suggest             skills do catálogo para ESTE projeto"
echo "────────────────────────────────────────────────────────────"
