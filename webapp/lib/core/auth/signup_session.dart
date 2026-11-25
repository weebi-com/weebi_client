/// Pure helpers for the signup → createFirm journey.
///
/// Fence `signUp` never creates a firm. After credentials auth, a new boss
/// (`CREATED`) must call `createFirm`. That response carries the credential
/// with `firmId`. Invited users (`UPDATED`) skip firm creation.

/// Whether authenticate* returned enough proof to continue (BFF session vs JWT).
bool signupAuthSucceeded({
  required bool isBffMode,
  required String accessToken,
  required String sessionId,
}) {
  if (isBffMode) return sessionId.isNotEmpty;
  return accessToken.isNotEmpty;
}

/// Invited pending users are `UPDATED` and must not create a second firm.
bool shouldCreateFirmAfterSignup(String statusTypeName) =>
    statusTypeName != 'UPDATED';

/// Returns the access JWT that the client may hold in memory / prefs, or null.
///
/// In BFF mode the JWT lives strictly server-side in `web_sessions`; even if an
/// older backend build populates `accessToken` on a response, the webapp must
/// ignore it and never persist it to `localStorage`.
String? clientAccessTokenForMode({
  required bool isBffMode,
  required String? accessToken,
}) {
  if (isBffMode) return null;
  if (accessToken == null || accessToken.isEmpty) return null;
  return accessToken;
}

/// Validates an optional national phone input for registration.
/// Empty input is valid; non-empty input must be digits of [expectedLength]
/// (or at least 8 digits when [expectedLength] is unknown).
enum OptionalPhoneValidation { valid, notDigits, wrongLength }

OptionalPhoneValidation validateOptionalPhoneDigits(
  String? raw, {
  int? expectedLength,
}) {
  final digits = raw?.trim() ?? '';
  if (digits.isEmpty) return OptionalPhoneValidation.valid;
  if (int.tryParse(digits) == null) return OptionalPhoneValidation.notDigits;
  if (expectedLength != null && digits.length != expectedLength) {
    return OptionalPhoneValidation.wrongLength;
  }
  if (expectedLength == null && digits.length < 8) {
    return OptionalPhoneValidation.wrongLength;
  }
  return OptionalPhoneValidation.valid;
}
