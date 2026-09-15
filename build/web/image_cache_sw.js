'use strict';

// Replaced with content hashes by scripts/prepare_image_cache.py.
const IMAGE_VERSIONS = {"assets/assets/images/asia_united_bank.png": "d37beec23db1ebe828824e2129746f5c785dde229fd4e3c361b1dc49bdc13df0", "assets/assets/images/back_cover.jpg": "c0d186146567324b31a1b1ee07783646fbff62723e12290f760883a6f021b09e", "assets/assets/images/casa_germana.jpg": "e2378fa601294a271fea5553d7fa2387f6bd80253c4bd74856bd73d3ac989510", "assets/assets/images/ct_logo.png": "fc9146b2612368d7f66242412608dad42dd0befe82844396ab9c69338e5ec8e0", "assets/assets/images/ctc.png": "df747985916d51704df29750dbe6004c3ec3332588558ddc444132729d07fbbf", "assets/assets/images/ctc_logo.png": "5b7bf2cdcafdbce48448199b0eda8dc7a81176ccc688c0f54d5ad8f08bf56af5", "assets/assets/images/fourpoints.jpg": "242b165fd60840780b83903150864bb3af22d6562d1fdb783b7f5e401966723a", "assets/assets/images/front_cover.jpg": "075232670ba82e89c0d8908f782c74dd84ac7af06130134dff24ccf7f77a1b13", "assets/assets/images/ltp.png": "6e23df17de0170d5b145c5a575465e85cf010c92dbb8371ec886a2ebae013971", "assets/assets/images/ppc_logo.png": "d8a6ac25c2179b01b3012880ef741c9346f920582dd9b842b8928b0f0ea6053b", "assets/assets/images/speakers/anna_aban.png": "886e8233411f0a4e7fc9be2387f864f21b4cf34a5f29dda0bea0fc81808069d4", "assets/assets/images/speakers/bryan_dizon.png": "2772b481a6d558871e1b2699643a85ddc46fa332be7de21faea1dd6819816ef4", "assets/assets/images/speakers/carlos_libosada.png": "e4a97eff056542f96cb74e2a8d585a6295c205baf43456bbfa349605e8a52d51", "assets/assets/images/speakers/christine_longno.png": "05b28bfb7356d33bb783f3143ab82ec0f67071f72defe632a507896153741d2e", "assets/assets/images/speakers/earl_timbancaya.png": "537d68980be6fc10c6e643ab68b6fa06c4fbc5fc5a693b36b96cfe1257b9ce23", "assets/assets/images/speakers/jovenee_sagun.png": "66192f7e9bd94472d95f7e79c60fd45b6c47539b967515b999ace855427c26ff", "assets/assets/images/speakers/leonora_escollante.png": "8442bdd2b086a7d497a63c36ba754e957ebefe020704b1540b988d035cb5ea1f", "assets/assets/images/speakers/lucilo_bayron.png": "c274864f8232fea7deef813aacf0911960f89a8fb7cadf65ca02ff952a739559", "assets/assets/images/speakers/roberto_alabado.png": "7903cff0c0a82db90fcf64c1df08e9ebae0187896f4c25b735fffacbbe0eea0d", "assets/assets/images/speakers/roy_rodriguez.png": "1658a258ddad9df239ef140ee8201368517b46e1259eed455f800b392d63db47", "assets/assets/images/speakers/senith_araez.png": "a45098fad7c6d206db6f7f6a8f9631a90b3fc90d479e4585892e1b790b945892", "assets/assets/images/speedovate.jpg": "643034dd50bb5c17f510a1941c5dbead9e705943a084d7237e517fd2b1adb425", "assets/assets/images/summit_branding.png": "150ec01408602360c82b2e83603b2c40c088d111a4714446d90af9164e3175d0", "ctc-favicon.png": "df747985916d51704df29750dbe6004c3ec3332588558ddc444132729d07fbbf", "icons/Icon-192.png": "6bf80dc826d238646f7310767e20abe7dee01e1face2ca1fb5c6a0faba681607", "icons/Icon-512.png": "c1402ac58539331463691959a73663a018b6defad6c094f0925f5ccfdc1af9ba", "icons/Icon-maskable-192.png": "6bf80dc826d238646f7310767e20abe7dee01e1face2ca1fb5c6a0faba681607", "icons/Icon-maskable-512.png": "c1402ac58539331463691959a73663a018b6defad6c094f0925f5ccfdc1af9ba", "sdv_footer_lite.png": "a5160c5382d4345b781e74868fe3100cfffe82877a03cade14f343a1415709d5"};
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
