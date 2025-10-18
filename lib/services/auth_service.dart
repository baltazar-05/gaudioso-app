import 'auth/api_auth_service.dart';
import 'auth/session_storage.dart';

/// AuthService de alto nível para o app.
/// - Tenta usar a API (ApiAuthService) para login/registro.
/// - Persiste a sessão localmente (SessionStorage).
/// - Mantém a mesma interface pública usada no app.
class AuthService {
  final _api = ApiAuthService();
  final _storage = SessionStorage();

  Future<Map<String, dynamic>?> currentUser() => _storage.currentUser();
  Future<bool> isLoggedIn() async => (await currentUser())?.isNotEmpty == true;

  Future<String?> register(String username, String password) async {
    try {
      final user = await _api.register(username, password);
      await _storage.setCurrentUser(user);
      return null;
    } catch (e) {
      return 'Erro ao registrar: ${_friendlyMessage(e)}';
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      final user = await _api.login(username, password);
      await _storage.setCurrentUser(user);
      return null;
    } catch (e) {
      return 'Erro ao entrar: ${_friendlyMessage(e)}';
    }
  }

  Future<void> logout() => _storage.clear();

  String _friendlyMessage(Object error) {
    final text = error.toString();
    const marker = 'Exception: ';
    return text.startsWith(marker) ? text.substring(marker.length) : text;
  }
}
