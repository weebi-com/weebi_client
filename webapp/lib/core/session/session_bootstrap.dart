import 'package:web_admin/core/session/bff_session_store.dart';
import 'package:web_admin/providers/user_data_provider.dart';

/// Result of a BFF session refresh (cookie re-issue).
class SessionRestoreResult {
  const SessionRestoreResult({required this.sessionId});

  final String sessionId;
}

/// Cold-start BFF session restore. Re-issues the HttpOnly cookie by calling
/// authenticateWithRefreshToken when Stay connected is on and a session id
/// is still in localStorage.
class SessionBootstrap {
  SessionBootstrap._();

  static Future<void> restore({
    required UserDataProvider userDataProvider,
    required Future<SessionRestoreResult> Function() refreshSession,
    bool isBffMode = true,
  }) async {
    if (!isBffMode) return;

    if (!userDataProvider.stayConnected) {
      await userDataProvider.clearSessionDataAsync();
      return;
    }

    final sessionId = await BffSessionStore.getSessionId();
    if (sessionId == null || sessionId.isEmpty) {
      if (userDataProvider.bffSessionId.isNotEmpty) {
        await userDataProvider.clearSessionDataAsync();
      }
      return;
    }

    try {
      final restored = await refreshSession();
      if (restored.sessionId.isEmpty) {
        await userDataProvider.clearSessionDataAsync();
        return;
      }
      await userDataProvider.setUserDataAsync(
        bffSessionId: restored.sessionId,
        stayConnected: true,
        bffSessionLive: true,
      );
    } catch (_) {
      await userDataProvider.clearSessionDataAsync();
    }
  }
}
