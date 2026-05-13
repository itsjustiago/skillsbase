---
name: prompt-optimizer
description: Analyze raw prompts, identify intent and gaps, match ECC components (skills/commands/agents/hooks), and output a ready-to-paste optimized prompt. Advisory role only — never executes the task itself.
tags: [prompt-engineering, llm, learning]
project_types: [any]
when_to_use: |
  When user says "optimize prompt", "improve my prompt", "how to write a prompt for", "help me prompt", or explicitly asks to enhance prompt quality. This is an advisory skill—analyze and suggest, never execute the task directly.
cost_tokens: 13000
---

# Prompt Optimizer

Analyze a draft prompt, critique it, match it to ECC ecosystem components, and output a complete optimized prompt the user can paste and run.

## When to Use

- User says "optimize this prompt", "improve my prompt", "rewrite this prompt"
- User says "help me write a better prompt for..."
- User says "what's the best way to ask Claude Code to..."
- User pastes a draft prompt and asks for feedback or enhancement
- User says "I don't know how to prompt for this"
- User says "how should I use ECC for..."
- User explicitly invokes `/prompt-optimize`

### Do Not Use When

- User wants the task done directly (just execute it)
- User is asking about ECC configuration (use `configure-ecc` instead)
- User wants a skill inventory (use `skill-stocktake` instead)
- User says "just do it" or "don't optimize, just execute"

## How It Works

**Advisory only — do not execute the user's task.**

Do NOT write code, create files, run commands, or take any implementation action. Your ONLY output is an analysis plus an optimized prompt.

Run the 6-phase pipeline sequentially. Present results using the Output Format below.

### Analysis Pipeline

#### Phase 0: Project Detection

Before analyzing the prompt, detect the current project context:

1. Check if a `CLAUDE.md` exists in the working directory — read it for project conventions
2. Detect tech stack from project files
3. Note detected tech stack for use in Phase 3 and Phase 4

If no project files are found (e.g., the prompt is abstract or for a new project), skip detection and flag "tech stack unknown" in Phase 4.

#### Phase 1: Intent Detection

Classify the user's task into one or more categories (New Feature, Bug Fix, Refactor, Research, Testing, Review, Documentation, Infrastructure, Design).

#### Phase 2: Scope Assessment

Estimate task complexity:

| Scope | Heuristic | Orchestration |
|-------|-----------|---------------|
| TRIVIAL | Single file, < 50 lines | Direct execution |
| LOW | Single component or module | Single command or skill |
| MEDIUM | Multiple components, same domain | Command chain + /verify |
| HIGH | Cross-domain, 5+ files | /plan first, then phased execution |
| EPIC | Multi-session, multi-PR, architectural shift | Use blueprint skill for multi-session plan |

#### Phase 3: ECC Component Matching

Map intent + scope + tech stack to specific ECC components (commands, skills, agents).

#### Phase 4: Missing Context Detection

Scan the prompt for missing critical information. If 3+ critical items are missing, ask the user up to 3 clarification questions before generating the optimized prompt.

#### Phase 5: Workflow & Model Recommendation

Determine where this prompt sits in the development lifecycle and recommend model tier.

---

## Output Format

### Section 1: Prompt Diagnosis

**Strengths:** List what the original prompt does well.

**Issues:**

| Issue | Impact | Suggested Fix |
|-------|--------|---------------|
| (problem) | (consequence) | (how to fix) |

**Needs Clarification:** Numbered list of questions or auto-detected info.

### Section 2: Recommended ECC Components

| Type | Component | Purpose |
|------|-----------|---------|
| Command | /plan | Plan architecture before coding |
| Skill | tdd-workflow | TDD methodology guidance |
| Agent | code-reviewer | Post-implementation review |
| Model | Sonnet 4.6 | Recommended for this scope |

### Section 3: Optimized Prompt — Full Version

Complete optimized prompt inside a fenced code block. Ready to copy-paste.

### Section 4: Optimized Prompt — Quick Version

Compact version for experienced ECC users.

### Section 5: Enhancement Rationale

| Enhancement | Reason |
|-------------|--------|
| (what was added) | (why it matters) |

---

## When to Use This Skill

- Analyzing and improving user prompts
- Matching prompts to ECC ecosystem components
- Providing prompt optimization advice
- Helping users understand better ways to ask Claude Code
- Advisory guidance only — never execute the task
