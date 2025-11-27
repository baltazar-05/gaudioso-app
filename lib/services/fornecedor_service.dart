import 'package:gaudioso_app/services/api_service.dart';
import '../models/fornecedor.dart';

class FornecedorService {
  static const _path = '/api/fornecedores';

  Future<List<Fornecedor>> listar() async {
    final data = await ApiService.getJson(_path) as List<dynamic>;
    return data.map((e) => Fornecedor.fromJson(e)).toList();
  }

  Future<void> adicionar(Fornecedor f) async {
    await ApiService.postJson(_path, f.toJson());
  }

  Future<void> atualizar(Fornecedor f) async {
    await ApiService.putJson('$_path/${f.id}', f.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiService.delete('$_path/$id');
  }
}
