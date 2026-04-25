class SignUpResult {
  final bool success;
  final String? userId;
  final String? errorMessage;

  SignUpResult({required this.success, this.userId, this.errorMessage});
}
