import 'package:auth_weebi/auth_weebi.dart' show JsonWebToken;

/// Extracts [UserPermissions.firmId] from a bearer JWT.
///
/// Throws [StateError] when the token is missing or has an empty `firmId`
/// (proto3 JSON omits empty strings, so a wiped permissions payload yields '').
String requireFirmIdFromAccessToken(String token) {
  if (token.trim().isEmpty) {
    throw StateError('access token is empty; cannot resolve firmId');
  }
  final jwt = JsonWebToken.parse(token);
  final firmId = jwt.permissions.firmId;
  if (firmId.isEmpty) {
    throw StateError(
        'access token has empty firmId; cannot create a user for a firm');
  }
  return firmId;
}
