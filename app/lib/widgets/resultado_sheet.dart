import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/checkin_service.dart';

/// Mostra "processando" e depois o retorno do check-in.
Future<void> mostrarResultadoCheckin(
    BuildContext context, Future<ResultadoCheckin> futuro) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: true,
    showDragHandle: true,
    // Branco no claro e cinza-grafite (#1C1C1E) no escuro, para destacar do fundo preto.
    backgroundColor: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => FutureBuilder<ResultadoCheckin>(
      future: futuro,
      builder: (context, snap) {
        final secundario = CupertinoColors.secondaryLabel.resolveFrom(context);
        if (!snap.hasData) {
          return SizedBox(
            height: 240,
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const CupertinoActivityIndicator(radius: 14),
              const SizedBox(height: 16),
              Text('Registrando visita…', style: TextStyle(fontSize: 15, color: secundario)),
            ])),
          );
        }
        final r = snap.data!;
        final nome = r.estande?.nome;
        final (IconData icone, CupertinoDynamicColor cor, String titulo, String texto) = switch (r.tipo) {
          TipoResultado.sucesso => (CupertinoIcons.checkmark_alt, CupertinoColors.systemGreen,
              'Check-in concluído', 'Sua visita ao estande ${nome ?? ''} foi registrada.'),
          TipoResultado.jaRegistrado => (CupertinoIcons.info, CupertinoColors.systemBlue,
              'Visita já registrada',
              'Você já fez check-in ${nome != null ? 'em $nome' : 'neste estande'}.'),
          TipoResultado.estandeInativo => (CupertinoIcons.nosign, CupertinoColors.systemOrange,
              'Estande inativo', '${nome ?? 'Este estande'} não está aceitando check-ins agora.'),
          TipoResultado.qrInvalido => (CupertinoIcons.qrcode, CupertinoColors.systemRed,
              'QR code inválido', r.detalhe ?? 'Este código não é de um estande do circuito.'),
          TipoResultado.erro => (CupertinoIcons.exclamationmark_triangle_fill, CupertinoColors.systemRed,
              'Não foi possível registrar', r.detalhe ?? 'Tente novamente.'),
        };
        final c = cor.resolveFrom(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: c.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icone, color: c, size: 36),
              ),
              const SizedBox(height: 16),
              Text(titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: CupertinoColors.label.resolveFrom(context),
                  )),
              const SizedBox(height: 6),
              Text(texto,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, height: 1.35, color: secundario)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(14),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ]),
          ),
        );
      },
    ),
  );
}
