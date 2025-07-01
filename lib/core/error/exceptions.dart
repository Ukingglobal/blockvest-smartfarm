class ServerException implements Exception {
  final String message;
  
  const ServerException([this.message = 'Server error occurred']);
  
  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException([this.message = 'Cache error occurred']);
  
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException([this.message = 'Network error occurred']);
  
  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  
  const ValidationException([this.message = 'Validation error occurred']);
  
  @override
  String toString() => 'ValidationException: $message';
}
