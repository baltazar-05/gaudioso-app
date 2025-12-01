import 'api_service.dart';

class UsuarioService {
  Future<List<Map<String, dynamic>>> listar() async {
    try {
      final res = await ApiService.getJson('/api/usuarios');
      if (res is List) {
        return List<Map<String, dynamic>>.from(
          res.map((u) => (u as Map<String, dynamic>)),
        );
      }
      return [];
    } catch (e) {
      throw Exception('Erro ao listar usuários: $e');
    }
  }

  Future<void> alterarPermissao(int usuarioId, String novaPermissao) async {
    try {
      await ApiService.putJson('/api/usuarios/$usuarioId/role', {
        'role': novaPermissao,
      });
    } catch (e) {
      throw Exception('Erro ao alterar permissão: $e');
    }
  }

  Future<void> deletarUsuario(int usuarioId) async {
    try {
      await ApiService.delete('/api/usuarios/$usuarioId');
    } catch (e) {
      throw Exception('Erro ao deletar usuário: $e');
    }
  }

  Future<Map<String, dynamic>> criarUsuario(
    String nome,
    String username,
    String password,
    String role,
  ) async {
    try {
      final res = await ApiService.postJson('/api/usuarios', {
        'nome': nome,
        'username': username,
        'email': username,
        'senha': password,
        'role': role,
      });
      return res as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erro ao criar usuário: $e');
    }
  }
}
