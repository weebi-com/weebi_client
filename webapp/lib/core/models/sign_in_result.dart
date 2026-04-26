class SignInResult {
  final bool success;
  final String? message;
  final String? errorMessage;
  /// Access token when [success] is true (saved to SharedPreferences by AuthService).
  final String? accessToken;

  SignInResult({
    required this.success,
    this.message,
    this.errorMessage,
    this.accessToken,
  });
}
