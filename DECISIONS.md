# DECISIONS — porquê desta build (auditoria de 2026-07-03)

Registo das decisões da reconstrução de julho/2026, para o futuro eu (e o futuro
Claude) não re-litigar o que já foi avaliado. Se quiseres reverter algo daqui,
lê primeiro o motivo.

## Contexto: o audit

Análise de 38 sessões / ~31.500 mensagens (jun–jul 2026, projetos soma-seg,
elevia, somaeseg_site, tvdefleet, Desktop). Maiores perdas identificadas:

- **Esperas por input** — ~15,5h/mês parado em AskUserQuestion (média 13 min/pergunta) → CLAUDE.md agora manda avançar com defaults e perguntar no máx. 1 coisa.
- **Contexto inicial ~42k tokens** — conectores MCP + skills a mais → conectores mortos desligados, skills pesadas tornadas manual-only.
- **Skills avariadas** — design-auto-pipeline e ship referenciavam ferramentas nunca instaladas (impeccable/magia/sanctum) → o Claude improvisava e perdia tempo.

## Arquitetura: ficheiros, não plugins

A build antiga instalava 8 plugins (superpowers, sanctum+leyline+abstract,
conserve, impeccable, frontend-design, watch). A nova instala **skills como
ficheiros** em `~/.claude/skills/`:

- funciona no desktop app sem o CLI `claude` no PATH;
- zero hooks automáticos (a latência era a queixa nº1);
- terceiros vêm sempre das **fontes originais** via `setup/install-externals.sh`
  (licenças respeitadas, updates = re-correr o script) — nunca vendorizados aqui.

## Skills globais da build (14)

**Próprias (5, vendorizadas em `global-skills/`):** session-handoff, ship,
ship-merge, skill-matchmaker, skill-scout.

**Externas (9, via install-externals.sh):**

| Skill | Fonte | Papel |
|---|---|---|
| frontend-design | anthropics/skills | direção estética (auto) |
| impeccable | pbakaus/impeccable | processo de design, 23 comandos |
| emil-design-eng | emilkowalski/skills | motion/polish (auto) |
| review-animations | emilkowalski/skills | review de motion (manual) |
| supabase | supabase/agent-skills | guidance oficial (auto) |
| supabase-postgres-best-practices | supabase/agent-skills | Postgres perf (auto) |
| systematic-debugging | obra/superpowers | root cause antes de fixes |
| verification-before-completion | obra/superpowers | evidência antes de "feito" |
| ui-ux-pro-max | nextlevelbuilder/ui-ux-pro-max-skill | kickoff de projetos (manual) |

## Removido/rejeitado — NÃO reinstalar sem motivo novo

| O quê | Porquê |
|---|---|
| design-auto-pipeline (skill própria) | Auto-disparava em toda a UI, turns 2,3× mais lentos, orquestrava ferramentas não instaladas. Substituído pela secção "Workflow de design" do CLAUDE.md. |
| taste-skill | Regras rígidas redundantes/conflituosas com o frontend-design oficial. A versão atual (55k⭐) continua a ser regras estáticas — reavaliada e rejeitada em 2026-07-03. |
| output-skill | Os modelos atuais não truncam código; só alongava outputs (mais lento). |
| redesign-skill | Coberto pelo impeccable (critique → fix → polish → audit). |
| Plugins sanctum/leyline/abstract/conserve/watch | Sem uso real; o sanctum deixou referências mortas no ship durante semanas. |
| superpowers COMPLETO | A metodologia inteira (brainstorm→plan→TDD→review) é cerimónia para o estilo rápido do Tiago; reviews confirmam overhead em tarefas simples. Cherry-pick de 2 skills chega. |
| brand-guidelines (anthropics/skills) | Aplica a marca DA Anthropic (cores hardcoded). Por cliente, o equivalente certo é o DESIGN.md do `/impeccable init`. |
| Hook PostToolUse do impeccable | +até 5s por edit de UI. Enforcement via CLAUDE.md + audits manuais. Por projeto: `npx impeccable install` se um dia se quiser. |
| Conectores: Vercel MCP, Google Drive, mcp-registry (+ chrome/computer-use dormentes) | 0 usos no mês analisado; contexto inicial mais gordo em todas as sessões. |
| MCPs CLI antigos: magic, shadcn-ui, designlang, n8n, playwright, github, firebase | Substituídos pelo stack de skills + Preview, ou nunca usados. |
| statusline.sh | Não usado na build atual. |
| Automações (hooks de notificação, fewer-permission-prompts, Supabase advisors semanal) | Propostas no audit, recusadas pelo Tiago em 2026-07-03 — preferiu manter simples. Reavaliar se as esperas voltarem a doer. |

## Patches aplicados a terceiros (o installer reaplica-os)

- **ui-ux-pro-max**: `disable-model-invocation: true` + prefixo de kickoff na
  description. O upstream auto-dispara em QUALQUER trabalho de UI (47KB de
  SKILL.md ≈ 12k tokens por invocação) e chocaria com o resto do stack; assim
  só corre quando o Tiago escreve `/ui-ux-pro-max` no início de um projeto.
- **systematic-debugging**: removidos os ficheiros de teste internos do upstream
  (`test-*.md`, `CREATION-LOG.md`) — ruído.

## Notas de manutenção

- Atualizar externas: `bash setup/install-externals.sh` (ou re-correr `setup.sh`).
- Impeccable também atualiza via `npx impeccable update` (instala o hook — evitar).
- Antes de adicionar uma skill global nova: ela vale o custo de arranque em TODAS
  as sessões? Se é de stack/tarefa → catálogo per-project (`skills/`) via matchmaker.
