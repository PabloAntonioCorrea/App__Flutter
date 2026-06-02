import '../models/usuario.dart';

class AppSession {
  static Usuario? currentUser;

  static void setUser(Usuario user) {
    currentUser = user;
  }

  static void clear() {
    currentUser = null;
  }

  static bool get isLoggedIn => currentUser != null;
}
