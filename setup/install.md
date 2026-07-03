# Instalação manual (fallback do setup.sh)

O caminho normal é `bash setup.sh` na raiz do repo (Git Bash no Windows).
Se precisares de fazer à mão, é isto que o script faz:

## 1. Pré-requisitos

- **Claude Code** (desktop app ou CLI) — https://claude.com/claude-code
- **git** e **node** (LTS) no PATH
- **python 3** — só para a pesquisa do `ui-ux-pro-max` (opcional até usares)
- Windows: correr tudo em **Git Bash** (vem com o git)

## 2. Skills próprias e comandos

Copiar cada pasta de `global-skills/` para `~/.claude/skills/` e os `.md` de
`commands/` para `~/.claude/commands/`.

## 3. Skills externas

```bash
bash setup/install-externals.sh
```

Clona as fontes originais (Anthropic, pbakaus, Emil Kowalski, Supabase,
obra/superpowers, nextlevelbuilder) e instala as 9 skills externas, aplicando
os patches documentados em `DECISIONS.md` (ex.: ui-ux-pro-max fica manual-only).
Re-correr este script = atualizar as externas.

## 4. Configs

- `setup/CLAUDE.md` → `~/.claude/CLAUDE.md` (faz backup do existente se diferir)
- `setup/settings.json` → `~/.claude/settings.json` (só se não existir)

## 5. Pós-instalação

1. Reinicia o Claude Code.
2. Desktop app: Settings → Connectors → liga o **Supabase** (só esse — ver `setup/mcps.md`).
3. Num projeto novo: `/ui-ux-pro-max <descrição>` → `/impeccable init`.
4. Em qualquer projeto: `/skills-suggest` instala skills do catálogo per-project.
