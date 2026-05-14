# Design Workflow Guide

## The Stack
UI UX Pro Max → Frontend-Design → taste-skill → Impeccable

These four work as a pipeline. Most of it is automatic — you just need to know when to trigger Impeccable.

## Step by Step

### Starting a new UI
Tell Claude what you're building. UI UX Pro Max reads the context and auto-selects an industry-appropriate design system (palettes, styles, layout patterns).

### Set your aesthetic upfront
Before the first component is written, pick a taste-skill variant:
- `"Use soft-skill"` — spacious, breathing room, premium feel
- `"Use minimalist-skill"` — editorial, typographic, clean
- `"Use brutalist-skill"` — raw, mechanical, unapologetic
- `"Use taste-skill"` — modern default, balanced

### Let Frontend-Design ask questions
Claude will pause before coding and ask about tone, purpose, and differentiation. This is intentional — answer it. This is what separates distinctive design from generic AI output.

### Refine with Impeccable
Run these after any component or page is done:

| Command | Use it when... |
|---|---|
| `/audit` | You want a full list of everything wrong |
| `/critique` | You want honest feedback on overall quality |
| `/polish` | Spacing, padding, touch targets feel off |
| `/animate` | Interactions feel static or lifeless |
| `/colorize` | Colors feel flat or inconsistent |
| `/delight` | It works but feels generic |
| `/typeset` | Typography feels wrong |
| `/bolder` | Design feels timid or safe |
| `/layout` | Alignment or grid feels broken |
| `/impeccable` | Ship-check — runs everything |
