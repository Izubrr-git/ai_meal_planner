class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ParsingException extends ApiException {
  ParsingException(super.message);
}

class ValidationException extends ApiException {
  ValidationException(super.message);
}