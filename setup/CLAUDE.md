# Preferências globais — Tiago

## Língua e ritmo
- Responde sempre em PT-PT.
- Avança com defaults sensatos e decide tu; lista no fim as decisões tomadas. Pergunta no máximo 1 coisa por tarefa, e só se for genuinamente bloqueante (com recomendação marcada).
- Turns curtos e objetivos; não insistas em verificações que falham em loop.

## Consistência de design (aplica-se a QUALQUER projeto)
- Antes de criar ou estilizar UI, descobre o design system do projeto: `components/ui` (ou `src/components/ui`), tokens (`globals.css` `@theme`, `tailwind.config.*`, `tokens.ts`, tema Chakra) e docs (`DESIGN.md`, `DESIGN_SYSTEM.md`, `PRODUCT.md`). Usa-o.
- Reutiliza SEMPRE o componente partilhado que já existe (Button, Card, Input, Badge…). Falta uma variante? Estende o componente partilhado — nunca dupliques a recipe inline na página.
- Cores, spacing, radius e shadows vêm dos tokens do projeto — nunca hex/valores arbitrários soltos em páginas.
- Elemento novo usado 2+ vezes → extrai primitive partilhada em vez de copy-paste.
- Projeto sem design system: propõe criar primitives + tokens primeiro (`/impeccable init` + `/impeccable extract`) em vez de espalhar classes à mão.

## Workflow de design
- Projeto novo: 1) o Tiago corre `/ui-ux-pro-max <descrição>` (direção: estilo+paleta+fontes), 2) `/impeccable init` fixa a direção em PRODUCT.md/DESIGN.md, 3) build normal.
- UI significativa concluída → sugere `/impeccable critique`; pré-launch → `/impeccable audit`; motion novo → `/review-animations`.
- Drift acumulado → `/impeccable extract` para consolidar primitives.

## Git & sessões paralelas
- O Tiago costuma ter VÁRIOS chats em paralelo no mesmo repo. Uma sessão = um branch: antes de qualquer trabalho git, corre `git branch --show-current`; se o branch atual não é o desta tarefa, NÃO o uses — cria o branch da tarefa ou entra num worktree.
- Nunca faças checkout, merge ou push de um branch de outra tarefa/sessão, nem "aproveites" mudanças no working tree que não fizeste tu — são provavelmente de outro chat; avisa o Tiago em vez de misturar.
- Ao primeiro sinal de sessões paralelas no mesmo repo (ele diz que tem outro chat, o working tree muda sozinho, o branch salta entre turns), muda-te para um git worktree isolado (EnterWorktree) e continua o trabalho lá.
- Commits e push só no branch desta sessão (sem pré-confirmar); em main só quando ele disser ship/merge — isso É o pedido explícito, nunca por iniciativa tua.
- Ao entrar num worktree de um projeto Node: o worktree nasce SEM os ficheiros gitignored — copia da pasta principal o que for preciso (`.env.local`, `.env`) e corre `npm install` antes de arrancar dev servers. Faz isto sem perguntar.

## Confirmações de ship / merge (não voltes a pedir o que já pedi)
- **Default = executa, não pré-confirmes.** Palavra-gatilho de release do Tiago — "ship", "merge", "dá merge", "ship merge", "manda para main", "bora ship" — corre LOGO o `/ship` ou `/ship-merge` apropriado. Ele já pediu; não perguntes "posso dar merge?".
- Commits e push de rotina no branch DESTA sessão também não precisam de pré-confirmação — faz e reporta.
- `/ship` (commit → push → PR, pára no PR) é sempre seguro: corre sem perguntar. Nada em `main`.
- `/ship-merge` (ship + espera CI + review leve + squash-merge + apaga branch remoto) corre logo quando ele pedir ship/merge. Confia nos guardrails do próprio skill — ele pára sozinho em conflito, CI vermelho, changes-requested ou secrets no diff.
- **Sem palavra-gatilho, NÃO faças merge a `main` por iniciativa própria.** Acaba as alterações, mostra o que fizeste, e OFERECE o merge (formato abaixo). Isto protege contra mandar para `main` o branch errado com vários chats no mesmo repo — mantêm-se TODAS as regras de "Git & sessões paralelas" acima (branch certo, worktree, nunca o branch de outro chat).
- **Quando MESMO tiveres de pedir go/no-go** (bloqueio real, ou o momento "está pronto, dou merge?"): pede SEMPRE com botão (AskUserQuestion) no FIM — "Sim, merge" / "Não" — e dispara um `PushNotification` a dizer QUAL o chat/branch está à espera. Nunca enterres o pedido no meio do texto. (Se o harness achar que ele está ativo neste terminal, a notificação auto-salta — sem spam, tudo bem.)

## Skills & skillsbase
- Fonte de verdade do setup: https://github.com/itsjustiago/skillsbase — bootstrap da máquina (`setup.sh`) + catálogo per-project. Depois de mudanças relevantes a skills/config globais, atualiza esse repo (e vê o DECISIONS.md antes de re-sugerir algo que já foi rejeitado).
- `skill-matchmaker` procura no catálogo próprio ("o que já tenho para isto?"); `skill-scout` procura no ecossistema público ("o que existe que não conheço?").
- Skill de stack/tarefa específica → per-project via matchmaker; capacidade genuinamente global → `~/.claude/skills/` (sê conservador — global é custo de arranque em todas as sessões).
- "Põe esta máquina igual ao skillsbase" → `bash sync.sh` (dry-run), mostra o diff ao Tiago, aplica só com OK (`--apply`).
