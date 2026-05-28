---
description: Propose a locally-installed project skill to the skillsbase catalog so the team benefits. Usage: /propose-skill <skill-name>
---

You are opening a pull request against the skillsbase catalog on behalf of the user. The skill being proposed lives under the current project's `.claude/skills/<skill-name>/` directory. Follow the steps below exactly — stop and report the error clearly if any step fails; do not continue silently.

## Step 1 — Resolve the skill name

The argument passed to this command is `$ARGUMENTS`. That is the skill name. If it is empty or missing, tell the user:

> Usage: `/propose-skill <skill-name>`  — where `<skill-name>` is a directory name under `.claude/skills/`.

Then stop.

## Step 2 — Read the source skill

Read the file `<cwd>/.claude/skills/<skill-name>/SKILL.md`.

If the file does not exist, report:

> Error: `.claude/skills/<skill-name>/SKILL.md` not found in this project.  
> Make sure the skill is installed (check `.claude/skills/` for available skills) and the name matches the directory exactly.

Then stop.

## Step 3 — Parse and validate frontmatter

Parse the YAML frontmatter block at the top of the file (the `---` ... `---` block).

Validate:
- `name` must be present and non-empty. If missing: report `Error: SKILL.md is missing the required "name" field in its frontmatter.`
- `description` must be present and non-empty. If missing: report `Error: SKILL.md is missing the required "description" field in its frontmatter.`
- `description` must be ≤ 200 characters. If over the limit, report:

> Error: The description in SKILL.md is `<N>` characters — the catalog limit is 200.  
> Please shorten it before proposing. Do not truncate it yourself; the wording is yours to decide.

Stop on any validation failure.

## Step 4 — Prepare the skillsbase clone

The local clone lives at `~/.claude/cache/skillsbase/` (expand `~` to the actual home directory).

**If the directory does not exist:**
1. Try: `git clone git@github.com:itsjustiago/skillsbase.git ~/.claude/cache/skillsbase/`
2. If SSH clone fails (non-zero exit), fall back to: `git clone https://github.com/itsjustiago/skillsbase.git ~/.claude/cache/skillsbase/`
3. If both fail, report the exact error from the second attempt and stop.

**If the directory exists:**
Run in sequence inside `~/.claude/cache/skillsbase/`:
```
git fetch origin
git checkout main
git pull --ff-only
```
If any command fails, report which one failed and the exact error, then stop.

## Step 5 — Check for an existing skill

Check whether `~/.claude/cache/skillsbase/skills/<skill-name>/` already exists as a directory.

If it does, report:

> `<skill-name>` is already in the skillsbase catalog (`skills/<skill-name>/`). Nothing to propose.

Then stop.

## Step 6 — Preview and confirm

Show the user a preview before doing anything permanent:

```
Proposing skill: <skill-name>
─────────────────────────────────────────────────────
Source project : <cwd basename>
Skill file     : .claude/skills/<skill-name>/SKILL.md
Description    : <description from frontmatter>

Catalog entry that will be added:
  name         : <name>
  description  : <description>
  tags         : <tags>
  project_types: <project_types>

Files to copy  : <list all files in .claude/skills/<skill-name>/ — one per line>
─────────────────────────────────────────────────────
```

Then ask the user:

> Open PR to skillsbase? [y/N]

If the user answers anything other than `y` or `yes` (case-insensitive), say "Cancelled." and stop.

## Step 7 — Create the proposal branch

Inside `~/.claude/cache/skillsbase/`:

```bash
git checkout main
git checkout -b propose/<skill-name>
```

If the branch `propose/<skill-name>` already exists remotely (`git ls-remote --heads origin propose/<skill-name>` returns a result), report:

> A branch `propose/<skill-name>` already exists on origin — there may already be an open PR for this skill. Check https://github.com/itsjustiago/skillsbase/pulls before proceeding.

Then stop.

## Step 8 — Copy the skill files

Copy the **entire** `.claude/skills/<skill-name>/` directory from the source project into `~/.claude/cache/skillsbase/skills/<skill-name>/`, preserving all files.

Use a platform-appropriate copy command:
- On Unix/macOS: `cp -r "<cwd>/.claude/skills/<skill-name>" "~/.claude/cache/skillsbase/skills/"`
- On Windows (PowerShell): `Copy-Item -Recurse "<cwd>\.claude\skills\<skill-name>" "~\.claude\cache\skillsbase\skills\"`

If the copy fails, report the exact error and stop.

## Step 9 — Regenerate the catalog

Inside `~/.claude/cache/skillsbase/`, run:

```
node scripts/build-catalog.mjs
```

If this fails, report the exact error output (it will tell you exactly what is wrong with the frontmatter, e.g. a description over 200 chars) and stop. Do not proceed to commit if the build fails.

## Step 10 — Commit

Inside `~/.claude/cache/skillsbase/`, stage and commit:

```bash
git add skills/<skill-name>/ catalog.json
git commit -m "Propose skill: <skill-name>

Source project: <cwd basename>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

## Step 11 — Push

```bash
git push -u origin propose/<skill-name>
```

If the push fails, report the exact error and stop.

## Step 12 — Open the PR

Run the following `gh` command (fill in the real values for `<skill-name>`, `<description>`, and `<source-project>`):

```bash
gh pr create \
  --repo itsjustiago/skillsbase \
  --base main \
  --head propose/<skill-name> \
  --title "Propose new skill: <skill-name>" \
  --body "$(cat <<'PRBODY'
## Proposed skill: `<skill-name>`

**Description:** <description>

**Source project:** `<source-project>` (the project that adopted this skill first)

---

## Review checklist

- [ ] Review SKILL.md for prompt quality
- [ ] Confirm description is ≤200 chars and accurate
- [ ] Confirm category placement in catalog and README

---

*Proposed via `/propose-skill` in Claude Code.*
PRBODY
)"
```

Capture the PR URL from the output. If `gh` fails (e.g. not authenticated), report the error and remind the user to run `gh auth login`.

## Step 13 — Report

Print the PR URL and a one-line summary:

```
PR opened: <url>
Skill "<skill-name>" proposed to skillsbase from project "<source-project>".
```

Done. The user can now review, edit the PR, and merge when ready.
