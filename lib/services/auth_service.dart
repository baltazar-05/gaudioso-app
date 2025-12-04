import 'auth/api_auth_service.dart';
import 'auth/session_storage.dart';

/// AuthService de alto nivel para o app.
/// - Usa a API para login/registro.
/// - Persiste sessao localmente (SharedPreferences).
/// - Expõe os mesmos helpers usados pelo app.
class AuthService {
  final _api = ApiAuthService();
  final _storage = SessionStorage();

  Future<Map<String, dynamic>?> currentUser({bool refreshFromServer = false}) async {
    final cached = await _storage.currentUser();
    if (!refreshFromServer || cached == null) return cached;
    try {
      final remote = await _api.me();
      final merged = {...cached, ...remote};
      await _storage.setCurrentUser(merged);
      return merged;
    } catch (_) {
      return cached;
    }
  }

  /// Valida token salvo e atualiza dados (incluindo role). Se o token falhar, limpa a sessao.
  Future<Map<String, dynamic>?> bootstrapUser() async {
    final cached = await _storage.currentUser();
    if (cached == null) return null;
    try {
      final remote = await _api.me();
      final merged = {...cached, ...remote};
      await _storage.setCurrentUser(merged);
      return merged;
    } catch (_) {
      await _storage.clear();
      return null;
    }
  }

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

  Future<String?> updateNome(String novoNome) async {
    try {
      final updated = await _api.updateNome(novoNome);
      final current = await _storage.currentUser() ?? {};
      final merged = {...current, ...updated};
      await _storage.setCurrentUser(merged);
      return null;
    } catch (e) {
      return 'Erro ao alterar nome: ${_friendlyMessage(e)}';
    }
  }

  Future<String?> updateSenha(String senhaAtual, String novaSenha) async {
    try {
      await _api.updateSenha(senhaAtual, novaSenha);
      return null;
    } catch (e) {
      return 'Erro ao alterar senha: ${_friendlyMessage(e)}';
    }
  }

  Future<String?> updateAvatar(String filePath) async {
    try {
      final url = await _api.updateAvatar(filePath);
      if (url == null) return 'Erro ao salvar avatar';
      final current = await _storage.currentUser() ?? {};
      final merged = {...current, 'avatarUrl': url};
      await _storage.setCurrentUser(merged);
      return null;
    } catch (e) {
      return 'Erro ao salvar avatar: ${_friendlyMessage(e)}';
    }
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    const marker = 'Exception: ';
    return text.startsWith(marker) ? text.substring(marker.length) : text;
  }
}
