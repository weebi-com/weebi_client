/// Envoy proxy URL for gRPC. Change this when merging between dev and prod.
/// - Dev branch: use [kApiUrlDev]
/// - Prod / main: use [kApiUrl]
const String kApiUrl =
    'https://weebi-envoyproxy-prd-29758828833.europe-west1.run.app';

/// Dev Envoy (used by `lib/main_dev.dart` regardless of [kApiUrl]).
const String kApiUrlDev =
    'https://weebi-envoyproxy-dev-29758828833.europe-west1.run.app';
