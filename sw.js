// Lab Rat service worker: works offline after the first visit.
const VERSION = "lab-rat-v86";
const SHELL = ["./", "index.html", "config.js", "manifest.webmanifest", "icons/icon-192.png", "icons/icon-512.png", "icons/favicon-64.png"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener("activate", e => {
  e.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.hostname.endsWith("supabase.co") || url.hostname.endsWith("supabase.in")) return; // sync traffic always goes to the network
  // App pages: network first so updates arrive, cache when offline
  if (url.origin === location.origin) {
    // Slow lab Wi-Fi: if the network takes longer than 4 s, open from the cache and let the update finish in the background
    const net = fetch(req, { cache: "no-cache" }).then(res => { if (res.ok) { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); } return res; });
    const cached = () => caches.match(req).then(r => r || caches.match("index.html"));
    e.respondWith(new Promise(resolve => {
      let done = false; const finish = r => { if (!done && r) { done = true; resolve(r); } };
      const t = setTimeout(() => cached().then(r => r && finish(r)), 4000);
      net.then(r => { clearTimeout(t); finish(r); }).catch(() => { clearTimeout(t); cached().then(r => finish(r || Response.error())); });
    }));
    e.waitUntil(net.catch(() => {}));
    return;
  }
  // Fonts and the sync library: cache first
  e.respondWith(caches.match(req).then(hit => hit || fetch(req).then(res => { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); return res; })));
});
// Tapping an alarm notification brings Lab Rat to the front
self.addEventListener("notificationclick", e => {
  e.notification.close();
  e.waitUntil(self.clients.matchAll({ type: "window", includeUncontrolled: true }).then(list => {
    for (const c of list) { if ("focus" in c) return c.focus(); }
    return self.clients.openWindow ? self.clients.openWindow("./") : null;
  }));
});
