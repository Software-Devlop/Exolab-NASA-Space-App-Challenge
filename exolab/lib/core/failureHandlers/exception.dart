class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (StatusCode: $statusCode)';
}

class LocalDatabaseException implements Exception {
  final String message;
  const LocalDatabaseException(this.message);

  @override
  String toString() => 'LocalDatabaseException: $message';
}
