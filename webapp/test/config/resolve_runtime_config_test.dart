import 'package:flutter_test/flutter_test.dart';
import 'package:web_admin/config/api_url.dart';
import 'package:web_admin/config/resolve_runtime_config.dart';
import 'package:web_admin/config_loader.dart';
import 'package:web_admin/environment.dart';

void main() {
  const prod = 'https://weebi-envoyproxy-prd.example';
  const dev = 'https://weebi-envoyproxy-dev.example';

  group('resolveRuntimeConfig', () {
    test('container API_URL overrides the compiled production URL', () {
      final resolved = resolveRuntimeConfig(
        compiledApiUrl: prod,
        runtime: {
          'API_URL': dev,
          'LOCALE': 'fr',
          'IS_BFF_MODE': 'true',
          'IS_DEV': 'true',
        },
      );

      expect(resolved.apiUrl, dev);
      expect(resolved.locale, 'fr');
      expect(resolved.isBffMode, isTrue);
      expect(resolved.isDev, isTrue);
    });

    test('blank or missing API_URL keeps the compiled production URL', () {
      for (final runtime in <Map<String, dynamic>?>[
        null,
        {},
        {'API_URL': ''},
        {'API_URL': '   '},
        {'API_URL': null},
        {'LOCALE': 'en', 'IS_DEV': 'true', 'IS_BFF_MODE': 'false'},
      ]) {
        final resolved = resolveRuntimeConfig(
          compiledApiUrl: prod,
          runtime: runtime,
        );
        expect(resolved.apiUrl, prod, reason: '$runtime');
        expect(resolved.locale, 'fr', reason: '$runtime');
        expect(resolved.isBffMode, isTrue, reason: '$runtime');
        expect(resolved.isDev, isFalse, reason: '$runtime');
      }
    });

    test('explicit runtime flags are honored only with a URL', () {
      final resolved = resolveRuntimeConfig(
        compiledApiUrl: prod,
        runtime: {
          'API_URL': dev,
          'IS_BFF_MODE': 'false',
          'IS_DEV': false,
        },
      );

      expect(resolved.apiUrl, dev);
      expect(resolved.isBffMode, isFalse);
      expect(resolved.isDev, isFalse);
    });

    test('missing BFF flag stays on, missing dev flag stays off', () {
      final resolved = resolveRuntimeConfig(
        compiledApiUrl: prod,
        runtime: {'API_URL': dev},
      );

      expect(resolved.isBffMode, isTrue);
      expect(resolved.isDev, isFalse);
    });
  });

  test('loadConfig with no config.json falls back to compiled kApiUrl', () async {
    await loadConfig();

    expect(Config.apiUrl, kApiUrl);
    expect(Config.locale, 'fr');
    expect(Config.isBffMode, isTrue);
    expect(Config.isDev, isFalse);
  });
}
