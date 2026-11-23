/// Values applied to [Config] after startup.
class ResolvedApiConfig {
  const ResolvedApiConfig({
    required this.apiUrl,
    required this.locale,
    required this.isBffMode,
    required this.isDev,
  });

  final String apiUrl;
  final String locale;
  final bool isBffMode;
  final bool isDev;
}

/// Deployed `API_URL` (from `/config.json`, written by the container env) wins.
///
/// [compiledApiUrl] is used only when the runtime URL is missing or blank.
/// That keeps production on the baked-in Envoy host if `API_URL` is unset.
ResolvedApiConfig resolveRuntimeConfig({
  required String compiledApiUrl,
  Map<String, dynamic>? runtime,
}) {
  final runtimeUrl = _nonEmptyString(runtime?['API_URL']);
  if (runtimeUrl != null) {
    final locale = _nonEmptyString(runtime?['LOCALE']) ?? 'fr';
    return ResolvedApiConfig(
      apiUrl: runtimeUrl,
      locale: locale,
      isBffMode: _flag(runtime, 'IS_BFF_MODE', whenAbsent: true),
      isDev: _flag(runtime, 'IS_DEV', whenAbsent: false),
    );
  }

  return ResolvedApiConfig(
    apiUrl: compiledApiUrl,
    locale: 'fr',
    isBffMode: true,
    isDev: false,
  );
}

String? _nonEmptyString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return trimmed;
}

bool _flag(Map<String, dynamic>? runtime, String key, {required bool whenAbsent}) {
  if (runtime == null || !runtime.containsKey(key)) return whenAbsent;
  final value = runtime[key];
  return value == true || value == 'true';
}
