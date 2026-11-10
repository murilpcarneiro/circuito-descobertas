import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/estande.dart';
import '../services/checkin_service.dart';
import '../services/missao_service.dart';
import '../widgets/barra_checkin.dart';
import '../widgets/estande_card.dart';
import 'missao_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Streams criadas uma vez só, para não reabrir a escuta a cada redesenho.
  final Stream<List<Estande>> _estandes = CheckinService.instance.estandesAtivos();
  final Stream<Set<String>> _visitados = CheckinService.instance.meusCheckins();

  @override
  Widget build(BuildContext context) {
    final missao = MissaoService.instance;
    final fundo = CupertinoColors.systemGroupedBackground.resolveFrom(context);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const BarraCheckin(),
      body: ListenableBuilder(
        listenable: missao,
        builder: (context, _) {
          return StreamBuilder<Set<String>>(
            stream: _visitados,
            builder: (context, visitadosSnap) {
              final visitados = visitadosSnap.data ?? const <String>{};
              return StreamBuilder<List<Estande>>(
                stream: _estandes,
                builder: (context, snap) {
                  final estandes = snap.data ?? const <Estande>[];
                  final daMissao = estandes.where((e) => missao.destacado(e.id)).toList();
                  return CustomScrollView(
                    slivers: [
                      CupertinoSliverNavigationBar(
                        largeTitle: const Text('Descobertas'),
                        middle: const Text('Circuito de Descobertas'),
                        alwaysShowMiddle: false,
                        backgroundColor: fundo.withValues(alpha: 0.8),
                        border: null,
                      ),
                      if (snap.hasError)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _Aviso(
                            icone: CupertinoIcons.wifi_exclamationmark,
                            titulo: 'Não foi possível carregar',
                            texto: '${snap.error}',
                          ),
                        )
                      else if (!snap.hasData)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CupertinoActivityIndicator(radius: 14)),
                        )
                      else ...[
                        SliverToBoxAdapter(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: missao.ativa
                                ? _BannerMissao(
                                    titulo: missao.titulo,
                                    total: daMissao.length,
                                    feitos: daMissao.where((e) => visitados.contains(e.id)).length,
                                  )
                                : const SizedBox(width: double.infinity),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _Cabecalho(
                            titulo: 'Estandes',
                            detalhe: '${estandes.where((e) => visitados.contains(e.id)).length} '
                                'de ${estandes.length} visitados',
                          ),
                        ),
                        if (estandes.isEmpty)
                          const SliverToBoxAdapter(
                            child: _Aviso(
                              icone: CupertinoIcons.building_2_fill,
                              titulo: 'Nenhum estande ativo',
                              texto: 'Os estandes aparecem aqui assim que a organização abrir a feira.',
                            ),
                          )
                        else
                          SliverToBoxAdapter(
                            child: GrupoEstandes(
                              estandes: estandes,
                              destacado: missao.destacado,
                              visitados: visitados,
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(32, 8, 32, 0),
                            child: Text(
                              'Toque em Fazer check-in e aponte a câmera para o QR code do estande.',
                              style: TextStyle(
                                fontSize: 13,
                                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                              ),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.titulo, required this.detalhe});
  final String titulo;
  final String detalhe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(titulo,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: CupertinoColors.label.resolveFrom(context),
              )),
          const Spacer(),
          Text(detalhe,
              style: TextStyle(fontSize: 15, color: CupertinoColors.secondaryLabel.resolveFrom(context))),
        ],
      ),
    );
  }
}

/// Cartão em destaque da missão, com gradiente no estilo dos cartões do app Fitness.
class _BannerMissao extends StatelessWidget {
  const _BannerMissao({required this.titulo, required this.total, required this.feitos});
  final String titulo;
  final int total;
  final int feitos;

  @override
  Widget build(BuildContext context) {
    const branco = CupertinoColors.white;
    final completa = total > 0 && feitos == total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => const MissaoScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF9F0A), Color(0xFFFF375F)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: branco.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      completa ? CupertinoIcons.checkmark_alt : CupertinoIcons.star_fill,
                      color: branco,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titulo,
                            style: const TextStyle(
                              color: branco,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            )),
                        Text(
                          completa
                              ? 'Missão cumprida!'
                              : 'Visite os $total estandes destacados',
                          style: TextStyle(color: branco.withValues(alpha: 0.9), fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_right, color: branco.withValues(alpha: 0.8), size: 18),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : feitos / total,
                  minHeight: 6,
                  color: branco,
                  backgroundColor: branco.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 6),
              Text('$feitos de $total concluídos',
                  style: TextStyle(color: branco.withValues(alpha: 0.9), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.icone, required this.titulo, required this.texto});
  final IconData icone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final secundario = CupertinoColors.secondaryLabel.resolveFrom(context);
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 44, color: CupertinoColors.tertiaryLabel.resolveFrom(context)),
          const SizedBox(height: 12),
          Text(titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(texto, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: secundario)),
        ],
      ),
    );
  }
}
