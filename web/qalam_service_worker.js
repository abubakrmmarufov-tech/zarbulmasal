'use strict';

// Scope the cache to this installation, including GitHub Pages subdirectories.
// Network-first reads pick up new releases; the last successful response is the
// offline fallback. Preferences remain in SharedPreferences/localStorage.
const CACHE = `zarbulmasal-offline-v1:${self.registration.scope}`;
const resolve = path => new URL(path, self.registration.scope).href;
const CORE = [
  './', 'index.html', 'flutter_bootstrap.js', 'main.dart.js', 'manifest.json',
  'assets/AssetManifest.bin.json', 'assets/FontManifest.json',
  'assets/shaders/ink_sparkle.frag', 'assets/shaders/stretch_effect.frag',
  'canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm',
  'canvaskit/chromium/canvaskit.js', 'canvaskit/chromium/canvaskit.wasm',
];

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const manifest = await fetch(resolve('assets/FontManifest.json'), {
      cache: 'reload',
    });
    if (!manifest.ok) throw new Error('Font manifest unavailable');
    const fonts = (await manifest.json()).flatMap(family =>
      family.fonts.map(font => `assets/${font.asset}`));
    const cache = await caches.open(CACHE);
    await cache.addAll([...CORE, ...fonts].map(path =>
      new Request(resolve(path), {cache: 'reload'})));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', event => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || !url.href.startsWith(self.registration.scope)) {
    return;
  }
  const path = url.href.slice(self.registration.scope.length).split('?')[0];
  // Cache app resources only; future API endpoints must remain outside this list.
  if (request.mode !== 'navigate' && !CORE.includes(path) &&
      !/^(assets|canvaskit|icons)\//.test(path) && path !== 'favicon.png') {
    return;
  }
  event.respondWith((async () => {
    const cache = await caches.open(CACHE).catch(error => {
      console.warn('Offline storage unavailable:', error);
      return null;
    });
    try {
      const response = await fetch(request);
      if (response.ok) {
        if (cache) {
          await cache.put(request, response.clone()).catch(error => {
            console.warn('Could not retain resource offline:', error);
          });
        }
        return response;
      }
      return (cache && await cache.match(request)) || response;
    } catch (error) {
      const saved = cache && (await cache.match(request) ||
        (request.mode === 'navigate' && await cache.match(resolve('index.html'))));
      if (saved) return saved;
      throw error;
    }
  })());
});
