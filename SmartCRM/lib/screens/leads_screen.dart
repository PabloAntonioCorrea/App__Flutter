import 'package:flutter/material.dart';

import '../config/app_strings.dart';
import '../core/models/lead.dart';
import '../core/services/leads_service.dart';
import '../widgets/lead_list_tile.dart';
import '../widgets/smart_app_bar.dart';
import 'lead_detail_screen.dart';
import 'lead_form_screen.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final LeadsService _service = LeadsService();
  List<Lead> _leads = [];
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
      final data = await _service.fetchLeads();
      if (mounted) setState(() => _leads = data);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Lead> get _filtered {
    if (_search.isEmpty) return _leads;
    final q = _search.toLowerCase();
    return _leads.where((l) {
      return l.nome.toLowerCase().contains(q) ||
          (l.empresa ?? '').toLowerCase().contains(q) ||
          (l.email ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SmartAppBar(title: AppStrings.leads),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const LeadFormScreen()),
          );
          if (created == true) _load();
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
                hintText: AppStrings.buscarLead,
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
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _filtered.isEmpty
                        ? ListView(
                            children: const [
                              Center(child: Text('Nenhum lead encontrado')),
                            ],
                          )
                        : ListView.builder(
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final lead = _filtered[i];
                              return LeadListTile(
                                lead: lead,
                                onTap: () async {
                                  final changed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LeadDetailScreen(leadId: lead.id),
                                    ),
                                  );
                                  if (changed == true) _load();
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
