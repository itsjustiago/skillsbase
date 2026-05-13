---
name: pwa-deployment
description: PWA essentials — manifest, service worker registration, install prompt, iOS quirks, and deploying so the app actually installs.
tags: [pwa, service-worker, manifest, mobile, ios, android, vercel]
project_types: [nextjs, vite, any-web]
when_to_use: |
  Project should install on mobile/desktop home screens, work offline,
  or pass Lighthouse PWA audits. Triggers on manifest.json, service-worker
  registration, "Add to Home Screen" flows, push notifications setup,
  or debugging "why doesn't iOS install my app".
cost_tokens: 1400
---

# PWA Deployment

## The minimum viable PWA

A PWA installable on home screens needs **three** things:

1. A web app manifest (`manifest.json`) linked from `<head>`.
2. A registered service worker scoped to the root.
3. HTTPS (or localhost for dev).

Lighthouse will flag anything else missing — but those three are the bar for the install prompt to fire.

## Manifest essentials

```json
{
  "name": "My App",
  "short_name": "App",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "icons": [
    { "src": "/icons/192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "/icons/512.png", "sizes": "512x512", "type": "image/png" },
    { "src": "/icons/512-maskable.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ]
}
```

**Mandatory for installability:**
- `name` and `short_name`
- `start_url`
- `display: standalone` (or `fullscreen` / `minimal-ui`)
- At least one 192×192 and one 512×512 icon
- A **maskable** icon (otherwise Android crops badly)

Linked from HTML:
```html
<link rel="manifest" href="/manifest.json" />
<meta name="theme-color" content="#000000" />
```

In Next.js App Router, prefer `app/manifest.ts`:

```ts
import type { MetadataRoute } from 'next';

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'My App',
    short_name: 'App',
    start_url: '/',
    display: 'standalone',
    background_color: '#fff',
    theme_color: '#000',
    icons: [/* ... */],
  };
}
```

## Service worker registration

For Next.js, the cleanest approach is `next-pwa` or `@serwist/next` (the modern fork). Avoid hand-rolling unless you have specific reasons.

```ts
// next.config.js
const withSerwist = require('@serwist/next').default({
  swSrc: 'app/sw.ts',
  swDest: 'public/sw.js',
});
module.exports = withSerwist({ /* your next config */ });
```

Manual registration (vanilla):
```ts
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js');
  });
}
```

## iOS quirks (the hard part)

iOS Safari doesn't show the same install prompt as Chrome/Android. Users have to manually pick "Share → Add to Home Screen". Things to do:

1. **`apple-touch-icon`** — separate from manifest icons, must be in `<head>`:
   ```html
   <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
   ```
   Use a 180×180 PNG without transparency.

2. **Status bar style**:
   ```html
   <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
   <meta name="apple-mobile-web-app-capable" content="yes" />
   ```

3. **Splash screens** — iOS doesn't read manifest icons for splash. You need separate `<link rel="apple-touch-startup-image">` for each device size. Painful but use a generator like [pwa-asset-generator](https://github.com/elegantapp/pwa-asset-generator).

4. **Standalone detection** in JS:
   ```ts
   const isStandalone = window.matchMedia('(display-mode: standalone)').matches
     || (window.navigator as any).standalone === true;
   ```

5. **iOS keeps a separate cookie/storage jar for the installed PWA.** Users will be logged out in the installed app even if logged in in Safari. Plan UX around this.

## Install prompt (Android/Chrome)

```ts
let deferredPrompt: BeforeInstallPromptEvent | null = null;

window.addEventListener('beforeinstallprompt', (e) => {
  e.preventDefault();
  deferredPrompt = e as BeforeInstallPromptEvent;
  // Show your own "Install" button
});

async function promptInstall() {
  if (!deferredPrompt) return;
  deferredPrompt.prompt();
  const { outcome } = await deferredPrompt.userChoice;
  deferredPrompt = null;
}
```

## Updates (the second hardest part)

A service worker that's already installed will keep serving the cached app version forever unless you handle updates explicitly. Two strategies:

1. **Skip waiting on activate** — new SW takes over immediately. Risk: in-flight tabs may have inconsistent assets mid-session.
2. **Notify and reload** — when a new SW is waiting, show a toast "Update available — reload?". Cleaner UX.

```ts
navigator.serviceWorker.addEventListener('controllerchange', () => {
  window.location.reload();
});
```

For dev, use Chrome DevTools → Application → Service Workers → "Update on reload" — saves hours.

## Deployment checks

Before declaring done:

- [ ] Lighthouse PWA score (mobile, throttled) ≥ 90.
- [ ] Manifest loads without 404 in Network tab.
- [ ] Service worker `activated and running` in DevTools.
- [ ] Maskable icon previews correctly on https://maskable.app
- [ ] iPhone Safari → Add to Home Screen actually shows your icon, not a generic web screenshot.
- [ ] Android Chrome → Install prompt appears after engagement heuristics.
- [ ] Offline page works (kill network in DevTools, refresh).

## References

- [web.dev — Progressive Web Apps](https://web.dev/learn/pwa)
- [Serwist (next-pwa successor)](https://serwist.pages.dev/)
- [maskable.app icon preview](https://maskable.app)
