import '../api/api_client.dart';
import '../models/etapa_funil.dart';

class EtapasService {
  Future<List<EtapaFunil>> fetchEtapas() async {
    final data = await ApiClient.get('/etapas-funil') as List<dynamic>;
    return data
        .map((e) => EtapaFunil.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
