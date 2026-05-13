---
name: nextjs-app-router
description: Next.js App Router patterns — server components, server actions, route handlers, layouts, streaming, and the boundaries between server and client code.
tags: [nextjs, react, app-router, ssr, server-components, server-actions]
project_types: [nextjs]
when_to_use: |
  Project uses Next.js 13+ with the `app/` directory. Active work involves
  server components, layouts, route handlers, server actions, parallel/intercepting
  routes, streaming with Suspense, or the `use client` / `use server` boundary.
cost_tokens: 1500
---

# Next.js App Router

## Mental model

- **Server components by default.** Files in `app/` are server components unless they have `"use client"` at the top.
- **Client components** are leaves of the tree — they can render server components passed as props (`children`), but they cannot `import` them.
- **Server actions** are async functions marked with `"use server"` (either inline or at file top). They run on the server and can be called from client components as if local.

## Common pitfalls

1. **Hydration mismatches** — anything time-dependent (`new Date()`, `Math.random()`) or environment-dependent (window, localStorage) accessed during render in a server component will diverge from the client. Move to `useEffect`, or use `suppressHydrationWarning` only as last resort.
2. **`async` client components are not allowed.** If you need data in a client component, fetch in a server parent and pass via props, or use SWR/TanStack Query.
3. **`cookies()` / `headers()` are dynamic.** Calling them in a route forces dynamic rendering. If you want static, avoid them in the render path.
4. **Form actions need `<form action={fn}>`** — the action can be a server action directly. For progressive enhancement, prefer this over `onSubmit`.
5. **Cache headers**: `fetch()` in server components is auto-deduped and cached by default. Add `{ cache: 'no-store' }` for dynamic data, or `{ next: { revalidate: 60 } }` for ISR-style.

## Route handlers

- Live at `app/api/<route>/route.ts`.
- Export named functions matching HTTP methods: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`.
- Return `Response` or `NextResponse`. Use `NextResponse.json(data)` for typed JSON responses.
- For streaming, return a `Response` with a `ReadableStream` body.

## Server actions

```ts
// app/actions.ts
"use server";

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string;
  // ... mutate DB
  revalidatePath("/posts");
}
```

```tsx
// app/new-post/page.tsx
import { createPost } from "@/app/actions";

export default function Page() {
  return (
    <form action={createPost}>
      <input name="title" />
      <button type="submit">Create</button>
    </form>
  );
}
```

For progressive UI, wrap with `useFormStatus()` and `useFormState()` from `react-dom`.

## Caching layers (Next.js 14+)

1. **Request memoization** — same `fetch()` URL inside one render is deduped.
2. **Data cache** — persistent cache of `fetch()` responses (opt-out with `no-store`).
3. **Full route cache** — entire route output cached at build time if all data is static.
4. **Router cache** — client-side cache of RSC payloads between navigations.

Invalidate with `revalidatePath()` or `revalidateTag()` from server actions or route handlers.

## When to use Suspense

Wrap any server component that does slow data fetching in `<Suspense fallback={...}>` so it streams independently. Without Suspense, the entire route waits for the slowest child.

## Edge runtime gotchas

- `export const runtime = "edge"` switches the route to Edge. Loses access to `fs`, `child_process`, most Node APIs.
- Good for low-latency reads, geo-aware logic, lightweight auth.
- Bad for heavy DB drivers (use HTTP-based clients like Supabase, Neon, PlanetScale).

## Migration tips (pages → app)

- `getServerSideProps` → just fetch directly in the server component.
- `getStaticProps` → also direct fetch; for ISR add `revalidate`.
- `_app.tsx` / `_document.tsx` → `app/layout.tsx`.
- `useRouter` from `next/router` → split into `useRouter` (`next/navigation`, for push/replace), `usePathname`, `useSearchParams`, `useParams`.
- API routes (`pages/api/*.ts`) → route handlers (`app/api/*/route.ts`) — different signature, no `req`/`res`, use `Request`/`Response`.

## References

- [Next.js docs — App Router](https://nextjs.org/docs/app)
- [Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
- [Caching](https://nextjs.org/docs/app/building-your-application/caching)
