abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class ServerException extends AppException {
  const ServerException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class CacheException extends AppException {
  const CacheException({
    required String message,
  }) : super(message: message);
}

class AuthenticationException extends AppException {
  const AuthenticationException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}

class ValidationException extends AppException {
  const ValidationException({
    required String message,
  }) : super(message: message);
}

class UnknownException extends AppException {
  const UnknownException({
    String message = 'An unknown error occurred',
  }) : super(message: message);
}

class UnauthorizedException extends AuthenticationException {
  const UnauthorizedException({
    required String message,
    int? statusCode,
  }) : super(message: message, statusCode: statusCode);
}
