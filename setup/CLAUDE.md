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
- Commits e push só no branch desta sessão (sem pré-confirmar); nunca merjes a `main` a partir do branch de OUTRA sessão/chat. Política de quando merjar → secção "Confirmações de ship / merge" abaixo.
- Ao entrar num worktree de um projeto Node: o worktree nasce SEM os ficheiros gitignored — copia da pasta principal o que for preciso (`.env.local`, `.env`) e corre `npm install` antes de arrancar dev servers. Faz isto sem perguntar.

## Confirmações de ship / merge (auto-merge por default)
- **Default = auto-merge.** Quando acabas um bloco de alterações que dá para shipar, corre `/ship-merge` SOZINHO — sem perguntar e sem esperar por palavra-gatilho. Acabei → commit → push → PR → squash-merge a `main`. Nunca perguntes "posso dar merge?".
- **Único caso em que NÃO merjas logo: o Tiago disse EXPLICITAMENTE para não** ("não dês merge ainda", "ainda não merjes", "só commita", "faz X Y Z primeiro"). Aí fazes o trabalho todo e ESPERAS — só merjas quando ele disser. (Sem alterações shipáveis — research, perguntas, WIP — não há nada para merjar.)
- Commits e push de rotina também sem pré-confirmar — faz e reporta.
- Guardrails que se MANTÊM (é correção, não pedir permissão): merja SÓ o branch/worktree DESTA sessão — nunca o de outro chat nem mudanças que não fizeste tu (regras de "Git & sessões paralelas" acima). E o próprio `/ship-merge` já pára sozinho em conflito, CI vermelho, changes-requested ou secrets no diff.
- **Só pedes go/no-go quando um bloqueio real acima te trava** e precisas da decisão dele — não para merges de rotina. Aí, e só aí, pede com botão (AskUserQuestion) no FIM — "Sim" / "Não" — + `PushNotification` a dizer QUAL o chat/branch está à espera. Nunca enterres o pedido no meio do texto.

## Subagentes & contexto (o recurso escasso é o contexto do principal, não o custo)
O Tiago é subscritor — tokens não são dinheiro. O que dói é **encher o contexto do principal** e ser obrigado a dar `/clear` a meio de um raciocínio. Otimiza para isso.

**O critério, numa pergunta:** *o que volta é uma CONCLUSÃO ou é MATÉRIA-PRIMA que vou ter de editar a seguir?*
- **Conclusão** (um resumo, uma lista de achados, um ficheiro:linha, um veredito) → **delega**. O subagente pode queimar 150k a ler o que quiser; ao principal chegam 2k.
- **Matéria-prima** (os ficheiros que vais mesmo editar) → **lê tu**. Ias precisar deles em contexto de qualquer forma; delegar só acrescenta uma cópia e o briefing tax.

Daqui sai:
- **Editar é sempre do principal, inline.** Features, fixes, refactors com dependências — nunca delegados (fragmenta o contexto e obriga a re-explicar).
- **Compreender/mapear é delegável, mesmo dentro de uma implementação.** "Como funciona X através destes 12 ficheiros?", "onde é que isto é usado?", "porque falha este teste?" → subagente ou `explorador`, e volta a resposta em vez dos 12 ficheiros. Isto vale MESMO quando a seguir vais escrever código: só não delegues a leitura dos ficheiros que vais editar.
- Delega sempre: review pré-merge (`revisor`), auditoria read-only (`seguranca`, `dados`, `design`), correr a app (`testador`), research (`investigador`), busca ficheiro:linha (`explorador`), edição mecânica em massa bem especificada (`engenheiro`, em worktree).
- Skill pesada + trabalho delegado → invoca-se DENTRO do subagente; o principal nunca carrega o conteúdo dela.
- Output de comandos ruidosos (build, testes, logs longos) → filtra no shell (`| tail`, `| grep`) em vez de despejar tudo no contexto.
- Workflows multi-agente: formato compacto (2 revisores + 1 verificador único com todos os findings). Nunca verify paralelo por finding — empanca (medido no Leme: 3h45 vs 11 min).
- Conversa longa + assunto NOVO → fecha e abre limpa (`/clear`; no Leme, "nova"). Assunto novo é o gatilho, não o número de tokens: dar clear a meio de um raciocínio é a perda que queremos evitar.

Ordem de grandeza (Leme, 2026-07-28): a critique de UI custou **315k tokens** aos dois subagentes e entrou no principal como **~4k de relatório** — 1,3%. Feita inline, tinha comido o contexto todo.

## Skills & skillsbase
- Fonte de verdade do setup: https://github.com/itsjustiago/skillsbase — bootstrap da máquina (`setup.sh`) + catálogo per-project. Depois de mudanças relevantes a skills/config globais, atualiza esse repo (e vê o DECISIONS.md antes de re-sugerir algo que já foi rejeitado).
- `skill-matchmaker` procura no catálogo próprio ("o que já tenho para isto?"); `skill-scout` procura no ecossistema público ("o que existe que não conheço?").
- Skill de stack/tarefa específica → per-project via matchmaker; capacidade genuinamente global → `~/.claude/skills/` (sê conservador — global é custo de arranque em todas as sessões).
- "Põe esta máquina igual ao skillsbase" → `bash sync.sh` (dry-run), mostra o diff ao Tiago, aplica só com OK (`--apply`).
