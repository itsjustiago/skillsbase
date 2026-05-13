---
name: second-opinion
description: "Runs external LLM code reviews (OpenAI Codex or Google Gemini CLI) on uncommitted changes, branch diffs, or specific commits. Provides independent review powered by a separate model."
tags: [review, code-review, quality, testing]
project_types: [any]
when_to_use: "Getting a second opinion on code changes from a different model, reviewing branch diffs before opening a PR, checking uncommitted work for issues before committing, or running focused reviews on security, performance, or error handling."
cost_tokens: 3200
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
---

# Second Opinion

Shell out to external LLM CLIs for an independent code review powered by a separate model. Supports OpenAI Codex CLI and Google Gemini CLI.

## When to Use

- Getting a second opinion on code changes from a different model
- Reviewing branch diffs before opening a PR
- Checking uncommitted work for issues before committing
- Running a focused review (security, performance, error handling)
- Comparing review output from multiple models

## When NOT to Use

- Neither Codex CLI nor Gemini CLI is installed
- No API key or subscription configured for either tool
- Reviewing non-code files (documentation, config)
- You want Claude's own review (just ask Claude directly)

## Invocation Process

### 1. Gather Context Interactively

Use `AskUserQuestion` to collect review parameters in one shot. Combine all applicable questions into a single `AskUserQuestion` call (max 4 questions).

**Question 1 — Tool** (skip if user already specified):
- Both Codex and Gemini (Recommended)
- Codex only
- Gemini only

**Question 2 — Scope** (skip if user already specified):
- Uncommitted changes
- Branch diff vs main
- Specific commit

**Question 3 — Project context** (skip if neither CLAUDE.md nor AGENTS.md exists):
- Yes, include it
- No, standard review

**Question 4 — Review focus** (always ask):
- General review
- Security & auth
- Performance
- Error handling

### 2. Run the Tool Directly

Do not pre-check tool availability. Run the selected tool immediately. If the command fails with "command not found" or an extension is missing, report the install command and skip that tool.

### 3. Diff Preview

After collecting answers, show the diff stats. If the diff is empty, stop. If the diff is very large (>2000 lines), warn the user and ask whether to proceed.

### 4. Running Both

When the user picks "Both":
1. Run Codex and Gemini in parallel — issue both Bash tool calls in a single response
2. Collect both results and present with clear headers
3. Summarize where the two reviews agree and differ

## Diff Scope Detection

**For uncommitted (tracked + untracked):**
```bash
git diff --stat HEAD
git ls-files --others --exclude-standard
```

**For branch diff:**
```bash
git diff --stat <branch>...HEAD
```

**For specific commit:**
```bash
git diff --stat <sha>~1..<sha>
```

## Auto-detect Default Branch

For branch diff scope:
```bash
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main
```

## Error Handling

| Error | Action |
|-------|--------|
| `codex: command not found` | Tell user: `npm i -g @openai/codex` |
| `gemini: command not found` | Tell user: `npm i -g @google/gemini-cli` |
| Extension missing | Tell user install command |
| Model auth error | Inform user and suggest narrowing diff |
| Empty diff | Tell user there are no changes to review |
| Timeout | Inform user and suggest narrowing scope |

## Safety Note

Gemini CLI is invoked with `--yolo`, which auto-approves all tool calls without confirmation. This is required for headless (non-interactive) operation.
