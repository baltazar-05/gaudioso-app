import 'package:gaudioso_app/services/api_service.dart';
import '../models/material.dart';

class MaterialService {
  static const _path = '/api/materiais';

  Future<List<MaterialItem>> listar() async {
    final body = await ApiService.getJson(_path);

    if (body is List) {
      return body.map((e) => MaterialItem.fromJson(e)).toList();
    }

    if (body is Map) {
      final data = body['content'] ?? body['materiais'] ?? [];
      if (data is List) {
        return data.map((e) => MaterialItem.fromJson(e)).toList();
      }
    }

    throw Exception("Formato de resposta inesperado da API");
  }

  Future<void> adicionar(MaterialItem m) async {
    await ApiService.postJson(_path, m.toJson());
  }

  Future<void> atualizar(MaterialItem m) async {
    await ApiService.putJson('$_path/${m.id}', m.toJson());
  }

  Future<void> excluir(int id) async {
    await ApiService.delete('$_path/$id');
  }
}
