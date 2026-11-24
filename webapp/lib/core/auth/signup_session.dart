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
