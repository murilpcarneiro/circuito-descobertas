import 'package:firebase_analytics/firebase_analytics.dart';

import 'demo.dart';

class Analytics {
  static FirebaseAnalytics get _fa => FirebaseAnalytics.instance;

  static Future<void> missaoAberta(int qtdEstandes) async {
    if (Demo.ativo) return;
    await _fa.logEvent(
      name: 'missao_aberta',
      parameters: {'qtd_estandes': qtdEstandes},
    );
  }

  static Future<void> checkinConcluido({
    required String estandeId,
    required bool missaoAtiva,
    required bool destacado,
  }) async {
    if (Demo.ativo) return;
    await _fa.logEvent(
      name: 'checkin_concluido',
      parameters: {
        'estande_id': estandeId,
        'missao_ativa': missaoAtiva ? 1 : 0,
        'estande_destacado': destacado ? 1 : 0,
      },
    );
  }
}
