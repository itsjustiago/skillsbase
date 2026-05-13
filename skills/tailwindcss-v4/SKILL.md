---
name: tailwindcss-v4
description: Tailwind CSS v4 — CSS-first config (no tailwind.config.js by default), @theme directive, new @utility / @variant, breaking changes from v3, and the @tailwindcss/postcss vs Vite plugin split.
tags: [tailwindcss, tailwind-v4, css, postcss, design]
project_types: [nextjs, vite, any-web]
when_to_use: |
  Project uses tailwindcss@4 (check package.json — v4 is a major rewrite).
  Triggers on theming, custom utilities, breakpoints, dark mode, migrating
  from v3, or debugging "why doesn't this class work anymore".
cost_tokens: 1500
---

# Tailwind CSS v4

v4 is **not** a drop-in upgrade from v3. The config moved into CSS, the engine was rewritten in Rust (Oxide), and several utilities renamed or shifted defaults.

## The biggest mental model shift

**v3:** config lived in `tailwind.config.js`, JS object dictating colors, spacing, etc.

**v4:** config lives in your CSS file via `@theme`. The JS config file is **optional** (legacy escape hatch).

```css
/* app/globals.css */
@import "tailwindcss";

@theme {
  --color-brand: oklch(0.7 0.2 250);
  --color-brand-fg: white;
  --font-sans: "Inter", system-ui;
  --breakpoint-3xl: 120rem;
  --spacing-128: 32rem;
}
```

Every `@theme` token becomes a CSS variable **and** generates a utility class:
- `--color-brand` → `bg-brand`, `text-brand`, `border-brand`
- `--spacing-128` → `p-128`, `mx-128`, `gap-128`
- `--breakpoint-3xl` → enables `3xl:` variant

No more JS object, no more "extend.colors" nesting.

## PostCSS vs Vite vs CLI

Three install paths, pick one:

```bash
# PostCSS plugin (Next.js, anything PostCSS-based)
npm install tailwindcss @tailwindcss/postcss

# Vite plugin (better DX in Vite projects)
npm install tailwindcss @tailwindcss/vite

# CLI standalone (build CSS without a bundler)
npm install tailwindcss @tailwindcss/cli
```

For Next.js (App Router), the PostCSS plugin is the path. `postcss.config.mjs`:

```js
export default {
  plugins: { '@tailwindcss/postcss': {} },
};
```

Then in your root CSS file:

```css
@import "tailwindcss";
```

That single `@import` replaces the old `@tailwind base; @tailwind components; @tailwind utilities;` from v3.

## Custom utilities — `@utility`

Replaces `addUtilities` from v3 plugins.

```css
@utility scrollbar-hide {
  scrollbar-width: none;
  &::-webkit-scrollbar { display: none; }
}
```

Use as `class="scrollbar-hide"`. Supports variants (`hover:`, `md:`) automatically.

## Custom variants — `@variant` / `@custom-variant`

```css
@custom-variant rtl (&:where([dir="rtl"], [dir="rtl"] *));
@custom-variant supports-grid (@supports (display: grid));
```

Then `rtl:text-right supports-grid:grid` works.

## Breaking changes from v3 (the ones that actually bite)

| v3 | v4 |
|---|---|
| `tailwind.config.js` | `@theme` in CSS (config file optional, legacy-only) |
| `@tailwind base/components/utilities` | `@import "tailwindcss"` |
| `shadow-sm` | `shadow-xs` (everything shifted; old `shadow-sm` is now `shadow-xs`, `shadow` is `shadow-sm`, etc.) |
| `outline-none` (no visible outline) | Renamed to `outline-hidden`. New `outline-none` actually disables outlines including forced colors. |
| Default border color | Was `gray-200`, now `currentColor`. Always specify a color: `border border-gray-200`. |
| `ring` default width 3px | Now 1px (matches CSS spec). Use `ring-2` / `ring-3` to match v3. |
| Hover on touch devices | v4 only applies `hover:` when device actually has hover (`@media (hover: hover)`). Mobile users no longer see hover styles "stuck" on tap. |
| `@apply` in component CSS | Still works but needs `@reference "../app.css"` at top of the file if not in the main entry. |
| Theme keys like `theme.extend.colors.brand` | Use `var(--color-brand)` in arbitrary values: `bg-[var(--color-brand)]` or just `bg-brand`. |
| Plugin authoring with JS | Most use cases now CSS-native via `@utility` / `@variant`. JS plugins still supported via `@plugin` directive. |

## Dark mode

Default `media` strategy (system preference) works out of the box.

For class-based dark mode:

```css
@import "tailwindcss";
@custom-variant dark (&:where(.dark, .dark *));
```

Then toggle `<html class="dark">` from JS. (v4 dropped the JS `darkMode: 'class'` config option — variant goes in CSS.)

## Arbitrary values still work

```html
<div class="bg-[#ff0066] mt-[17px] grid-cols-[200px_1fr_auto]"></div>
```

But prefer theme tokens (`bg-brand`, `grid-cols-3`) — they're tree-shaken better and theme-aware.

## Performance — what the Rust engine actually buys

- Cold builds ~3-5× faster than v3.
- Incremental builds (one file changed) often <50ms.
- No more `content: [...]` config — v4 auto-detects sources via your build tool (PostCSS/Vite). The `@source` directive lets you add extra paths:

```css
@import "tailwindcss";
@source "../components/**/*.tsx";
@source "../emails/**/*.html";
```

## clsx + tailwind-merge pattern (still relevant)

v4 doesn't change this — same conflict-resolution problem with conditional classes:

```ts
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: Parameters<typeof clsx>) {
  return twMerge(clsx(inputs));
}
```

`tailwind-merge` 3.x supports v4 utility names. Make sure your version is recent.

## Common pitfalls

1. **Forgetting `@import "tailwindcss"`** in the entry CSS. v4 fails silently — utilities just don't apply.
2. **`shadow-sm` renamed.** If you upgrade and shadows look wrong, that's why.
3. **Default border color is `currentColor`.** If `border` makes lines invisible, explicitly set `border-gray-200` or similar.
4. **`@theme` in a non-entry CSS file** doesn't apply unless the file is `@import`-ed into the entry. Keep theme in your top-level CSS.
5. **Using v3 plugins.** Plugins written for v3's JS API may not load. Check for v4-compatible forks or rewrite as `@utility`.
6. **VS Code IntelliSense** needs the Tailwind extension v3.0+ for v4 support. Older versions show stale autocomplete.

## References

- [Tailwind v4 docs](https://tailwindcss.com/docs)
- [v3 → v4 upgrade guide](https://tailwindcss.com/docs/upgrade-guide)
- [@theme reference](https://tailwindcss.com/docs/theme)
