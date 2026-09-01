import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/constants/values.dart';
import 'package:web_admin/core/session/bff_session_store.dart';
import 'package:web_admin/core/session/session_bootstrap.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/providers/user_data_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Config.init(apiUrl: 'http://localhost', locale: 'fr', isBffMode: true);
    await BffSessionStore.clear();
  });

  group('BffSessionStore', () {
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

    test('persist false keeps id in memory only', () async {
      await BffSessionStore.setSessionId('mem-only', persist: false);
      expect(await BffSessionStore.getSessionId(), 'mem-only');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(SharePrefKeys.bffSessionId), isNull);
    });

    test('forgetMemory reloads id from prefs (tab-close analogue)', () async {
      await BffSessionStore.setSessionId('persisted-sid');
      BffSessionStore.forgetMemory();
      expect(await BffSessionStore.getSessionId(), 'persisted-sid');
    });
  });

  group('UserDataProvider logged-in gate', () {
    test('BFF requires mail and session id', () async {
      final provider = UserDataProvider();
      await provider.loadAsync();
      expect(provider.isUserLoggedIn(), isFalse);

      await provider.setUserDataAsync(mail: 'a@b.com');
      expect(provider.isUserLoggedIn(), isFalse);

      await provider.setUserDataAsync(
        mail: 'a@b.com',
        bffSessionId: 'sid',
        stayConnected: true,
      );
      expect(provider.isUserLoggedIn(), isTrue);
      expect(await BffSessionStore.getSessionId(), 'sid');
    });

    test('clearSessionDataAsync keeps remembered mail', () async {
      final provider = UserDataProvider();
      await provider.setUserDataAsync(
        mail: 'keep@weebi.com',
        bffSessionId: 'sid',
        stayConnected: true,
      );
      await provider.clearSessionDataAsync();
      expect(provider.mail, 'keep@weebi.com');
      expect(provider.bffSessionId, isEmpty);
      expect(provider.isUserLoggedIn(), isFalse);
      expect(await BffSessionStore.getSessionId(), isNull);
    });
  });

  group('SessionBootstrap', () {
    test('stayConnected false skips restore and logs out session', () async {
      SharedPreferences.setMockInitialValues({
        SharePrefKeys.mail: 'a@b.com',
        SharePrefKeys.stayConnected: false,
        SharePrefKeys.bffSessionId: 'leftover',
      });
      var refreshed = false;
      final provider = UserDataProvider();
      await provider.loadAsync();

      await SessionBootstrap.restore(
        userDataProvider: provider,
        refreshSession: () async {
          refreshed = true;
          return const SessionRestoreResult(sessionId: 'new');
        },
      );

      expect(refreshed, isFalse);
      expect(provider.mail, 'a@b.com');
      expect(provider.isUserLoggedIn(), isFalse);
    });

    test('stayConnected true with session calls restore', () async {
      SharedPreferences.setMockInitialValues({
        SharePrefKeys.mail: 'a@b.com',
        SharePrefKeys.stayConnected: true,
        SharePrefKeys.bffSessionId: 'old-sid',
      });
      var refreshed = false;
      final provider = UserDataProvider();
      await provider.loadAsync();

      await SessionBootstrap.restore(
        userDataProvider: provider,
        refreshSession: () async {
          refreshed = true;
          return const SessionRestoreResult(sessionId: 'new-sid');
        },
      );

      expect(refreshed, isTrue);
      expect(provider.bffSessionId, 'new-sid');
      expect(provider.isUserLoggedIn(), isTrue);
      expect(await BffSessionStore.getSessionId(), 'new-sid');
    });

    test('refresh failure with live probe keeps session and logs in', () async {
      SharedPreferences.setMockInitialValues({
        SharePrefKeys.mail: 'a@b.com',
        SharePrefKeys.stayConnected: true,
        SharePrefKeys.bffSessionId: 'old-sid',
      });
      var probed = false;
      final provider = UserDataProvider();
      await provider.loadAsync();
      expect(provider.isUserLoggedIn(), isFalse);
      expect(provider.isBffSessionCheckPending, isTrue);

      await SessionBootstrap.restore(
        userDataProvider: provider,
        refreshSession: () async => throw Exception('refresh rpc failed'),
        probeLiveSession: () async {
          probed = true;
        },
      );

      expect(probed, isTrue);
      expect(provider.mail, 'a@b.com');
      expect(provider.isUserLoggedIn(), isTrue);
      expect(await BffSessionStore.getSessionId(), 'old-sid');
    });

    test('refresh failure with dead probe logs out but keeps mail', () async {
      SharedPreferences.setMockInitialValues({
        SharePrefKeys.mail: 'a@b.com',
        SharePrefKeys.stayConnected: true,
        SharePrefKeys.bffSessionId: 'old-sid',
      });
      final provider = UserDataProvider();
      await provider.loadAsync();

      await SessionBootstrap.restore(
        userDataProvider: provider,
        refreshSession: () async => throw Exception('refresh rpc failed'),
        probeLiveSession: () async => throw Exception('unauthenticated'),
        isDeadSession: (_) => true,
      );

      expect(provider.mail, 'a@b.com');
      expect(provider.isUserLoggedIn(), isFalse);
      expect(await BffSessionStore.getSessionId(), isNull);
    });

    test('refresh failure without probe does not wipe stored session', () async {
      SharedPreferences.setMockInitialValues({
        SharePrefKeys.mail: 'a@b.com',
        SharePrefKeys.stayConnected: true,
        SharePrefKeys.bffSessionId: 'old-sid',
      });
      final provider = UserDataProvider();
      await provider.loadAsync();

      await SessionBootstrap.restore(
        userDataProvider: provider,
        refreshSession: () async => throw Exception('refresh rpc failed'),
      );

      expect(provider.mail, 'a@b.com');
      expect(provider.isUserLoggedIn(), isFalse);
      expect(provider.isBffSessionCheckPending, isTrue);
      expect(await BffSessionStore.getSessionId(), 'old-sid');
    });

    test('empty refresh sessionId falls through to live probe', () async {
      SharedPreferences.setMockInitialValues({
        SharePrefKeys.mail: 'a@b.com',
        SharePrefKeys.stayConnected: true,
        SharePrefKeys.bffSessionId: 'old-sid',
      });
      var probed = false;
      final provider = UserDataProvider();
      await provider.loadAsync();

      await SessionBootstrap.restore(
        userDataProvider: provider,
        refreshSession: () async => const SessionRestoreResult(sessionId: ''),
        probeLiveSession: () async {
          probed = true;
        },
      );

      expect(probed, isTrue);
      expect(provider.isUserLoggedIn(), isTrue);
      expect(await BffSessionStore.getSessionId(), 'old-sid');
    });

    test('stayConnected true without session id skips restore', () async {
      SharedPreferences.setMockInitialValues({
        SharePrefKeys.mail: 'a@b.com',
        SharePrefKeys.stayConnected: true,
      });
      var refreshed = false;
      final provider = UserDataProvider();
      await provider.loadAsync();

      await SessionBootstrap.restore(
        userDataProvider: provider,
        refreshSession: () async {
          refreshed = true;
          return const SessionRestoreResult(sessionId: 'new');
        },
      );

      expect(refreshed, isFalse);
      expect(provider.mail, 'a@b.com');
      expect(provider.isUserLoggedIn(), isFalse);
    });
  });
}
