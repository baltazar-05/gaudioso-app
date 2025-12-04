import 'package:gaudioso_app/services/api_service.dart';
import '../models/fornecedor.dart';

class FornecedorService {
  static const _path = '/api/fornecedores';

  Future<List<Fornecedor>> listar({bool? ativo = true}) async {
    final query = ativo == null ? '' : '?ativo=${ativo ? 'true' : 'false'}';
    final data = await ApiService.getJson('$_path$query') as List<dynamic>;
    return data.map((e) => Fornecedor.fromJson(e)).toList();
  }

  Future<void> adicionar(Fornecedor f) async {
    await ApiService.postJson(_path, f.toJson());
  }

  Future<void> atualizar(Fornecedor f) async {
    await ApiService.putJson('$_path/${f.id}', f.toJson());
  }

  Future<void> inativar(int id) async {
    await ApiService.putJson('$_path/$id', {"ativo": false});
  }

  Future<void> reativar(int id) async {
    await ApiService.putJson('$_path/$id', {"ativo": true});
  }
}
