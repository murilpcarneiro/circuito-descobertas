import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/estande.dart';
import '../services/analytics.dart';
import '../services/checkin_service.dart';
import '../services/missao_service.dart';
import '../widgets/barra_checkin.dart';
import '../widgets/estande_card.dart';

class MissaoScreen extends StatefulWidget {
  const MissaoScreen({super.key});

  @override
  State<MissaoScreen> createState() => _MissaoScreenState();
}

class _MissaoScreenState extends State<MissaoScreen> {
  final Stream<List<Estande>> _estandes = CheckinService.instance.estandesAtivos();
  final Stream<Set<String>> _visitados = CheckinService.instance.meusCheckins();

  @override
  void initState() {
    super.initState();
    Analytics.missaoAberta(MissaoService.instance.estandesIds.length);
  }

  @override
  Widget build(BuildContext context) {
    final missao = MissaoService.instance;
    final fundo = CupertinoColors.systemGroupedBackground.resolveFrom(context);

    return ListenableBuilder(
      listenable: missao,
      builder: (context, _) {
        return Scaffold(
          extendBody: true,
          bottomNavigationBar: missao.ativa ? const BarraCheckin() : null,
          body: CustomScrollView(
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: Text(missao.titulo),
                previousPageTitle: 'Voltar',
                backgroundColor: fundo.withValues(alpha: 0.8),
                border: null,
              ),
              if (!missao.ativa)
                SliverFillRemaining(hasScrollBody: false, child: _Encerrada())
              else
                SliverToBoxAdapter(
                  child: StreamBuilder<Set<String>>(
                    stream: _visitados,
                    builder: (context, visitadosSnap) {
                      final visitados = visitadosSnap.data ?? const <String>{};
                      return StreamBuilder<List<Estande>>(
                        stream: _estandes,
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(48),
                              child: CupertinoActivityIndicator(radius: 14),
                            );
                          }
                          final participantes =
                              snap.data!.where((e) => missao.estandesIds.contains(e.id)).toList();
                          final feitos = participantes.where((e) => visitados.contains(e.id)).length;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Progresso(feitos: feitos, total: participantes.length),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                                child: Text('Estandes da missão',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                      color: CupertinoColors.label.resolveFrom(context),
                                    )),
                              ),
                              if (participantes.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text('Nenhum estande ativo participa da missão.',
                                      style: TextStyle(
                                          color: CupertinoColors.secondaryLabel.resolveFrom(context))),
                                )
                              else
                                GrupoEstandes(
                                  estandes: participantes,
                                  destacado: (_) => true,
                                  visitados: visitados,
                                ),
                              const SizedBox(height: 120),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Cartão com o anel de progresso, inspirado nos anéis de atividade do iOS.
class _Progresso extends StatelessWidget {
  const _Progresso({required this.feitos, required this.total});
  final int feitos;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fracao = total == 0 ? 0.0 : feitos / total;
    final completa = total > 0 && feitos == total;
    final secundario = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fracao),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, valor, _) => CustomPaint(
                painter: _Anel(
                  valor,
                  trilho: CupertinoColors.systemFill.resolveFrom(context),
                ),
                child: Center(
                  child: Text(
                    '$feitos/$total',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completa ? 'Missão cumprida!' : 'Em andamento',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4),
                ),
                const SizedBox(height: 4),
                Text(
                  completa
                      ? 'Você visitou todos os estandes destacados.'
                      : 'Faça check-in em cada estande destacado para completar.',
                  style: TextStyle(fontSize: 15, height: 1.3, color: secundario),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Anel extends CustomPainter {
  _Anel(this.valor, {required this.trilho});
  final double valor;
  final Color trilho;

  @override
  void paint(Canvas canvas, Size size) {
    const espessura = 12.0;
    final rect = Offset.zero & size;
    final arco = rect.deflate(espessura / 2);
    canvas.drawArc(
      arco,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = trilho
        ..style = PaintingStyle.stroke
        ..strokeWidth = espessura,
    );
    if (valor <= 0) return;
    canvas.drawArc(
      arco,
      -math.pi / 2,
      math.pi * 2 * valor,
      false,
      Paint()
        // Gira um pouco além do topo para a ponta arredondada inicial não pegar a cor final.
        ..shader = const SweepGradient(
          colors: [Color(0xFFFF9F0A), Color(0xFFFF375F)],
          transform: GradientRotation(-math.pi / 2 - 0.2),
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = espessura,
    );
  }

  @override
  bool shouldRepaint(_Anel old) => old.valor != valor || old.trilho != trilho;
}

class _Encerrada extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.flag_fill, size: 48, color: CupertinoColors.tertiaryLabel.resolveFrom(context)),
          const SizedBox(height: 12),
          const Text('Missão encerrada',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('A organização encerrou esta missão.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel.resolveFrom(context))),
          const SizedBox(height: 20),
          CupertinoButton.filled(
            borderRadius: BorderRadius.circular(14),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Voltar para a lista'),
          ),
        ],
      ),
    );
  }
}
