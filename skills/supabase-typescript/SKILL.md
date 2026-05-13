---
name: supabase-typescript
description: Supabase patterns in TypeScript — typed client setup, RLS-friendly queries, auth flows, realtime subscriptions, and the SSR/server-action handoff.
tags: [supabase, postgres, auth, typescript, rls, realtime, ssr]
project_types: [nextjs, vite, any-web]
when_to_use: |
  Project uses @supabase/supabase-js or @supabase/ssr. Work involves writing
  queries, setting up auth, handling RLS policies, doing SSR with cookies,
  or wiring up realtime subscriptions.
cost_tokens: 1600
---

# Supabase + TypeScript

## Generate types from your schema

The single biggest quality-of-life win. Run after every migration:

```bash
npx supabase gen types typescript --project-id <your-ref> > src/types/supabase.ts
```

Or for local dev:
```bash
npx supabase gen types typescript --local > src/types/supabase.ts
```

Then create a typed client:

```ts
import { createClient } from '@supabase/supabase-js';
import type { Database } from '@/types/supabase';

export const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
);
```

Now `supabase.from('users').select('id, name')` autocompletes columns and returns typed rows.

## SSR client (Next.js App Router)

Use `@supabase/ssr`, **not** the plain client, for anything that runs server-side and needs the user's session:

```ts
// utils/supabase/server.ts
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';
import type { Database } from '@/types/supabase';

export async function createClient() {
  const cookieStore = await cookies();
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (cookies) => {
          cookies.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options);
          });
        },
      },
    },
  );
}
```

Client-side (`"use client"` files):
```ts
// utils/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr';
import type { Database } from '@/types/supabase';

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  );
}
```

Middleware (to refresh sessions on every request):
```ts
// middleware.ts
import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function middleware(req: NextRequest) {
  let res = NextResponse.next({ request: req });
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => req.cookies.getAll(),
        setAll: (cookies) => {
          cookies.forEach(({ name, value, options }) => {
            req.cookies.set(name, value);
            res = NextResponse.next({ request: req });
            res.cookies.set(name, value, options);
          });
        },
      },
    },
  );
  await supabase.auth.getUser();
  return res;
}
```

Without the middleware, session cookies don't refresh and users get silently logged out.

## RLS-friendly queries

Row Level Security is the right way to authorize Supabase. The client uses the `anon` key, the DB enforces "can this user see this row?".

**Always** query with the user's session (the SSR client handles this). With RLS on, an unauthorized `select` returns an empty result, not an error — so make sure you're calling `auth.getUser()` early to detect "not logged in" vs "logged in but no rows".

Anti-pattern: using the **service role key** on the client. That key bypasses RLS — only use server-side, in trusted routes/actions, for admin operations.

## Common queries

```ts
// Single row by id
const { data, error } = await supabase
  .from('posts')
  .select('id, title, author:users(name)')
  .eq('id', postId)
  .single();

// With pagination
const { data, error } = await supabase
  .from('posts')
  .select('*', { count: 'exact' })
  .order('created_at', { ascending: false })
  .range(0, 19);

// Insert with returning row
const { data, error } = await supabase
  .from('posts')
  .insert({ title: 'hi' })
  .select()
  .single();

// Upsert
await supabase.from('settings').upsert(
  { user_id: userId, theme: 'dark' },
  { onConflict: 'user_id' }
);
```

`data` is typed (rows of the table or null on error). `error` is `PostgrestError | null`. Always check both — Supabase doesn't throw on query failure.

## Realtime

```ts
const channel = supabase
  .channel('posts-changes')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'posts' },
    (payload) => console.log('new post:', payload.new),
  )
  .subscribe();

// Cleanup
return () => { supabase.removeChannel(channel); };
```

RLS applies to realtime too — users only see events for rows they're authorized to read.

## Auth basics

```ts
// Email + password
await supabase.auth.signInWithPassword({ email, password });

// Magic link
await supabase.auth.signInWithOtp({ email });

// OAuth (redirects)
await supabase.auth.signInWithOAuth({ provider: 'google' });

// Sign out
await supabase.auth.signOut();

// Current user (server)
const { data: { user } } = await supabase.auth.getUser();
```

In server components, **always use `getUser()` not `getSession()`** — `getUser()` re-validates with the auth server, `getSession()` trusts the JWT in the cookie which could be stale or forged.

## Storage

```ts
// Upload
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`${userId}/avatar.png`, file, {
    cacheControl: '3600',
    upsert: true,
  });

// Public URL (bucket must be public)
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl(`${userId}/avatar.png`);

// Signed URL (private bucket)
const { data } = await supabase.storage
  .from('private')
  .createSignedUrl('path/to/file', 60);
```

Storage also respects RLS via bucket policies.

## Gotchas

- **Don't trust `auth.user` from cookies in server components.** Re-validate with `getUser()`.
- **Generated types lag behind migrations.** Regenerate after every schema change.
- **`select('*')` ignores joins.** Use explicit columns + relation syntax: `select('id, profile:profiles(*)')`.
- **`single()` errors if 0 or 2+ rows.** Use `maybeSingle()` if "zero rows" is valid.
- **PostgREST is case-sensitive on column names.** Snake_case in DB → snake_case in code.

## References

- [@supabase/ssr docs](https://supabase.com/docs/guides/auth/server-side/creating-a-client)
- [Type generation](https://supabase.com/docs/guides/api/rest/generating-types)
- [RLS policies](https://supabase.com/docs/guides/database/postgres/row-level-security)
