# Design Workflow Guide

## The pipeline

One skill orchestrates everything: **`design-auto-pipeline`**. It fires automatically when you ask Claude to build / design / make / refine any UI surface — you don't invoke the others by hand.

```
design-auto-pipeline  (orchestrator — auto-fires on UI work)
   │
   ├─ DIRECTION   taste-skill        → 3 dials (variance / motion / density), aesthetic baselines
   │              frontend-design    → Anthropic anti-AI-slop floor (auto-active)
   │
   ├─ BUILD       impeccable craft   → production-grade generation
   │              + MCPs: magic (inspiration), shadcn-ui (real components),
   │                designlang (extract tokens from a reference URL)
   │
   └─ CLOSEOUT    /critique → fix → /polish → /audit   (runs before "done")
```

## What each piece does

| Piece | Role | How it activates |
|---|---|---|
| `design-auto-pipeline` | Orchestrator — runs the whole flow | Auto, on any UI request |
| `frontend-design` | Anti-slop floor — bans overused fonts, forces aesthetic commitment | Auto, Anthropic plugin |
| `taste-skill` | Direction — opinionated dials + aesthetic | Triggered by the pipeline, or "use taste-skill, density 7" |
| `redesign-skill` | Upgrade an *existing* site (scan → diagnose → fix) | "redesign this", "modernize this UI" |
| `output-skill` | Bans truncation / placeholder code | Passive, always on |
| `impeccable` (17 commands) | Refinement — see table below | Pipeline closeout, or invoke a command directly |

## impeccable commands

| Command | Use it when… |
|---|---|
| `/critique` | You want a UX evaluation — hierarchy, cognitive load, anti-patterns, scored |
| `/audit` | You want the technical pass — a11y, performance, theming, P0–P3 severity |
| `/polish` | Spacing, alignment, micro-detail feels off |
| `/animate` | Interactions feel static |
| `/colorize` | Colors feel flat or monochrome |
| `/typeset` | Typography feels wrong |
| `/distill` | Too busy — strip to essence |
| `/clarify` | Copy / errors / labels unclear |
| `/layout` | Grid / alignment / rhythm broken |
| `/adapt` | Needs responsive breakpoints + touch targets |
| `/delight` | Works but feels generic |
| `/bolder` | Feels timid or safe |
| `/quieter` | Too loud / overstimulating |
| `/overdrive` | Push into shaders / spring physics / 60fps |
| `/optimize` | UI perf — rendering, bundle, images |
| `/shape` | Plan UX + UI for a feature **before** code |
| `/impeccable` | Run the whole suite end-to-end |

## In practice

You usually don't think about any of this. You say *"build me a settings page"* and the pipeline runs: direction → build → critique → polish → audit, reporting once at the end.

Steer it when you want to:
- **Set an aesthetic:** *"build a brutalist landing page"* or *"use taste-skill, density 8, motion 3"*
- **Use a reference:** *"make it like vercel.com"* → `designlang` MCP extracts the tokens
- **Refine an existing thing:** *"this dashboard looks generic"* → pipeline runs the refine path

## Related

- MCP servers the pipeline uses: [`setup/mcps.md`](../setup/mcps.md) — magic, shadcn-ui, designlang
- The global skills: [`README.md`](../README.md) → 🌍 Global skills
