import 'package:flutter/cupertino.dart';

import '../models/estande.dart';

/// Lista agrupada no estilo "inset grouped" do iOS: um cartão arredondado
/// com uma linha por estande e separadores alinhados ao texto.
class GrupoEstandes extends StatelessWidget {
  const GrupoEstandes({
    super.key,
    required this.estandes,
    required this.destacado,
    required this.visitados,
  });

  final List<Estande> estandes;
  final bool Function(String id) destacado;
  final Set<String> visitados;

  @override
  Widget build(BuildContext context) {
    final separador = CupertinoColors.separator.resolveFrom(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < estandes.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.only(left: 72),
                child: Container(height: 0.5, color: separador),
              ),
            EstandeCard(
              estande: estandes[i],
              destacado: destacado(estandes[i].id),
              visitado: visitados.contains(estandes[i].id),
            ),
          ],
        ],
      ),
    );
  }
}

class EstandeCard extends StatelessWidget {
  const EstandeCard({
    super.key,
    required this.estande,
    this.destacado = false,
    this.visitado = false,
  });

  final Estande estande;
  final bool destacado;
  final bool visitado;

  @override
  Widget build(BuildContext context) {
    final laranja = CupertinoColors.systemOrange.resolveFrom(context);
    final azul = CupertinoColors.systemBlue.resolveFrom(context);
    final secundario = CupertinoColors.secondaryLabel.resolveFrom(context);
    final terciario = CupertinoColors.tertiaryLabel.resolveFrom(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone com o código, como os ícones coloridos dos Ajustes do iOS.
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: destacado ? laranja : azul,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              estande.id,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        estande.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: CupertinoColors.label.resolveFrom(context),
                        ),
                      ),
                    ),
                    if (destacado) ...[
                      const SizedBox(width: 6),
                      Icon(CupertinoIcons.star_fill, size: 14, color: laranja),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  estande.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, height: 1.3, letterSpacing: -0.2, color: secundario),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(CupertinoIcons.location_solid, size: 12, color: terciario),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        estande.localizacao,
                        style: TextStyle(fontSize: 13, letterSpacing: -0.1, color: terciario),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (visitado) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 24,
                color: CupertinoColors.systemGreen.resolveFrom(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
