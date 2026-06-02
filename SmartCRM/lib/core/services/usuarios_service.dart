import '../api/api_client.dart';
import '../models/usuario.dart';

class UsuariosService {
  Future<List<Usuario>> fetchUsuarios() async {
    final data = await ApiClient.get('/usuarios') as List<dynamic>;
    return data.map((e) => Usuario.fromJson(e as Map<String, dynamic>)).toList();
  }
}
