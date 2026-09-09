import 'package:web_admin/core/session/bff_session_store.dart';
import 'package:web_admin/providers/user_data_provider.dart';

/// Result of a BFF session refresh (cookie re-issue).
class SessionRestoreResult {
  const SessionRestoreResult({required this.sessionId});

  final String sessionId;
}

/// Cold-start BFF session restore.
///
/// Cookie re-issue ([refreshSession]) is best-effort. The live session probe
/// ([probeLiveSession], typically `readOneUser` with `x-session-id`) is the
/// source of truth. A failed refresh must not wipe a still-valid session.
class SessionBootstrap {
  SessionBootstrap._();

  static Future<void> restore({
    required UserDataProvider userDataProvider,
    Future<SessionRestoreResult> Function()? refreshSession,
    Future<void> Function()? probeLiveSession,
    bool Function(Object error)? isDeadSession,
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

    if (refreshSession != null) {
      try {
        final restored = await refreshSession();
        if (restored.sessionId.isNotEmpty) {
          await userDataProvider.setUserDataAsync(
            bffSessionId: restored.sessionId,
            stayConnected: true,
            bffSessionLive: true,
          );
          return;
        }
      } catch (_) {
        // Fall through to the live probe. Do not clear prefs here.
      }
    }

    if (probeLiveSession != null) {
      await userDataProvider.verifyLiveBffSession(
        probeLiveSession,
        isDeadSession: isDeadSession,
      );
    }
  }
}
