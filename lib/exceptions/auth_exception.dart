class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException(super.message);
}

class BadRequestException extends AuthException {
  BadRequestException(super.message);
}

class NetworkException extends AuthException {
  NetworkException(super.message);
}

// Add more as needed, e.g., UserNotFoundException, AccountLockedException