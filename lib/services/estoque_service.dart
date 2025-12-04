import 'package:gaudioso_app/services/api_service.dart';
import '../models/estoque.dart';

class EstoqueService {
  static const _path = '/api/estoque';

  Future<List<Estoque>> listar() async {
    final data = await ApiService.getJson(_path) as List<dynamic>;
    return data.map((e) => Estoque.fromJson(e)).toList();
  }
}
