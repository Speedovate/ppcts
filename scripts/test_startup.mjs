import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import vm from 'node:vm';

const html = readFileSync('web/index.html', 'utf8');
const bootstrap = readFileSync('web/flutter_bootstrap.js', 'utf8').replace(/\{\{flutter_(js|build_config)\}\}/g, '');
for (const ua of ['Mozilla/5.0 Chrome/140', 'Android FBAV/1', 'iPhone Instagram', 'Android Line/1', 'iPhone Messenger']) {
  const events = new Map();
  const attributes = new Map();
  let loads = 0, removed = false;
  const splash = {style: {}, remove() {removed = true;}};
  const sandbox = {
    navigator: {userAgent: ua}, URL, console, setTimeout, clearTimeout,
    document: {getElementById: () => splash, documentElement: {setAttribute: (k, v) => attributes.set(k, v)}},
    _flutter: {loader: {load: async (options) => {
      loads++;
      await options.onEntrypointLoaded({initializeEngine: async () => ({runApp: async () => events.get('flutter-first-frame')()})});
    }}},
    requestAnimationFrame: fn => fn(),
    addEventListener: (name, fn) => events.set(name, fn),
  };
  sandbox.window = sandbox;
  vm.runInNewContext(bootstrap, sandbox);
  await new Promise(resolve => setTimeout(resolve, 150));
  const social = !ua.includes('Chrome/140');
  assert.equal(loads, social ? 0 : 1, ua);
  assert.equal(attributes.get('data-social-inapp'), social ? 'true' : undefined, ua);
  assert.equal(removed, !social, ua);
}
const linkScript = html.match(/function getChromeOpenUrl\(\) \{[\s\S]*?\n    \}/)[0];
for (const [ua, expected] of [
  ['Android FBAV', 'intent://summit.example/program?day=1#Intent;scheme=https;package=com.android.chrome;end'],
  ['iPhone Instagram', 'googlechromes://summit.example/program?day=1'],
  ['Desktop', 'https://summit.example/program?day=1'],
]) {
  const sandbox = {navigator: {userAgent: ua}, window: {location: {href: 'https://summit.example/program?day=1'}}};
  vm.runInNewContext(linkScript, sandbox);
  assert.equal(sandbox.getChromeOpenUrl(), expected);
}
assert.match(html, /#app-startup-splash__footer-mark\s*\{\s*background: #132051/);
assert.equal((html.match(/assets\/assets\/images\/summit_branding.png/g) || []).length, 2);
assert.doesNotMatch(html, /Andrew|as_logo/);
console.log('PASS: normal startup, social gates, first-frame splash dismissal, Chrome links, summit branding.');
