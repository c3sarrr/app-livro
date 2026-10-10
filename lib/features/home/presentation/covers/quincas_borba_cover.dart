import 'package:flutter/widgets.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/neo_box.dart';

/// Arte da capa "Quincas Borba" de "Para você" (F08, item 2): 116×174, azul, borda 1,5, raio 4/10/10/4,
/// `overflow: hidden` (recorte na padding box 113×171), sem sombra e sem rotação. Os filhos são absolutos,
/// medidos dentro da borda e pintados na ordem do arquivo: lombada, barras e bloco de texto. Na prancha 01 o mesmo
/// desenho é a capa de "Memorial de Aires".
class QuincasBorbaCover extends StatelessWidget {
  const QuincasBorbaCover({
    super.key,
    this.title = 'Quincas\nBorba',
    this.author = 'MACHADO DE ASSIS',
  });

  /// "Memorial / de Aires" da prancha 01.
  const QuincasBorbaCover.memorialDeAires({Key? key})
    : this(key: key, title: 'Memorial\nde Aires');

  /// O texto do título na arte (com os `<br>` do arquivo como "\n").
  final String title;

  /// O autor em maiúsculas, como no arquivo.
  final String author;

  @override
  Widget build(BuildContext context) {
    return NeoBox(
      key: const ValueKey('forYou.item2.cover'),
      width: 116,
      height: 174,
      color: AppColors.azure,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      radius: AppRadii.coverL,
      clip: true,
      // O único recorte é o do NeoBox (padding box, raio interno, suavizado). Sem `Clip.none`, a Stack
      // recortaria de novo — num retângulo SEM suavização — sempre que um filho transbordasse.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lombada: 7 px na altura toda, rgba(0,0,0,.18).
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 7,
            child: NeoBox(
              key: ValueKey('forYou.item2.cover.spine'),
              color: AppColors.spine18,
            ),
          ),
          // Barras: left 16 / right 16 / top 18 → coluna de 81 com gap 6; larguras 100 %, 70 % e 40 %.
          const Positioned(
            left: 16,
            right: 16,
            top: 18,
            child: Column(
              key: ValueKey('forYou.item2.cover.lines'),
              mainAxisSize: MainAxisSize.min,
              // `stretch` obrigatório: o FractionallySizedBox recebe os 81 e posiciona a fração à esquerda
              // (com `center` ele mediria só a fração e seria centralizado pela coluna).
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                _Bar(id: 'forYou.item2.cover.line1', widthFactor: 1),
                _Bar(id: 'forYou.item2.cover.line2', widthFactor: .7),
                _Bar(id: 'forYou.item2.cover.line3', widthFactor: .4),
              ],
            ),
          ),
          // Bloco inferior: left 16 / right 10 / bottom 12, gap 6.
          Positioned(
            left: 16,
            right: 10,
            bottom: 12,
            child: Column(
              key: const ValueKey('forYou.item2.cover.textBlock'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                // O `<br>` do arquivo.
                AppText(
                  title,
                  key: const ValueKey('forYou.item2.cover.title'),
                  style: AppTextStyles.coverTitle26,
                ),
                AppText(
                  author,
                  key: const ValueKey('forYou.item2.cover.author'),
                  style: AppTextStyles.coverAuthorSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra 6 px `#F7F0E3`, raio 6, com [widthFactor] da largura da coluna, alinhada à esquerda. A Key fica na
/// caixa da barra (81 / 56,7 / 32,4 × 6), não no `FractionallySizedBox` (que mede a coluna toda).
class _Bar extends StatelessWidget {
  const _Bar({required this.id, required this.widthFactor});

  final String id;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        key: ValueKey(id),
        height: 6,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
    );
  }
}
