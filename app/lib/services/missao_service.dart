import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'demo.dart';

/// Lê a missão surpresa do Remote Config e avisa a UI quando ela muda
/// (atualização em tempo real, sem reinstalar o app).
///
/// Parâmetros no console:
///  - missao_ativa    (booleano)  padrão local: false
///  - missao_estandes (string)    IDs separados por vírgula, ex.: "E01,E03"
///  - missao_titulo   (string)    opcional, texto da chamada
class MissaoService extends ChangeNotifier {
  MissaoService._();
  static final MissaoService instance = MissaoService._();

  late final FirebaseRemoteConfig _rc = FirebaseRemoteConfig.instance;
  StreamSubscription<RemoteConfigUpdate>? _sub;

  bool get ativa => Demo.ativo ? Demo.missaoAtiva : _rc.getBool('missao_ativa');

  String get titulo {
    final t = (Demo.ativo ? Demo.missaoTitulo : _rc.getString('missao_titulo')).trim();
    return t.isEmpty ? 'Missão surpresa' : t;
  }

  Set<String> get estandesIds => (Demo.ativo
          ? Demo.missaoEstandes
          : _rc.getString('missao_estandes'))
      .split(',')
      .map((s) => s.trim().toUpperCase())
      .where((s) => s.isNotEmpty)
      .toSet();

  bool destacado(String estandeId) => ativa && estandesIds.contains(estandeId);

  Future<void> iniciar() async {
    await _rc.setDefaults(const {
      'missao_ativa': false,
      'missao_estandes': '',
      'missao_titulo': 'Missão surpresa',
    });
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(minutes: 1),
    ));
    try {
      await _rc.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config: usando padrões locais ($e)');
    }

    // Tempo real: o console publica, o app ativa e redesenha.
    _sub = _rc.onConfigUpdated.listen(
      (_) async {
        await _rc.activate();
        notifyListeners();
      },
      onError: (Object e) => debugPrint('Remote Config tempo real: $e'),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
