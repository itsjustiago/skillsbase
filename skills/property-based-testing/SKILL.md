---
name: property-based-testing
description: "Provides guidance for property-based testing across multiple languages and smart contracts. Helps write stronger test coverage than example-based tests for serialization, parsing, validation, and algorithmic code."
tags: [testing, property-based-testing, pbt, coverage]
project_types: [any]
when_to_use: "When writing tests, reviewing code with serialization/validation/parsing patterns, designing features, or when property-based testing would provide stronger coverage than example-based tests."
cost_tokens: 3600
---

# Property-Based Testing Guide

Use this skill proactively during development when you encounter patterns where PBT provides stronger coverage than example-based tests.

## When to Invoke (Automatic Detection)

**Invoke this skill when you detect:**

- **Serialization pairs**: `encode`/`decode`, `serialize`/`deserialize`, `toJSON`/`fromJSON`, `pack`/`unpack`
- **Parsers**: URL parsing, config parsing, protocol parsing, string-to-structured-data
- **Normalization**: `normalize`, `sanitize`, `clean`, `canonicalize`, `format`
- **Validators**: `is_valid`, `validate`, `check_*` (especially with normalizers)
- **Data structures**: Custom collections with `add`/`remove`/`get` operations
- **Mathematical/algorithmic**: Pure functions, sorting, ordering, comparators
- **Smart contracts**: Solidity/Vyper contracts, token operations, state invariants, access control

## When NOT to Use

Do NOT use this skill for:
- Simple CRUD operations without transformation logic
- One-off scripts or throwaway code
- Code with side effects that cannot be isolated
- Tests where specific example cases are sufficient
- Integration or end-to-end testing

## Property Catalog (Quick Reference)

| Property | Formula | When to Use |
|----------|---------|-------------|
| **Roundtrip** | `decode(encode(x)) == x` | Serialization, conversion pairs |
| **Idempotence** | `f(f(x)) == f(x)` | Normalization, formatting, sorting |
| **Invariant** | Property holds before/after | Any transformation |
| **Commutativity** | `f(a, b) == f(b, a)` | Binary/set operations |
| **Associativity** | `f(f(a,b), c) == f(a, f(b,c))` | Combining operations |
| **Identity** | `f(x, identity) == x` | Operations with neutral element |
| **Inverse** | `f(g(x)) == x` | encrypt/decrypt, compress/decompress |
| **Oracle** | `new_impl(x) == reference(x)` | Optimization, refactoring |
| **Easy to Verify** | `is_sorted(sort(x))` | Complex algorithms |
| **No Exception** | No crash on valid input | Baseline property |

**Strength hierarchy** (weakest to strongest):
No Exception → Type Preservation → Invariant → Idempotence → Roundtrip

## Decision Tree

Based on the current task:

```
TASK: Writing new tests
  → Use test generation patterns and examples
  → Then check input generation strategies if complex

TASK: Designing a new feature
  → Use Property-Driven Development approach

TASK: Code is difficult to test
  → Use refactoring patterns for testability

TASK: Reviewing existing PBT tests
  → Use quality checklist and anti-patterns

TASK: Test failed, need to interpret
  → Use failure analysis and bug classification

TASK: Need library reference
  → Use PBT libraries by language (includes smart contract tools)
```

## How to Suggest PBT

When you detect a high-value pattern while writing tests, offer PBT as an option:

> "I notice `encode_message`/`decode_message` is a serialization pair. Property-based testing with a roundtrip property would provide stronger coverage than example tests. Want me to use that approach?"

**If codebase already uses a PBT library** (Hypothesis, fast-check, proptest, Echidna), be more direct:

> "This codebase uses Hypothesis. I'll write property-based tests for this serialization pair using a roundtrip property."

## Rationalizations to Reject

Do not accept these shortcuts:

- **"Example tests are good enough"** — PBT finds edge cases examples miss
- **"The function is simple"** — Simple functions with complex inputs benefit most from PBT
- **"We don't have time"** — PBT tests are often shorter than comprehensive example suites
- **"It's too hard to write generators"** — Most PBT libraries have excellent built-in strategies
- **"The test failed, so it's a bug"** — Failures require validation
- **"No crash means it works"** — "No exception" is the weakest property
