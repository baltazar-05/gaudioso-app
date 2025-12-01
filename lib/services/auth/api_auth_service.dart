import '../../services/api_service.dart';

class ApiAuthService {
  Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    final res = await ApiService.postJson('/api/auth/register', {
      'username': username,
      'senha': password,
      'nome': username,
    });
    return _parseAuthResponse(res);
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await ApiService.postJson('/api/auth/login', {
      'username': username,
      'senha': password,
    });
    return _parseAuthResponse(res);
  }

  Map<String, dynamic> _parseAuthResponse(dynamic res) {
    if (res is Map<String, dynamic>) {
      final token = res['token'];
      final apiUsername = res['username'];
      final nome = res['nome'];
      final rawId = res['id'];
      final role = res['role'];

      int? id;
      if (rawId is int) {
        id = rawId;
      } else if (rawId is num) {
        id = rawId.toInt();
      } else if (rawId is String) {
        id = int.tryParse(rawId);
      }

      if (token is String && apiUsername is String) {
        return {
          'token': token,
          'username': apiUsername,
          'nome': nome is String && nome.isNotEmpty ? nome : apiUsername,
          if (id != null) 'id': id,
          if (role != null) 'role': role,
        };
      }
    }
    throw Exception('Resposta de autenticacao inesperada');
  }
}
