import 'package:gaudioso_app/services/api_service.dart';
import '../models/entrada.dart';

class EntradaService {
  static const _path = '/api/entradas';

  Future<List<Entrada>> listar() async {
    final data = await ApiService.getJson(_path) as List<dynamic>;
    return data.map((e) => Entrada.fromJson(e)).toList();
  }

  Future<void> adicionar(Entrada e) async {
    await ApiService.postJson(_path, e.toJson());
  }

  Future<void> atualizar(Entrada e) async {
    await ApiService.putJson('$_path/${e.id}', e.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiService.delete('$_path/$id');
  }
}
