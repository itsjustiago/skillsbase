#!/usr/bin/env bash
# install-externals.sh — puxa as skills de TERCEIROS das fontes originais.
#
# Estas skills NÃO são vendorizadas neste repo (licenças + updates fáceis):
# este script traz o HEAD atual de cada upstream (sem pin, por desenho:
# "updates = re-run") e aplica os patches documentados em DECISIONS.md.
# Idempotente — re-correr = atualizar.
#
# Cada fonte é tratada isoladamente: se uma falhar (rede, caminho), as outras
# continuam e a skill já instalada dessa fonte NÃO é tocada. No fim imprime o
# resumo das falhas e sai != 0 se alguma falhou.
#
# Uso:  bash setup/install-externals.sh          (chamado pelo setup.sh)
#       CLAUDE_DIR=/tmp/teste bash setup/install-externals.sh   (sandbox)

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILLS="$CLAUDE_DIR/skills"
TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP" "$SKILLS"/.skillsbase-new-* 2>/dev/null; }
trap cleanup EXIT
trap 'exit 130' INT TERM   # Ctrl-C: sai e o EXIT trap limpa o TMP e os stages
mkdir -p "$SKILLS"

# Backup de skills substituídas (uma pasta por corrida; o setup/sync podem partilhá-la)
BAK="${SKILLSBASE_BAK:-$CLAUDE_DIR/backups/skillsbase-$(date +%Y-%m-%d-%H%M%S)}"
FAILS=()

fetch_sparse() { # fetch_sparse <owner/repo> <path...>  → ecoa o dir local; != 0 se falhar
  local repo="$1"; shift
  local dest="$TMP/${repo//\//-}"
  git clone -q --depth 1 --filter=blob:none --sparse "https://github.com/$repo" "$dest" || return 1
  git -C "$dest" sparse-checkout set "$@" >/dev/null 2>&1 || return 1
  echo "$dest"
}

# install_skill <src-dir> <nome> [função-de-patch]
# Prepara uma cópia, aplica o patch nela, e só então (se diferir) faz backup e troca.
install_skill() {
  local src="$1" name="$2" patch="${3:-}" stage="$SKILLS/.skillsbase-new-$2"
  if [ ! -d "$src" ]; then
    echo "  x $name: origem em falta no upstream ($src)"
    return 1
  fi
  rm -rf "$stage"
  cp -R "$src" "$stage" || { rm -rf "$stage"; echo "  x $name: cópia falhou"; return 1; }
  if [ -n "$patch" ]; then "$patch" "$stage" || { rm -rf "$stage"; echo "  x $name: patch falhou"; return 1; }; fi
  if [ -d "$SKILLS/$name" ] && diff -rq "$stage" "$SKILLS/$name" >/dev/null 2>&1; then
    rm -rf "$stage"
    echo "  = $name (já atualizada)"
    return 0
  fi
  if [ -e "$SKILLS/$name" ] || [ -L "$SKILLS/$name" ]; then
    if [ ! -e "$BAK/skills/$name" ]; then
      { mkdir -p "$BAK/skills" && cp -R -P "$SKILLS/$name" "$BAK/skills/$name"; } \
        || { rm -rf "$stage"; echo "  x $name: backup falhou (skill existente NÃO foi tocada)"; return 1; }
    fi
    rm -rf "${SKILLS:?}/$name"
  fi
  mv "$stage" "$SKILLS/$name" || { echo "  x $name: instalação falhou"; return 1; }
  echo "  v $name"
}

# ── patches (operam na cópia preparada, nunca na skill instalada) ──
patch_systematic_debugging() { # ficheiros de teste internos do upstream = ruído
  rm -f "$1"/test-*.md "$1/CREATION-LOG.md"
}
patch_ui_ux_pro_max() { # manual-only: só corre com /ui-ux-pro-max
  node -e '
const fs = require("fs");
const f = process.argv[1] + "/SKILL.md";
let s = fs.readFileSync(f, "utf8");
if (!s.includes("disable-model-invocation")) {
  s = s.replace(/^name: ui-ux-pro-max$/m, "name: ui-ux-pro-max\ndisable-model-invocation: true");
  s = s.replace("description: \"", "description: \"KICKOFF de projetos novos — invocar manualmente com /ui-ux-pro-max no início de um projeto para gerar a direção de design (estilo + paleta + tipografia + anti-patterns + design system inicial). ");
  fs.writeFileSync(f, s);
}
' "$1"
}
patch_web_accessibility() { # o upstream chama-lhe "accessibility"; aqui pasta e name são "web-accessibility"
  node -e '
const fs = require("fs");
const f = process.argv[1] + "/SKILL.md";
const s = fs.readFileSync(f, "utf8");
fs.writeFileSync(f, s.replace(/^name: accessibility$/m, "name: web-accessibility"));
' "$1"
}

# ── fontes (cada função devolve != 0 se falhar; erros explícitos, sem depender de set -e) ──
src_frontend_design() {
  local D; D=$(fetch_sparse anthropics/skills skills/frontend-design) || return 1
  install_skill "$D/skills/frontend-design" frontend-design
}
src_impeccable() {
  # NOTA: o hook PostToolUse do impeccable e o agente impeccable-manual-edit-applier
  # NAO sao instalados de proposito (latencia em cada edit de UI) — ver DECISIONS.md.
  local D; D=$(fetch_sparse pbakaus/impeccable .claude) || return 1
  install_skill "$D/.claude/skills/impeccable" impeccable
}
src_emil() {
  local D rc=0; D=$(fetch_sparse emilkowalski/skills skills/emil-design-eng skills/review-animations) || return 1
  install_skill "$D/skills/emil-design-eng" emil-design-eng || rc=1
  install_skill "$D/skills/review-animations" review-animations || rc=1
  return $rc
}
src_supabase() {
  local D rc=0; D=$(fetch_sparse supabase/agent-skills skills) || return 1
  install_skill "$D/skills/supabase" supabase || rc=1
  install_skill "$D/skills/supabase-postgres-best-practices" supabase-postgres-best-practices || rc=1
  return $rc
}
src_superpowers() {
  local D rc=0; D=$(fetch_sparse obra/superpowers skills/systematic-debugging skills/verification-before-completion) || return 1
  install_skill "$D/skills/systematic-debugging" systematic-debugging patch_systematic_debugging || rc=1
  install_skill "$D/skills/verification-before-completion" verification-before-completion || rc=1
  return $rc
}
src_ui_ux_pro_max() {
  local D; D=$(fetch_sparse nextlevelbuilder/ui-ux-pro-max-skill .claude/skills/ui-ux-pro-max) || return 1
  install_skill "$D/.claude/skills/ui-ux-pro-max" ui-ux-pro-max patch_ui_ux_pro_max
}
src_addy_agent_skills() {
  local D rc=0; D=$(fetch_sparse addyosmani/agent-skills skills/browser-testing-with-devtools skills/security-and-hardening) || return 1
  install_skill "$D/skills/browser-testing-with-devtools" browser-testing-with-devtools || rc=1
  install_skill "$D/skills/security-and-hardening" security-and-hardening || rc=1
  return $rc
}
src_addy_web_quality() {
  local D rc=0; D=$(fetch_sparse addyosmani/web-quality-skills skills/core-web-vitals skills/accessibility) || return 1
  install_skill "$D/skills/core-web-vitals" core-web-vitals || rc=1
  install_skill "$D/skills/accessibility" web-accessibility patch_web_accessibility || rc=1
  return $rc
}
src_trailofbits() { # CC-BY-SA-4.0
  local D rc=0
  D=$(fetch_sparse trailofbits/skills \
    plugins/static-analysis/skills/semgrep \
    plugins/differential-review/skills/differential-review \
    plugins/supply-chain-risk-auditor/skills/supply-chain-risk-auditor) || return 1
  install_skill "$D/plugins/static-analysis/skills/semgrep" semgrep || rc=1
  install_skill "$D/plugins/differential-review/skills/differential-review" differential-review || rc=1
  install_skill "$D/plugins/supply-chain-risk-auditor/skills/supply-chain-risk-auditor" supply-chain-risk-auditor || rc=1
  return $rc
}

run_source() { # run_source <rótulo> <função>
  echo "  -- $1"
  if ! "$2"; then
    FAILS+=("$1")
    echo "  x FALHOU: $1 (a skill já instalada, se existir, ficou intacta)"
  fi
}

run_source "frontend-design (anthropics/skills)" src_frontend_design
run_source "impeccable (pbakaus/impeccable)" src_impeccable
run_source "emil-design-eng + review-animations (emilkowalski/skills)" src_emil
run_source "supabase x2 (supabase/agent-skills)" src_supabase
run_source "systematic-debugging + verification-before-completion (obra/superpowers)" src_superpowers
run_source "ui-ux-pro-max (nextlevelbuilder/ui-ux-pro-max-skill, patch manual-only)" src_ui_ux_pro_max
run_source "browser-testing-with-devtools + security-and-hardening (addyosmani/agent-skills)" src_addy_agent_skills
run_source "core-web-vitals + web-accessibility (addyosmani/web-quality-skills)" src_addy_web_quality
run_source "semgrep, differential-review, supply-chain-risk-auditor (trailofbits/skills)" src_trailofbits

if [ "${#FAILS[@]}" -gt 0 ]; then
  echo ""
  echo "  ✗ ${#FAILS[@]} fonte(s) externa(s) falharam:"
  for f in "${FAILS[@]}"; do echo "      - $f"; done
  echo "    Re-corre quando tiveres rede: bash setup/install-externals.sh"
  exit 1
fi
echo "  Externas instaladas/atualizadas."
