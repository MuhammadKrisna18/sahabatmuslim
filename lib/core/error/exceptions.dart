class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Error']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache Error']);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network Error']);

  @override
  String toString() => message;
}

class LocationException implements Exception {
  final String message;
  LocationException([this.message = 'Location Error']);

  @override
  String toString() => message;
}
