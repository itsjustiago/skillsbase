---
name: drizzle-neon-typescript
description: Drizzle ORM on Neon serverless Postgres in TypeScript — schema definition, type-safe queries, migrations via drizzle-kit, connection pooling, and the serverless vs edge driver split.
tags: [drizzle, neon, postgres, typescript, orm, migrations, serverless]
project_types: [nextjs, any-web]
when_to_use: |
  Project uses drizzle-orm + @neondatabase/serverless (or @neondatabase/edge).
  Triggers on schema changes, writing queries, generating migrations,
  debugging "where's my type inference", or wiring the DB into server
  actions / route handlers.
cost_tokens: 1600
---

# Drizzle + Neon + TypeScript

## The split: drizzle-orm + driver + drizzle-kit

Three packages, three jobs — easy to mix up:

| Package | What it does | Where it runs |
|---|---|---|
| `drizzle-orm` | Query builder, type inference, schema DSL | App runtime (any env) |
| `@neondatabase/serverless` | The Postgres driver (HTTP-based) | App runtime — Node, Edge, Vercel functions |
| `drizzle-kit` | CLI for migrations, introspection, studio | Dev-time only |

You install all three. `drizzle-kit` is a dev dependency; the other two are runtime.

## Connection — two flavors

### Pooled HTTP (default for serverless)

```ts
// src/db/index.ts
import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import * as schema from './schema';

const sql = neon(process.env.DATABASE_URL!);
export const db = drizzle(sql, { schema });
```

This is HTTP-based, no TCP — perfect for Vercel functions, Edge, serverless. Each query is one HTTP roundtrip. **Cannot do transactions.**

### Pooled WebSocket (for transactions)

```ts
import { Pool, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-serverless';
import ws from 'ws';

neonConfig.webSocketConstructor = ws; // Node only; not needed in Edge/browser

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
export const db = drizzle(pool, { schema });
```

Use this when you need `db.transaction(...)`. Slower than HTTP for single queries, but enables atomic multi-statement ops.

## Schema

```ts
// src/db/schema.ts
import { pgTable, serial, text, timestamp, integer, boolean, uuid } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: text('email').notNull().unique(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  authorId: uuid('author_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  title: text('title').notNull(),
  body: text('body'),
  published: boolean('published').default(false).notNull(),
});

// Relations (used by query.* API, not select())
export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, { fields: [posts.authorId], references: [users.id] }),
}));
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));
```

Inferred types — these are free, no codegen:

```ts
type User = typeof users.$inferSelect;       // shape of a row
type NewUser = typeof users.$inferInsert;    // shape for .insert()
```

## Two query APIs — pick consciously

### `select()` — explicit SQL-builder

```ts
import { eq, and, desc } from 'drizzle-orm';

const rows = await db
  .select({ id: posts.id, title: posts.title, author: users.email })
  .from(posts)
  .innerJoin(users, eq(users.id, posts.authorId))
  .where(and(eq(posts.published, true)))
  .orderBy(desc(posts.id))
  .limit(20);
```

Full control, no magic. Result type is inferred from the projection object.

### `query.*` — relational, ergonomic

```ts
const rows = await db.query.posts.findMany({
  where: (p, { eq }) => eq(p.published, true),
  with: { author: true },
  orderBy: (p, { desc }) => desc(p.id),
  limit: 20,
});
```

Cleaner for reads with relations. Requires `relations` defined in schema. Under the hood it generates one or many queries depending on cardinality.

**Rule of thumb:** `query.*` for reads with joins, `select()` when you need exact SQL shape or aggregations.

## Inserts / updates / deletes

```ts
// Insert with returning row
const [row] = await db
  .insert(posts)
  .values({ authorId, title: 'hi' })
  .returning();

// Upsert
await db
  .insert(users)
  .values({ email })
  .onConflictDoUpdate({ target: users.email, set: { email } });

// Update
await db
  .update(posts)
  .set({ published: true })
  .where(eq(posts.id, postId));

// Delete
await db.delete(posts).where(eq(posts.id, postId));
```

## Transactions (WebSocket driver only)

```ts
await db.transaction(async (tx) => {
  const [user] = await tx.insert(users).values({ email }).returning();
  await tx.insert(profiles).values({ userId: user.id, name });
});
```

HTTP driver throws if you try `db.transaction(...)`. Use the serverless pool flavor for any flow that must be atomic.

## Migrations with drizzle-kit

`drizzle.config.ts`:

```ts
import type { Config } from 'drizzle-kit';

export default {
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: { url: process.env.DATABASE_URL! },
} satisfies Config;
```

Workflow:

```bash
# 1. Change schema.ts
# 2. Generate SQL migration
npx drizzle-kit generate

# 3. Apply to DB
npx drizzle-kit push           # dev — pushes diff directly, no migration files
# OR
npx drizzle-kit migrate        # prod — applies SQL files from ./drizzle

# Inspect DB
npx drizzle-kit studio         # localhost:4983
```

**`push` vs `migrate`:**
- `push` — dev only. Compares schema to DB and applies the diff. Skips writing migration files. Fast iteration, risky in prod.
- `generate` + `migrate` — writes versioned SQL files, applies them in order. Safe for prod, reviewable in PRs.

## Common pitfalls

1. **Mixing HTTP and WebSocket drivers.** `drizzle-orm/neon-http` and `drizzle-orm/neon-serverless` are different builds. Pick one per file and stick to it.
2. **No `relations`, no `query.*` joins.** If you use `db.query.X.findMany({ with: {...} })` without declaring relations, it silently returns plain rows without the joined data.
3. **`drizzle-kit push` overwrites without prompting** when columns are renamed. Always inspect the diff or use `generate` for non-trivial changes.
4. **Edge runtime needs HTTP driver.** WebSocket driver won't load in Edge — you'll get a runtime error. Vercel Edge functions, middleware, etc. → use `neon-http`.
5. **Date columns: use `mode: 'date'` or `'string'`**. The default is `'date'` (returns JS `Date`). Set `'string'` if you want ISO strings instead.
6. **Returning JSON columns**: `text('data').$type<MyType>()` for typed JSON-ish, or `jsonb('data').$type<MyType>()` for real jsonb. The `.$type<>()` is a type-only hint, no runtime validation.

## Server actions pattern (Next.js)

```ts
// app/actions/posts.ts
'use server';

import { db } from '@/db';
import { posts } from '@/db/schema';
import { revalidatePath } from 'next/cache';

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string;
  await db.insert(posts).values({ authorId: '...', title });
  revalidatePath('/posts');
}
```

No try/catch wrapper unless you need user-facing error messages — let exceptions surface to the framework boundary.

## References

- [Drizzle docs](https://orm.drizzle.team/docs/overview)
- [Neon serverless driver](https://neon.tech/docs/serverless/serverless-driver)
- [Drizzle Kit migrations](https://orm.drizzle.team/docs/kit-overview)
