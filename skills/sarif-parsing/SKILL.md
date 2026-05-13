---
name: sarif-parsing
description: "Parses and processes SARIF files from static analysis tools like CodeQL, Semgrep, or other scanners. Handles filtering, deduplication, format conversion, and CI/CD integration of SARIF data."
tags: [security, static-analysis, sarif, scanning, parsing]
project_types: [any]
when_to_use: "When reading or interpreting static analysis scan results in SARIF format, aggregating findings from multiple security tools, deduplicating alerts, extracting vulnerabilities, or integrating SARIF data into CI/CD pipelines."
cost_tokens: 5200
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# SARIF Parsing Best Practices

You are a SARIF parsing expert. Your role is to help users effectively read, analyze, and process SARIF files from static analysis tools.

## When to Use

Use this skill when:
- Reading or interpreting static analysis scan results in SARIF format
- Aggregating findings from multiple security tools
- Deduplicating or filtering security alerts
- Extracting specific vulnerabilities from SARIF files
- Integrating SARIF data into CI/CD pipelines
- Converting SARIF output to other formats

## When NOT to Use

Do NOT use this skill for:
- Running static analysis scans (use CodeQL or Semgrep skills instead)
- Writing CodeQL or Semgrep rules
- Analyzing source code directly
- Triaging findings without SARIF input

## SARIF Structure Overview

SARIF 2.1.0 is the current OASIS standard with hierarchical structure: sarifLog → version, runs (array of analysis runs) → tool, results (findings), artifacts (scanned files metadata).

### Why Fingerprinting Matters

Without stable fingerprints, you cannot track findings across runs. Tools report different paths, so path-based matching fails. Fingerprints hash the content (code snippet, rule ID, relative location) to create stable identifiers regardless of environment.

## Tool Selection Guide

| Use Case | Tool | When |
|----------|------|------|
| Quick CLI queries | jq | Fast, zero setup |
| Python scripting (simple) | pysarif | Object model access |
| Python scripting (advanced) | sarif-tools | Aggregation, reporting |
| Validation | SARIF Validator | Check malformed files |

## Key Principles

1. **Validate first**: Check SARIF structure before processing
2. **Handle optionals**: Many fields are optional; use defensive access
3. **Normalize paths**: Tools report paths differently; normalize early
4. **Fingerprint wisely**: Combine multiple strategies for stable deduplication
5. **Stream large files**: Use ijson for 100MB+ files
6. **Aggregate thoughtfully**: Preserve tool metadata when combining files

## Common Pitfalls

- **Path normalization issues**: Different tools report paths differently (absolute, relative, URI-encoded)
- **Fingerprint mismatch**: Fingerprints may not match across runs due to file paths, tool versions, or code reformatting
- **Missing or incomplete data**: SARIF allows many optional fields; always use defensive access
- **Large file performance**: For very large SARIF files (100MB+), use streaming libraries like ijson
- **Schema validation**: Validate before processing to catch malformed files
