class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ParsingException extends ApiException {
  ParsingException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}