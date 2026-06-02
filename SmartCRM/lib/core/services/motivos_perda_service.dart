import '../api/api_client.dart';
import '../models/motivo_perda.dart';

class MotivosPerdaService {
  Future<List<MotivoPerda>> fetchAtivos() async {
    final data = await ApiClient.get('/motivos-perda?ativos=true') as List<dynamic>;
    return data
        .map((e) => MotivoPerda.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
