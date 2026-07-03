#!/usr/bin/env bash
# install-externals.sh — puxa as skills de TERCEIROS das fontes originais.
#
# Estas skills NÃO são vendorizadas neste repo (licenças + updates fáceis):
# este script traz sempre a versão atual de cada upstream e aplica os patches
# documentados em DECISIONS.md. Idempotente — re-correr = atualizar.
#
# Uso:  bash setup/install-externals.sh          (chamado pelo setup.sh)
#       CLAUDE_DIR=/tmp/teste bash setup/install-externals.sh   (sandbox)

set -e
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILLS="$CLAUDE_DIR/skills"
AGENTS="$CLAUDE_DIR/agents"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$SKILLS" "$AGENTS"

fetch_sparse() { # fetch_sparse <owner/repo> <path...>  → ecoa o dir local
  local repo="$1"; shift
  local dest="$TMP/${repo//\//-}"
  git clone -q --depth 1 --filter=blob:none --sparse "https://github.com/$repo" "$dest"
  git -C "$dest" sparse-checkout set "$@" >/dev/null 2>&1
  echo "$dest"
}

install_skill() { # install_skill <src-dir> <nome>
  rm -rf "${SKILLS:?}/$2"
  cp -r "$1" "$SKILLS/$2"
  echo "  v $2"
}

echo "  -- frontend-design (anthropics/skills, oficial)"
D=$(fetch_sparse anthropics/skills skills/frontend-design)
install_skill "$D/skills/frontend-design" frontend-design

echo "  -- impeccable (pbakaus/impeccable)"
D=$(fetch_sparse pbakaus/impeccable .claude)
install_skill "$D/.claude/skills/impeccable" impeccable
cp "$D/.claude/agents/impeccable-manual-edit-applier.md" "$AGENTS/"
echo "  v agent impeccable-manual-edit-applier"
# NOTA: o hook PostToolUse do impeccable NAO e instalado de proposito
# (latencia em cada edit de UI) — ver DECISIONS.md. Para o ativar num projeto
# especifico: npx impeccable install na raiz desse projeto.

echo "  -- emil-design-eng + review-animations (emilkowalski/skills)"
D=$(fetch_sparse emilkowalski/skills skills/emil-design-eng skills/review-animations)
install_skill "$D/skills/emil-design-eng" emil-design-eng
install_skill "$D/skills/review-animations" review-animations

echo "  -- supabase x2 (supabase/agent-skills, oficial)"
D=$(fetch_sparse supabase/agent-skills skills)
install_skill "$D/skills/supabase" supabase
install_skill "$D/skills/supabase-postgres-best-practices" supabase-postgres-best-practices

echo "  -- systematic-debugging + verification-before-completion (obra/superpowers, cherry-pick)"
D=$(fetch_sparse obra/superpowers skills/systematic-debugging skills/verification-before-completion)
install_skill "$D/skills/systematic-debugging" systematic-debugging
rm -f "$SKILLS/systematic-debugging"/test-*.md "$SKILLS/systematic-debugging/CREATION-LOG.md"
install_skill "$D/skills/verification-before-completion" verification-before-completion

echo "  -- ui-ux-pro-max (nextlevelbuilder/ui-ux-pro-max-skill) + patch manual-only"
D=$(fetch_sparse nextlevelbuilder/ui-ux-pro-max-skill .claude/skills/ui-ux-pro-max)
install_skill "$D/.claude/skills/ui-ux-pro-max" ui-ux-pro-max
node -e '
const fs = require("fs");
const f = process.argv[1];
let s = fs.readFileSync(f, "utf8");
if (!s.includes("disable-model-invocation")) {
  s = s.replace(/^name: ui-ux-pro-max$/m, "name: ui-ux-pro-max\ndisable-model-invocation: true");
  s = s.replace("description: \"", "description: \"KICKOFF de projetos novos — invocar manualmente com /ui-ux-pro-max no início de um projeto para gerar a direção de design (estilo + paleta + tipografia + anti-patterns + design system inicial). ");
  fs.writeFileSync(f, s);
  console.log("  v patch manual-only aplicado");
} else {
  console.log("  v patch manual-only já presente");
}
' "$SKILLS/ui-ux-pro-max/SKILL.md"

echo "  Externas instaladas/atualizadas."
