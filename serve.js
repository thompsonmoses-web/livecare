// Simple static file server for the Flutter web build in ./build/web
const http = require('http');
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, 'build', 'web');
// A fresh port = a fresh browser origin = no stale service-worker cache.
const port = Number(process.env.PORT) || 8081;

const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.wasm': 'application/wasm',
  '.map': 'application/json; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
};

const server = http.createServer((req, res) => {
  try {
    let urlPath = decodeURIComponent(req.url.split('?')[0]);
    if (urlPath.endsWith('/')) urlPath += 'index.html';

    let filePath = path.join(root, urlPath);
    // Prevent path traversal
    if (!filePath.startsWith(root)) {
      res.writeHead(403);
      return res.end('Forbidden');
    }

    if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
      // SPA fallback to index.html
      filePath = path.join(root, 'index.html');
    }

    const ext = path.extname(filePath).toLowerCase();
    const data = fs.readFileSync(filePath);
    res.writeHead(200, {
      'Content-Type': types[ext] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    res.end(data);
  } catch (e) {
    res.writeHead(500);
    res.end('Server error');
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log(`LiveCare serving on http://localhost:${port}`);
});
