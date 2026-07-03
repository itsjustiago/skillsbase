# Design — o stack e o workflow (build jul/2026)

> Substitui o antigo "design pipeline" (design-auto-pipeline + taste-skill +
> redesign-skill + MCPs magic/designlang) — ver DECISIONS.md para o porquê da troca.

## O stack (5 skills, cada uma numa dimensão)

| Skill | Papel | Quando atua |
|---|---|---|
| **frontend-design** (Anthropic) | Direção estética comprometida, anti-template | Auto, em qualquer UI |
| **impeccable** (pbakaus) | Processo: critique/audit/polish/extract + DESIGN.md por projeto + detector de 45 anti-patterns | Auto + `/impeccable <cmd>` (23 comandos) |
| **emil-design-eng** (Emil Kowalski) | Motion, micro-interactions, polish invisível | Auto, quando relevante |
| **review-animations** (Emil Kowalski) | Review rigorosa de animações ("approval is earned") | Só manual |
| **ui-ux-pro-max** (patched manual-only) | Base de dados de direções: 67 estilos, 161 paletas, 57 pares de fontes, reasoning por tipo de produto | Só no kickoff, `/ui-ux-pro-max` |

O sexto elemento é o **loop de preview** (Claude Preview, built-in no app):
renderizar, ver o screenshot, corrigir. Nenhuma skill substitui olhar para o
resultado real.

## Workflow

**Projeto novo (o remédio para "o primeiro design sai sempre lixo"):**
1. `/ui-ux-pro-max <descrição do produto>` → direção concreta e fundamentada
2. `/impeccable init` → PRODUCT.md + DESIGN.md (todos os comandos passam a respeitá-los)
3. Build normal — as skills automáticas cuidam da direção e do motion

**Durante o trabalho:** a regra de consistência do CLAUDE.md global obriga a
reutilizar `components/ui` + tokens do projeto — nunca recriar botões/cards
inline. Elemento repetido 2+ vezes → primitive partilhada.

**Fecho:** `/impeccable critique` em UI significativa; `/impeccable audit`
pré-launch; `/review-animations` quando há motion novo.

**Manutenção:** `/impeccable extract` consolida padrões repetidos em primitives
quando o drift se acumula.

## Referências reais ("faz tipo X.com")

O grounding mais forte é dar referências concretas: URLs ou screenshots de
sites de que gostas. O agente vê e extrai a linguagem visual real — não é
preciso skill para isto.

## Hook automático do impeccable

Existe mas NÃO se instala por defeito (+até ~5s por edit de UI). Para o ativar
num projeto específico: `npx impeccable install` na raiz desse projeto.
