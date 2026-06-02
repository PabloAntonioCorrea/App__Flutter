import '../utils/json_utils.dart';

class MotivoPerda {
  final int id;
  final String nome;

  MotivoPerda({required this.id, required this.nome});

  factory MotivoPerda.fromJson(Map<String, dynamic> json) {
    return MotivoPerda(
      id: parseInt(json['id']),
      nome: json['nome'] as String? ?? '',
    );
  }
}
