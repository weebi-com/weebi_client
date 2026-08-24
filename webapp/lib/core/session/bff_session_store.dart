import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/constants/values.dart';

/// Persists the BFF [sessionId] returned by the server after login/refresh.
///
/// Envoy looks up the JWT from this id. The HttpOnly `weebi_session_id` cookie
/// is preferred, but after Stripe/PawaPay redirects third-party cookies are
/// often blocked — [SessionRecoveryCoordinator] therefore also sends this value
/// as `x-session-id` (allowlisted in Envoy CORS).
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
