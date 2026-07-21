class Config {
  static String _apiUrl = '';
  static String _locale = '';
  static bool _isBffMode = true;
  static bool _isDev = false;

  static String get apiUrl => _apiUrl;
  static String get locale => _locale;
  static bool get isBffMode => _isBffMode;

  /// True when launched via [main_dev.dart] / [main_local.dart].
  /// Use for in-progress features (e.g. catalog discovery) that must not
  /// appear in production builds from [main.dart].
  static bool get isDev => _isDev;

  static void init({
    required String apiUrl,
    required String locale,
    bool isBffMode = true,
    bool isDev = false,
  }) {
    _apiUrl = apiUrl;
    _locale = locale.isNotEmpty ? locale : 'fr';
    _isBffMode = isBffMode;
    _isDev = isDev;
  }
}