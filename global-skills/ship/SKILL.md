---
name: ship
description: Use when the user wants to stage, commit, push, and open a pull request in one shot. Triggers on "/ship", "ship it", "dá push e abre PR", "commit push e PR". One-shot release flow that delegates commit message generation to sanctum:commit-messages and PR description generation to PR-prep logic, without running the heavy quality gates (no tests, no docs, no code review).
---

# SKILL: ship

## Overview

**One-shot `stage → commit → push → open PR`** for when the user trusts the changes and just wants them up on GitHub with a proper Conventional Commit message and a PR description generated from the diff. No quality gates, no ceremony.

**Core principle:** Delegate the smart parts (message + PR body), skip the slow parts (tests, docs, reviews).

## When to Use

**Use when the user says:**
- `/ship`, "ship it", "dá push", "commit push e PR", "bora ship"
- They have local changes on a feature branch and want them on GitHub as a PR

**Do NOT use when:**
- The user asks for a review, tests, or docs update first → use `sanctum:prepare-pr` or `sanctum:pr-prep` instead
- The user is on `main` / `master` — STOP and ask them to create a branch first
- There are no changes (`git status` is clean) — tell the user, don't create an empty commit

## Workflow

Follow these steps in order. Do not skip. Do not batch.

### 1. Preflight (parallel)

Run these in parallel via a single message:
- `git status` (confirm dirty tree, no -uall)
- `git branch --show-current` (confirm NOT main/master)
- `git diff --stat` (size check — if huge, warn user before proceeding)
- `git log -5 --oneline` (style reference for commit message)
- `git remote get-url origin` (confirm remote exists)

**Stop conditions:**
- On `main` or `master` → ask user to create a feature branch first
- Clean working tree AND nothing unpushed → tell user there's nothing to ship
- Clean working tree but commits are unpushed → skip to step 3 (just push + PR)

### 2. Stage + commit

- `git add -A` (stage everything, including untracked)
- **Warn if any staged file looks like a secret** (`.env`, `credentials*`, `*.pem`, `*.key`) — stop and confirm before proceeding
- Generate the commit message by invoking **`sanctum:commit-messages`** (or `sanctum:commit-msg`) — do NOT write the message yourself. That skill knows the project's Conventional Commit conventions.
- Commit using a HEREDOC so multi-line messages format correctly:

```bash
git commit -m "$(cat <<'EOF'
<message from sanctum:commit-messages>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

- If the pre-commit hook fails: **fix the underlying issue**, re-stage, create a NEW commit. Never `--amend` or `--no-verify`.

### 3. Push

- If the current branch has no upstream: `git push -u origin <branch>`
- Otherwise: `git push`

### 4. Open PR

Check if a PR already exists for this branch first:

```bash
gh pr view --json number,url 2>/dev/null
```

**If a PR already exists:** stop. Tell the user the PR URL. Do NOT create a duplicate.

**If no PR exists:** generate title + body from the branch's commits and diff against the base branch (usually `main`). Reuse the PR-description logic from `sanctum:pr-prep` — read that skill's body-generation section, but **skip** its quality-gate steps (tests, docs, review).

The PR body should follow the repo's PR template if one exists at `.github/pull_request_template.md`. Otherwise:

```markdown
## Summary
<1-3 bullets — the "why", not the "what">

## Changes
<bullet list of notable changes, grouped logically>

## Test plan
- [ ] <item the reviewer should verify>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

Create the PR via HEREDOC:

```bash
gh pr create --title "<short title, <70 chars>" --body "$(cat <<'EOF'
<body here>
EOF
)"
```

### 5. Report back

Return the PR URL to the user. One line. Nothing else unless something failed.

## Quick Reference

| Step | Command | Notes |
|------|---------|-------|
| Preflight | `git status` + branch + diff --stat | Parallel |
| Stage | `git add -A` | Warn on secret-looking files |
| Commit msg | Invoke `sanctum:commit-messages` | Don't write it yourself |
| Commit | `git commit` via HEREDOC | Never `--amend`, never `--no-verify` |
| Push | `git push [-u origin <br>]` | `-u` only if no upstream |
| PR check | `gh pr view` | Skip create if exists |
| PR body | Reuse `sanctum:pr-prep` body logic | Skip its quality gates |
| PR create | `gh pr create` via HEREDOC | Return URL |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Writing commit message manually | Always delegate to `sanctum:commit-messages` |
| Running tests / docs / review | That's `prepare-pr`. This skill is the fast lane. |
| Using `--amend` on pre-commit failure | Create a NEW commit. Amend rewrites history. |
| Using `--no-verify` to skip hooks | Fix the underlying issue. Hooks exist for a reason. |
| `git add .` instead of `git add -A` | Same behavior here, but `-A` is explicit. Either works; be consistent. |
| Creating a PR when one already exists | Always `gh pr view` first. |
| Shipping from `main` | Stop. Ask the user to branch first. |
| Proceeding when diff includes `.env` or keys | Stop. Confirm with user. |

## Red Flags — STOP

- Current branch is `main` or `master` → stop
- Staged files match secret patterns (`.env`, `*.pem`, `credentials*`) → stop, confirm
- Pre-commit hook failed → fix root cause, don't bypass
- A PR already exists for this branch → don't duplicate, report URL
- User asked for "ship with tests" or "ship with review" → wrong skill, use `sanctum:prepare-pr`

## Scope Boundary

This skill is **deliberately minimal**. If you find yourself wanting to:
- run the test suite
- update docs
- run a code review
- bump versions
- generate changelogs

…you are using the wrong skill. Stop and switch to `sanctum:prepare-pr` or `sanctum:pr-prep`.
