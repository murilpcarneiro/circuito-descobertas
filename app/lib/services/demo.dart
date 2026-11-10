import 'dart:async';

import '../models/estande.dart';

/// Dados em memória para ver as telas sem Firebase (lib/main_demo.dart).
/// Nada é gravado: os check-ins somem ao fechar o app.
class Demo {
  static bool ativo = false;

  // Missão ligada para mostrar o banner e os destaques.
  static const bool missaoAtiva = true;
  static const String missaoEstandes = 'E01,E03';
  static const String missaoTitulo = 'Missão surpresa';

  static const List<Estande> estandes = [
    Estande(
      id: 'E01',
      nome: 'Robótica Amazônica',
      descricao: 'Robôs feitos com sucata que separam lixo reciclável.',
      localizacao: 'Corredor A · Estande 1',
      ativo: true,
    ),
    Estande(
      id: 'E02',
      nome: 'Laboratório de Sabores',
      descricao: 'A química por trás do açaí e do tucupi.',
      localizacao: 'Corredor B · Estande 3',
      ativo: true,
    ),
    Estande(
      id: 'E03',
      nome: 'Céu do Norte',
      descricao: 'Planetário inflável com as constelações vistas da Amazônia.',
      localizacao: 'Corredor C · Estande 1',
      ativo: true,
    ),
    Estande(
      id: 'E04',
      nome: 'Mapa Verde',
      descricao: 'Estande desativado, para testar o aviso de inativo.',
      localizacao: 'Corredor D · Estande 2',
      ativo: false,
    ),
  ];

  static final Set<String> _visitados = {};
  static final StreamController<Set<String>> _mudancas =
      StreamController<Set<String>>.broadcast();

  static Stream<List<Estande>> estandesAtivos() =>
      Stream.value(estandes.where((e) => e.ativo).toList());

  static Stream<Set<String>> visitados() async* {
    yield {..._visitados};
    yield* _mudancas.stream;
  }

  static Estande? buscar(String id) {
    for (final e in estandes) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// Registra a visita; devolve false se já existia.
  static bool registrar(String id) {
    if (!_visitados.add(id)) return false;
    _mudancas.add({..._visitados});
    return true;
  }
}
