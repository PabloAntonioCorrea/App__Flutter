import '../utils/json_utils.dart';

class EtapaFunil {
  final int id;
  final String nome;
  final int ordem;

  EtapaFunil({
    required this.id,
    required this.nome,
    required this.ordem,
  });

  factory EtapaFunil.fromJson(Map<String, dynamic> json) {
    return EtapaFunil(
      id: parseInt(json['id']),
      nome: json['nome'] as String? ?? '',
      ordem: parseInt(json['ordem']),
    );
  }
}
