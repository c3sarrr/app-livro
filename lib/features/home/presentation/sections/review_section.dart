import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons_inicio.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_shadows.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../../../core/design_system/widgets/pressable.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';

/// Seção 6 da prancha 01 — "Seus grifos de hoje" (L01a5): cartão `#FFFAF1`, borda 1,5, raio 28, sombra dura 4/4,
/// padding 16 e linha (gap 14, centralizada) com a arte 104 × 112 e o texto (gap 4) — 350 × 165,15. Só existe com o
/// baralho do dia: com dados reais `dailyReview` é `null` até a T05 e a seção some (D-247); vazio, também some
/// ([HomeSnapshot.visibleReview]). "Revisar" fica sem ação até a T05 (D-243 b).
class ReviewSection extends ConsumerWidget {
  const ReviewSection({super.key, this.onReviewTap});

  /// "Revisar" (`review.cta`): a Início passa o "sem ação" até a rota da revisão (T05).
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final review = ref.watch(
      homeSnapshotProvider.select((s) => s.visibleReview),
    );
    if (review == null) return const SizedBox.shrink();
    // <section aria-label="Seus grifos de hoje"> (convenção §5.1 do prompt mestre).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Seus grifos de hoje',
      child: NeoBox(
        key: const ValueKey('review'),
        color: AppColors.surface,
        border: const BorderSide(width: 1.5, color: AppColors.ink),
        radius: BorderRadius.circular(AppRadii.card),
        shadow: AppShadows.hard4,
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 14,
          children: [
            const _Art(),
            Expanded(
              child: _Text(review: review, onReviewTap: onReviewTap),
            ),
          ],
        ),
      ),
    );
  }
}

/// A arte `aria-hidden` (104 × 112): três cartõezinhos de grifo girados — verde −12°, rosa +8° e lavanda −2° por cima
/// (a ordem do arquivo) — e o brilho amarelo 26 em `right −2 · top −4`, que sai da caixa.
class _Art extends StatelessWidget {
  const _Art();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: SizedBox(
        key: ValueKey('review.art'),
        width: 104,
        height: 112,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 2,
              top: 18,
              child: _MiniCard(
                id: 'review.art.card1',
                width: 62,
                height: 82,
                degrees: -12,
                color: AppColors.leaf,
              ),
            ),
            Positioned(
              left: 36,
              top: 14,
              child: _MiniCard(
                id: 'review.art.card2',
                width: 62,
                height: 82,
                degrees: 8,
                color: AppColors.blush,
              ),
            ),
            Positioned(
              left: 18,
              top: 6,
              child: _MiniCard(
                id: 'review.art.card3',
                width: 66,
                height: 90,
                degrees: -2,
                color: AppColors.lavender,
              ),
            ),
            Positioned(
              right: -2,
              top: -4,
              child: AppSvg(
                AppIconsInicio.sparkleYellow,
                size: 26,
                key: ValueKey('review.art.sparkle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Um cartãozinho de grifo: raio 10, borda 1,5, sombra dura 2/2 (gira junto), padding 10/8 e 4 traços de 5 (raio 3,
/// gap 5) em 90/70/82/55 % — os dois primeiros na cor do grifo, os outros `#E4DACA`. A Key do id fica no slot sem
/// giro e o filho do `Transform` leva `<id>#rot` (a convenção das capas giradas).
class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.id,
    required this.width,
    required this.height,
    required this.degrees,
    required this.color,
  });

  final String id;
  final double width, height, degrees;

  /// A cor do grifo (os dois primeiros traços).
  final Color color;

  static const List<double> _widths = [0.9, 0.7, 0.82, 0.55];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey(id),
      width: width,
      height: height,
      child: Transform.rotate(
        angle: degrees * math.pi / 180,
        child: KeyedSubtree(
          key: ValueKey('$id#rot'),
          child: NeoBox(
            color: AppColors.surface,
            border: const BorderSide(width: 1.5, color: AppColors.ink),
            radius: BorderRadius.circular(10),
            shadow: AppShadows.hard2,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                for (final (i, w) in _widths.indexed)
                  FractionallySizedBox(
                    widthFactor: w,
                    child: NeoBox(
                      key: ValueKey('$id.line$i'),
                      height: 5,
                      color: i < 2 ? color : AppColors.reviewLineNeutral,
                      radius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// O texto (coluna, gap 4): o sobretítulo "REVISÃO · 5 GRIFOS · 2 MIN", "Seus grifos *de hoje*", de onde vêm os
/// grifos e o "Revisar" (6 abaixo, pílula tinta 40).
class _Text extends StatelessWidget {
  const _Text({required this.review, required this.onReviewTap});

  final DailyReview review;
  final VoidCallback? onReviewTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('review.textBlock'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        AppText(
          HomeFormatters.reviewKicker(review.highlights, review.minutes),
          key: const ValueKey('review.kicker'),
          style: AppTextStyles.reviewKicker,
        ),
        // "Seus grifos " + <span>de hoje</span>: um parágrafo, duas fontes, a mesma baseline (a serifada define a
        // linha de 25,2).
        AppText.rich(
          TextSpan(
            text: 'Seus grifos ',
            style: AppTextStyles.reviewTitle,
            children: [
              TextSpan(text: 'de hoje', style: AppTextStyles.reviewTitleSerif),
            ],
          ),
          key: const ValueKey('review.title'),
        ),
        AppText(
          HomeFormatters.reviewSubtitle(review.bookTitles),
          key: const ValueKey('review.subtitle'),
          style: AppTextStyles.reviewSubtitle,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6), // margin-top: 6
          child: Align(
            alignment: Alignment.centerLeft, // align-self: flex-start
            // <a href>: o nome do link é o texto ("Revisar").
            child: Pressable(
              isLink: true,
              onTap: onReviewTap,
              child: NeoBox(
                key: const ValueKey('review.cta'),
                height: 40,
                color: AppColors.ink,
                radius: BorderRadius.circular(AppRadii.pill),
                padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 7,
                  children: [
                    const AppSvg(
                      AppIconsInicio.sparkleSolidYellow,
                      size: 15,
                      key: ValueKey('review.cta.icon'),
                    ),
                    AppText(
                      'Revisar',
                      key: const ValueKey('review.cta.label'),
                      style: AppTextStyles.cta14OnInk,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
