import 'dart:ui';

import 'package:flutter/cupertino.dart';

import '../screens/scanner_screen.dart';
import '../services/checkin_service.dart';
import 'resultado_sheet.dart';

/// Abre o leitor e mostra o resultado do check-in.
Future<void> fazerCheckin(BuildContext context) async {
  final conteudo = await Navigator.of(context).push<String>(
    CupertinoPageRoute(fullscreenDialog: true, builder: (_) => const ScannerScreen()),
  );
  if (conteudo == null || !context.mounted) return;
  await mostrarResultadoCheckin(context, CheckinService.instance.registrar(conteudo));
}

/// Barra inferior translúcida (material "vidro" do iOS) com o botão principal.
class BarraCheckin extends StatelessWidget {
  const BarraCheckin({super.key});

  @override
  Widget build(BuildContext context) {
    final fundo = CupertinoColors.systemGroupedBackground.resolveFrom(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: fundo.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(color: CupertinoColors.separator.resolveFrom(context), width: 0.5),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                borderRadius: BorderRadius.circular(14),
                padding: const EdgeInsets.symmetric(vertical: 15),
                onPressed: () => fazerCheckin(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(CupertinoIcons.qrcode_viewfinder, size: 22),
                    SizedBox(width: 8),
                    Text('Fazer check-in',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.4)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
