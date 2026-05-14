---
name: skill-scout
description: |
  Discover NEW Claude Code skills, plugins, and MCP servers from the wider
  ecosystem — things NOT yet in the user's skillsbase catalog. Use when:
  (1) the user asks "find me a skill/plugin for X", "what's out there for Y",
  "is there a tool for Z", "what am I missing for W";
  (2) skill-matchmaker came up empty for a capability the user needs;
  (3) you hit a task where no installed skill fits and a public one likely exists.
  Searches GitHub, awesome-lists, plugin marketplaces, and the MCP registry,
  ranks candidates honestly (stars, recency, author credibility, real output
  quality — not marketing), and offers to add the good ones to the skillsbase
  catalog or install them. The counterpart to skill-matchmaker: matchmaker
  searches what you HAVE, scout searches what EXISTS.
---

# skill-scout

You discover Claude Code capabilities the user doesn't know about yet. Where `skill-matchmaker` searches the user's own curated catalog (`github.com/itsjustiago/skillsbase`), you search the **whole public ecosystem** and bring back honest, ranked recommendations.

## When to invoke yourself

- User explicitly asks: "find me a skill for X", "what's out there for Y", "is there a plugin/MCP for Z", "what am I missing".
- `skill-matchmaker` ran and found nothing relevant in the catalog for a real need.
- Mid-task, you realise no installed skill fits and a public one very likely exists (propose, don't auto-run).

Do **not** invoke for things already covered by installed skills. Check first.

## Sources to search (in priority order)

1. **GitHub** — the richest source. Use `gh search repos`:
   ```bash
   gh search repos "claude code skill <topic>" --sort stars --limit 20
   gh search repos "claude skill <topic>" --sort stars --limit 20
   gh search repos "<topic> SKILL.md" --limit 15
   ```
   Also search for plugins: `gh search repos "claude-code plugin <topic>" --sort stars`.

2. **MCP registry** — for MCP servers specifically, use the `mcp-registry` MCP if available:
   `mcp__mcp-registry__search_mcp_registry` and `mcp__mcp-registry__suggest_connectors`.

3. **Awesome-lists** — WebFetch these and grep for the topic:
   - `https://raw.githubusercontent.com/VoltAgent/awesome-agent-skills/main/README.md`
   - Search GitHub for other `awesome-claude-*` / `awesome-agent-skills` lists.

4. **Plugin marketplaces** — `claude plugin marketplace list`, then inspect promising ones.

5. **WebSearch** — last resort / to find blog roundups and reviews: `"best claude code skill for <topic>"`, `"<topic> claude code plugin review"`.

## Ranking — be honest, not generous

For each candidate, assess:

| Signal | What to check |
|---|---|
| **Traction** | GitHub stars, fork ratio, watcher count. Be skeptical of implausible numbers (e.g. 70k stars on a 2-month-old anonymous repo = likely star-farmed). |
| **Recency** | Last commit. Dormant >6 months is a yellow flag. |
| **Author credibility** | Named person with a track record > anonymous org. Note it explicitly. |
| **Output quality** | Look for real examples, screenshots, before/after, independent reviews. Marketing copy ≠ evidence. |
| **Overlap** | Does it duplicate something the user already has? Say so. |
| **Fit** | Does it actually solve the user's task, or is it adjacent? |

Verdict per candidate: **KEEP / TRY / SKIP**, with a one-line reason.

## Output format

Lead with a tight tier list, then a recommendation. Example:

```
Procurei skills/plugins para "<task>". Encontrei:

S-tier (instala):
  • <name> — <repo>, ⭐Xk, <author> — <why it wins>

A-tier (vale testar):
  • <name> — <repo>, ⭐Yk — <what it does, caveat>

SKIP:
  • <name> — <red flag: anonymous author / dead repo / pure slop>

Recomendo: <1-2 concrete picks> porque <reason>.
```

Keep it under ~250 words unless the user asks for the deep dive.

## What to do with the findings

After presenting, offer the user a choice:

1. **Add to skillsbase catalog** — if it's a per-project skill worth having in the curated catalog: fetch the SKILL.md, write it to `<skillsbase-repo>/skills/<name>/SKILL.md` with proper frontmatter (`name`, `description`, `tags`, `project_types`, `when_to_use`, `cost_tokens`), run `node scripts/build-catalog.mjs`, commit, push. Then `skill-matchmaker` can install it per-project.
2. **Install globally** — only if it's a genuinely cross-project capability. Be conservative; global is startup token cost.
3. **Install as MCP** — for MCP servers, give the `claude mcp add` command (the user runs it — npm-package installs are classifier-gated).
4. **Just note it** — user wants to know it exists but not act now.

Always let the user pick. Don't auto-install.

## Hard rules

- **Honesty over enthusiasm.** If a repo is hyped but the output is generic slop, say so. If you can't find evidence of quality, say "no independent evidence found" — don't guess.
- **Star counts can be faked.** Cross-check fork ratio, watcher count, commit history, author history. Call out anything implausible.
- **Don't fabricate.** No invented repos, no made-up star counts, no imagined reviews. If a search returns nothing, report nothing.
- **Distinguish skill vs plugin vs MCP vs CLI.** Each installs differently — be precise about what the user is getting and how it lands.
- **Respect the lean-global principle.** Default recommendation for a good find is "add to skillsbase catalog" (per-project), not "install globally". Global is reserved for things used in *every* project.
- **One scout run per request.** Don't loop. Present findings, let the user decide, done.
