class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE',
    // Default to the fixed public domain behind Cloudflare Tunnel
      Override at runtime with: --dart-define=API_BASE=https:,
    // defaultValue: 'http://192.168.0.168:8080',
  );

  static String endpoint(String path) {
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return '$baseUrl$path';
  }
}
