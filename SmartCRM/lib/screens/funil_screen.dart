import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../core/models/etapa_funil.dart';
import '../core/services/etapas_service.dart';
import '../core/services/oportunidades_service.dart';
import '../widgets/smart_app_bar.dart';
import 'funil_etapa_screen.dart';

class FunilScreen extends StatefulWidget {
  const FunilScreen({super.key});

  @override
  State<FunilScreen> createState() => _FunilScreenState();
}

class _FunilScreenState extends State<FunilScreen> {
  final OportunidadesService _oportunidadesService = OportunidadesService();
  final EtapasService _etapasService = EtapasService();

  Map<String, int> _counts = {};
  List<EtapaFunil> _etapas = [];
  bool _loading = true;

  static const _etapaColors = [
    AppColors.funilGray,
    AppColors.funilGray,
    AppColors.funilBlue,
    AppColors.funilBlue,
    AppColors.funilPurple,
    AppColors.funilPurpleDark,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _oportunidadesService.fetchFunil(),
        _etapasService.fetchEtapas(),
      ]);
      final funil = results[0] as Map<String, List<dynamic>>;
      final etapas = results[1] as List<EtapaFunil>;

      final ativas = etapas.where((e) => e.nome != 'Perdida').toList();
      final counts = <String, int>{};
      for (final etapa in ativas) {
        counts[etapa.nome] = funil[etapa.nome]?.length ?? 0;
      }

      if (mounted) {
        setState(() {
          _etapas = ativas;
          _counts = counts;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartAppBar(title: AppStrings.funil),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _etapas.length,
                  itemBuilder: (_, index) {
                    final etapa = _etapas[index];
                    final count = _counts[etapa.nome] ?? 0;
                    final color = _etapaColors[index % _etapaColors.length];

                    return Material(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FunilEtapaScreen(
                                etapaNome: etapa.nome,
                                etapaId: etapa.id,
                              ),
                            ),
                          ).then((_) => _load());
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              etapa.nome,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              count.toString().padLeft(2, '0'),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
