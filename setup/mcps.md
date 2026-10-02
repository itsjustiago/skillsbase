# MCP — referência da build

A build documenta **um** MCP: o do Supabase, par das skills `supabase` e
`supabase-postgres-best-practices`. Cada servidor MCP ligado engorda o contexto
inicial de todas as sessões — liga só o que usas.

## Supabase

Via CLI (read-only, restrito a um projeto):

```bash
claude mcp add supabase \
  --env SUPABASE_ACCESS_TOKEN=<TOKEN> \
  -- npx -y @supabase/mcp-server-supabase@latest --read-only --project-ref=<PROJECT_REF>
```

- `<PROJECT_REF>` — referência do projeto (Supabase dashboard → Project Settings → General).
- `<TOKEN>` — Personal Access Token (Supabase dashboard → Account → Access Tokens).

Ou, no desktop app: Settings → Connectors → Supabase (OAuth no browser).

Nunca commites valores reais: o token vive só no ambiente/config local da máquina.
