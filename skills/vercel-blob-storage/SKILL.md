---
name: vercel-blob-storage
description: Vercel Blob — uploading from server actions or client, the put/del/list/head API, public vs private blobs, signed client uploads for large files, and the path/pathname conventions.
tags: [vercel, blob, storage, uploads, files, cdn]
project_types: [nextjs, any-web]
when_to_use: |
  Project uses @vercel/blob. Triggers on file uploads, image storage,
  serving user-generated media, deleting blobs, or wiring a client-side
  uploader (Resumable, multipart).
cost_tokens: 1400
---

# Vercel Blob

Object storage on Vercel, fronted by a CDN. Conceptually similar to S3 but with a simpler API and a `pathname`-based namespace instead of bucket+key.

## Setup

```bash
npm install @vercel/blob
```

Required env var (auto-injected on Vercel, manual in local dev):
```
BLOB_READ_WRITE_TOKEN=vercel_blob_rw_...
```

Get the token from the Vercel dashboard → Storage → Blob → `.env.local`.

## The four operations

```ts
import { put, del, list, head } from '@vercel/blob';

// Upload
const { url, pathname } = await put('avatars/me.png', file, {
  access: 'public',
});

// Inspect
const info = await head(url);
// { url, downloadUrl, pathname, contentType, contentDisposition, size, uploadedAt }

// List
const { blobs, hasMore, cursor } = await list({ prefix: 'avatars/', limit: 100 });

// Delete
await del(url);          // by URL
await del([url1, url2]); // batch
```

`put()` accepts `string | Buffer | Blob | File | ReadableStream`. For Node streams, use `Buffer.from(...)` first or convert via `Readable.toWeb(...)`.

## Path conventions

The `pathname` is the human-readable name. Vercel appends a random suffix to the **final URL** for cache busting and uniqueness:

```
pathname: 'avatars/me.png'
url:      'https://<store-id>.public.blob.vercel-storage.com/avatars/me-AbCd123.png'
```

This means **two uploads to the same `pathname` produce different URLs**. To overwrite (same URL), use:

```ts
await put('avatars/me.png', file, {
  access: 'public',
  addRandomSuffix: false,
  allowOverwrite: true,
});
```

Both flags are required to get a stable URL. Use this for "user avatar" type slots where you want the URL not to change.

## Server-side upload (server action)

```ts
'use server';
import { put } from '@vercel/blob';

export async function uploadAvatar(formData: FormData) {
  const file = formData.get('file') as File;
  if (!file) throw new Error('no file');

  const blob = await put(`avatars/${crypto.randomUUID()}.png`, file, {
    access: 'public',
    contentType: file.type,
  });

  return { url: blob.url };
}
```

Server uploads stream through your serverless function. **Hard cap: ~4.5 MB** for Vercel Functions (request body limit). For larger files, use client uploads.

## Client-side upload (signed) — for files >4.5 MB

The pattern: client requests a signed URL from your server, then PUTs directly to Vercel.

```ts
// app/api/upload/route.ts
import { handleUpload, type HandleUploadBody } from '@vercel/blob/client';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const body = (await request.json()) as HandleUploadBody;

  const json = await handleUpload({
    body,
    request,
    onBeforeGenerateToken: async (pathname) => {
      // Auth check here — reject if user can't upload.
      return {
        allowedContentTypes: ['image/*', 'video/mp4'],
        maximumSizeInBytes: 100 * 1024 * 1024,
        tokenPayload: JSON.stringify({ userId: '...' }),
      };
    },
    onUploadCompleted: async ({ blob, tokenPayload }) => {
      // Persist `blob.url` to DB here.
      const { userId } = JSON.parse(tokenPayload!);
      await db.update(...).set({ avatarUrl: blob.url });
    },
  });

  return NextResponse.json(json);
}
```

Client:
```tsx
'use client';
import { upload } from '@vercel/blob/client';

async function handleFile(file: File) {
  const blob = await upload(file.name, file, {
    access: 'public',
    handleUploadUrl: '/api/upload',
  });
  console.log('uploaded to', blob.url);
}
```

The client gets a one-time token, PUTs straight to Vercel's edge, and your `onUploadCompleted` runs server-side after. The token is scoped to one pathname and expires fast.

## Private blobs

```ts
const { url } = await put('private/report.pdf', file, { access: 'public' });
```

Wait — there is no `access: 'private'` yet (as of late 2025). All blobs are public-by-URL but the URL is unguessable (long random suffix). For "private" semantics, you have two paths:

1. **Don't expose the URL.** Store it in your DB, gate access through your own auth layer, stream the file via your server.
2. **Use signed download URLs**: `head(url)` returns a `downloadUrl` that you can refresh server-side; combine with short-lived tokens.

This is different from S3 — there's no IAM, no bucket policies. Treat all blob URLs as bearer tokens.

## Listing and pagination

```ts
let cursor: string | undefined;
do {
  const result = await list({ prefix: 'clips/', limit: 1000, cursor });
  for (const blob of result.blobs) console.log(blob.pathname, blob.size);
  cursor = result.cursor;
} while (cursor);
```

`list` returns up to 1000 per call. Use `cursor` to paginate. `prefix` filters by pathname prefix.

## Content type and caching

Vercel infers `contentType` from the upload's MIME type. Override explicitly:

```ts
await put('data.json', JSON.stringify(obj), {
  access: 'public',
  contentType: 'application/json',
  cacheControlMaxAge: 31536000, // seconds, default ~1 year for public blobs
});
```

For HTML or anything served as a page, set `contentDisposition: 'inline'`. For downloads, `'attachment; filename="..."'`.

## Common pitfalls

1. **`addRandomSuffix: false` without `allowOverwrite: true`** — second upload to same pathname throws. Set both or accept new URLs.
2. **Forgetting to delete** when replacing — old blobs sit around forever and count toward storage. Always `del(oldUrl)` after a successful re-upload.
3. **CORS on client upload** — handled by `handleUpload`. If you're not using the helper and uploading from the browser directly, you need to wire up CORS yourself.
4. **Treating URLs as private** — they're guess-resistant, not access-controlled. Anyone with the URL has the file.
5. **Server upload >4.5 MB** — fails silently or times out. Switch to client upload pattern.
6. **Stream uploads in Node** — must convert Node `Readable` to web `ReadableStream` (`Readable.toWeb(...)`) before passing to `put()`.

## Local dev

Vercel Blob has **no local emulator**. In dev:
- Use the production token in `.env.local` (uploads go to a real Vercel store).
- Or branch on env: write to local FS in dev, Blob in prod.

The first approach is simpler; just be careful about littering test files. Use a `dev/` prefix and prune periodically with `list({ prefix: 'dev/' })` + `del(...)`.

## References

- [Vercel Blob docs](https://vercel.com/docs/storage/vercel-blob)
- [@vercel/blob API](https://vercel.com/docs/storage/vercel-blob/using-blob-sdk)
- [Client uploads guide](https://vercel.com/docs/storage/vercel-blob/client-upload)
