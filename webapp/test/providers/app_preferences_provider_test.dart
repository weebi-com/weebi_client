import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/providers/app_preferences_provider.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/core/constants/values.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppPreferencesProvider Date Formatting regression test', () {
    late AppPreferencesProvider provider;
    late SharedPreferences sharedPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPrefs = await SharedPreferences.getInstance();
      provider = AppPreferencesProvider();
      
      // Initialize Config for tests
      Config.init(apiUrl: 'test', locale: 'fr');
    });

    test('loadAsync should initialize date formatting for French locale', () async {
      // 1. Set locale to French in preferences
      await sharedPrefs.setString(SharePrefKeys.appLanguageCode, 'fr');
      
      // 2. Load preferences (this now calls initializeDateFormatting)
      await provider.loadAsync(sharedPrefs);
      
      // 3. Verify that DateFormat can format in French without throwing
      final date = DateTime(2026, 8, 26);
      expect(
        () => DateFormat.yMMMd('fr').format(date),
        returnsNormally,
        reason: 'DateFormat should have access to French symbols after provider initialization',
      );
      
      final result = DateFormat.yMMMd('fr').format(date);
      expect(result.toLowerCase(), contains('août'), reason: 'Should use French month name');
    });

    test('setLocaleAsync should initialize date formatting for new locale', () async {
      // 1. Start with English (usually works by default, but let's be explicit)
      await provider.setLocaleAsync(locale: const Locale('en'), save: false);
      
      // 2. Switch to Chinese (simplified)
      const zhLocale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
      await provider.setLocaleAsync(locale: zhLocale, save: false);
      
      // 3. Verify formatting works for Chinese
      final date = DateTime(2026, 8, 26);
      expect(
        () => DateFormat.yMMMd('zh_Hans').format(date),
        returnsNormally,
        reason: 'DateFormat should have access to Chinese symbols after locale switch',
      );
    });
  });
}
