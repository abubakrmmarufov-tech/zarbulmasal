{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  config: { canvasKitBaseUrl: "canvaskit/" },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    document.getElementById('opening')?.remove();
    // Flutter no longer generates offline caching. Keep registration nonblocking;
    // the app remains usable if storage is unavailable or the connection drops.
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('qalam_service_worker.js', {
        updateViaCache: 'none'
      }).catch(error => console.warn('Offline preparation unavailable:', error));
    }
  }
});
