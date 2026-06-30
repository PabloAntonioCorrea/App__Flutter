import '../api/api_client.dart';
import '../database/sync_status.dart';
import '../models/oportunidade.dart';
import '../models/service_result.dart';
import '../persistence/oportunidade_cache_dao.dart';
import '../session/app_session.dart';

class OportunidadesService {
  final OportunidadeCacheDao _cache = OportunidadeCacheDao();

  Future<ServiceResult<List<Oportunidade>>> fetchOportunidades() async {
    try {
      final data = await ApiClient.get('/oportunidades') as List<dynamic>;
      final items = data
          .map((e) => Oportunidade.fromJson(e as Map<String, dynamic>))
          .toList();
      await _cache.replaceSynced(items);
      final merged = await _cache.getAllVisible();
      return ServiceResult(merged.isNotEmpty ? merged : items);
    } catch (_) {
      final cached = await _cache.getAllVisible();
      if (cached.isNotEmpty) {
        return ServiceResult(cached, fromCache: true);
      }
      rethrow;
    }
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

  Future<ServiceResult<Oportunidade>> fetchById(int id) async {
    try {
      final data =
          await ApiClient.get('/oportunidades/$id') as Map<String, dynamic>;
      final item = Oportunidade.fromJson(data);
      await _cache.upsert(item, SyncStatus.synced);
      return ServiceResult(item);
    } catch (_) {
      final cached = await _cache.getById(id);
      if (cached != null) {
        return ServiceResult(cached, fromCache: true);
      }
      rethrow;
    }
  }

  Future<Oportunidade> create(Map<String, dynamic> body) async {
    try {
      final data =
          await ApiClient.post('/oportunidades', body) as Map<String, dynamic>;
      final item = Oportunidade.fromJson(data);
      await _cache.upsert(item, SyncStatus.synced);
      return item;
    } catch (_) {
      final localId = await _cache.nextLocalId();
      final item = Oportunidade(
        id: localId,
        titulo: body['titulo'] as String? ?? '',
        valorEstimado: body['valorEstimado'],
        valor: body['valorEstimado']?.toString() ?? '0',
        prioridade: body['prioridade'] as String? ?? 'Média',
        usuarioId: _parseInt(body['usuarioId']),
        leadId: _parseInt(body['leadId']),
        etapaFunilId: _parseInt(body['etapaFunilId']),
        observacoes: body['observacoes'] as String?,
      );
      await _cache.upsert(item, SyncStatus.pendingCreate);
      return item;
    }
  }

  Future<Oportunidade> update(int id, Map<String, dynamic> body) async {
    try {
      final data = await ApiClient.put('/oportunidades/$id', body)
          as Map<String, dynamic>;
      final item = Oportunidade.fromJson(data);
      await _cache.upsert(item, SyncStatus.synced);
      return item;
    } catch (_) {
      final existing = await _cache.getById(id);
      if (existing == null) rethrow;
      final item = Oportunidade(
        id: id,
        titulo: body['titulo'] as String? ?? existing.titulo,
        valorEstimado: body['valorEstimado'] ?? existing.valorEstimado,
        valor: existing.valor,
        prioridade: body['prioridade'] as String? ?? existing.prioridade,
        prioridadeDb: existing.prioridadeDb,
        usuarioId: _parseInt(body['usuarioId'] ?? existing.usuarioId),
        leadId: _parseInt(body['leadId'] ?? existing.leadId),
        etapaFunilId: _parseInt(body['etapaFunilId'] ?? existing.etapaFunilId),
        responsavel: existing.responsavel,
        lead: existing.lead,
        etapa: existing.etapa,
        observacoes: body['observacoes'] as String? ?? existing.observacoes,
        perdida: existing.perdida,
        motivoPerda: existing.motivoPerda,
      );
      final status = id < 0 ? SyncStatus.pendingCreate : SyncStatus.pendingUpdate;
      await _cache.upsert(item, status);
      return item;
    }
  }

  Future<void> delete(int id) async {
    try {
      await ApiClient.delete('/oportunidades/$id');
      await _cache.deleteById(id);
    } catch (_) {
      if (id < 0) {
        await _cache.deleteById(id);
      }
    }
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

  int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
