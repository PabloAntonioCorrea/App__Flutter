import '../api/api_client.dart';
import '../database/sync_status.dart';
import '../models/lead.dart';
import '../models/service_result.dart';
import '../persistence/lead_cache_dao.dart';
import '../session/app_session.dart';

class LeadsService {
  final LeadCacheDao _cache = LeadCacheDao();

  Future<void> _syncPending() async {
    final rows = await _cache.getPendingRows();
    for (final row in rows) {
      final id = row['id'] as int;
      final status = row['sync_status'] as String;
      final lead = await _cache.getById(id);
      if (lead == null) continue;

      try {
        if (status == SyncStatus.pendingCreate) {
          final payload = buildPayload(
            nome: lead.nome,
            email: lead.email,
            telefone: lead.telefone,
            empresa: lead.empresa,
            nicho: lead.nicho,
            observacoes: lead.observacoes,
            usuarioId: lead.usuarioId,
            dataCadastro: lead.dataCadastro,
          );
          final data =
              await ApiClient.post('/leads', payload) as Map<String, dynamic>;
          final synced = Lead.fromJson(data);
          await _cache.deleteById(id);
          await _cache.upsert(synced, SyncStatus.synced);
        } else if (status == SyncStatus.pendingUpdate) {
          final payload = buildPayload(
            nome: lead.nome,
            email: lead.email,
            telefone: lead.telefone,
            empresa: lead.empresa,
            nicho: lead.nicho,
            observacoes: lead.observacoes,
            usuarioId: lead.usuarioId,
            dataCadastro: lead.dataCadastro,
          );
          final data = await ApiClient.put('/leads/$id', payload)
              as Map<String, dynamic>;
          final synced = Lead.fromJson(data);
          await _cache.upsert(synced, SyncStatus.synced);
        } else if (status == SyncStatus.pendingDelete) {
          await ApiClient.delete('/leads/$id');
          await _cache.deleteById(id);
        }
      } catch (_) {}
    }
  }

  Future<ServiceResult<List<Lead>>> fetchLeads() async {
    try {
      await _syncPending();
      final data = await ApiClient.get('/leads') as List<dynamic>;
      final leads =
          data.map((e) => Lead.fromJson(e as Map<String, dynamic>)).toList();
      await _cache.replaceSynced(leads);
      final merged = await _cache.getAllVisible();
      return ServiceResult(merged.isNotEmpty ? merged : leads);
    } catch (_) {
      final cached = await _cache.getAllVisible();
      if (cached.isNotEmpty) {
        return ServiceResult(cached, fromCache: true);
      }
      rethrow;
    }
  }

  Future<ServiceResult<Lead>> fetchById(int id) async {
    try {
      final data = await ApiClient.get('/leads/$id') as Map<String, dynamic>;
      final lead = Lead.fromJson(data);
      await _cache.upsert(lead, SyncStatus.synced);
      return ServiceResult(lead);
    } catch (_) {
      final cached = await _cache.getById(id);
      if (cached != null) {
        return ServiceResult(cached, fromCache: true);
      }
      rethrow;
    }
  }

  Future<Lead> create(Map<String, dynamic> body) async {
    try {
      final data = await ApiClient.post('/leads', body) as Map<String, dynamic>;
      final lead = Lead.fromJson(data);
      await _cache.upsert(lead, SyncStatus.synced);
      return lead;
    } catch (e) {
      final localId = await _cache.nextLocalId();
      final lead = Lead(
        id: localId,
        nome: body['nome'] as String? ?? '',
        email: body['email'] as String?,
        telefone: body['telefone'] as String?,
        empresa: body['empresa'] as String?,
        nicho: body['nicho'] as String?,
        observacoes: body['observacoes'] as String?,
        usuarioId: parseUsuarioId(body['usuarioId']),
        dataCadastro: body['dataCadastro'] as String?,
      );
      await _cache.upsert(lead, SyncStatus.pendingCreate);
      return lead;
    }
  }

  Future<Lead> update(int id, Map<String, dynamic> body) async {
    try {
      final data =
          await ApiClient.put('/leads/$id', body) as Map<String, dynamic>;
      final lead = Lead.fromJson(data);
      await _cache.upsert(lead, SyncStatus.synced);
      return lead;
    } catch (_) {
      final existing = await _cache.getById(id);
      final lead = Lead(
        id: id,
        nome: body['nome'] as String? ?? existing?.nome ?? '',
        email: body['email'] as String? ?? existing?.email,
        telefone: body['telefone'] as String? ?? existing?.telefone,
        empresa: body['empresa'] as String? ?? existing?.empresa,
        nicho: body['nicho'] as String? ?? existing?.nicho,
        observacoes: body['observacoes'] as String? ?? existing?.observacoes,
        responsavel: existing?.responsavel,
        usuarioId: parseUsuarioId(body['usuarioId'] ?? existing?.usuarioId),
        dataCadastro: body['dataCadastro'] as String? ?? existing?.dataCadastro,
      );
      final status = id < 0 ? SyncStatus.pendingCreate : SyncStatus.pendingUpdate;
      await _cache.upsert(lead, status);
      return lead;
    }
  }

  Future<void> delete(int id) async {
    try {
      await ApiClient.delete('/leads/$id');
      await _cache.deleteById(id);
    } catch (_) {
      if (id < 0) {
        await _cache.deleteById(id);
        return;
      }
      await _cache.markPendingDelete(id);
    }
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

  int parseUsuarioId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ??
        AppSession.currentUser?.id ??
        0;
  }
}
