'use strict';

// Replaced with content hashes by scripts/prepare_image_cache.py.
const IMAGE_VERSIONS = {"assets/assets/images/back_cover.jpg": "c0d186146567324b31a1b1ee07783646fbff62723e12290f760883a6f021b09e", "assets/assets/images/ct_logo.png": "fc9146b2612368d7f66242412608dad42dd0befe82844396ab9c69338e5ec8e0", "assets/assets/images/ctc.png": "df747985916d51704df29750dbe6004c3ec3332588558ddc444132729d07fbbf", "assets/assets/images/ctc_logo.png": "5b7bf2cdcafdbce48448199b0eda8dc7a81176ccc688c0f54d5ad8f08bf56af5", "assets/assets/images/fourpoints.jpg": "242b165fd60840780b83903150864bb3af22d6562d1fdb783b7f5e401966723a", "assets/assets/images/front_cover.jpg": "075232670ba82e89c0d8908f782c74dd84ac7af06130134dff24ccf7f77a1b13", "assets/assets/images/ltp.png": "6e23df17de0170d5b145c5a575465e85cf010c92dbb8371ec886a2ebae013971", "assets/assets/images/ppc_logo.png": "d8a6ac25c2179b01b3012880ef741c9346f920582dd9b842b8928b0f0ea6053b", "assets/assets/images/speedovate.jpg": "643034dd50bb5c17f510a1941c5dbead9e705943a084d7237e517fd2b1adb425", "assets/assets/images/summit_branding.png": "150ec01408602360c82b2e83603b2c40c088d111a4714446d90af9164e3175d0", "ctc-favicon.png": "df747985916d51704df29750dbe6004c3ec3332588558ddc444132729d07fbbf", "icons/Icon-192.png": "3dce99077602f70421c1c6b2a240bc9b83d64d86681d45f2154143310c980be3", "icons/Icon-512.png": "baccb205ae45f0b421be1657259b4943ac40c95094ab877f3bcbe12cd544dcbe", "icons/Icon-maskable-192.png": "d2c842e22a9f4ec9d996b23373a905c88d9a203b220c5c151885ad621f974b5c", "icons/Icon-maskable-512.png": "6aee06cdcab6b2aef74b1734c4778f4421d2da100b0ff9e52b21b55240202929", "sdv_footer_lite.png": "a5160c5382d4345b781e74868fe3100cfffe82877a03cade14f343a1415709d5"};
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
