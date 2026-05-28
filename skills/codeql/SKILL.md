---
name: codeql
description: "Scans a codebase for security vulnerabilities using CodeQL interprocedural data flow and taint tracking. Supports run-all and important-only scan modes with data extension models and SARIF output."
tags: [security, sast, static-analysis, codeql, data-flow]
project_types: [any]
when_to_use: "When scanning a codebase for security vulnerabilities with deep data flow analysis, building a CodeQL database from source, finding complex vulnerabilities requiring interprocedural taint tracking, or performing comprehensive security audits."
cost_tokens: 7200
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - TaskCreate
  - TaskList
  - TaskUpdate
  - TaskGet
  - TodoRead
  - TodoWrite
---

# CodeQL Analysis

Supported languages: Python, JavaScript/TypeScript, Go, Java/Kotlin, C/C++, C#, Ruby, Swift.

## Essential Principles

1. **Database quality is non-negotiable.** A database that builds is not automatically good. Always run quality assessment (file counts, baseline LoC, extractor errors) and compare against expected source files. A cached build produces zero useful extraction.

2. **Data extensions catch what CodeQL misses.** Even projects using standard frameworks (Django, Spring, Express) have custom wrappers around database calls, request parsing, or shell execution. Skipping the create-data-extensions workflow means missing vulnerabilities in project-specific code paths.

3. **Explicit suite references prevent silent query dropping.** Never pass pack names directly to `codeql database analyze` — each pack's `defaultSuiteFile` applies hidden filters that can produce zero results. Always generate a custom `.qls` suite file.

4. **Zero findings needs investigation, not celebration.** Zero results can indicate poor database quality, missing models, wrong query packs, or silent suite filtering. Investigate before reporting clean.

5. **macOS Apple Silicon requires workarounds for compiled languages.** Exit code 137 is `arm64e`/`arm64` mismatch, not a build failure. Try Homebrew arm64 tools or Rosetta before falling back to `build-mode=none`.

6. **Follow workflows step by step.** Once a workflow is selected, execute it step by step without skipping phases. Each phase gates the next.

## When to Use

- Scanning a codebase for security vulnerabilities with deep data flow analysis
- Building a CodeQL database from source code (with build capability for compiled languages)
- Finding complex vulnerabilities that require interprocedural taint tracking
- Performing comprehensive security audits with multiple query packs

## When NOT to Use

- Writing custom queries
- CI/CD integration
- Quick pattern searches (use Semgrep instead)
- No build capability for compiled languages
- Single-file or lightweight analysis

## Success Criteria

- [ ] Output directory resolved (user-specified or auto-incremented default)
- [ ] Database built with quality assessment passed
- [ ] Data extensions evaluated or explicitly skipped with justification
- [ ] Analysis run with explicit suite reference (not default pack suite)
- [ ] Unfiltered results preserved in `$OUTPUT_DIR/raw/results.sarif`
- [ ] Final results in `$OUTPUT_DIR/results/results.sarif` (filtered for important-only)
- [ ] Zero-finding results investigated (database quality, model coverage, suite selection)
