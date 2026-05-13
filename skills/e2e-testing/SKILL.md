---
name: e2e-testing
description: "Playwright E2E testing patterns, Page Object Model, configuration, CI/CD integration, artifact management, and flaky test strategies for building stable, fast, and maintainable test suites."
tags: [testing, e2e, playwright, dast, browser-testing]
project_types: [any-web]
when_to_use: "When writing end-to-end tests using Playwright, setting up test infrastructure, handling flaky tests, managing test artifacts, integrating tests into CI/CD pipelines, or testing complex user workflows."
cost_tokens: 4400
---

# E2E Testing Patterns

Comprehensive Playwright patterns for building stable, fast, and maintainable E2E test suites.

## When to Use

- Writing end-to-end tests for web applications
- Setting up Playwright test infrastructure
- Handling and fixing flaky tests
- Integrating E2E tests into CI/CD pipelines
- Testing critical user journeys (login, checkout, onboarding)
- Multi-browser and responsive testing

## When NOT to Use

- Unit testing (use Jest, Vitest instead)
- Testing individual components (use component testing)
- Static analysis (use linting/type checkers)
- Performance profiling at extreme scale

## Page Object Model (POM)

Encapsulates page elements and interactions to keep tests maintainable:
- Define page selectors as locators
- Group related actions into methods
- Reuse page objects across test suites
- Update selectors in one place

## Test Structure

- Organized in `tests/e2e/` by feature
- Use fixtures for setup/teardown
- Group tests with `test.describe()`
- Page Objects separate element selectors from test logic
- Screenshots on failure for debugging

## Flaky Test Patterns

### Quarantine
Mark flaky tests with `test.fixme()` or conditional `test.skip()` while investigating.

### Identify Flakiness
```bash
npx playwright test tests/search.spec.ts --repeat-each=10
npx playwright test tests/search.spec.ts --retries=3
```

### Common Causes & Fixes

**Race conditions:** Use auto-wait locators instead of hardcoded `page.click()`
**Network timing:** Wait for specific conditions, not arbitrary timeouts
**Animation timing:** Wait for visibility and `networkidle` before interactions

## Artifact Management

- **Screenshots:** Captured on failure, manually at key points
- **Traces:** Full execution traces for debugging
- **Videos:** Recorded on failure for visual inspection
- **HTML Reports:** Auto-generated with results and failures

## CI/CD Integration

- Run in headless mode on CI
- Parallelize tests across workers
- Retry flaky tests automatically
- Upload artifacts on failure
- Generate HTML reports

## Test Report Template

```markdown
# E2E Test Report

**Date:** YYYY-MM-DD HH:MM
**Duration:** Xm Ys
**Status:** PASSING / FAILING

## Summary
- Total: X | Passed: Y (Z%) | Failed: A | Flaky: B | Skipped: C

## Failed Tests
[List failures with file:line, error, screenshot, recommended fix]

## Artifacts
- HTML Report: playwright-report/index.html
- Screenshots: artifacts/*.png
- Videos: artifacts/videos/*.webm
- Traces: artifacts/*.zip
```

## Wallet / Web3 Testing

Mock wallet providers using `context.addInitScript()` to inject ethereum object with test values.

## Financial / Critical Flow Testing

Skip critical flows on production environments. Verify preview states before confirmation. Wait for blockchain responses with long timeouts (30s+).
