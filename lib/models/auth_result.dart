/// Represents the outcome of an authentication operation.
class AuthResult {
  final bool success;
  final String? errorMessage;

  const AuthResult._({required this.success, this.errorMessage});

  /// Constructs a successful auth result.
  const AuthResult.success() : this._(success: true);

  /// Constructs a failed auth result with an optional [errorMessage].
  const AuthResult.failure([String? errorMessage])
      : this._(success: false, errorMessage: errorMessage);

  @override
  String toString() =>
      'AuthResult(success: $success, errorMessage: $errorMessage)';
}
