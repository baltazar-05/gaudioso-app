class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static String endpoint(String path) {
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return '$baseUrl$path';
  }
}
