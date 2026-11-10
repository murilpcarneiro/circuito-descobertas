import 'package:cloud_firestore/cloud_firestore.dart';

class Estande {
  const Estande({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.localizacao,
    required this.ativo,
  });

  final String id;
  final String nome;
  final String descricao;
  final String localizacao;
  final bool ativo;

  factory Estande.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? const {};
    return Estande(
      id: doc.id,
      nome: (m['nome'] as String?) ?? '',
      descricao: (m['descricao'] as String?) ?? '',
      localizacao: (m['localizacao'] as String?) ?? '',
      ativo: m['ativo'] == true,
    );
  }
}
