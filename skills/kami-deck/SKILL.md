---
name: kami-deck
description: Produce a print-grade slide deck in the kami design system—warm parchment, serif typography, ink-blue accent, magazine-style swipe navigation.
tags:
  - presentation
  - deck
  - slides
  - print-design
  - editorial
  - serif
project_types:
  - any
when_to_use: |
  Trigger when the user requests a presentation deck with editorial or print-first aesthetics. Use for internal reviews, conference talks, and branded slide decks where visual restraint and typographic hierarchy matter more than animation or flashy graphics.
cost_tokens: 3250
---

# kami-deck

Sister skill to [`kami-landing`](../kami-landing/). Produces a single
self-contained HTML file: a horizontal magazine-style swipe deck in
the **kami (紙 / 纸)** design system — print rhythm, ink-blue accent,
serif at one weight, no italic, no cool grays.

The navigation model is intentionally borrowed from the
[`guizang-ppt`](../guizang-ppt/) skill — `←/→` arrow keys, wheel /
swipe, ESC for the overview grid. The aesthetic stays kami: parchment
content slides, ink-blue cover and chapter slides, serif everywhere.

> **Design system source of truth:**
> [`design-systems/kami/DESIGN.md`](../../design-systems/kami/DESIGN.md).
> Read it before shipping. Tokens, type rules, and forbidden colors
> all live there. Slide-specific scale ratios (macro × 1.6,
> letter-spacing × 0.6 vs. print) are documented in §3 "Hierarchy"
> and §5 "Layout Principles · Slides".

## What you get

- N viewport-sized slides (6-15 is the sweet spot) laid out
  horizontally on one transformed flex track.
- **Cover and chapter slides** flip background to ink-blue
  (`#1B365D`) with ivory text — the only place dark theme is used.
- **Content / stats / quote / CTA slides** stay on parchment
  (`#f5f4ed`) with serif at weight 500.
- **Per-slide chrome strip**: brand mark · deck title · live slide
  counter (`01 / 09`).
- **Tabular-nums** on every counter, metric, page number.
- **Coral-free** — kami's accent is ink-blue. Progress bar and dot
  nav are ink-blue too.
- **Keyboard / wheel / touch nav**, ESC overview grid, dot indicator.
- **Multilingual stack** — EN / zh-CN / ja, set on `:root` via
  the `language` parameter.

## Slide types

| Kind        | Background | Use it for                                                |
| :---------- | :--------- | :-------------------------------------------------------- |
| `cover`     | ink-blue   | Title plate at the start. Centered serif title + tagline. |
| `chapter`   | ink-blue   | Roman/Arabic numeral chapter divider.                     |
| `content`   | parchment  | Section number + title + body + optional bullets.         |
| `stats`     | parchment  | 3-4 metric cells (value · label · sub).                   |
| `quote`     | parchment  | Pull quote with ink-blue left rule + author signature.    |
| `cta`       | parchment  | Closing pitch + 1-2 buttons.                              |
| `end`       | ink-blue   | Mega serif kicker word + colophon footer.                 |

A typical 11-slide deck:

```
1. cover     — ink-blue title plate
2. chapter   — "01 / Why now"
3. content   — manifesto
4. content   — capabilities + bullets
5. stats     — 4 numbers
6. chapter   — "02 / How it feels"
7. content   — method
8. content   — selected work
9. quote     — testimonial
10. cta      — primary action
11. end      — ink-blue kicker
```

## Workflow

### 1. Gather the brief

Ask in two rounds (don't dump the whole list at once):

1. Identity round — name, mark, tagline, location, edition, language.
2. Content round — for each slide, kind + the typed fields.

### 2. Pick the language stack

Same as [`kami-landing`](../kami-landing/SKILL.md#2-pick-the-language-stack):
EN → Charter, zh-CN → TsangerJinKai02 / Source Han Serif, ja →
YuMincho. JA also overrides `--olive` to `#4d4c48` because YuMincho
strokes are thinner.

### 3. Write `index.html`

Output a single file with all CSS inline. Mirror the structure of
[`example.html`](./example.html). Use only the tokens from
`design-systems/kami/DESIGN.md`.

The runtime script (keyboard / wheel / touch nav, dot indicator,
progress bar, ESC overview) should match the model documented in
[`open-design-landing-deck/scripts/compose.ts`](../open-design-landing-deck/scripts/compose.ts).
Do **not** reuse the open-design-landing-deck CSS; the visual
language is different.

### 4. Self-check

- [ ] All cover / chapter / end slides use ink-blue background
      (`#1B365D`) with ivory text. All other slides are on
      parchment.
- [ ] Ink-blue covers ≤ 5% of any parchment slide's surface.
- [ ] Slide titles use serif weight 500 only. No italic.
- [ ] All numeric stacks (counter, metrics, page numbers) carry
      `font-variant-numeric: tabular-nums`.
- [ ] Press `→` / `Space` / scroll. Smoothly slides one viewport
      to the right; dot nav advances; the ink-blue progress bar
      ticks forward.
- [ ] Press `Esc`. Overview grid appears with scaled thumbnails.
- [ ] Resize to 1080px and 640px. Cover / content collapse to a
      single column; dot nav still works.
- [ ] Lighthouse: contrast AA, font-display swap, no layout shift.

## Boundaries

- **Do not** introduce a second accent color. Pick ink-blue or
  pick nothing.
- **Do not** use italic anywhere — emphasis swaps to ink-blue.
- **Do not** use `rgba()` for tag fills; pre-blend over parchment
  and use solid hex from the table in
  `design-systems/kami/DESIGN.md` §2.
- **Do not** add a router. This is a single-file artifact.
- **Do not** reuse Atelier Zero collage imagery (the open-design-landing
  visual system). Kami is gradient-free, image-light, and hierarchy
  is carried by type.

## See also

- [`kami-landing`](../kami-landing/) — long-form one-pager sister skill.
- [`design-systems/kami/DESIGN.md`](../../design-systems/kami/DESIGN.md) — token spec.
- [`open-design-landing-deck`](../open-design-landing-deck/) — same
  horizontal swipe nav model, different visual language (Atelier Zero).
- Upstream: [`tw93/kami`](https://github.com/tw93/kami) — original
  Claude skill (MIT). Kami's slides.py template documents the macro
  × 1.6 / micro × 0.6 ratios this skill applies.
