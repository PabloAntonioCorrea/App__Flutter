import '../models/usuario.dart';
import '../persistence/session_storage.dart';

class AppSession {
  static Usuario? currentUser;
  static final SessionStorage _storage = SessionStorage();

  static void setUser(Usuario user) {
    currentUser = user;
  }

  static void clear() {
    currentUser = null;
  }

  static bool get isLoggedIn => currentUser != null;

  static Future<void> restore() async {
    currentUser = await _storage.loadUser();
  }

  static Future<void> persistUser(Usuario user) async {
    setUser(user);
    await _storage.saveUser(user);
  }

  static Future<void> clearPersisted() async {
    clear();
    await _storage.clear();
  }
}
