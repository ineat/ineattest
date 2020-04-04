'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "6e56e5bff62f902571302df3fee580c2",
"/": "6e56e5bff62f902571302df3fee580c2",
"main.dart.js": "409fc1890ca058d7dc3516a1faa2dabe",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "c29fe814afd1f1f06149096d5a0693ae",
"assets/LICENSE": "14c5d155e6bca897920de30a1a19c6c2",
"assets/AssetManifest.json": "00771fbc62002ad1e13c64cd89e61994",
"assets/FontManifest.json": "01700ba55b08a6141f33e168c4a6c22f",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/assets/work.png": "af850dd66108c52ec214be2c24178bec",
"assets/assets/arrow_bottom_right.png": "3e5bf90d5eb197e36c8b5abb2495da0a",
"assets/assets/health.png": "6f394a6a25236fc875652240f29ba206",
"assets/assets/family.png": "c75b4730ab14a730a575b2d6dd8056d6",
"assets/assets/checked.png": "5017049dfb5086c51faedf406ba508c8",
"assets/assets/sport.png": "094f21fcac8834b84b3e473933912247",
"assets/assets/food.png": "daef45c855d772660d9b02d1bdac1e24",
"assets/assets/poulpy.png": "8dc8633f35cad5a7ac1b2c1ddc24b520",
"assets/assets/arial.ttf": "5995c725ca5a13be62d3dc75c2fc59fc",
"assets/assets/icn_appstore.png": "31b3b93aa6664852f48eb0e0d9627667",
"assets/assets/unchecked.png": "cd01dbf009c254c017ce72c753381d57",
"assets/assets/poulpymasque.png": "adb1f70cb11c677dbfae18b818eecc35",
"assets/assets/icn_googleplay.png": "31b3b93aa6664852f48eb0e0d9627667",
"assets/assets/i18n/fr.yaml": "fc9ab7f59836cd671a1f1774f9fad058"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
