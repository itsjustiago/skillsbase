---
name: preclear
autor: tiago
description: Guarda o estado da tarefa e limpa o chat — o chat novo continua daqui sem re-explicar.
disable-model-invocation: true
allowed-tools: Bash(python3 ~/.claude/hooks/estado_sessao.py *) Bash(git status *) Bash(git branch *) Edit(~/.claude/estado/**) mcp__ccd_session_mgmt__clear_session
---

# /preclear

O Tiago vai limpar este chat. Tu guardas o estado, o app limpa, e o chat novo recebe
o ficheiro pelo hook SessionStart e retoma daqui.

## Estado atual

!`python3 ~/.claude/hooks/estado_sessao.py --mostrar`

## 1. Reescreve esse ficheiro

Inteiro — não acrescentes ao antigo; o que do antigo ainda valer, fica. Curto, no
máximo ~60 linhas:

- **Objetivo** — a tarefa, em 1–2 frases.
- **Decisões** — o que ficou decidido e porquê, sobretudo o que o Tiago escolheu.
- **Feito** — com ficheiros, branches, PRs.
- **Próximo** — o passo exato a seguir. O que foi oferecido mas NÃO aprovado, marcado como tal.
- **Em fundo** — agentes e processos ainda a correr: nome/ID, o que fazem, onde cai o
  resultado, PID se foste tu a lançar (na dúvida, `ListAgents`). "Nada" se nada.
- **Git** — branch e mudanças por commitar (`git status --short`).

Escreve para quem não viu esta conversa: caminhos absolutos, nada de "aquilo de há bocado".

## 2. Limpa

Chama `mcp__ccd_session_mgmt__clear_session` com `session_id: "self"` (se estiver
diferido, carrega-o antes com ToolSearch). O clear acontece quando o turno acaba.
Sem essa ferramenta (terminal): diz "Estado guardado — faz /clear." e pára.

## 3. Resposta

Uma linha: "Estado guardado, a limpar." Nada depois disso — uma mensagem a seguir cancela o clear.
