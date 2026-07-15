# AGENT-INSTALL — instalar a build skillsbase (guia para o agente)

> **Para um agente (Claude Code), não para humanos.** Para specs manuais passo-a-passo vê [`setup/install.md`](install.md).
> Objetivo: instalar esta build no `~/.claude` do utilizador **adaptado ao que ele já tem**, com **uma** pergunta.

**Regra de ouro:** faz **UMA** `AskUserQuestion` com a opção recomendada marcada — **nunca** um menu neutro de tudo. (Mesma convenção do `skill-matchmaker`.)

Esta build tem **14 skills globais**:
- **Próprias (5):** `ship`, `ship-merge`, `session-handoff`, `skill-matchmaker`, `skill-scout`
- **Externas (9):** `frontend-design`, `impeccable`, `emil-design-eng`, `review-animations`, `supabase`, `supabase-postgres-best-practices`, `systematic-debugging`, `verification-before-completion`, `ui-ux-pro-max`

---

## 1. Inspeciona o terreno (só leitura, antes de perguntar)

- `ls ~/.claude/skills 2>/dev/null` → quantas skills globais ele já tem, e **quantas NÃO são das 14 acima** (essas são as candidatas a remoção no modo "match").
- `~/.claude/CLAUDE.md` existe? → vai ser substituído nos modos com instruções (com backup).
- `~/.claude/settings.json` existe? → **nunca** sobrescrever (pode ter chaves locais da máquina).
- Nota se ele tem **plugins/MCPs** configurados — nenhum comando desta build os toca; convém avisar.

Guarda os números para usar na pergunta (ex.: *"tens 18 skills globais, 12 não são desta build"*).

## 2. Pergunta (uma `AskUserQuestion`, recomendação marcada)

Usa o estado real dele nas descrições. Opções:

- **Só skills, por cima** — *(recomendado)* — instala as 14 skills + comandos por cima. Mantém **tudo** o resto: as tuas outras skills, plugins, o teu CLAUDE.md, settings. Nada é removido nem substituído.
- **Skills + instruções** — o bootstrap completo. Instala as 14 + comandos **e substitui o teu CLAUDE.md** pelo desta build (backup em `CLAUDE.md.pre-skillsbase.bak`). As tuas outras skills/plugins ficam.
- **Deixar igual à build** — reconcilia: instala as 14 **e remove as {N} skills globais tuas que não são desta build**, + substitui o CLAUDE.md. *(NÃO remove plugins nem settings — são sistemas à parte; para ficar 100% igual terias de tirar os plugins à mão.)*
- **Só instruções** — só substitui o CLAUDE.md (com backup). Não toca em skills.

Se ele quiser **ver o que muda antes** de decidir o "match": corre o dry-run (`bash sync.sh`) e mostra-lhe a lista de remoções/atualizações.

## 3. Aplica o modo escolhido

Já clonaste o repo (o prompt mandou clonar). A partir da **raiz do repo**:

| Modo | Comando |
|---|---|
| Só skills, por cima | `bash setup.sh --skills` |
| Skills + instruções | `bash setup.sh` |
| Deixar igual (match) | `bash sync.sh` *(dry-run — mostra)* → confirma com ele → `bash sync.sh --apply` |
| Só instruções | `bash setup.sh --instructions` |

**Não violes:**
- `CLAUDE.md` é sobrescrito, mas **sempre com backup** `.pre-skillsbase.bak` (o script trata).
- `settings.json` **nunca** é sobrescrito — só criado se não existir (o script trata).
- Não toques em **plugins** nem em `<projeto>/.claude/`.

## 4. Reporta + passos manuais (o utilizador tem de fazer)

Diz-lhe, em concreto:
- O que **instalou / removeu / substituiu** (e onde ficou o backup do CLAUDE.md, se houve).
- **Reinicia o Claude Code** para as skills e o CLAUDE.md carregarem.
- **Liga o conector Supabase:** Settings → Connectors → Supabase (OAuth no browser). É o **único** MCP desta build e só ele o pode ligar — tu (agente) não consegues. (ver [`setup/mcps.md`](mcps.md))
- *(Opcional, por projeto)* `/skills-suggest` instala skills do catálogo para a stack desse projeto.

---

**Notas:** idempotente (seguro re-correr — também atualiza as externas). Porquê *no plugins / no hooks*: [`DECISIONS.md`](../DECISIONS.md).
