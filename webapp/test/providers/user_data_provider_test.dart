import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/constants/values.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/providers/user_data_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Config.init(apiUrl: 'http://localhost', locale: 'fr', isBffMode: true);
  });

  test('BFF: mail in prefs is not logged in until live session is verified',
      () async {
    SharedPreferences.setMockInitialValues({
      SharePrefKeys.mail: 'a@b.c',
      SharePrefKeys.bffSessionId: 'session-1',
    });
    final provider = UserDataProvider();
    await provider.loadAsync();

    expect(provider.isBffSessionCheckPending, isTrue);
    expect(provider.isUserLoggedIn(), isFalse);

    await provider.verifyLiveBffSession(() async {});
    expect(provider.isUserLoggedIn(), isTrue);
    expect(provider.isBffSessionCheckPending, isFalse);
  });

  test('BFF: dead session probe clears mail so UI is logged out', () async {
    SharedPreferences.setMockInitialValues({
      SharePrefKeys.mail: 'a@b.c',
      SharePrefKeys.bffSessionId: 'stale',
    });
    final provider = UserDataProvider();
    await provider.loadAsync();

    await provider.verifyLiveBffSession(
      () async => throw Exception('unauthenticated'),
      isDeadSession: (_) => true,
    );

    expect(provider.isUserLoggedIn(), isFalse);
    expect(provider.mail, isEmpty);
    expect(provider.isBffSessionCheckPending, isFalse);
  });

  test('BFF: login path can mark session live without a probe', () async {
    final provider = UserDataProvider();
    await provider.loadAsync();
    await provider.setUserDataAsync(mail: 'a@b.c', bffSessionLive: true);
    expect(provider.isUserLoggedIn(), isTrue);
  });

  test('non-BFF still requires access token, not session verification',
      () async {
    Config.init(apiUrl: 'http://localhost', locale: 'fr', isBffMode: false);
    SharedPreferences.setMockInitialValues({
      SharePrefKeys.mail: 'a@b.c',
      SharePrefKeys.accessToken: 'jwt',
    });
    final provider = UserDataProvider();
    await provider.loadAsync();
    expect(provider.isUserLoggedIn(), isTrue);
  });
}
