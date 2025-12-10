class Usuario {
  final int id;
  final String nome;
  final String username;
  final String role;
  final bool ativo;

  const Usuario({
    required this.id,
    required this.nome,
    required this.username,
    required this.role,
    this.ativo = true,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    int id;
    if (rawId is int) {
      id = rawId;
    } else if (rawId is num) {
      id = rawId.toInt();
    } else if (rawId is String && int.tryParse(rawId) != null) {
      id = int.parse(rawId);
    } else {
      throw const FormatException('Usuario sem ID valido');
    }
    bool ativo = true;
    final rawAtivo = json['ativo'];
    if (rawAtivo is bool) {
      ativo = rawAtivo;
    } else if (rawAtivo is num) {
      ativo = rawAtivo != 0;
    } else if (rawAtivo is String) {
      final v = rawAtivo.toLowerCase();
      ativo = !(v == 'false' || v == '0' || v == 'inativo' || v == 'inactive' || v == 'nao');
    }
    final username = (json['username'] ?? '') as String;
    final nome = (json['nome'] ?? username) as String;
    final role = ((json['role'] ?? 'funcionario') as String).toLowerCase();
    return Usuario(id: id, nome: nome, username: username, role: role, ativo: ativo);
  }
}

class UsuarioResumo {
  final int total;
  final int admins;
  final int funcionarios;
  final List<Usuario> usuarios;

  const UsuarioResumo({
    required this.total,
    required this.admins,
    required this.funcionarios,
    required this.usuarios,
  });

  factory UsuarioResumo.fromJson(Map<String, dynamic> json) {
    final usuarios = (json['usuarios'] as List<dynamic>? ?? [])
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
    return UsuarioResumo(
      total: (json['total'] as num? ?? usuarios.length).toInt(),
      admins: (json['admins'] as num? ?? 0).toInt(),
      funcionarios: (json['funcionarios'] as num? ?? 0).toInt(),
      usuarios: usuarios,
    );
  }
}
