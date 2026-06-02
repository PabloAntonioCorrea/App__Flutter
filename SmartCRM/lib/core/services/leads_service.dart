import '../api/api_client.dart';
import '../models/lead.dart';
import '../session/app_session.dart';

class LeadsService {
  Future<List<Lead>> fetchLeads() async {
    final data = await ApiClient.get('/leads') as List<dynamic>;
    return data.map((e) => Lead.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Lead> fetchById(int id) async {
    final data = await ApiClient.get('/leads/$id') as Map<String, dynamic>;
    return Lead.fromJson(data);
  }

  Future<Lead> create(Map<String, dynamic> body) async {
    final data = await ApiClient.post('/leads', body) as Map<String, dynamic>;
    return Lead.fromJson(data);
  }

  Future<Lead> update(int id, Map<String, dynamic> body) async {
    final data = await ApiClient.put('/leads/$id', body) as Map<String, dynamic>;
    return Lead.fromJson(data);
  }

  Future<void> delete(int id) async {
    await ApiClient.delete('/leads/$id');
  }

  Map<String, dynamic> buildPayload({
    required String nome,
    String? email,
    String? telefone,
    String? empresa,
    String? nicho,
    String? observacoes,
    int? usuarioId,
    String? dataCadastro,
  }) {
    final now = DateTime.now();
    final cadastro = dataCadastro ??
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'empresa': empresa,
      'nicho': nicho,
      'observacoes': observacoes,
      'usuarioId': usuarioId ?? AppSession.currentUser?.id,
      'dataCadastro': cadastro,
      'status': 'Ativo',
    };
  }
}
