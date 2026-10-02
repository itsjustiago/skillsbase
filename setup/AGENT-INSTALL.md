# AGENT-INSTALL — instalar a build skillsbase (guia para o agente)

> **Para um agente (Claude Code), não para humanos.**
> Objetivo: instalar esta build no `~/.claude` do utilizador **adaptado ao que ele já tem**, com **uma** pergunta.

**Regra de ouro:** faz **UMA** `AskUserQuestion` com a opção recomendada marcada — **nunca** um menu neutro de tudo.

Esta build tem **22 skills globais**, **8 agentes**, **2 hooks** e as instruções globais:
- **Skills próprias (6):** `ship`, `ship-merge`, `session-handoff`, `preclear`, `skill-scout`, `watch-youtube`
- **Skills externas (16, puxadas dos upstreams):** `frontend-design`, `impeccable`, `emil-design-eng`, `review-animations`, `supabase`, `supabase-postgres-best-practices`, `systematic-debugging`, `verification-before-completion`, `ui-ux-pro-max`, `browser-testing-with-devtools`, `security-and-hardening`, `core-web-vitals`, `web-accessibility`, `semgrep`, `differential-review`, `supply-chain-risk-auditor`
- **Agentes (8):** `design`, `engenheiro`, `explorador`, `financas`, `investigador`, `revisor`, `seguranca`, `testador`
- **Hooks (2):** `bloquear_kill_por_nome.py` (PreToolUse em Bash; bloqueia `pkill`/`killall` e afins) e `estado_sessao.py` (SessionStart; injeta o ficheiro de estado da pasta, que vive em `~/.claude/estado/`, no arranque, compact e clear — é o que o `/preclear` reescreve)

---

## 1. Inspeciona o terreno (só leitura, antes de perguntar)

- `ls ~/.claude/skills 2>/dev/null` → quantas skills globais ele já tem, e **quantas NÃO são das 22 acima** (candidatas a remoção no modo "match").
- `ls ~/.claude/agents ~/.claude/hooks 2>/dev/null` → o mesmo para agentes e hooks que não são da build.
- `~/.claude/CLAUDE.md` existe? → vai ser substituído nos modos com instruções (com backup).
- `~/.claude/settings.json` existe? → **nunca** é sobrescrito. Se existir, vê se já tem os hooks `bloquear_kill_por_nome` (`hooks.PreToolUse`) e `estado_sessao` (`hooks.SessionStart`).
- Nota se ele tem **plugins/MCPs** configurados — nenhum comando desta build os remove; convém avisar.

Guarda os números para usar na pergunta (ex.: *"tens 18 skills globais, 12 não são desta build"*).

## 2. Pergunta (uma `AskUserQuestion`, recomendação marcada)

Usa o estado real dele nas descrições. Opções:

- **Só skills, por cima** — *(recomendado)* — instala as 22 skills, os 8 agentes e os ficheiros dos hooks por cima. Mantém as tuas outras skills/agentes, plugins, o teu CLAUDE.md e settings. Itens teus **com o mesmo nome** que os da build são substituídos, com backup em `~/.claude/backups/skillsbase-<TS>/`. Os hooks só ficam ativos depois do §4.
- **Skills + instruções** — o bootstrap completo. Faz o de cima **e substitui o teu CLAUDE.md** pelo desta build (backup em `CLAUDE.md.pre-skillsbase.bak`, ou `…-<TS>.bak` se já existir um). Cria o `settings.json` só se não existir. **Avisa numa linha:** o CLAUDE.md é o do dono (auto-merge e push sem perguntar, escrito para "o Tiago") e convém adaptá-lo.
- **Deixar igual à build** — reconcilia: instala tudo **e remove as {N} skills globais, os agentes e os hooks teus que não são desta build**, + substitui o CLAUDE.md. *(NÃO remove plugins nem settings — são sistemas à parte.)*
- **Só instruções** — só substitui o CLAUDE.md (com backup; mesmo aviso do dono). Não toca em skills, agentes nem hooks.

Se ele quiser **ver o que muda antes** de decidir o "match": corre o dry-run (`bash sync.sh`) e mostra-lhe a lista de remoções/atualizações.

## 3. Aplica o modo escolhido

Já clonaste o repo (o prompt mandou clonar). **Antes de correr**, mostra ao utilizador, em poucas linhas, o que vão fazer: `setup.sh` copia skills próprias, agentes, hooks (e CLAUDE.md/settings conforme o modo) para `~/.claude`, com backup do que substitui; `setup/install-externals.sh` **clona o HEAD dos 9 repos upstream** (sem pin, por desenho) e instala 16 skills — convém ele rever o script se quiser. Só depois corre, a partir da **raiz do repo**:

| Modo | Comando |
|---|---|
| Só skills, por cima | `bash setup.sh --skills` |
| Skills + instruções | `bash setup.sh` |
| Deixar igual (match) | `bash sync.sh` *(dry-run — mostra)* → confirma com ele → `bash sync.sh --apply` |
| Só instruções | `bash setup.sh --instructions` |

**Não violes:**
- `CLAUDE.md` é sobrescrito, mas **sempre com backup**: `.pre-skillsbase*.bak` no `setup.sh`, `backups/sync-<TS>/` no `sync.sh` (os scripts tratam).
- `settings.json` **nunca** é sobrescrito — só criado se não existir (o script trata).
- Não removas **plugins** nem toques em `<projeto>/.claude/`.
- Sem rede, as externas falham sem tocar nas já instaladas e o script sai com erro: o resto fica instalado; diz-lho e sugere re-correr.

## 4. Settings: registar os hooks (só com OK dele) — **propõe-no sempre**, em todos os modos que instalam skills

Os modos "Só skills" e "Deixar igual" copiam os ficheiros dos hooks mas **nada os regista**; `setup.sh --skills` imprime o excerto, e o `sync.sh` nunca cria nem toca em `settings.json` (no modo "Deixar igual", se ele não existir, **crias tu** o `settings.json` com a fusão abaixo, com OK do utilizador). Por isso, depois de qualquer um destes modos, propõe a fusão abaixo.

A build traz **2 hooks** (`PreToolUse` em `Bash` → `python3 ~/.claude/hooks/bloquear_kill_por_nome.py`; `SessionStart` → `python3 ~/.claude/hooks/estado_sessao.py`, `timeout: 5`) e **1 plugin** (`security-guidance@claude-code-plugins`, via `enabledPlugins` + `extraKnownMarketplaces`), tudo em `setup/settings.json`.

- **Sem `~/.claude/settings.json`:** o `setup.sh` (modo completo) cria-o com isto tudo — os hooks ficam ativos.
- **Com `~/.claude/settings.json`:** o script não lhe toca e imprime o excerto dos hooks. Mostra-o ao utilizador e **só com o OK dele** funde-o no ficheiro dele (acrescenta as entradas a `hooks.PreToolUse` e `hooks.SessionStart`, sem apagar nada do que lá está). Faz o mesmo, também só com OK, para o plugin se ele o quiser.
- **Chaves de contexto a juntar à mão** (também só com OK): `"autoCompactWindow": 250000` e `"permissions": { "deny": ["Artifact", "ArtifactComments", "ArtifactData"] }` (se ele já tiver `permissions.deny`, acrescenta aos que lá estão). Porquê: `DECISIONS.md`.
- Os hooks precisam de `python3` a funcionar (no Windows `python3` pode ser o stub da Microsoft Store): o `setup.sh` avisa se `python3 --version` falhar; se avisou, diz-lho claramente antes de registar os hooks.
- Avisa que `setup/settings.json` inclui preferências do dono (tema `dark`, Remote Control desligado, stop-review desligado) — **não** as fundas por defeito; só os hooks e as chaves de contexto (e o plugin, se ele quiser).

## 5. Reporta + passos manuais (o utilizador tem de fazer)

Diz-lhe, em concreto:
- O que **instalou / removeu / substituiu** e **onde ficaram os backups**, conforme o modo: `~/.claude/CLAUDE.md.pre-skillsbase.bak` (ou `…-<TS>.bak`) para o CLAUDE.md; `~/.claude/backups/skillsbase-<TS>/` para itens de nome igual substituídos pelo `setup.sh`; `~/.claude/backups/sync-<TS>/` para o `sync.sh --apply`.
- **Reinicia o Claude Code** para skills, agentes e CLAUDE.md carregarem.
- Os hooks precisam de `python3` no PATH.
- **Supabase (opcional):** conector OAuth no desktop app ou MCP por CLI — ver [`setup/mcps.md`](mcps.md). Tu (agente) não consegues ligá-lo por ele.

---

**Notas:** idempotente (seguro re-correr — também atualiza as externas). Porquê ficheiros e não plugins: [`DECISIONS.md`](../DECISIONS.md).
