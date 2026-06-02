import 'package:flutter/material.dart';

import '../core/models/oportunidade.dart';
import '../core/services/oportunidades_service.dart';
import '../widgets/oportunidade_list_tile.dart';
import '../widgets/smart_app_bar.dart';
import 'oportunidade_detail_screen.dart';
import 'oportunidade_form_screen.dart';

class FunilEtapaScreen extends StatefulWidget {
  final String etapaNome;
  final int etapaId;

  const FunilEtapaScreen({
    super.key,
    required this.etapaNome,
    required this.etapaId,
  });

  @override
  State<FunilEtapaScreen> createState() => _FunilEtapaScreenState();
}

class _FunilEtapaScreenState extends State<FunilEtapaScreen> {
  final OportunidadesService _service = OportunidadesService();
  List<Oportunidade> _items = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final funil = await _service.fetchFunil();
      final list = funil[widget.etapaNome] ?? [];
      if (mounted) setState(() => _items = list);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Oportunidade> get _filtered {
    if (_search.isEmpty) return _items;
    final q = _search.toLowerCase();
    return _items
        .where((o) => o.titulo.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartAppBar(title: widget.etapaNome),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OportunidadeFormScreen(
                initialEtapaFunilId: widget.etapaId,
              ),
            ),
          );
          _load();
        },
        backgroundColor: const Color(0xFF4A90D9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(child: Text('Nenhuma oportunidade nesta etapa'))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final op = _filtered[i];
                            return OportunidadeListTile(
                              oportunidade: op,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OportunidadeDetailScreen(
                                      oportunidadeId: op.id,
                                    ),
                                  ),
                                );
                                _load();
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
