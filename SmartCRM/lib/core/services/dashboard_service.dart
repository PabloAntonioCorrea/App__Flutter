import '../api/api_client.dart';
import '../models/home_stats.dart';
import 'oportunidades_service.dart';

class DashboardService {
  final OportunidadesService _oportunidadesService = OportunidadesService();

  Future<HomeStats> loadHomeStats() async {
    final dashboard = await ApiClient.get('/dashboard') as Map<String, dynamic>;
    final funil = await _oportunidadesService.fetchFunil();
    final perdidas = funil['Perdida']?.length ?? 0;
    final fechadas = funil['Fechado']?.length ?? 0;
    final vendas = dashboard['vendasFechadas'] as Map<String, dynamic>?;

    return HomeStats(
      leadsTotais: dashboard['totalLeads'] as int? ?? 0,
      oportunidadesAbertas: dashboard['oportunidadesAbertas'] as int? ?? 0,
      oportunidadesPerdidas: perdidas,
      vendasConcluidas: fechadas > 0 ? fechadas : (vendas?['quantidade'] as int? ?? 0),
    );
  }
}
