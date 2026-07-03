# Conectores MCP — referência da build

A build atual corre no **Claude Code desktop app** e usa os connectors do app,
não `claude mcp add`. O princípio (audit jul/2026): cada conector engorda o
contexto inicial de TODAS as sessões (~42k tokens na build antiga) — só se liga
o que se usa de facto.

## Essencial (liga isto)

- **Supabase** — Settings → Connectors → Supabase (OAuth no browser).
  Par das skills `supabase` / `supabase-postgres-best-practices`. Usado
  intensamente nos projetos de clientes (soma-seg, etc.).

## Já vem com o app (nada a fazer)

- **Claude Preview** — dev server + screenshots + inspeção (o loop visual do design).
- Ferramentas de sessão/visualização internas.

## Removidos no audit de jul/2026 — não religar por hábito

| Conector | Porquê saiu |
|---|---|
| Vercel MCP | 0 usos — os deploys vão por GitHub Actions |
| Google Drive | 0 usos |
| mcp-registry | 0 usos |
| claude-in-chrome | religa só quando precisares de automação de browser |
| computer-use | religa só quando precisares de automação de desktop |

## Descontinuados da build antiga (via CLI) — ver DECISIONS.md

magic (21st.dev), shadcn-ui, designlang, n8n-mcp, playwright, github, firebase.
O stack de design atual (frontend-design + impeccable + emil + ui-ux-pro-max +
Preview) substitui os três primeiros; os restantes nunca ganharam uso real.
