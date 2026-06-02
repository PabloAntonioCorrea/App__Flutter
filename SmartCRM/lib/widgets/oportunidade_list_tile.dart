import 'package:flutter/material.dart';

import '../core/models/oportunidade.dart';

class OportunidadeListTile extends StatelessWidget {
  final Oportunidade oportunidade;
  final VoidCallback onTap;

  const OportunidadeListTile({
    super.key,
    required this.oportunidade,
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
                oportunidade.titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text('Etapa: ${oportunidade.etapa ?? '—'}'),
              Text('Prioridade: ${oportunidade.prioridade}'),
              Text('Valor: ${oportunidade.valor}'),
            ],
          ),
        ),
      ),
    );
  }
}
