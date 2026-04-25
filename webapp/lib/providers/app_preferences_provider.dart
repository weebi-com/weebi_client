import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/environment.dart';

import '../core/constants/values.dart';

class AppPreferencesProvider extends ChangeNotifier {
  var _locale = Locale(Config.locale.isNotEmpty ? Config.locale : 'fr');
  var _themeMode = ThemeMode.system;

  Locale get locale => _locale;

  ThemeMode get themeMode => _themeMode;

  void loadAsync(SharedPreferences sharedPref) {
    final langCode = (sharedPref.getString(SharePrefKeys.appLanguageCode) ??
            Config.locale)
        .trim();
    final effectiveLangCode = langCode.isNotEmpty ? langCode : 'fr';

    if (effectiveLangCode.contains('_')) {
      final values = effectiveLangCode.split('_');
      final lang = values[0].isNotEmpty ? values[0] : 'fr';
      final script = values.length > 1 && values[1].isNotEmpty ? values[1] : null;
      _locale = Locale.fromSubtags(languageCode: lang, scriptCode: script);
    } else {
      _locale = Locale(effectiveLangCode);
    }

    _themeMode = ThemeMode.values.byName(
        sharedPref.getString(SharePrefKeys.appThemeMode) ?? ThemeMode.light.name);

    // Defer to avoid "setState during build" - loadAsync can be called from a
    // Future that completes during the build phase (e.g. in RootApp)
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  Future<void> setLocaleAsync({
    required Locale locale,
    save = true,
  }) async {
    if (locale != _locale) {
      _locale = locale;

      if (save) {
        final sharedPref = await SharedPreferences.getInstance();
        var langCode = locale.languageCode;

        if (locale.scriptCode != null) {
          langCode += '_${locale.scriptCode}';
        }

        await sharedPref.setString(SharePrefKeys.appLanguageCode, langCode);
      }

      notifyListeners();
    }
  }

  Future<void> setThemeModeAsync({
    required ThemeMode themeMode,
    bool save = true,
  }) async {
    if (themeMode != _themeMode) {
      _themeMode = themeMode;

      if (save) {
        final sharedPref = await SharedPreferences.getInstance();

        await sharedPref.setString(SharePrefKeys.appThemeMode, themeMode.name);
      }

      notifyListeners();
    }
  }
}
