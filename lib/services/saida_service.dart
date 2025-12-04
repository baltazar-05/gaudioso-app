import 'package:gaudioso_app/services/api_service.dart';
import '../models/saida.dart';

class SaidaService {
  static const _path = '/api/saidas';
  // Use --dart-define=API_BASE to override the base URL when deploying remotely.

  Future<List<Saida>> listar() async {
    final data = await ApiService.getJson(_path) as List<dynamic>;
    return data.map((e) => Saida.fromJson(e)).toList();
  }

  Future<void> adicionar(Saida s) async {
    await ApiService.postJson(_path, s.toJson());
  }

  Future<void> atualizar(Saida s) async {
    await ApiService.putJson('$_path/${s.id}', s.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiService.delete('$_path/$id');
  }
}
