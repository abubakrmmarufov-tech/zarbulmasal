'use strict';

// Scope and version caches by the generated Flutter build identifier. The
// bootstrap passes it in the worker URL so an interrupted release cannot mix
// application resources from two builds.
const CACHE_NAMESPACE = 'zarbulmasal-offline:';
const LEGACY_CACHE_NAMESPACE = 'zarbulmasal-offline-v1:';
const WORKER_URL = new URL(self.location.href);
const BUILD_ID = WORKER_URL.searchParams.get('build') ||
  '__ZARBULMASAL_BUILD_ID__';
const CANVASKIT_VARIANT = WORKER_URL.searchParams.get('variant') === 'chromium'
  ? 'chromium'
  : 'full';
const SCOPE_SUFFIX = `:${self.registration.scope}`;
const CACHE = `${CACHE_NAMESPACE}${BUILD_ID}:${CANVASKIT_VARIANT}${SCOPE_SUFFIX}`;
const resolve = path => new URL(path, self.registration.scope).href;
const CANVASKIT = CANVASKIT_VARIANT === 'chromium'
  ? ['canvaskit/chromium/canvaskit.js',
    'canvaskit/chromium/canvaskit.wasm']
  : ['canvaskit/canvaskit.js', 'canvaskit/canvaskit.wasm'];
const CORE = [
  './', 'index.html', 'flutter_bootstrap.js', 'main.dart.js', 'manifest.json',
  'assets/AssetManifest.bin.json', 'assets/FontManifest.json',
  'assets/shaders/ink_sparkle.frag', 'assets/shaders/stretch_effect.frag',
  ...CANVASKIT,
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
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys
      .filter(key => ((key.startsWith(CACHE_NAMESPACE) &&
        key.endsWith(SCOPE_SUFFIX)) ||
        key === `${LEGACY_CACHE_NAMESPACE}${self.registration.scope}`) &&
        key !== CACHE)
      .map(key => caches.delete(key)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', event => {
  const request = event.request;
  const url = new URL(request.url);
  if (request.method !== 'GET' || !url.href.startsWith(self.registration.scope)) {
    return;
  }
  const path = url.href.slice(self.registration.scope.length).split('?')[0];
  const scopeUrl = new URL(self.registration.scope);
  const isShellNavigation = request.mode === 'navigate' &&
    url.origin === scopeUrl.origin &&
    (url.pathname === scopeUrl.pathname ||
      url.pathname === `${scopeUrl.pathname}index.html`);
  // Cache app resources only; future API endpoints must remain outside this list.
  if (request.mode === 'navigate' && !isShellNavigation) return;
  if (!isShellNavigation && !CORE.includes(path) &&
      !/^(assets|canvaskit|icons)\//.test(path) && path !== 'favicon.png') {
    return;
  }
  event.respondWith((async () => {
    const cache = await caches.open(CACHE).catch(error => {
      console.warn('Offline storage unavailable:', error);
      return null;
    });

    if (!isShellNavigation) {
      const saved = cache && await cache.match(request, { ignoreSearch: true });
      if (saved) return saved;
      const response = await fetch(request);
      if (response.ok && cache) {
        await cache.put(request, response.clone()).catch(error => {
          console.warn('Could not retain resource offline:', error);
        });
      }
      return response;
    }

    const shellRequest = new Request(resolve('index.html'));
    try {
      const response = await fetch(request);
      const isHtml = response.headers.get('content-type')
        ?.toLowerCase().includes('text/html');
      if (response.ok && isHtml && cache) {
        await cache.put(shellRequest, response.clone()).catch(error => {
          console.warn('Could not retain application shell offline:', error);
        });
      }
      return response.ok
        ? response
        : (cache && await cache.match(shellRequest)) || response;
    } catch (error) {
      const saved = cache && await cache.match(shellRequest);
      if (saved) return saved;
      throw error;
    }
  })());
});
