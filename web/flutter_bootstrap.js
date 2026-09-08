{{flutter_js}}
{{flutter_build_config}}

async function prepareImageCache() {
  if (!('serviceWorker' in navigator) || !window.isSecureContext) return;
  try {
    const url = new URL('image_cache_sw.js', document.baseURI);
    const registration = await navigator.serviceWorker.register(url, {scope: new URL('.', url).pathname, updateViaCache: 'none'});
    await registration.update();
    const installing = registration.installing;
    if (installing && installing.state !== 'activated') {
      await new Promise((resolve) => {
        const changed = () => {
          if (installing.state === 'activated' || installing.state === 'redundant') {
            installing.removeEventListener('statechange', changed);
            resolve();
          }
        };
        installing.addEventListener('statechange', changed);
        changed();
      });
    }
    if (!navigator.serviceWorker.controller) {
      await new Promise((resolve) => {
        const ready = () => {
          navigator.serviceWorker.removeEventListener('controllerchange', ready);
          resolve();
        };
        navigator.serviceWorker.addEventListener('controllerchange', ready);
        if (navigator.serviceWorker.controller) ready();
      });
    }
  } catch (_) {
    // Unsupported/private browsing must not prevent app startup.
  }
}

const userAgent = navigator.userAgent || "";
const isSocialInAppBrowser =
  /FBAN|FBAV|Messenger|Instagram|Line\/|Line |MicroMessenger|WeChat|Viber|Telegram|Twitter|X\/|Snapchat|LinkedInApp|Pinterest/i.test(
    userAgent,
  );

window.__PPCTS_SOCIAL_INAPP__ = isSocialInAppBrowser;

if (isSocialInAppBrowser) {
  document.documentElement.setAttribute("data-social-inapp", "true");
}

const splash = document.getElementById("app-startup-splash");
let splashRemoved = false;

function removeSplashWhenFirstFrameIsLikelyReady() {
  if (!splash || splashRemoved) {
    return;
  }
  splashRemoved = true;

  const remove = () => {
    splash.style.opacity = "0";
    splash.style.transition = "opacity 120ms ease-out";
    window.setTimeout(() => {
      splash.remove();
      if (typeof window.__syncThemeColor === "function") {
        window.__syncThemeColor();
      }
    }, 120);
  };

  window.requestAnimationFrame(() => {
    window.requestAnimationFrame(() => {
      window.requestAnimationFrame(remove);
    });
  });
}

async function loadFlutterApp() {
  let timeout;
  await Promise.race([prepareImageCache(), new Promise(resolve => { timeout = setTimeout(resolve, 2000); })]);
  clearTimeout(timeout);
  await _flutter.loader.load({
    config: {
      canvasKitBaseUrl: "canvaskit/",
    },
    onEntrypointLoaded: async function (engineInitializer) {
      const fallbackRemovalTimer = window.setTimeout(
        removeSplashWhenFirstFrameIsLikelyReady,
        4000,
      );
      window.addEventListener(
        "flutter-first-frame",
        () => {
          window.clearTimeout(fallbackRemovalTimer);
          removeSplashWhenFirstFrameIsLikelyReady();
        },
        { once: true },
      );
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
    },
  });
}

window.__PPCTS_START_FLUTTER__ = loadFlutterApp;

if (!isSocialInAppBrowser) {
  window.__PPCTS_START_FLUTTER__();
}
