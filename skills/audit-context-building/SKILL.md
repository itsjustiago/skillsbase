---
name: audit-context-building
description: "Enables ultra-granular, line-by-line code analysis to build deep architectural context before vulnerability or bug finding. Applies First Principles, 5 Whys, and 5 Hows at micro scale."
tags: [security, audit, analysis, context-building, architecture]
project_types: [any]
when_to_use: "When deep comprehension is needed before bug or vulnerability discovery, wanting bottom-up understanding instead of high-level guessing, or reducing hallucinations and context loss during security auditing or architecture review."
cost_tokens: 4800
---

# Deep Context Builder Skill (Ultra-Granular Pure Context Mode)

## 1. Purpose

This skill governs how Claude thinks during the context-building phase of an audit. When active, Claude will perform line-by-line/block-by-block code analysis, apply First Principles and 5 Whys/5 Hows at micro scale, continuously link insights across functions/modules/system, and maintain a stable mental model that evolves with new evidence.

## 2. When to Use This Skill

Use when:
- Deep comprehension is needed before bug or vulnerability discovery
- You want bottom-up understanding instead of high-level guessing
- Reducing hallucinations, contradictions, and context loss is critical
- Preparing for security auditing, architecture review, or threat modeling

Do NOT use for:
- Vulnerability findings
- Fix recommendations
- Exploit reasoning
- Severity/impact rating

## 3. How This Skill Behaves

When active, Claude will:
- Default to ultra-granular analysis of each block and line
- Apply micro-level First Principles, 5 Whys, and 5 Hows
- Build and refine a persistent global mental model
- Update earlier assumptions when contradicted
- Periodically anchor summaries to maintain stable context
- Avoid speculation; express uncertainty explicitly

Goal: deep, accurate understanding, not conclusions.

## 4. Analysis Phases

**Phase 1 — Initial Orientation (Bottom-Up Scan):**
1. Identify major modules/files/contracts
2. Note obvious public/external entrypoints
3. Identify likely actors (users, owners, relayers, oracles)
4. Identify important storage variables, dicts, state structs
5. Build preliminary structure without assuming behavior

**Phase 2 — Ultra-Granular Function Analysis (Default Mode):**
For each function: Purpose, Inputs & Assumptions, Outputs & Effects, Block-by-Block Analysis (What, Why here, Assumptions, First Principles/5 Whys/5 Hows), Cross-Function & External Flow Analysis.

**Phase 3 — Global System Understanding:**
1. State & Invariant Reconstruction
2. Workflow Reconstruction
3. Trust Boundary Mapping
4. Complexity & Fragility Clustering

## 5. Stability & Consistency Rules

Claude must:
- Never reshape evidence to fit earlier assumptions
- Periodically anchor key facts (invariants, state relationships, actor roles, workflows)
- Avoid vague guesses; use "Unclear; need to inspect X"
- Cross-reference constantly to maintain global coherence

## 6. Output Requirements

Key requirements:
- **Purpose** (2-3 sentences minimum)
- **Inputs & Assumptions** (all parameters, preconditions, trust assumptions)
- **Outputs & Effects** (returns, state writes, external calls, events, postconditions)
- **Block-by-Block Analysis**
- **Cross-Function Dependencies**

Quality thresholds:
- Minimum 3 invariants per function
- Minimum 5 assumptions documented
- Minimum 3 risk considerations for external interactions
- At least 1 First Principles application
- At least 3 combined 5 Whys/5 Hows applications

## 7. Non-Goals

While active, Claude should NOT:
- Identify vulnerabilities
- Propose fixes
- Generate proofs-of-concept
- Model exploits
- Assign severity or impact

This is pure context building only.
