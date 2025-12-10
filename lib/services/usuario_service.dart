import '../models/usuario.dart';
import 'api_service.dart';

class UsuarioService {
  Future<UsuarioResumo> listar({bool? ativo}) async {
    final query = ativo == null ? null : {'ativo': ativo ? 'true' : 'false'};
    final res = await ApiService.getJson('/api/usuarios', query: query);
    if (res is Map<String, dynamic>) {
      final resumo = UsuarioResumo.fromJson(res);
      if (ativo == null) return resumo;
      final filtrados = resumo.usuarios.where((u) => ativo ? u.ativo : !u.ativo).toList();
      final admins = filtrados.where((u) => u.isAdmin).length;
      return UsuarioResumo(
        total: filtrados.length,
        admins: admins,
        funcionarios: filtrados.length - admins,
        usuarios: filtrados,
      );
    }
    if (res is List<dynamic>) {
      final usuarios = res.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
      final filtrados = ativo == null ? usuarios : usuarios.where((u) => ativo ? u.ativo : !u.ativo).toList();
      final admins = filtrados.where((u) => u.isAdmin).length;
      return UsuarioResumo(
        total: filtrados.length,
        admins: admins,
        funcionarios: filtrados.length - admins,
        usuarios: filtrados,
      );
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

  Future<void> inativar(int id) async {
    await ApiService.putJson('/api/usuarios/$id', {'ativo': false});
  }

  Future<void> reativar(int id) async {
    await ApiService.putJson('/api/usuarios/$id', {'ativo': true});
  }

  Future<void> deletar(int id) async {
    await inativar(id);
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
