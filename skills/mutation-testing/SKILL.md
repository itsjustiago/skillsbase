---
name: mutation-testing
description: "Configures mewt or muton mutation testing campaigns — scopes targets, tunes timeouts, and optimizes long-running runs. Helps configure and optimize mutation testing campaigns for code quality assurance."
tags: [testing, mutation-testing, quality, coverage]
project_types: [any]
when_to_use: "When the user mentions mewt, muton, or mutation testing, needs to configure or optimize a mutation testing campaign, or wants to run mutation testing and needs help getting set up first."
cost_tokens: 2200
allowed-tools:
  - Read
  - Write
  - Bash
  - Grep
---

# Mutation Testing — Campaign Configuration (mewt/muton)

Note: muton and mewt share identical interfaces but target different languages — mewt for general-purpose languages (Rust, Solidity, Go, TypeScript, JavaScript), muton for TON smart contracts (Tact, Tolk, FunC). All examples use `mewt` commands, but they work exactly the same with `muton`.

## When to Use

Use this skill when the user:
- Mentions "mewt", "muton", or "mutation testing"
- Needs to configure or optimize a mutation testing campaign
- Wants to run `mewt run` and needs help getting set up first

## When NOT to Use

Do not use this skill when the user:
- Wants to analyze or report on completed campaign results
- Asks about tests or coverage without mentioning mutation testing

## What Results Mean

- **Caught/TestFail**: Tests detected the mutation (good)
- **Uncaught**: Mutation survived — indicates untested logic
- **Timeout**: Tests took too long, inconclusive
- **Skipped**: A more severe mutant already failed on the same line

## Essential Commands

```bash
# Initialize and mutate
mewt init                    # Create mewt.toml and mewt.sqlite
mewt mutate [paths]          # Generate mutants without running tests
mewt run [paths]             # Run the full campaign

# Inspect configuration and scope
mewt print config            # View effective configuration
mewt print targets           # Table of all targeted files
mewt print mutations --language [lang]  # Available mutation types
mewt status                  # Mutant count and per-file breakdown

# Investigate specific mutants
mewt print mutants --target [path]   # All mutants for a file
mewt print mutants --severity high   # Filter by severity
mewt print mutant --id [id]          # View mutated code diff
mewt test --ids [ids]                # Re-test specific mutants
```

## Quick Start

Load the 5-phase guide from configuration documentation: init, scope, optimize, validate, run.

**General question or unfamiliar command?**
Run `mewt --help` or `mewt <subcommand> --help`, then assist.

## Configuration Phases

1. **Initialize** - Create mewt.toml and mewt.sqlite
2. **Scope** - Define target files and scope
3. **Optimize** - Tune timeouts and mutation filtering
4. **Validate** - Check configuration is correct
5. **Run** - Execute the campaign

Each phase gates the next; follow steps in order.
