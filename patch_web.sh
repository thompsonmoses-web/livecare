#!/usr/bin/env bash
# Post-build patch (Linux/Render): disable the Flutter service worker so every
# reload serves the LATEST build instead of a stale cache.
# Run AFTER `flutter build web`. Linux twin of patch_web.ps1.

set -euo pipefail

WEB="build/web"

# 1) Stop Flutter from registering the service worker.
BOOT="$WEB/flutter_bootstrap.js"
if [ -f "$BOOT" ]; then
  perl -0pi -e 's/_flutter\.loader\.load\(\{\s*serviceWorkerSettings:\s*\{.*?\}\s*\}\);/_flutter.loader.load({ serviceWorkerSettings: null });/s' "$BOOT"
  echo "patched: flutter_bootstrap.js (SW registration disabled)"
else
  echo "flutter_bootstrap.js not found - skipping SW registration patch"
fi

# 2) Replace the caching worker with a network-only pass-through.
#    The already-registered old worker will detect this byte change and update.
cat > "$WEB/flutter_service_worker.js" <<'EOF'
// LiveCare: pass-through service worker (no caching) so updates show immediately.
self.addEventListener('install', function () { self.skipWaiting(); });
self.addEventListener('activate', function (e) { e.waitUntil(self.clients.claim()); });
self.addEventListener('fetch', function (e) {
  if (e.request.method !== 'GET') return;
  e.respondWith(fetch(e.request).catch(function () { return caches.match(e.request); }));
});
EOF
echo "patched: flutter_service_worker.js (network-only)"

# 3) Force-unregister any already-installed worker + clear caches on load.
IDX="$WEB/index.html"
if [ -f "$IDX" ] && ! grep -q 'r.unregister();' "$IDX"; then
  python3 - "$IDX" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    html = f.read()

snippet = """<script>
  // Unregister stale service workers and clear app caches once.
  (function () {
    try {
      if ('serviceWorker' in navigator) {
        navigator.serviceWorker.getRegistrations().then(function (rs) {
          rs.forEach(function (r) { r.unregister(); });
        });
      }
      if (window.caches && caches.keys) {
        caches.keys().then(function (ks) {
          ks.forEach(function (k) { caches.delete(k); });
        });
      }
    } catch (e) {}
  })();
</script>"""

html, n = re.subn(r"(<head>)", lambda m: m.group(1) + "\n" + snippet, html,
                  count=1, flags=re.IGNORECASE)
if n:
    with open(path, "w", encoding="utf-8") as f:
        f.write(html)
    print("patched: index.html (cache-buster injected)")
else:
    print("index.html: <head> not found - skipped")
PY
else
  echo "index.html already patched"
fi

echo "DONE. Service worker disabled - reload serves the latest build."
