/// Pure helpers for magic-link deep links vs legacy go_router auth gates.
library;

/// Resolves GoRouter [initialLocation] from a browser [Uri].
///
/// Prefers the hash path (`#/bridge`) so cold-start deep links survive async
/// boot (FutureBuilder / delayed MaterialApp.router). Falls back to [fallback]
/// when the fragment is empty or only `/`.
String resolveGoRouterInitialLocation(
  Uri uri, {
  String fallback = '/',
}) {
  final fragment = uri.fragment.trim();
  if (fragment.isEmpty) return fallback;

  final withSlash = fragment.startsWith('/') ? fragment : '/$fragment';
  final q = withSlash.indexOf('?');
  final path = q >= 0 ? withSlash.substring(0, q) : withSlash;
  if (path.isEmpty || path == '/') return fallback;
  return path;
}

/// Whether [matchedLocation] may be opened without [isLoggedIn].
bool isUnrestrictedLocation(
  String matchedLocation,
  List<String> unrestrictedRoutes,
) =>
    unrestrictedRoutes.contains(matchedLocation);

/// Auth / magic-link redirect decision.
///
/// Returns a location to navigate to, or null to keep [matchedLocation].
///
/// Rescue: when the document still has `?t=…` (App→Web magic link) but the
/// hash route was lost and we landed on `/` or `/dashboard` while logged out,
/// send the user to `/bridge` so BridgeScreen can exchange the token.
/// Does **not** rescue `/login` so an explicit "Go to login" after a failed
/// exchange is not bounced back into a spent-token loop.
String? resolveAuthRedirect({
  required String matchedLocation,
  required bool isLoggedIn,
  required Map<String, String> documentQuery,
  required List<String> unrestrictedRoutes,
  required List<String> publicRoutes,
  bool isAuthCheckPending = false,
  String loginRoute = '/login',
  String bridgeRoute = '/bridge',
  String homeRoute = '/',
  String dashboardRoute = '/dashboard',
}) {
  final token = documentQuery['t']?.trim() ?? '';
  if (token.isNotEmpty &&
      !isLoggedIn &&
      !isAuthCheckPending &&
      (matchedLocation == homeRoute || matchedLocation == dashboardRoute)) {
    return bridgeRoute;
  }

  if (isUnrestrictedLocation(matchedLocation, unrestrictedRoutes)) {
    return null;
  }

  if (publicRoutes.contains(matchedLocation)) {
    if (isLoggedIn) return homeRoute;
    return null;
  }

  if (!isLoggedIn) {
    if (isAuthCheckPending) return null;
    return loginRoute;
  }

  return null;
}
