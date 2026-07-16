import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/core/constants/values.dart';

/// Persists the BFF [sessionId] returned by the server after login/refresh.
///
/// Used locally to know a BFF session was established. Auth itself relies on
/// the HttpOnly session cookie set by Envoy (`withCredentials: true`). Do not
/// send this id as a custom browser header — that breaks CORS.
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
