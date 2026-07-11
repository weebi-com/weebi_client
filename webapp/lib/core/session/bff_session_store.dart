import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/constants/values.dart';

/// Persists the BFF [sessionId] returned by the server after login/refresh.
///
/// Envoy normally forwards the session cookie as `x-session-id` metadata, but
/// when the cookie is missing or stale the client can still attach the stored
/// session id so refresh and protected RPCs remain recoverable.
class BffSessionStore {
  BffSessionStore._();

  static Future<void> setSessionId(String sessionId) async {
    if (sessionId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharePrefKeys.bffSessionId, sessionId);
  }

  static Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(SharePrefKeys.bffSessionId);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharePrefKeys.bffSessionId);
  }
}
