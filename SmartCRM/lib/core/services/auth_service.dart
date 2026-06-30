import '../api/api_client.dart';
import '../models/usuario.dart';
import '../session/app_session.dart';

class AuthService {
  Future<Usuario> login(String email, String senha) async {
    final data = await ApiClient.post('/auth/login', {
      'email': email,
      'senha': senha,
    });
    final map = data as Map<String, dynamic>;
    final userJson = map['usuario'] ?? map;
    final user = Usuario.fromJson(userJson as Map<String, dynamic>);
    await AppSession.persistUser(user);
    return user;
  }

  Future<void> logout() async {
    await AppSession.clearPersisted();
  }
}
