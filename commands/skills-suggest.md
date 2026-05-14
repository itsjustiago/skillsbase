---
description: Consult the skillsbase catalog and propose project-relevant skills for the current project.
---

Invoca a skill `skill-matchmaker` para:

1. Fazer fingerprint do projeto atual (read `package.json` e configs).
2. Fazer fetch a `https://raw.githubusercontent.com/itsjustiago/skillsbase/main/catalog.json`.
3. Pontuar skills do catálogo contra o fingerprint.
4. Apresentar as recomendações com custo em tokens.
5. Instalar as que o utilizador aprovar em `<cwd>/.claude/skills/`.

Segue o protocolo da skill exatamente. Se ela já correu nesta sessão, diz isso ao utilizador em vez de repetir — uma proposta por sessão chega.
