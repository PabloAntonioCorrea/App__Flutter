import '../utils/json_utils.dart';

class Oportunidade {
  final int id;
  final String titulo;
  final dynamic valorEstimado;
  final String valor;
  final String prioridade;
  final String? prioridadeDb;
  final int usuarioId;
  final int leadId;
  final int etapaFunilId;
  final String? responsavel;
  final String? lead;
  final String? etapa;
  final bool perdida;
  final String? motivoPerda;

  Oportunidade({
    required this.id,
    required this.titulo,
    required this.valorEstimado,
    required this.valor,
    required this.prioridade,
    this.prioridadeDb,
    required this.usuarioId,
    required this.leadId,
    required this.etapaFunilId,
    this.responsavel,
    this.lead,
    this.etapa,
    this.perdida = false,
    this.motivoPerda,
  });

  bool get isFechada => etapa == 'Fechado';
  bool get isPerdidaEtapa => etapa == 'Perdida' || perdida;

  factory Oportunidade.fromJson(Map<String, dynamic> json) {
    return Oportunidade(
      id: parseInt(json['id']),
      titulo: json['titulo'] as String? ?? '',
      valorEstimado: json['valorEstimado'],
      valor: json['valor'] as String? ?? '',
      prioridade: json['prioridade'] as String? ?? '',
      prioridadeDb: json['prioridadeDb'] as String?,
      usuarioId: parseInt(json['usuarioId']),
      leadId: parseInt(json['leadId']),
      etapaFunilId: parseInt(json['etapaFunilId']),
      responsavel: json['responsavel'] as String?,
      lead: json['lead'] as String?,
      etapa: json['etapa'] as String?,
      perdida: json['perdida'] as bool? ?? false,
      motivoPerda: json['motivoPerda'] as String?,
    );
  }

  Map<String, dynamic> toPayload({int? etapaFunilIdOverride}) {
    return {
      'titulo': titulo,
      'valorEstimado': parseDouble(valorEstimado),
      'prioridade': prioridadeParaApi(prioridade, prioridadeDb),
      'usuarioId': usuarioId,
      'leadId': leadId,
      'etapaFunilId': etapaFunilIdOverride ?? etapaFunilId,
    };
  }
}
