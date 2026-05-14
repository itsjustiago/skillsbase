# Security Workflow Guide

## When to run security checks
- Before shipping any feature touching auth, payments, or user data
- When adding new dependencies
- When writing cryptographic or session-handling code
- As a pre-launch checklist

## Commands

### Dependency check (run on every project)
> *"Run a supply chain audit on this project"*
Scans all npm/pip/etc. packages for known vulnerabilities.

### Code review
> *"Security review the [module name]"*
Deep review of specific code for vulnerabilities, insecure patterns, dangerous defaults.

### Config check
> *"Check for insecure defaults in this config"*
Catches things like missing rate limits, open CORS, hardcoded secrets, debug flags left on.

### Find similar vulnerabilities
> *"Run variant analysis on the auth code"*
If one bug is found, this searches the whole codebase for similar patterns.

### Second opinion
> *"Give me a second opinion on the security of this"*
Independent review before shipping something sensitive.

### Pre-ship checklist
> *"Run a full security audit before we ship"*
Triggers supply chain + static analysis + insecure defaults in sequence.
