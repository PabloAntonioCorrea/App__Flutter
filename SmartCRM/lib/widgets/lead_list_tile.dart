import 'package:flutter/material.dart';

import '../core/models/lead.dart';

class LeadListTile extends StatelessWidget {
  final Lead lead;
  final VoidCallback onTap;

  const LeadListTile({
    super.key,
    required this.lead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lead.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text('Empresa: ${lead.empresa ?? '—'}'),
              Text('Email: ${lead.email ?? '—'}'),
            ],
          ),
        ),
      ),
    );
  }
}
