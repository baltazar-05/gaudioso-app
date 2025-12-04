import '../../services/api_service.dart';
import 'package:http_parser/http_parser.dart';

class ApiAuthService {
  Future<Map<String, dynamic>> register(String username, String password) async {
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

  Future<Map<String, dynamic>> me() async {
    final res = await ApiService.getJson('/api/auth/me');
    if (res is Map<String, dynamic>) {
      return _parseUser(res);
    }
    throw Exception('Resposta inesperada ao carregar usuario atual');
  }

  Future<Map<String, dynamic>> updateNome(String novoNome) async {
    final res = await ApiService.putJson('/api/auth/me/nome', {'nome': novoNome});
    if (res is Map<String, dynamic>) {
      return _parseUser(res);
    }
    throw Exception('Resposta inesperada ao atualizar nome');
  }

  Future<void> updateSenha(String senhaAtual, String novaSenha) async {
    await ApiService.putJson('/api/auth/me/senha', {
      'senhaAtual': senhaAtual,
      'novaSenha': novaSenha,
    });
  }

  Map<String, dynamic> _parseAuthResponse(dynamic res) {
    final parsedUser = _parseUser(res);
    if (res is Map<String, dynamic>) {
      final token = res['token'];
      if (token is String && token.isNotEmpty) {
        return {...parsedUser, 'token': token};
      }
    }
    throw Exception('Resposta de autenticacao inesperada');
  }

  Map<String, dynamic> _parseUser(Map<String, dynamic> res) {
    final apiUsername = res['username'];
    final nome = res['nome'];
    final rawId = res['id'];
    final roleRaw = res['role'];
    final avatarUrl = res['avatarUrl'];

    int? id;
    if (rawId is int) {
      id = rawId;
    } else if (rawId is num) {
      id = rawId.toInt();
    } else if (rawId is String) {
      id = int.tryParse(rawId);
    }

    final role = roleRaw is String && roleRaw.isNotEmpty ? roleRaw.toLowerCase() : 'funcionario';
    if (apiUsername is String) {
      return {
        if (id != null) 'id': id,
        'username': apiUsername,
        'nome': nome is String && nome.isNotEmpty ? nome : apiUsername,
        'role': role,
        if (avatarUrl is String && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
      };
    }
    throw Exception('Usuario invalido na resposta');
  }

  Future<String?> updateAvatar(String filePath) async {
    final res = await ApiService.uploadFile(
      '/api/auth/me/avatar',
      filePath,
      contentType: MediaType('image', 'png'),
    );
    if (res is Map<String, dynamic>) {
      final url = res['avatarUrl'];
      if (url is String && url.isNotEmpty) return url;
    }
    return null;
  }
}
