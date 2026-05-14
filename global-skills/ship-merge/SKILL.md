---
name: ship-merge
description: Use when the user wants the FULL one-shot release - stage, commit, push, open PR, check conflicts, wait for CI, light review, squash-merge to main, and clean up the branch. Triggers on "/ship-merge", "ship and merge", "dá ship e merge", "ship até ao fim", "ship merge it". Extends the `ship` skill with PR review + auto-merge. Does NOT run heavy quality gates (no test suite execution, no docs updates, no full code review) — for that use `sanctum:prepare-pr`.
---

# SKILL: ship-merge

## Overview

**One-shot `stage → commit → push → PR → review → squash-merge`** for when the user trusts the changes and just wants them landed on `main` with a proper Conventional Commit message, a generated PR description, a conflict/CI check, a light review, and branch cleanup.

**Core principle:** Reuse the `/ship` flow as-is for steps 1–4, then extend with conflict check + CI wait + light review + squash merge + branch delete.

This skill does NOT replace `/ship`. `/ship` remains the fast lane that stops after the PR is opened. `/ship-merge` is the full lane for the "I trust this, just land it" workflow.

## When to Use

**Use when the user says:**
- `/ship-merge`, "ship and merge", "dá ship e merge", "ship até ao fim", "ship merge it"
- They have local changes on a feature branch and want them **landed on `main`** in one shot

**Do NOT use when:**
- The user says `/ship` or "ship it" without "merge" — that's the fast lane, stop after PR creation
- The user asks for tests, docs, or a thorough review first → use `sanctum:prepare-pr`
- The user is on `main` / `master` — STOP and ask them to create a branch first
- There are no changes and nothing unpushed — tell the user, don't force a merge

## Workflow

Follow these steps in order. Do not skip. Do not parallelize across steps (you can parallelize within step 1).

### Steps 1–4: Delegate to the `/ship` flow

Execute exactly the steps from the `ship` skill (`C:\Users\tiago\.claude\skills\ship\SKILL.md`):

1. **Preflight** (parallel: `git status`, `git branch --show-current`, `git diff --stat`, `git log -5 --oneline`, `git remote get-url origin`). Stop conditions: on `main`/`master`, or clean tree AND nothing unpushed.
2. **Stage + commit** — `git add -A`, secret-file check, invoke `sanctum:commit-messages` for the message, commit via HEREDOC. Never `--amend`, never `--no-verify`.
3. **Push** — `git push -u origin <branch>` if no upstream, else `git push`.
4. **Open PR** — `gh pr view` first; if one exists, reuse it; otherwise create via `gh pr create` using `sanctum:pr-prep` body logic (skip its quality gates).

After step 4, capture the PR number and URL:

```bash
gh pr view --json number,url,headRefName
```

Save `number` (let's call it `<num>`) and `headRefName` (let's call it `<branch>`) for the next steps.

### Step 5: Conflict check + CI wait

Check mergeable state and CI rollup:

```bash
gh pr view <num> --json mergeable,mergeStateStatus,statusCheckRollup,reviewDecision
```

**Stop conditions (report and halt, do not attempt merge):**

| Condition | Action |
|-----------|--------|
| `mergeable == "CONFLICTING"` | Report to user with conflicting files (from `gh pr view --json files`). Tell them to resolve locally and re-run `/ship-merge`. |
| `reviewDecision == "CHANGES_REQUESTED"` | Report the reviewer. Tell the user to address feedback first. |
| Any check in `statusCheckRollup` has `conclusion == "FAILURE"` | Report the failed check name + URL. Do not merge. |

**If checks are still pending:**

Poll with `gh pr checks <num>` (up to ~10 minutes, 30s between polls). Stop on first conclusive state. If it times out, report the pending checks and tell the user to re-run once they settle.

```bash
gh pr checks <num>
```

Proceed only when `mergeable == "MERGEABLE"` AND (`statusCheckRollup` is empty OR all checks are `SUCCESS`/`NEUTRAL`/`SKIPPED`).

### Step 6: Light review

This is NOT a full code review. Do not invoke `sanctum:pr-review` (too heavy for this skill). Instead, do an inline diff scan:

```bash
gh pr diff <num>
gh pr view <num> --json files,additions,deletions
```

**Blockers (STOP and ask the user before continuing):**
- Any file in the diff matches secret patterns: `.env`, `credentials*`, `*.pem`, `*.key`, `*.secret`, `id_rsa*`
- Clearly committed generated/vendored trees: `node_modules/`, `.next/`, `dist/`, `build/`, `.vercel/`, `coverage/`

**Warnings (list them to the user, but proceed):**
- Total diff > 1000 lines
- Lines added contain `console.log(`, `debugger;`, `TODO`, `FIXME`, `XXX` (heuristic, not exhaustive)
- Any binary files added unexpectedly

Report the review as a short summary before merging:

```
Review: <N> files, +<adds> -<dels>. <warnings if any, else "no issues found">.
```

### Step 7: Squash-merge + delete branch

Merge with squash + auto + delete-branch:

```bash
gh pr merge <num> --squash --delete-branch --auto
```

- `--squash` — the chosen strategy for this project (one commit per PR on `main`)
- `--delete-branch` — deletes the remote branch after merge
- `--auto` — defense-in-depth: if any checks are still finalizing, GitHub only merges once they all pass

If `--auto` is not available on the repo (e.g., auto-merge disabled in settings), fall back to:

```bash
gh pr merge <num> --squash --delete-branch
```

### Step 8: Local cleanup

Sync local `main` and remove the local branch:

```bash
git checkout main
git pull --ff-only
git branch -d <branch>
```

- `git branch -d` (lowercase) refuses to delete an unmerged branch. Since we just squash-merged, the local branch will look "unmerged" to git (squash rewrites history). If `-d` refuses, do NOT auto-fall-back to `-D`. Instead, report to the user: *"Branch `<branch>` merged as squash on remote — local branch still has original commits. Delete with `git branch -D <branch>` when you're ready."*

### Step 9: Report back

One line to the user:

```
<PR URL> — merged to main (squash), branch <branch> deleted remote + local.
```

If local branch deletion was skipped, adjust:

```
<PR URL> — merged to main (squash), remote branch deleted; local branch kept (squash-merge is unmerged to git).
```

## Quick Reference

| Step | Command | Notes |
|------|---------|-------|
| 1. Preflight | See `/ship` skill | Parallel |
| 2. Commit | `sanctum:commit-messages` + HEREDOC | Never `--amend`/`--no-verify` |
| 3. Push | `git push [-u origin <br>]` | `-u` only if no upstream |
| 4. PR | `gh pr create` (or reuse existing) | Skip if one exists |
| 5. Merge state | `gh pr view --json mergeable,...` | Stop on CONFLICTING/failing checks |
| 5b. CI wait | `gh pr checks <num>` (poll ~10min) | Stop on first conclusive state |
| 6. Light review | `gh pr diff` + pattern scan | Secret patterns = blocker |
| 7. Merge | `gh pr merge --squash --delete-branch --auto` | Fallback without `--auto` if disabled |
| 8. Local cleanup | `git checkout main && git pull --ff-only && git branch -d <br>` | Don't auto-force-delete |
| 9. Report | PR URL + merge status | One line |

## Red Flags — STOP

- Branch is `main` or `master`
- Staged files match secret patterns (`.env`, `*.pem`, `credentials*`, `*.key`, `*.secret`, `id_rsa*`)
- Pre-commit hook failed (fix the underlying cause, don't bypass)
- `mergeable == "CONFLICTING"` — user must resolve locally
- CI check failed — don't merge broken code
- `reviewDecision == "CHANGES_REQUESTED"` — address feedback first
- Review blocker (secrets/generated trees in diff)

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Forcing `--admin` on merge to bypass failing checks | Don't. If checks fail, the user must fix them. |
| Using `git branch -D` when `-d` refuses | Report it to the user, let them decide. Squash-merge leaves local looking unmerged by design. |
| Running full `sanctum:pr-review` here | Too heavy — use the inline diff scan instead. For full review, user should use `sanctum:prepare-pr`. |
| Merging with pending checks by polling `--auto` off | Keep `--auto` on when available; it's the safety net. |
| Writing the commit message yourself | Always delegate to `sanctum:commit-messages`. Same as `/ship`. |
| Running tests / docs updates | Wrong skill — use `sanctum:prepare-pr`. |
| Deleting the branch before the merge completes | `--delete-branch` on `gh pr merge` handles this atomically. Don't pre-delete. |

## Scope Boundary

This skill is the **full one-shot lane**, but it is NOT a replacement for `sanctum:prepare-pr`. If you find yourself wanting to:

- run the full test suite locally
- update changelogs / docs
- run `sanctum:pr-review` for a deep review
- bump versions

…you are using the wrong skill. Switch to `sanctum:prepare-pr`.

## Relationship to Other Skills

| Skill | Commit | Push | PR | Review | Merge |
|-------|--------|------|----|----|-------|
| `/ship` | yes | yes | yes | no | no |
| `/ship-merge` (this skill) | yes | yes | yes | light (inline diff) | yes (squash + delete) |
| `sanctum:prepare-pr` | yes | yes | yes | full (tests + docs + review) | no |
