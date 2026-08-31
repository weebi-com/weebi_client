class SignUpResult {
  final bool success;
  final String? userId;
  final String? errorMessage;

  /// True when this signup also created a firm (boss path, not invited user).
  final bool firmCreated;

  /// Access token when [success] is true in JWT mode.
  final String? accessToken;

  /// BFF session id when [success] is true in BFF mode.
  final String? sessionId;

  SignUpResult({
    required this.success,
    this.userId,
    this.errorMessage,
    this.firmCreated = false,
    this.accessToken,
    this.sessionId,
  });
}
