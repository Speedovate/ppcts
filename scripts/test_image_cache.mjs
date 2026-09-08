// Real Chrome integration check. Uses an isolated temporary browser profile.
import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {spawn} from 'node:child_process';
import {mkdtemp, readFile, rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {once} from 'node:events';

const chrome = process.env.CHROME_BIN || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const root = new URL('../', import.meta.url);
const template = await readFile(new URL('web/image_cache_sw.js', root), 'utf8');
const bootstrap = await readFile(new URL('web/flutter_bootstrap.js', root), 'utf8');
const setup = bootstrap.slice(bootstrap.indexOf('async function prepareImageCache'), bootstrap.indexOf('const userAgent'));
const profile = await mkdtemp(join(tmpdir(), 'ppcts-cache-test-'));
let version = 'v1';
let imageRequests = 0;
const server = createServer((req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname;
  res.setHeader('Cache-Control', 'no-store');
  if (path.endsWith('/image_cache_sw.js')) {
    res.setHeader('Content-Type', 'application/javascript');
    res.end(template.replace('/* IMAGE_VERSIONS */ {}', JSON.stringify({'image.svg': version, 'other.svg': 'unchanged'})));
  } else if (path.endsWith('.svg')) {
    imageRequests++;
    res.setHeader('Content-Type', 'image/svg+xml');
    res.end(`<svg xmlns="http://www.w3.org/2000/svg"><title>${path.endsWith('other.svg') ? 'unchanged' : version}</title></svg>`);
  } else {
    res.setHeader('Content-Type', 'text/html');
    res.end(`<base href="/app/"><script>${setup}\nwindow.ready = prepareImageCache();</script>`);
  }
});
server.listen(0, '127.0.0.1');
await once(server, 'listening');
const origin = `http://127.0.0.1:${server.address().port}`;
const delay = ms => new Promise(resolve => setTimeout(resolve, ms));
let processHandle, socket;
async function start() {
  await rm(join(profile, 'DevToolsActivePort'), {force: true});
  processHandle = spawn(chrome, ['--headless=new', '--no-first-run', '--no-default-browser-check', '--disable-background-networking', '--remote-debugging-port=0', `--user-data-dir=${profile}`, 'about:blank'], {stdio: 'ignore'});
  let port;
  for (let i = 0; i < 150; i++) {
    try { port = (await readFile(join(profile, 'DevToolsActivePort'), 'utf8')).split('\n')[0]; break; } catch (_) { await delay(100); }
  }
  assert.ok(port, 'Chrome debugging port available');
  const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
  socket = new WebSocket(targets.find(target => target.type === 'page').webSocketDebuggerUrl);
  await new Promise(resolve => socket.addEventListener('open', resolve, {once: true}));
  const pending = new Map(); let id = 0;
  socket.addEventListener('message', event => {
    const data = JSON.parse(event.data);
    if (pending.has(data.id)) { const handler = pending.get(data.id); pending.delete(data.id); data.error ? handler.reject(data.error) : handler.resolve(data.result); }
  });
  const send = (method, params = {}) => new Promise((resolve, reject) => {
    pending.set(++id, {resolve, reject}); socket.send(JSON.stringify({id, method, params}));
  });
  const evaluate = async expression => {
    const result = await send('Runtime.evaluate', {expression, awaitPromise: true, returnByValue: true});
    if (result.exceptionDetails) throw new Error(JSON.stringify(result.exceptionDetails));
    return result.result.value;
  };
  await send('Page.navigate', {url: `${origin}/app/`});
  for (let i = 0; i < 100; i++) {
    try { if (await evaluate('!!window.ready')) break; } catch (_) {}
    await delay(100);
  }
  await evaluate('window.ready');
  assert.ok(await evaluate('!!navigator.serviceWorker.controller'), 'Page controlled on first visit');
  return {send, evaluate};
}
async function stop() {
  socket?.close();
  if (processHandle && processHandle.exitCode === null) {
    const exited = once(processHandle, 'exit'); processHandle.kill('SIGTERM'); await exited;
  }
}
const images = `Promise.all(['image.svg','other.svg'].map(path => fetch(path).then(response => response.text())))`;
try {
  let browser = await start();
  await browser.evaluate(images);
  assert.equal(imageRequests, 2);
  await browser.evaluate(images);
  assert.equal(imageRequests, 2, 'Second read does not redownload images');
  await stop();
  browser = await start();
  await browser.evaluate(images);
  assert.equal(imageRequests, 2, 'Image cache survives browser restart');
  await browser.send('Network.enable');
  await browser.send('Network.emulateNetworkConditions', {offline: true, latency: 0, downloadThroughput: 0, uploadThroughput: 0});
  await browser.evaluate(images);
  assert.equal(imageRequests, 2, 'Cached images load offline');
  await stop();
  version = 'v2';
  browser = await start();
  const updated = await browser.evaluate(images);
  assert.ok(updated[0].includes('v2'), 'Changed image refreshed');
  assert.equal(imageRequests, 3, 'Only changed image downloads after release');
  console.log('PASS: cold load, cache hit, browser restart, offline images, selective version refresh, subpath scope.');
} finally {
  await stop();
  await new Promise(resolve => server.close(resolve));
  await rm(profile, {recursive: true, force: true});
}
