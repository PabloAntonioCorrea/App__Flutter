import '../api/api_client.dart';
import '../models/oportunidade.dart';
import '../session/app_session.dart';

class OportunidadesService {
  Future<List<Oportunidade>> fetchOportunidades() async {
    final data = await ApiClient.get('/oportunidades') as List<dynamic>;
    return data
        .map((e) => Oportunidade.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, List<Oportunidade>>> fetchFunil() async {
    final data =
        await ApiClient.get('/oportunidades/funil') as Map<String, dynamic>;
    final result = <String, List<Oportunidade>>{};
    data.forEach((key, value) {
      final list = value as List<dynamic>? ?? [];
      result[key] = list
          .map((e) => Oportunidade.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    return result;
  }

  Future<Oportunidade> fetchById(int id) async {
    final data =
        await ApiClient.get('/oportunidades/$id') as Map<String, dynamic>;
    return Oportunidade.fromJson(data);
  }

  Future<Oportunidade> create(Map<String, dynamic> body) async {
    final data =
        await ApiClient.post('/oportunidades', body) as Map<String, dynamic>;
    return Oportunidade.fromJson(data);
  }

  Future<Oportunidade> update(int id, Map<String, dynamic> body) async {
    final data =
        await ApiClient.put('/oportunidades/$id', body) as Map<String, dynamic>;
    return Oportunidade.fromJson(data);
  }

  Future<void> delete(int id) async {
    await ApiClient.delete('/oportunidades/$id');
  }

  Future<Oportunidade> marcarPerdida(int id, int motivoPerdaId) async {
    final data = await ApiClient.post('/oportunidades/$id/perder', {
      'motivoPerdaId': motivoPerdaId,
      'usuarioId': AppSession.currentUser?.id,
    }) as Map<String, dynamic>;
    return Oportunidade.fromJson(data);
  }

  Future<Oportunidade> marcarGanha(Oportunidade oportunidade, int etapaFechadoId) {
    return update(
      oportunidade.id,
      oportunidade.toPayload(etapaFunilIdOverride: etapaFechadoId),
    );
  }
}
