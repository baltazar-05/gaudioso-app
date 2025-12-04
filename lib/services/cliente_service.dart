import 'dart:developer' show log;

import 'package:gaudioso_app/services/api_service.dart';
import '../models/cliente.dart';

class ClienteService {
  static const _path = '/api/clientes';

  Future<List<Cliente>> listar({bool? ativo = true}) async {
    final query = ativo == null ? '' : '?ativo=${ativo ? 'true' : 'false'}';
    final data = await ApiService.getJson('$_path$query') as List<dynamic>;
    log('Clientes carregados: ${data.length}');
    return data.map((e) => Cliente.fromJson(e)).toList();
  }

  Future<void> adicionar(Cliente c) async {
    await ApiService.postJson(_path, c.toJson());
  }

  Future<void> atualizar(Cliente c) async {
    await ApiService.putJson('$_path/${c.id}', c.toJson());
  }

  Future<void> inativar(int id) async {
    await ApiService.putJson('$_path/$id', {"ativo": false});
  }

  Future<void> reativar(int id) async {
    await ApiService.putJson('$_path/$id', {"ativo": true});
  }
}
