{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  config: { canvasKitBaseUrl: "canvaskit/" },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    document.getElementById('opening')?.remove();

    // Flutter no longer generates offline caching. The release preparation
    // script replaces the placeholder with a hash of the production artifact
    // set so each deployed application build receives an isolated, atomic cache.
    if ('serviceWorker' in navigator) {
      const isBlink = navigator.vendor === 'Google Inc.' ||
        navigator.userAgent.includes('Edg/');
      const usesChromiumCanvasKit = isBlink &&
        typeof ImageDecoder !== 'undefined' &&
        typeof Intl.v8BreakIterator !== 'undefined' &&
        typeof Intl.Segmenter !== 'undefined';
      const variant = usesChromiumCanvasKit ? 'chromium' : 'full';
      navigator.serviceWorker.register(
        `qalam_service_worker.js?build=__ZARBULMASAL_BUILD_ID__&variant=${variant}`,
        { updateViaCache: 'none' },
      )
        .catch(error => console.warn('Offline preparation unavailable:', error));
    }
  }
});
