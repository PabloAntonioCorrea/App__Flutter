import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../core/models/relatorio_resumo.dart';
import '../core/services/relatorios_service.dart';
import '../widgets/metric_card.dart';
import '../widgets/smart_app_bar.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final RelatoriosService _service = RelatoriosService();

  static const _monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];

  late int _selectedYear;
  late int _selectedMonth;
  RelatorioResumo? _resumo;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final resumo = await _service.fetchPorMes(_selectedYear, _selectedMonth);
      if (mounted) setState(() => _resumo = resumo);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<int> get _years {
    final current = DateTime.now().year;
    return List.generate(5, (i) => current - 2 + i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartAppBar(title: AppStrings.relatorios),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Selecione o período que deseja:'),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  isDense: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: List.generate(
                    12,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(
                        _monthNames[i],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedMonth = v);
                    _load();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _selectedYear,
                  isExpanded: true,
                  isDense: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: _years
                      .map(
                        (y) => DropdownMenuItem(
                          value: y,
                          child: Text('$y'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedYear = v);
                    _load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_resumo != null)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                MetricCard(
                  label: 'Leads do Mês',
                  value: '${_resumo!.leadsNoPeriodo}'.padLeft(2, '0'),
                  color: AppColors.purple,
                ),
                MetricCard(
                  label: 'Oportunidades Criadas',
                  value: '${_resumo!.oportunidadesCriadas}'.padLeft(2, '0'),
                  color: AppColors.lightBlue,
                ),
                MetricCard(
                  label: 'Vendas Concluídas',
                  value: '${_resumo!.vendasConcluidas}'.padLeft(2, '0'),
                  color: AppColors.green,
                ),
                MetricCard(
                  label: 'Oportunidades Perdidas',
                  value: '${_resumo!.oportunidadesPerdidas}'.padLeft(2, '0'),
                  color: AppColors.pink,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
