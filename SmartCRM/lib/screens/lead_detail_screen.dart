import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../core/models/lead.dart';
import '../core/services/leads_service.dart';
import '../widgets/smart_app_bar.dart';
import 'lead_form_screen.dart';
import 'oportunidade_form_screen.dart';
import 'oportunidade_detail_screen.dart';

class LeadDetailScreen extends StatefulWidget {
  final int leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  final LeadsService _service = LeadsService();
  Lead? _lead;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final lead = await _service.fetchById(widget.leadId);
      if (mounted) setState(() => _lead = lead);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir lead?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _service.delete(widget.leadId);
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
      appBar: const SmartAppBar(title: 'Lead'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _lead == null
              ? const Center(child: Text('Lead não encontrado'))
              : SingleChildScrollView(
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
                            Text(_lead!.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Empresa: ${_lead!.empresa ?? '—'}'),
                            Text('Email: ${_lead!.email ?? '—'}'),
                            Text('Telefone: ${_lead!.telefone ?? '—'}'),
                            Text('Cargo: ${_lead!.nicho ?? '—'}'),
                            Text('Responsável: ${_lead!.responsavel ?? '—'}'),
                            const SizedBox(height: 8),
                            const Text('Observações:', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(_lead!.observacoes ?? '—'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Oportunidades Vinculadas:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ...(_lead!.oportunidades ?? []).map(
                        (op) => Card(
                          child: ListTile(
                            title: Text(op.titulo),
                            subtitle: Text(op.etapa ?? ''),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      OportunidadeDetailScreen(oportunidadeId: op.id),
                                ),
                              ).then((_) => _load());
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OportunidadeFormScreen(
                                  initialLeadId: widget.leadId,
                                ),
                              ),
                            );
                            _load();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Nova Oportunidade'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.funilPurpleDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final ok = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LeadFormScreen(leadId: widget.leadId),
                                  ),
                                );
                                if (ok == true) {
                                  _load();
                                  Navigator.pop(context, true);
                                }
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
    );
  }
}
