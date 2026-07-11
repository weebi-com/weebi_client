import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/constants/values.dart';
import 'package:web_admin/core/session/bff_session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores and clears BFF session id', () async {
    await BffSessionStore.setSessionId('session-abc');
    expect(await BffSessionStore.getSessionId(), 'session-abc');

    await BffSessionStore.clear();
    expect(await BffSessionStore.getSessionId(), isNull);
  });

  test('ignores empty session id writes', () async {
    await BffSessionStore.setSessionId('');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SharePrefKeys.bffSessionId), isNull);
  });
}
