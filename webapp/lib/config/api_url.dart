/// Production Envoy. Compiled fallback for [loadConfig] when `/config.json`
/// has no `API_URL`. Deployed dev and prod override this via the container
/// env; do not swap this constant per branch.
const String kApiUrl =
    'https://weebi-envoyproxy-prd-29758828833.europe-west1.run.app';

/// Dev Envoy for local `lib/main_dev.dart` only. Deployed dev uses `API_URL`.
const String kApiUrlDev =
    'https://weebi-envoyproxy-dev-29758828833.europe-west1.run.app';
