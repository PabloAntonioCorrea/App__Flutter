import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../core/models/etapa_funil.dart';
import '../core/models/lead.dart';
import '../core/models/usuario.dart';
import '../core/services/etapas_service.dart';
import '../core/services/leads_service.dart';
import '../core/services/oportunidades_service.dart';
import '../core/services/usuarios_service.dart';
import '../core/session/app_session.dart';
import '../widgets/smart_app_bar.dart';

class OportunidadeFormScreen extends StatefulWidget {
  final int? oportunidadeId;
  final int? initialLeadId;
  final int? initialEtapaFunilId;

  const OportunidadeFormScreen({
    super.key,
    this.oportunidadeId,
    this.initialLeadId,
    this.initialEtapaFunilId,
  });

  @override
  State<OportunidadeFormScreen> createState() => _OportunidadeFormScreenState();
}

class _OportunidadeFormScreenState extends State<OportunidadeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final OportunidadesService _service = OportunidadesService();
  final LeadsService _leadsService = LeadsService();
  final UsuariosService _usuariosService = UsuariosService();
  final EtapasService _etapasService = EtapasService();

  final _tituloController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();

  List<Lead> _leads = [];
  List<Usuario> _usuarios = [];
  List<EtapaFunil> _etapas = [];

  int? _leadId;
  int? _usuarioId;
  int? _etapaFunilId;
  String _prioridade = 'Média';

  bool _loading = true;
  bool _saving = false;

  static const _prioridades = ['Baixa', 'Média', 'Alta'];

  bool get _isEditing => widget.oportunidadeId != null;

  @override
  void initState() {
    super.initState();
    _leadId = widget.initialLeadId;
    _etapaFunilId = widget.initialEtapaFunilId;
    _usuarioId = AppSession.currentUser?.id;
    _init();
  }

  Future<void> _init() async {
    try {
      final leadsResult = await _leadsService.fetchLeads();
      final usuarios = await _usuariosService.fetchUsuarios();
      final todasEtapas = await _etapasService.fetchEtapas();
      _leads = leadsResult.data;
      _usuarios = usuarios;

      if (_isEditing) {
        final opResult = await _service.fetchById(widget.oportunidadeId!);
        final op = opResult.data;
        _etapas = List<EtapaFunil>.from(todasEtapas);
        _tituloController.text = op.titulo;
        _valorController.text = op.valor.replaceAll('R\$', '').trim();
        _leadId = op.leadId;
        _usuarioId = op.usuarioId;
        _etapaFunilId = op.etapaFunilId;
        _prioridade = _prioridades.contains(op.prioridade)
            ? op.prioridade
            : 'Média';
        _observacoesController.text = op.observacoes ?? '';
      } else {
        _etapas =
            todasEtapas.where((e) => e.nome != 'Perdida' && e.nome != 'Fechado').toList();
        if (_etapas.isNotEmpty && _etapaFunilId == null) {
          _etapaFunilId = _etapas.first.id;
        }
      }
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

  int? get _leadDropdownValue =>
      _leads.any((l) => l.id == _leadId) ? _leadId : null;

  int? get _etapaDropdownValue =>
      _etapas.any((e) => e.id == _etapaFunilId) ? _etapaFunilId : null;

  int? get _usuarioDropdownValue =>
      _usuarios.any((u) => u.id == _usuarioId) ? _usuarioId : null;

  @override
  void dispose() {
    _tituloController.dispose();
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  double _parseValor(String raw) {
    final normalized = raw.replaceAll(RegExp(r'[^\d,.-]'), '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_leadId == null || _usuarioId == null || _etapaFunilId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final observacoes = _observacoesController.text.trim();
      final body = {
        'titulo': _tituloController.text.trim(),
        'valorEstimado': _parseValor(_valorController.text),
        'prioridade': _prioridade,
        'usuarioId': _usuarioId,
        'leadId': _leadId,
        'etapaFunilId': _etapaFunilId,
        'observacoes': observacoes.isEmpty ? null : observacoes,
      };
      if (_isEditing) {
        await _service.update(widget.oportunidadeId!, body);
      } else {
        await _service.create(body);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartAppBar(title: 'Oportunidade'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _leadDropdownValue,
                    decoration: const InputDecoration(
                      labelText: 'Lead',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Selecionar Lead...'),
                    items: _leads
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _leadId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _etapaDropdownValue,
                    decoration: const InputDecoration(
                      labelText: 'Etapa',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Selecionar Etapa...'),
                    items: _etapas
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _etapaFunilId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _prioridade,
                    decoration: const InputDecoration(
                      labelText: 'Prioridade',
                      border: OutlineInputBorder(),
                    ),
                    items: _prioridades
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (v) => setState(() => _prioridade = v ?? 'Média'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _usuarioDropdownValue,
                    decoration: const InputDecoration(
                      labelText: 'Responsável',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Selecionar Responsável...'),
                    items: _usuarios
                        .map(
                          (u) => DropdownMenuItem(
                            value: u.id,
                            child: Text(u.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _usuarioId = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _observacoesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observações',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(_isEditing ? AppStrings.salvar : AppStrings.cadastrar),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
