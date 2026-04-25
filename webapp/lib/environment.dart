class Config {
  static String _apiUrl = '';
  static String _locale = '';
  static bool _isBffMode = true;

  static String get apiUrl => _apiUrl;
  static String get locale => _locale;
  static bool get isBffMode => _isBffMode;

  static void init({required String apiUrl, required String locale, bool isBffMode = true}) {
    _apiUrl = apiUrl;
    _locale = locale.isNotEmpty ? locale : 'fr';
    _isBffMode = isBffMode;
  }
}