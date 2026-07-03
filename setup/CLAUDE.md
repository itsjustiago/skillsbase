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

## Skills & skillsbase
- Fonte de verdade do setup: https://github.com/itsjustiago/skillsbase — bootstrap da máquina (`setup.sh`) + catálogo per-project. Depois de mudanças relevantes a skills/config globais, atualiza esse repo (e vê o DECISIONS.md antes de re-sugerir algo que já foi rejeitado).
- `skill-matchmaker` procura no catálogo próprio ("o que já tenho para isto?"); `skill-scout` procura no ecossistema público ("o que existe que não conheço?").
- Skill de stack/tarefa específica → per-project via matchmaker; capacidade genuinamente global → `~/.claude/skills/` (sê conservador — global é custo de arranque em todas as sessões).
- "Põe esta máquina igual ao skillsbase" → `bash sync.sh` (dry-run), mostra o diff ao Tiago, aplica só com OK (`--apply`).
