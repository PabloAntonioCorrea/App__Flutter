import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../core/models/motivo_perda.dart';
import '../core/models/oportunidade.dart';
import '../core/services/etapas_service.dart';
import '../core/services/motivos_perda_service.dart';
import '../core/services/oportunidades_service.dart';
import '../widgets/smart_app_bar.dart';
import 'oportunidade_form_screen.dart';

class OportunidadeDetailScreen extends StatefulWidget {
  final int oportunidadeId;

  const OportunidadeDetailScreen({super.key, required this.oportunidadeId});

  @override
  State<OportunidadeDetailScreen> createState() => _OportunidadeDetailScreenState();
}

class _OportunidadeDetailScreenState extends State<OportunidadeDetailScreen> {
  final OportunidadesService _service = OportunidadesService();
  final EtapasService _etapasService = EtapasService();
  final MotivosPerdaService _motivosService = MotivosPerdaService();

  Oportunidade? _oportunidade;
  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final op = await _service.fetchById(widget.oportunidadeId);
      if (mounted) setState(() => _oportunidade = op);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _marcarGanha() async {
    if (_oportunidade!.isFechada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oportunidade já está como venda concluída')),
      );
      return;
    }
    setState(() => _acting = true);
    try {
      final etapas = await _etapasService.fetchEtapas();
      final fechados = etapas.where((e) => e.nome == 'Fechado').toList();
      if (fechados.isEmpty) {
        throw Exception('Etapa Fechado não encontrada no funil');
      }
      await _service.marcarGanha(_oportunidade!, fechados.first.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Venda concluída com sucesso')),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _marcarPerdida() async {
    List<MotivoPerda> motivos = [];
    try {
      motivos = await _motivosService.fetchAtivos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
      return;
    }
    if (motivos.isEmpty) return;

    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Motivo da perda'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: motivos.length,
            itemBuilder: (_, i) {
              final m = motivos[i];
              return ListTile(
                title: Text(m.nome),
                onTap: () => Navigator.pop(ctx, m.id),
              );
            },
          ),
        ),
      ),
    );

    if (selected == null) return;
    setState(() => _acting = true);
    try {
      await _service.marcarPerdida(widget.oportunidadeId, selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oportunidade marcada como perdida')),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir oportunidade?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.delete(widget.oportunidadeId);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartAppBar(title: 'Oportunidade'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _oportunidade == null
              ? const Center(child: Text('Oportunidade não encontrada'))
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informações:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _oportunidade!.titulo,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('Lead: ${_oportunidade!.lead ?? '—'}'),
                                Text('Etapa: ${_oportunidade!.etapa ?? '—'}'),
                                Text('Prioridade: ${_oportunidade!.prioridade}'),
                                Text('Valor: ${_oportunidade!.valor}'),
                                Text('Responsável: ${_oportunidade!.responsavel ?? '—'}'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Observações:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 80,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(
                              _oportunidade!.perdida
                                  ? 'Motivo: ${_oportunidade!.motivoPerda ?? '—'}'
                                  : '—',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Status da Oportunidade:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _acting || _oportunidade!.isFechada
                                      ? null
                                      : _marcarGanha,
                                  icon: const Icon(Icons.check),
                                  label: const Text('Ganha'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.green,
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _acting ||
                                          _oportunidade!.isPerdidaEtapa ||
                                          _oportunidade!.isFechada
                                      ? null
                                      : _marcarPerdida,
                                  icon: const Icon(Icons.close),
                                  label: const Text('Perdida'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 80),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OportunidadeFormScreen(
                                          oportunidadeId: widget.oportunidadeId,
                                        ),
                                      ),
                                    );
                                    _load();
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Editar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lightBlue,
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _delete,
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Excluir'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_acting)
                      const ColoredBox(
                        color: Color(0x33FFFFFF),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
    );
  }
}
