# Post-build patch: disable the Flutter service worker so every reload
# serves the LATEST build instead of a stale cache.
# Run AFTER every `flutter build web`.

$web = Join-Path $PSScriptRoot 'build\web'

# 1) Stop Flutter from registering the service worker.
$bootPath = Join-Path $web 'flutter_bootstrap.js'
if (Test-Path $bootPath) {
  $b = Get-Content $bootPath -Raw
  $b = [regex]::Replace($b,
    '_flutter\.loader\.load\(\{\s*serviceWorkerSettings:\s*\{[\s\S]*?\}\s*\}\);',
    "_flutter.loader.load({ serviceWorkerSettings: null });")
  Set-Content -Path $bootPath -Value $b -NoNewline -Encoding UTF8
  Write-Host "patched: flutter_bootstrap.js (SW registration disabled)"
}

# 2) Replace the caching worker with a network-only pass-through.
#    The already-registered old worker will detect this byte change and update.
$swPath = Join-Path $web 'flutter_service_worker.js'
$sw = @"
// LiveCare: pass-through service worker (no caching) so updates show immediately.
self.addEventListener('install', function () { self.skipWaiting(); });
self.addEventListener('activate', function (e) { e.waitUntil(self.clients.claim()); });
self.addEventListener('fetch', function (e) {
  if (e.request.method !== 'GET') return;
  e.respondWith(fetch(e.request).catch(function () { return caches.match(e.request); }));
});
"@
Set-Content -Path $swPath -Value $sw -NoNewline -Encoding UTF8
Write-Host "patched: flutter_service_worker.js (network-only)"

# 3) Force-unregister any already-installed worker + clear caches on load.
$idxPath = Join-Path $web 'index.html'
$snippet = @'
<script>
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
</script>
'@
$idx = Get-Content $idxPath -Raw
if ($idx -notlike '*r.unregister();*') {
  $idx = $idx -replace '(?i)(<head>)', "`$1`n$snippet"
  Set-Content -Path $idxPath -Value $idx -NoNewline -Encoding UTF8
  Write-Host "patched: index.html (cache-buster injected)"
} else {
  Write-Host "index.html already patched"
}

Write-Host "DONE. Service worker disabled - reload serves the latest build."
