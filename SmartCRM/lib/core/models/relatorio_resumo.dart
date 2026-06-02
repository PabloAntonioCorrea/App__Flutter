class RelatorioResumo {
  final int leadsNoPeriodo;
  final int oportunidadesCriadas;
  final int vendasConcluidas;
  final int oportunidadesPerdidas;

  RelatorioResumo({
    required this.leadsNoPeriodo,
    required this.oportunidadesCriadas,
    required this.vendasConcluidas,
    required this.oportunidadesPerdidas,
  });

  factory RelatorioResumo.fromJson(Map<String, dynamic> json) {
    return RelatorioResumo(
      leadsNoPeriodo: json['leadsNoPeriodo'] as int? ?? 0,
      oportunidadesCriadas: json['oportunidadesCriadas'] as int? ?? 0,
      vendasConcluidas: json['oportunidadesFechadas'] as int? ?? 0,
      oportunidadesPerdidas: json['oportunidadesPerdidas'] as int? ?? 0,
    );
  }
}
