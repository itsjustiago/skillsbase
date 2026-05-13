---
name: semgrep
description: "Run Semgrep static analysis scan on a codebase using parallel subagents. Supports two scan modes — run all and important only. Automatically detects and uses Semgrep Pro for cross-file taint analysis when available."
tags: [security, sast, static-analysis, semgrep, scanning]
project_types: [any]
when_to_use: "When asked to scan code for vulnerabilities, run a security audit with Semgrep, find bugs, or perform static analysis on codebases with parallel multi-language execution."
cost_tokens: 6800
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Task
  - AskUserQuestion
  - TaskCreate
  - TaskList
  - TaskUpdate
---

# Semgrep Security Scan

Run a Semgrep scan with automatic language detection, parallel execution via Task subagents, and merged SARIF output.

## Essential Principles

1. **Always use `--metrics=off`** — Semgrep sends telemetry by default; `--config auto` also phones home. Every `semgrep` command must include `--metrics=off` to prevent data leakage during security audits.
2. **User must approve the scan plan (Step 3 is a hard gate)** — The original "scan this codebase" request is NOT approval. Present exact rulesets, target, engine, and mode; wait for explicit "yes"/"proceed" before spawning scanners.
3. **Third-party rulesets are required, not optional** — Trail of Bits, 0xdea, and Decurity rules catch vulnerabilities absent from the official registry. Include them whenever the detected language matches.
4. **Spawn all scan Tasks in a single message** — Parallel execution is the core performance advantage. Never spawn Tasks sequentially; always emit all Task tool calls in one response.
5. **Always check for Semgrep Pro before scanning** — Pro enables cross-file taint tracking and catches approximately 250% more true positives. Skipping the check means silently missing critical inter-file vulnerabilities.

## When to Use

- Security audit of a codebase
- Finding vulnerabilities before code review
- Scanning for known bug patterns
- First-pass static analysis

## When NOT to Use

- Binary analysis
- Already have Semgrep CI configured
- Need cross-file analysis but no Pro license (consider CodeQL instead)
- Creating custom Semgrep rules
- Porting existing rules to other languages

## Output Directory

All scan results, SARIF files, and temporary data are stored in a single output directory. Default: `./static_analysis_semgrep_1` (auto-incremented if exists).

## Success Criteria

- [ ] Output directory resolved (user-specified or auto-incremented default)
- [ ] Languages detected with file counts; Pro status checked
- [ ] Scan mode selected by user (run all / important only)
- [ ] Rulesets include third-party rules for all detected languages
- [ ] User explicitly approved the scan plan (Step 3 gate passed)
- [ ] All scan Tasks spawned in a single message and completed
- [ ] Every `semgrep` command used `--metrics=off`
- [ ] Results summary reported with severity and category breakdown
