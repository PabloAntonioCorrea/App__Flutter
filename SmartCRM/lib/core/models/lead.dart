import 'oportunidade.dart';
import '../utils/json_utils.dart';

class Lead {
  final int id;
  final String nome;
  final String? email;
  final String? telefone;
  final String? empresa;
  final String? nicho;
  final String? observacoes;
  final String? responsavel;
  final int usuarioId;
  final String? dataCadastro;
  final List<Oportunidade>? oportunidades;

  Lead({
    required this.id,
    required this.nome,
    this.email,
    this.telefone,
    this.empresa,
    this.nicho,
    this.observacoes,
    this.responsavel,
    required this.usuarioId,
    this.dataCadastro,
    this.oportunidades,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    final oportunidadesJson = json['oportunidades'] as List<dynamic>?;
    return Lead(
      id: parseInt(json['id']),
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      empresa: json['empresa'] as String?,
      nicho: json['nicho'] as String?,
      observacoes: json['observacoes'] as String?,
      responsavel: json['responsavel'] as String?,
      usuarioId: parseInt(json['usuarioId']),
      dataCadastro: json['dataCadastro'] as String?,
      oportunidades: oportunidadesJson
          ?.map((e) => Oportunidade.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
