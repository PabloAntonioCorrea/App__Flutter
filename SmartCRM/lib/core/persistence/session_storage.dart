import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/usuario.dart';

class SessionStorage {
  static const String _userKey = 'smart_crm_user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveUser(Usuario user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<Usuario?> loadUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Usuario.fromJson(map);
  }

  Future<void> clear() async {
    await _storage.delete(key: _userKey);
  }
}
