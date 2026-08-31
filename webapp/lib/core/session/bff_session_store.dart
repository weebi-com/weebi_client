import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/constants/values.dart';

/// Holds the BFF [sessionId] returned by the server after login/refresh.
///
/// Auth itself relies on the HttpOnly session cookie set by Envoy
/// (`withCredentials: true`). [sessionId] is also sent as `x-session-id`
/// when third-party cookies are blocked (Envoy must CORS-allowlist it) —
/// including after Stripe/PawaPay redirects.
///
/// When [persist] is false (Stay connected off), the id lives in memory
/// for this tab only and is not written to localStorage.
class BffSessionStore {
  BffSessionStore._();

  static String? _memorySessionId;

  static Future<void> setSessionId(
    String sessionId, {
    bool persist = true,
  }) async {
    if (sessionId.isEmpty) return;
    _memorySessionId = sessionId;
    final prefs = await SharedPreferences.getInstance();
    if (persist) {
      await prefs.setString(SharePrefKeys.bffSessionId, sessionId);
    } else {
      await prefs.remove(SharePrefKeys.bffSessionId);
    }
  }

  static Future<String?> getSessionId() async {
    if (_memorySessionId != null && _memorySessionId!.isNotEmpty) {
      return _memorySessionId;
    }
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(SharePrefKeys.bffSessionId);
    if (value == null || value.isEmpty) return null;
    _memorySessionId = value;
    return value;
  }

  static Future<void> clear() async {
    _memorySessionId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SharePrefKeys.bffSessionId);
  }
}
