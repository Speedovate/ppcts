// Render a dedicated social card using the original branding asset.
import {readFile, writeFile, mkdtemp, rm} from 'node:fs/promises';
import {spawn} from 'node:child_process';
import {once} from 'node:events';
import {tmpdir} from 'node:os';
import {join, resolve} from 'node:path';
const root = new URL('../', import.meta.url);
const logo = await readFile(new URL('assets/images/summit_branding.png', root));
const temp = await mkdtemp(join(tmpdir(), 'summit-social-'));
try {
  const html = join(temp, 'preview.html');
  await writeFile(html, `<!doctype html><html><head><style>
    html,body{margin:0;width:1200px;height:630px;overflow:hidden;background:#FFFFFF}
    body{display:flex;align-items:center;justify-content:center}
    img{width:400px;height:auto;display:block}
  </style></head><body><img src="data:image/png;base64,${logo.toString('base64')}" alt="PPC Tourism Summit 2026"></body></html>`);
  const chrome = process.env.CHROME_BIN || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
  const child = spawn(chrome, ['--headless', '--no-first-run', '--no-default-browser-check',
    '--disable-background-networking', '--hide-scrollbars', '--force-device-scale-factor=1',
    '--window-size=1200,630', '--virtual-time-budget=1000', `--user-data-dir=${join(temp, 'profile')}`,
    `--screenshot=${resolve(new URL('web/social-preview.png', root).pathname)}`, `file://${html}`], {stdio:'ignore'});
  const [code] = await once(child, 'exit');
  if (code !== 0) throw new Error(`Chrome exited with ${code}`);
  console.log('Generated web/social-preview.png (1200 × 630).');
} finally { await rm(temp, {recursive:true,force:true}); }
