---
name: custom-jwt-auth-jose
description: Custom JWT auth in Next.js with jose + bcryptjs — sign/verify tokens, httpOnly cookies, middleware-friendly verification (Edge-compatible), password hashing, and the server-action login flow.
tags: [auth, jwt, jose, bcrypt, cookies, middleware, nextjs]
project_types: [nextjs, any-web]
when_to_use: |
  Project rolls its own auth with `jose` (JWT library) and `bcryptjs` (password
  hashing) instead of NextAuth/Clerk/etc. Triggers on login/signup flows,
  session cookies, protected route handlers, middleware-based gating, or
  rotating signing keys.
cost_tokens: 1600
---

# Custom JWT Auth (jose + bcryptjs)

When you don't want NextAuth's opinions and prefer to own the auth flow end-to-end. This stack works in Edge runtime (jose has no Node deps), which is critical for Next.js middleware.

## Why jose, not `jsonwebtoken`?

- `jsonwebtoken` uses Node's `crypto`. Doesn't work in Edge runtime, Cloudflare Workers, or browser.
- `jose` uses Web Crypto. Works everywhere including middleware and Edge functions.

Same JWT spec, different impl. If you have ambitions of running auth checks in middleware (you should — it's much faster), `jose` is the only choice.

## Setup

```bash
npm install jose bcryptjs
npm install -D @types/bcryptjs
```

Env:
```
JWT_SECRET=long-random-string-min-32-chars
```

Generate one: `openssl rand -base64 48`.

## The signing key

```ts
// lib/auth/key.ts
const secret = new TextEncoder().encode(process.env.JWT_SECRET!);
export function getKey() {
  if (!process.env.JWT_SECRET) throw new Error('JWT_SECRET not set');
  return secret;
}
```

For production-grade key rotation, you'd use an array of keys and try each one on verify. Skip for now unless you need it.

## Sign a token

```ts
// lib/auth/sign.ts
import { SignJWT } from 'jose';
import { getKey } from './key';

export async function signSession(payload: { userId: string; email: string }) {
  return new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('7d')
    .setSubject(payload.userId)
    .sign(getKey());
}
```

`HS256` is symmetric (same secret signs and verifies). For multi-service setups where verifiers shouldn't be able to sign, use `RS256` with a key pair.

## Verify

```ts
// lib/auth/verify.ts
import { jwtVerify } from 'jose';
import { getKey } from './key';

export async function verifySession(token: string) {
  try {
    const { payload } = await jwtVerify(token, getKey(), {
      algorithms: ['HS256'],
    });
    return payload as { userId: string; email: string; exp: number; iat: number };
  } catch {
    return null;
  }
}
```

`jwtVerify` throws on bad sig, expired, malformed. Always wrap in try/catch and return null — never propagate the underlying error to the route handler (leaks JWT-internals to attackers).

## The cookie

```ts
// app/actions/auth.ts
'use server';
import { cookies } from 'next/headers';
import { signSession } from '@/lib/auth/sign';

export async function setSessionCookie(userId: string, email: string) {
  const token = await signSession({ userId, email });
  const cookieStore = await cookies();
  cookieStore.set('session', token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    path: '/',
    maxAge: 60 * 60 * 24 * 7, // 7d
  });
}

export async function clearSessionCookie() {
  const cookieStore = await cookies();
  cookieStore.delete('session');
}
```

`httpOnly` is mandatory — without it, any XSS leaks the token. `sameSite: 'lax'` is the right default; use `'strict'` for paranoid setups (breaks some OAuth callbacks). `'none'` requires `secure: true` and is only for cross-site cookies.

## Reading the session in server components / route handlers

```ts
// lib/auth/session.ts
import { cookies } from 'next/headers';
import { verifySession } from './verify';

export async function getSession() {
  const cookieStore = await cookies();
  const token = cookieStore.get('session')?.value;
  if (!token) return null;
  return verifySession(token);
}
```

Use in server components:
```tsx
export default async function Page() {
  const session = await getSession();
  if (!session) redirect('/login');
  return <h1>Hi {session.email}</h1>;
}
```

## Middleware — Edge-compatible gate

```ts
// middleware.ts
import { NextResponse, type NextRequest } from 'next/server';
import { jwtVerify } from 'jose';

const PROTECTED = ['/dashboard', '/settings'];
const secret = new TextEncoder().encode(process.env.JWT_SECRET!);

export async function middleware(req: NextRequest) {
  const path = req.nextUrl.pathname;
  if (!PROTECTED.some(p => path.startsWith(p))) return NextResponse.next();

  const token = req.cookies.get('session')?.value;
  if (!token) return NextResponse.redirect(new URL('/login', req.url));

  try {
    await jwtVerify(token, secret, { algorithms: ['HS256'] });
    return NextResponse.next();
  } catch {
    return NextResponse.redirect(new URL('/login', req.url));
  }
}

export const config = {
  matcher: ['/dashboard/:path*', '/settings/:path*'],
};
```

Middleware runs in Edge — that's why you can't use `jsonwebtoken`, `bcrypt` (Node), or Drizzle's WebSocket driver here. `jose` is the right call.

**Don't do DB lookups in middleware.** Verifying the JWT signature is enough — if the token is valid, the user is "logged in for the purposes of routing". Do per-request DB checks (e.g. "is user banned") in the actual route, not middleware.

## Password hashing (bcryptjs)

```ts
import bcrypt from 'bcryptjs';

const hash = await bcrypt.hash(password, 10); // cost 10 ≈ 100ms on modest hardware
const valid = await bcrypt.compare(password, hash);
```

`bcryptjs` (not `bcrypt`) is pure JS. Slower than native `bcrypt` but works in serverless without native bindings. Cost 10 is the standard tradeoff; bump to 12 if your hardware can afford it.

**Never** call `bcrypt.compare` in middleware (Edge runtime, can't do Node crypto + it's slow). Always in server actions or route handlers running in Node.

## The full login flow

```ts
'use server';
import { db } from '@/db';
import { users } from '@/db/schema';
import { eq } from 'drizzle-orm';
import bcrypt from 'bcryptjs';
import { setSessionCookie } from './session';

export async function login(formData: FormData) {
  const email = formData.get('email') as string;
  const password = formData.get('password') as string;

  const [user] = await db.select().from(users).where(eq(users.email, email));
  if (!user) return { error: 'invalid credentials' };

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) return { error: 'invalid credentials' };

  await setSessionCookie(user.id, user.email);
  return { ok: true };
}
```

Hard rules:
- Same error for "no such user" and "wrong password" — never reveal which one.
- No DB writes on failed login (don't update `lastLoginAttempt` unless you're doing rate-limiting, and even then prefer Redis).
- Always hash in `bcrypt.compare`, never just compare strings — that breaks if you ever change the hash function.

## Logout

```ts
'use server';
import { clearSessionCookie } from './session';

export async function logout() {
  await clearSessionCookie();
}
```

JWTs can't be invalidated server-side without a denylist (the whole point of stateless tokens). If you need "log out all sessions" or "kick user", you need either:
- Short-lived tokens (15min) + refresh tokens with a denylist, or
- A `tokenVersion` field on users that's part of the JWT payload; bumping it invalidates all existing tokens.

For most apps, just delete the cookie. The token is still technically valid for `exp - now` seconds but the user can't reach it from the browser.

## Common pitfalls

1. **Forgetting `httpOnly`** — XSS becomes a session theft instantly.
2. **Storing the JWT in localStorage** — same problem. Cookies only.
3. **No `secure` in prod** — cookie sent over HTTP, intercepted.
4. **Bcrypt cost 4 in dev, 12 in prod** — different attack surfaces tested. Pick a value and stick to it.
5. **Verifying in middleware AND in the route** — fine, but redundant. Pick one as the gate.
6. **`alg: 'none'` not blocked** — `jwtVerify` enforces `algorithms: ['HS256']`, but if you forget that option, jose may accept other algs. Always specify.
7. **Encoding secrets with `TextEncoder`** in module top-level — fine, but make sure the env var is set at import time, not at runtime. Otherwise `process.env.JWT_SECRET` is `undefined` and you sign with the empty string.

## References

- [jose docs](https://github.com/panva/jose)
- [Next.js middleware](https://nextjs.org/docs/app/building-your-application/routing/middleware)
- [OWASP JWT cheatsheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)
