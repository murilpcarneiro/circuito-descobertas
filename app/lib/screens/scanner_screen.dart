import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Abre a câmera e devolve o conteúdo do primeiro QR code lido.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _lido = false;

  void _onDetect(BarcodeCapture capture) {
    if (_lido || capture.barcodes.isEmpty) return;
    final valor = capture.barcodes.first.rawValue;
    if (valor == null) return;
    _lido = true;
    Navigator.of(context).pop(valor);
  }

  Future<void> _digitarCodigo() async {
    final ctrl = TextEditingController(text: 'circuito:');
    final valor = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Digitar código'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              const Text('Use o código impresso abaixo do QR.'),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: ctrl,
                autofocus: true,
                autocorrect: false,
                placeholder: 'circuito:E01',
                onSubmitted: (v) => Navigator.pop(ctx, v),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Usar'),
          ),
        ],
      ),
    );
    if (valor != null && valor.isNotEmpty && mounted && !_lido) {
      _lido = true;
      Navigator.of(context).pop(valor);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          const Center(
            child: SizedBox(width: 260, height: 260, child: CustomPaint(painter: _Mira())),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _BotaoVidro(
                      icone: CupertinoIcons.xmark,
                      rotulo: 'Fechar',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const Text(
                      'Ler QR code',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    _BotaoVidro(
                      icone: CupertinoIcons.keyboard,
                      rotulo: 'Digitar código',
                      onTap: _digitarCodigo,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: SafeArea(
              child: Column(
                children: [
                  _BotaoVidro(
                    icone: CupertinoIcons.bolt_fill,
                    rotulo: 'Lanterna',
                    tamanho: 56,
                    onTap: () => _controller.toggleTorch(),
                  ),
                  const SizedBox(height: 20),
                  const _Capsula(texto: 'Aponte para o QR code do estande'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cantos arredondados da mira, como no leitor de códigos da Câmera do iPhone.
class _Mira extends CustomPainter {
  const _Mira();

  @override
  void paint(Canvas canvas, Size size) {
    const lado = 44.0;
    const r = 18.0;
    final p = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final w = size.width, h = size.height;
    final cantos = [
      Path()
        ..moveTo(0, lado)
        ..lineTo(0, r)
        ..arcToPoint(const Offset(r, 0), radius: const Radius.circular(r))
        ..lineTo(lado, 0),
      Path()
        ..moveTo(w - lado, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: const Radius.circular(r))
        ..lineTo(w, lado),
      Path()
        ..moveTo(w, h - lado)
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: const Radius.circular(r))
        ..lineTo(w - lado, h),
      Path()
        ..moveTo(lado, h)
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: const Radius.circular(r))
        ..lineTo(0, h - lado),
    ];
    for (final c in cantos) {
      canvas.drawPath(c, p);
    }
  }

  @override
  bool shouldRepaint(_Mira old) => false;
}

class _BotaoVidro extends StatelessWidget {
  const _BotaoVidro({
    required this.icone,
    required this.rotulo,
    required this.onTap,
    this.tamanho = 40,
  });
  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: rotulo,
      child: GestureDetector(
        onTap: onTap,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: tamanho,
              height: tamanho,
              color: CupertinoColors.white.withValues(alpha: 0.2),
              child: Icon(icone, color: CupertinoColors.white, size: tamanho * 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

class _Capsula extends StatelessWidget {
  const _Capsula({required this.texto});
  final String texto;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: CupertinoColors.black.withValues(alpha: 0.35),
          child: Text(
            texto,
            style: const TextStyle(color: CupertinoColors.white, fontSize: 15, letterSpacing: -0.2),
          ),
        ),
      ),
    );
  }
}
