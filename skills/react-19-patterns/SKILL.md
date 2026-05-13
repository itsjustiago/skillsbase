---
name: react-19-patterns
description: React 19 patterns — Actions, `useFormStatus`/`useFormState`/`useActionState`, `useOptimistic`, the `use()` hook, ref-as-prop, document metadata, and what's different from React 18.
tags: [react, react-19, hooks, actions, server-actions, forms]
project_types: [nextjs, vite, any-web]
when_to_use: |
  Project uses react@19. Triggers on writing forms, mutations, optimistic UI,
  reading promises in render, ref forwarding, or migrating from React 18.
cost_tokens: 1500
---

# React 19 Patterns

## Actions — the new mutation primitive

An "Action" in React 19 is any async function passed to a `<form action={fn}>` or to a Transition. React handles pending state, error state, and serialization for you.

```tsx
async function createTodo(formData: FormData) {
  await api.create({ title: formData.get('title') as string });
}

<form action={createTodo}>
  <input name="title" />
  <button type="submit">Add</button>
</form>
```

This works in pure-client React (the form posts via JS). In Next.js / RSC, the same syntax becomes a **server action** if the function is `"use server"`.

## `useFormStatus` — child knows form is submitting

```tsx
'use client';
import { useFormStatus } from 'react-dom';

function SubmitButton() {
  const { pending } = useFormStatus();
  return <button disabled={pending}>{pending ? 'Saving...' : 'Save'}</button>;
}
```

Must be a **child** of the `<form>` — it reads the form's status from context. Trying to call it in the form's own component returns `pending: false` always.

## `useActionState` — replaces `useFormState`

(`useFormState` from `react-dom` was renamed to `useActionState` in `react` proper. Both exist for now; prefer the new name.)

```tsx
import { useActionState } from 'react';

async function loginAction(prevState: State, formData: FormData) {
  const result = await login(formData.get('email') as string);
  if (!result.ok) return { error: result.error };
  return { ok: true };
}

function LoginForm() {
  const [state, formAction, isPending] = useActionState(loginAction, { ok: false });
  return (
    <form action={formAction}>
      <input name="email" />
      {state.error && <p>{state.error}</p>}
      <button disabled={isPending}>Log in</button>
    </form>
  );
}
```

Three returns: `state` (what the action returned), `formAction` (the wrapped function to pass to `<form>`), `isPending`.

## `useOptimistic` — instant UI before the server responds

```tsx
const [optimisticTodos, addOptimistic] = useOptimistic(
  todos,
  (state, newTodo: Todo) => [...state, newTodo]
);

async function addTodo(formData: FormData) {
  const title = formData.get('title') as string;
  addOptimistic({ id: 'tmp', title, pending: true });
  await api.create({ title });   // server roundtrip
  // React auto-reverts the optimistic state when the action resolves;
  // the real state comes from re-render with new `todos` prop.
}
```

The optimistic value is **scoped to the current Transition or Action**. After the action resolves, React re-renders with the real `todos`, and `optimisticTodos` reverts to match.

## `use()` — read a promise in render

```tsx
import { use } from 'react';

function Profile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);   // suspends until resolved
  return <h1>{user.name}</h1>;
}

// Parent:
<Suspense fallback={<Skeleton />}>
  <Profile userPromise={fetchUser(id)} />
</Suspense>
```

Unlike `useState` / `useEffect`, `use()` is callable **conditionally** and inside **loops** (it has different rules from the rules-of-hooks era). It suspends the component until the promise resolves.

Also reads context: `const theme = use(ThemeContext)` (same as `useContext` but conditional-safe).

## Ref as a prop — no more `forwardRef`

```tsx
// React 18
const Input = forwardRef<HTMLInputElement, Props>((props, ref) => (
  <input ref={ref} {...props} />
));

// React 19
function Input({ ref, ...props }: Props & { ref?: React.Ref<HTMLInputElement> }) {
  return <input ref={ref} {...props} />;
}
```

`forwardRef` still works, but is no longer needed for new components. Cleaner types, simpler component identity.

## Document metadata in JSX

Title, meta, link tags can be placed anywhere in the tree and React hoists them to `<head>`:

```tsx
function Article({ title }: { title: string }) {
  return (
    <>
      <title>{title}</title>
      <meta name="description" content="..." />
      <article>...</article>
    </>
  );
}
```

Useful for client components. In Next.js App Router, prefer the `metadata` export from server components — but for dynamic per-component metadata, this works.

## Stylesheets with precedence

```tsx
<link rel="stylesheet" href="/critical.css" precedence="high" />
<link rel="stylesheet" href="/normal.css" precedence="default" />
```

React de-dupes and orders these — multiple components can declare the same stylesheet and only one `<link>` ends up in the DOM, in precedence order.

## Async scripts

```tsx
<script async src="https://analytics.example.com/script.js" />
```

React de-dupes async scripts the same way as stylesheets. Drop `<script async>` anywhere in the tree.

## Migration gotchas from React 18

1. **`forwardRef` deprecation warning** — not yet, but planned. New code should use ref-as-prop.
2. **`useFormState` → `useActionState`** — same shape, new name. Imported from `react` not `react-dom`.
3. **`ReactDOM.render` is gone** (was deprecated in 18). Must use `createRoot`.
4. **String refs are gone.** `<input ref="myInput" />` was deprecated forever, now removed.
5. **`ref` cleanup functions**: `<div ref={(node) => { ... return () => cleanup(); }} />` is now supported (cleanup runs on unmount).
6. **PropTypes / defaultProps on function components** removed. Use TypeScript and default destructuring (`function X({ foo = 'bar' }) {}`).
7. **Context value identity** — passing `<Ctx value={{...}}>` still re-renders all consumers when the object identity changes. Memoize as before.

## Server vs client component split (Next.js context)

| Server component | Client component (`"use client"`) |
|---|---|
| Default in `app/` | Opt-in via directive |
| Can be `async` | Cannot be `async` |
| Can fetch directly | Use `use()` on a passed promise, or SWR/TanStack Query |
| Cannot use hooks | Can use all hooks |
| Cannot have event handlers | Can have `onClick` etc. |
| Can import client components | Can render server components via `children` prop, not import |

Server actions (`"use server"` functions) are callable from **both** sides — they always run on the server.

## Common pitfalls

1. **`useFormStatus` in the form itself** — returns `pending: false`. Must be a child.
2. **`useOptimistic` outside an Action / Transition** — silently never reverts. Must be triggered from a Transition (`startTransition` or via `<form action>`).
3. **`use()` in a non-Suspense parent** — throws. Always wrap in `<Suspense>`.
4. **Server action throws → client error boundary** — unhandled exceptions in server actions propagate as `Error` to the nearest error boundary on the client. Catch + return `{ error }` for user-facing messages.
5. **Caching with Actions** — server actions don't auto-revalidate routes. Call `revalidatePath()` / `revalidateTag()` from the action.

## References

- [React 19 release notes](https://react.dev/blog/2024/12/05/react-19)
- [Actions reference](https://react.dev/reference/react/useActionState)
- [`use()` hook](https://react.dev/reference/react/use)
