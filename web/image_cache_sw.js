'use strict';

// Replaced with content hashes by scripts/prepare_image_cache.py.
const IMAGE_VERSIONS = /* IMAGE_VERSIONS */ {};
const SCOPE = new URL(self.registration.scope);
const CACHE_NAME = `ppcts-images-v1:${SCOPE.pathname}`;
const pending = new Map();
const cacheKey = (path) => new URL(`__image_cache__/${IMAGE_VERSIONS[path]}/${path}`, SCOPE).href;

self.addEventListener('install', (event) => event.waitUntil(self.skipWaiting()));
self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    try {
      const cache = await caches.open(CACHE_NAME);
      const current = new Set(Object.keys(IMAGE_VERSIONS).map(cacheKey));
      await Promise.all((await cache.keys()).filter((key) => !current.has(key.url)).map((key) => cache.delete(key)));
    } catch (_) {
      // Storage may be unavailable or full; network loading still works.
    }
    await self.clients.claim();
  })());
});

async function loadImage(request, path) {
  let cache;
  const key = cacheKey(path);
  try {
    cache = await caches.open(CACHE_NAME);
    const hit = await cache.match(key);
    if (hit) return hit;
  } catch (_) {}
  const url = new URL(request.url);
  url.searchParams.set('image-version', IMAGE_VERSIONS[path]);
  const response = await fetch(new Request(url, {cache: 'no-cache', credentials: 'same-origin'}));
  if (response.ok && (response.headers.get('content-type') || '').startsWith('image/')) {
    try { if (cache) await cache.put(key, response.clone()); } catch (_) {}
  }
  return response;
}

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  if (event.request.method !== 'GET' || url.origin !== SCOPE.origin || !url.pathname.startsWith(SCOPE.pathname)) return;
  const path = decodeURI(url.pathname.slice(SCOPE.pathname.length));
  if (!Object.hasOwn(IMAGE_VERSIONS, path)) return;
  let task = pending.get(path);
  if (!task) {
    task = loadImage(event.request, path).finally(() => pending.delete(path));
    pending.set(path, task);
  }
  event.respondWith(task.then((response) => response.clone()));
});
