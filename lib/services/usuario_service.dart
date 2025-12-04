import '../models/usuario.dart';
import 'api_service.dart';

class UsuarioService {
  Future<UsuarioResumo> listar() async {
    final res = await ApiService.getJson('/api/usuarios');
    if (res is Map<String, dynamic>) {
      return UsuarioResumo.fromJson(res);
    }
    throw Exception('Resposta inesperada ao listar usuarios');
  }

  Future<Usuario> alterarRole(int id, String role) async {
    final res = await ApiService.putJson('/api/usuarios/$id/role', {'role': role});
    if (res is Map<String, dynamic>) {
      return Usuario.fromJson(res);
    }
    throw Exception('Resposta inesperada ao alterar role');
  }

  Future<void> deletar(int id) async {
    await ApiService.delete('/api/usuarios/$id');
  }

  Future<Usuario> criar(String username, String senha, String nome, {String role = 'funcionario'}) async {
    final res = await ApiService.postJson('/api/auth/register', {
      'username': username,
      'senha': senha,
      'nome': nome,
      'role': role,
    });
    if (res is Map<String, dynamic>) {
      return Usuario.fromJson(res);
    }
    throw Exception('Resposta inesperada ao criar usuario');
  }
}
