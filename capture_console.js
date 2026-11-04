const { spawn } = require('child_process');
const http = require('http');
const path = require('path');
const fs = require('fs');
const os = require('os');

const chrome = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const userData = fs.mkdtempSync(path.join(os.tmpdir(), 'lc-cdp-'));
const port = 9333;
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const args = [
  '--headless=new',
  `--remote-debugging-port=${port}`,
  `--user-data-dir=${userData}`,
  '--no-first-run',
  '--window-size=1400,900',
  '--use-gl=angle',
  '--use-angle=swiftshader',
  '--enable-unsafe-swiftshader',
  '--ignore-gpu-blocklist',
  'about:blank',
];
const proc = spawn(chrome, args, { stdio: 'ignore' });

function getJson(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let d = '';
      res.on('data', (c) => (d += c));
      res.on('end', () => { try { resolve(JSON.parse(d)); } catch (e) { reject(e); } });
    }).on('error', reject);
  });
}

(async () => {
  let targets = null;
  for (let i = 0; i < 40; i++) {
    try { targets = await getJson(`http://127.0.0.1:${port}/json`); break; }
    catch (e) { await sleep(500); }
  }
  if (!targets) { console.log('NO_TARGETS'); proc.kill(); return; }
  const page = targets.find((t) => t.type === 'page');
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  const logs = [];
  let id = 0;
  const pending = {};

  function send(method, params) {
    return new Promise((res) => { const i = ++id; pending[i] = res; ws.send(JSON.stringify({ id: i, method, params })); });
  }

  ws.onmessage = (ev) => {
    const m = JSON.parse(ev.data);
    if (m.id && pending[m.id]) { pending[m.id](m.result); delete pending[m.id]; return; }
    if (m.method === 'Runtime.exceptionThrown') {
      const d = m.params.exceptionDetails || {};
      logs.push('EXCEPTION: ' + (d.text || '') + ' | ' + JSON.stringify(d.exception || {}) + ' | url:' + (d.url||'') + ' line:' + (d.lineNumber||''));
    } else if (m.method === 'Log.entryAdded') {
      const e = m.params.entry;
      logs.push(`LOG[${e.level}]: ${e.text}`);
    } else if (m.method === 'Runtime.consoleAPICalled') {
      const a = (m.params.args || []).map((x) => x.value !== undefined ? x.value : (x.description || x.type)).join(' ');
      logs.push(`CONSOLE[${m.params.type}]: ${a}`);
    } else if (m.method === 'Network.loadingFailed') {
      const e = m.params;
      logs.push(`NET_FAIL: ${e.type} err=${e.errorText} blocked=${e.blockedReason||''} url=${(e.requestId||'')}`);
    } else if (m.method === 'Network.responseReceived') {
      const e = m.params.response;
      if (e && (e.url.includes('canvaskit') || e.url.includes('main.dart') || e.url.includes('.wasm'))) {
        logs.push(`NET_RESP: ${e.status} ${e.url.slice(0,120)}`);
      }
    }
  };

  await new Promise((res) => (ws.onopen = res));
  await send('Runtime.enable');
  await send('Log.enable');
  await send('Page.enable');
  await send('Network.enable');

  await send('Page.navigate', { url: 'http://localhost:8081' });

  // Poll until Flutter creates its canvas (canvaskit may take a while headless).
  let canvasCount = 0;
  for (let i = 0; i < 30; i++) {
    await sleep(1000);
    const c = await send('Runtime.evaluate', {
      expression: 'document.querySelectorAll("canvas").length',
      returnByValue: true,
    });
    canvasCount = (c && c.result && c.result.value) || 0;
    if (canvasCount > 0) break;
  }
  console.log('CANVAS_COUNT_AFTER_POLL:', canvasCount);
  await sleep(3000);

  // Inspect renderer/WASM promise state
  const rs = await send('Runtime.evaluate', {
    expression: `(async () => {
      const out = { canvasKit: !!window.flutterCanvasKit, webgl2: false, canvas: document.querySelectorAll('canvas').length };
      try { const c = document.createElement('canvas'); out.webgl2 = !!c.getContext('webgl2'); } catch (e) { out.webgl2Err = String(e); }
      try { if (window.flutterCanvasKitLoaded) { await Promise.race([window.flutterCanvasKitLoaded, new Promise(r=>setTimeout(()=>r('TIMEOUT'),3000))]); out.ckLoaded = 'resolved/timeout'; } } catch (e) { out.ckErr = String(e); }
      return JSON.stringify(out);
    })()`,
    awaitPromise: true,
    returnByValue: true,
  });
  console.log('RENDERER_STATE:', rs && rs.result && rs.result.value);

  // Inspect DOM/page state
  const st = await send('Runtime.evaluate', {
    expression: `JSON.stringify({ready:document.readyState, canvases:document.querySelectorAll('canvas').length, flutter:!!window._flutter, scripts:[...document.scripts].map(s=>s.src.split('/').pop()).slice(0,10), text:document.body.innerText.slice(0,300)})`,
    returnByValue: true,
  });
  console.log('PAGE_STATE:', st && st.result && st.result.value);

  // Dispatch a real mouse click at the sidebar "Clients" item (from screenshot coords).
  const clickTargets = [
    { name: 'Sidebar Clients', x: 117, y: 191 },
    { name: 'QuickAction View Live Sessions', x: 1219, y: 377 },
  ];
  let before = null;
  try {
    before = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(path.join(__dirname, 'click_before.png'), Buffer.from(before.data, 'base64'));
  } catch (e) {}

  for (const t of clickTargets) {
    logs.push('--> clicking ' + t.name + ' @ ' + t.x + ',' + t.y);
    await send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: t.x, y: t.y, button: 'none', clickCount: 0 });
    await send('Input.dispatchMouseEvent', { type: 'mousePressed', x: t.x, y: t.y, button: 'left', clickCount: 1, buttons: 1 });
    await send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: t.x, y: t.y, button: 'left', clickCount: 1, buttons: 0 });
    await sleep(2500);
  }

  try {
    const after = await send('Page.captureScreenshot', { format: 'png' });
    fs.writeFileSync(path.join(__dirname, 'click_after.png'), Buffer.from(after.data, 'base64'));
    console.log('CLICK_SCREENSHOTS_SAVED');
  } catch (e) {
    console.log('CLICK_SCREENSHOT_FAILED:', String(e));
  }

  const bodyAfter = await send('Runtime.evaluate', {
    expression: 'document.body.innerText.slice(0,200)',
    returnByValue: true,
  });
  console.log('BODY_AFTER_CLICK:', bodyAfter && bodyAfter.result && bodyAfter.result.value);

  console.log('--- LOGS (' + logs.length + ') ---');
  logs.forEach((l) => console.log(l));

  // Capture a screenshot to see what actually rendered.
  try {
    const shot = await send('Page.captureScreenshot', { format: 'png' });
    const out = path.join(__dirname, 'page_shot.png');
    fs.writeFileSync(out, Buffer.from(shot.data, 'base64'));
    console.log('SCREENSHOT_SAVED:', out);
  } catch (e) {
    console.log('SCREENSHOT_FAILED:', String(e));
  }

  proc.kill();
  setTimeout(() => { try { fs.rmSync(userData, { recursive: true, force: true }); } catch (e) {} }, 1000);
})();
