import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/estande.dart';
import 'analytics.dart';
import 'demo.dart';
import 'missao_service.dart';

/// Mesmo prefixo usado pelo painel ao gerar o QR code.
const String qrPrefix = 'circuito:';

enum TipoResultado { sucesso, qrInvalido, estandeInativo, jaRegistrado, erro }

class ResultadoCheckin {
  const ResultadoCheckin(this.tipo, {this.estande, this.detalhe});
  final TipoResultado tipo;
  final Estande? estande;
  final String? detalhe;
}

class CheckinService {
  CheckinService._();
  static final CheckinService instance = CheckinService._();

  late final FirebaseFirestore _db = FirebaseFirestore.instance;
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// Estandes ativos, ordenados pelo ID.
  Stream<List<Estande>> estandesAtivos() => Demo.ativo
      ? Demo.estandesAtivos()
      : _db
      .collection('estandes')
      .where('ativo', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(Estande.fromDoc).toList()
        ..sort((a, b) => a.id.compareTo(b.id)));

  /// IDs dos estandes que este visitante já visitou.
  Stream<Set<String>> meusCheckins() => Demo.ativo
      ? Demo.visitados()
      : _db
      .collection('checkins')
      .where('visitanteId', isEqualTo: _uid)
      .snapshots()
      .map((s) => s.docs.map((d) => d.get('estandeId') as String).toSet());

  /// Lê o conteúdo do QR, valida e grava o check-in.
  Future<ResultadoCheckin> registrar(String conteudoQr) async {
    final texto = conteudoQr.trim();
    if (!texto.startsWith(qrPrefix)) {
      return const ResultadoCheckin(TipoResultado.qrInvalido,
          detalhe: 'Este QR code não pertence ao Circuito de Descobertas.');
    }
    final id = texto.substring(qrPrefix.length).trim().toUpperCase();
    if (id.isEmpty || id.contains('/')) {
      return const ResultadoCheckin(TipoResultado.qrInvalido,
          detalhe: 'O QR code não contém um estande válido.');
    }

    if (Demo.ativo) return _registrarDemo(id);

    try {
      // 1) O estande existe e está ativo?
      final snap = await _db
          .collection('estandes')
          .doc(id)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      if (!snap.exists) {
        return ResultadoCheckin(TipoResultado.qrInvalido,
            detalhe: 'Nenhum estande encontrado com o código $id.');
      }
      final estande = Estande.fromDoc(snap);
      if (!estande.ativo) {
        return ResultadoCheckin(TipoResultado.estandeInativo, estande: estande);
      }

      // 2) Já visitou? A chave composta visitante_estande impede duplicatas.
      final ref = _db.collection('checkins').doc('${_uid}_$id');
      final existente = await ref
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));
      if (existente.exists) {
        return ResultadoCheckin(TipoResultado.jaRegistrado, estande: estande);
      }

      // 3) Grava e só confirma depois que o servidor aceitou.
      await ref.set({
        'visitanteId': _uid,
        'estandeId': id,
        'criadoEm': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));

      final missao = MissaoService.instance;
      await Analytics.checkinConcluido(
        estandeId: id,
        missaoAtiva: missao.ativa,
        destacado: missao.destacado(id),
      );
      return ResultadoCheckin(TipoResultado.sucesso, estande: estande);
    } on TimeoutException {
      return const ResultadoCheckin(TipoResultado.erro,
          detalhe: 'Sem resposta do servidor. Verifique a internet e tente de novo.');
    } on FirebaseException catch (e) {
      // As regras recusam criar um check-in que já existe.
      if (e.code == 'permission-denied') {
        final ja = await _db.collection('checkins').doc('${_uid}_$id').get();
        if (ja.exists) return const ResultadoCheckin(TipoResultado.jaRegistrado);
      }
      return ResultadoCheckin(TipoResultado.erro, detalhe: e.message ?? e.code);
    }
  }

  /// Mesmas regras de [registrar], com os dados em memória do modo demo.
  Future<ResultadoCheckin> _registrarDemo(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final estande = Demo.buscar(id);
    if (estande == null) {
      return ResultadoCheckin(TipoResultado.qrInvalido,
          detalhe: 'Nenhum estande encontrado com o código $id.');
    }
    if (!estande.ativo) {
      return ResultadoCheckin(TipoResultado.estandeInativo, estande: estande);
    }
    if (!Demo.registrar(id)) {
      return ResultadoCheckin(TipoResultado.jaRegistrado, estande: estande);
    }
    return ResultadoCheckin(TipoResultado.sucesso, estande: estande);
  }
}
