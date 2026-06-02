import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_strings.dart';
import '../core/models/lead.dart';
import '../core/models/usuario.dart';
import '../core/services/leads_service.dart';
import '../core/services/usuarios_service.dart';
import '../core/session/app_session.dart';
import '../widgets/smart_app_bar.dart';

class LeadFormScreen extends StatefulWidget {
  final int? leadId;

  const LeadFormScreen({super.key, this.leadId});

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LeadsService _leadsService = LeadsService();
  final UsuariosService _usuariosService = UsuariosService();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _empresaController = TextEditingController();
  final _cargoController = TextEditingController();
  final _observacoesController = TextEditingController();

  List<Usuario> _usuarios = [];
  int? _usuarioId;
  String? _dataCadastroBr;
  bool _loading = false;
  bool _saving = false;

  bool get _isEditing => widget.leadId != null;

  @override
  void initState() {
    super.initState();
    _usuarioId = AppSession.currentUser?.id;
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      _usuarios = await _usuariosService.fetchUsuarios();
      if (_isEditing) {
        final lead = await _leadsService.fetchById(widget.leadId!);
        _nomeController.text = lead.nome;
        _emailController.text = lead.email ?? '';
        _telefoneController.text = lead.telefone ?? '';
        _empresaController.text = lead.empresa ?? '';
        _cargoController.text = lead.nicho ?? '';
        _observacoesController.text = lead.observacoes ?? '';
        _usuarioId = lead.usuarioId;
        _dataCadastroBr = lead.dataCadastro;
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

  int? get _usuarioDropdownValue =>
      _usuarios.any((u) => u.id == _usuarioId) ? _usuarioId : null;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _empresaController.dispose();
    _cargoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final payload = _leadsService.buildPayload(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        empresa: _empresaController.text.trim(),
        nicho: _cargoController.text.trim(),
        observacoes: _observacoesController.text.trim(),
        usuarioId: _usuarioId,
        dataCadastro: _isEditing ? _parseDataCadastro(_dataCadastroBr) : null,
      );
      if (_isEditing) {
        await _leadsService.update(widget.leadId!, payload);
      } else {
        await _leadsService.create(payload);
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
      appBar: SmartAppBar(title: _isEditing ? 'Lead' : 'Lead'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _field('Nome', _nomeController, required: true),
                  _field('Email', _emailController),
                  _field('Telefone', _telefoneController),
                  _field('Empresa', _empresaController),
                  _field('Cargo', _cargoController),
                  DropdownButtonFormField<int>(
                    value: _usuarioDropdownValue,
                    decoration: const InputDecoration(
                      labelText: 'Responsável',
                      border: OutlineInputBorder(),
                    ),
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
                  _field('Observações', _observacoesController, maxLines: 3),
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

  String? _parseDataCadastro(String? brDate) {
    if (brDate == null || brDate.isEmpty) return null;
    final parts = brDate.split('/');
    if (parts.length != 3) return null;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null
            : null,
      ),
    );
  }
}
