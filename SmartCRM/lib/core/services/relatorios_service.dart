import '../api/api_client.dart';
import '../models/relatorio_resumo.dart';

class RelatoriosService {
  Future<RelatorioResumo> fetchPorMes(int year, int month) async {
    final inicio = DateTime(year, month, 1);
    final fim = DateTime(year, month + 1, 0);
    final dataInicio = _formatDate(inicio);
    final dataFim = _formatDate(fim);
    final data = await ApiClient.get(
      '/relatorios?dataInicio=$dataInicio&dataFim=$dataFim',
    ) as Map<String, dynamic>;
    return RelatorioResumo.fromJson(data);
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
