class Usuario {
  final int id;
  final String nome;
  final String username;
  final String role;

  const Usuario({
    required this.id,
    required this.nome,
    required this.username,
    required this.role,
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
    final username = (json['username'] ?? '') as String;
    final nome = (json['nome'] ?? username) as String;
    final role = ((json['role'] ?? 'funcionario') as String).toLowerCase();
    return Usuario(id: id, nome: nome, username: username, role: role);
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
