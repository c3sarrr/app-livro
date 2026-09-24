import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/painters/ring_progress_painter.dart';
import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/count_badge.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../../../core/design_system/widgets/pressable.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';
import '../covers/mrs_dalloway_cover.dart';
import '../covers/pride_prejudice_cover.dart';

/// Seção 4 — "Também lendo" (F06): coluna com gap 30 (grande porque as capas sobem 22 px para dentro dele)
/// entre o cabeçalho (título + contador, gap 8, centralizados) e a grade de 2 colunas iguais com gap 12
/// (cards de 169). Altura: 22 + 30 + 123,6 = 175,6. Nada recorta a grade nem os cards.
class AlsoReadingSection extends ConsumerWidget {
  const AlsoReadingSection({super.key, this.onBookTap});

  /// Card tocado (ligado a `/livro/:bookId` na F12).
  final ValueChanged<Book>? onBookTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(homeSnapshotProvider.select((s) => s.alsoReading));
    assert(
      items.length == 2 &&
          items[0].book.cover == CoverArt.mrsDalloway &&
          items[1].book.cover == CoverArt.pridePrejudice,
      'As artes de capa do arquivo nesta seção: Mrs. Dalloway (card 1) e Orgulho e Preconceito (card 2).',
    );
    final onBookTap = this.onBookTap;
    // <section aria-label="Também lendo"> (convenção §5.1 do prompt mestre).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Também lendo',
      child: Column(
        key: const ValueKey('alsoReading'),
        mainAxisSize: MainAxisSize.min, // altura auto do CSS
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 30,
        children: [
          Row(
            key: const ValueKey('alsoReading.header'),
            spacing: 8,
            children: [
              // <h3>: 21,6 de altura, centrado na linha de 22 do contador → y + 0,2.
              Semantics(
                container: true,
                header: true,
                headingLevel: 3,
                child: AppText(
                  'Também lendo',
                  key: const ValueKey('alsoReading.title'),
                  style: AppTextStyles.sectionTitleS,
                ),
              ),
              CountBadge(
                key: const ValueKey('alsoReading.count'),
                label: '${items.length}',
                style: AppTextStyles.count12OnInk,
                minWidth: 22,
                height: 22,
                horizontalPadding: 7,
                background: AppColors.ink,
              ),
            ],
          ),
          Row(
            key: const ValueKey('alsoReading.grid'),
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              for (final (i, item) in items.indexed)
                Expanded(
                  child: _BookCard(
                    id: 'alsoReading.card${i + 1}',
                    item: item,
                    onTap: onBookTap == null
                        ? null
                        : () => onBookTap(item.book),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card 169 × 123,6 (= 1,5 + 59 + 12 + 35,6 + 14 + 1,5): fundo `#FFFAF1`, borda 1,5, raio 22, padding
/// 0/14/14 (sem padding no topo), sem sombra e sem recorte — a capa passa por cima da borda. O card inteiro
/// é o `<a>`: sem `semanticsLabel`, o nome do link é o texto do card, como no navegador.
class _BookCard extends StatelessWidget {
  const _BookCard({required this.id, required this.item, required this.onTap});

  /// Prefixo das Keys: `alsoReading.card1` / `alsoReading.card2`.
  final String id;
  final AlsoReadingItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      isLink: true, // <a href>
      onTap: onTap,
      child: NeoBox(
        key: ValueKey(id),
        color: AppColors.surface,
        border: const BorderSide(width: 1.5, color: AppColors.ink),
        radius: BorderRadius.circular(AppRadii.cardM),
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            // align-items: flex-end + space-between; a linha mede 59 (81 − 22 da capa).
            SizedBox(
              key: ValueKey('$id.top'),
              height: 59,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _CoverSlot(id: '$id.cover', art: item.book.cover),
                  // margin-top 12 → o anel ocupa 58 e, alinhado embaixo, começa 13 abaixo do topo da linha.
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _Ring(id: '$id.ring', progress: item.progress),
                  ),
                ],
              ),
            ),
            Column(
              key: ValueKey('$id.textBlock'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: [
                // white-space: nowrap + text-overflow: ellipsis ("Orgulho e Precon…").
                AppText(
                  item.book.title,
                  key: ValueKey('$id.title'),
                  style: AppTextStyles.title15,
                  maxLines: 1,
                  ellipsis: true,
                ),
                AppText(
                  item.book.author,
                  key: ValueKey('$id.author'),
                  style: AppTextStyles.body13Muted,
                  maxLines: 1,
                  ellipsis: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Capa 54×81 com `margin-top: −22`: ocupa 54×59 na linha e vaza 22 px para cima (o `OverflowBox` mantém o
/// tamanho de layout do CSS). `transform: rotate` em torno do centro, sem afetar o layout; a sombra 2/2
/// gira junto com a arte.
class _CoverSlot extends StatelessWidget {
  const _CoverSlot({required this.id, required this.art});

  /// `alsoReading.card1.cover` / `alsoReading.card2.cover`.
  final String id;
  final CoverArt art;

  @override
  Widget build(BuildContext context) {
    final (cover, degrees) = switch (art) {
      CoverArt.mrsDalloway => (const MrsDallowayCover(), -4.0),
      CoverArt.pridePrejudice => (const PridePrejudiceCover(), 3.0),
      _ => throw ArgumentError.value(art, 'art', 'sem arte em "Também lendo"'),
    };
    return SizedBox(
      width: 54,
      height: 59,
      child: OverflowBox(
        minHeight: 81,
        maxHeight: 81,
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          key: ValueKey(id), // slot de layout, sem rotação
          width: 54,
          height: 81,
          child: Transform.rotate(
            angle: degrees * math.pi / 180,
            child: KeyedSubtree(key: ValueKey('$id#rot'), child: cover),
          ),
        ),
      ),
    );
  }
}

/// Anel 46×46: o SVG `aria-hidden` do arquivo (trilho `#EAE1CF` + arco tinta, r 18, traço 5, ponta redonda,
/// do topo no sentido horário) e o percentual centralizado por cima (`inset: 0` + flex centralizado).
class _Ring extends StatelessWidget {
  const _Ring({required this.id, required this.progress});

  /// `alsoReading.card1.ring` / `alsoReading.card2.ring`.
  final String id;

  /// Fração lida (0–1).
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: ValueKey(id),
      width: 46,
      height: 46,
      child: Stack(
        children: [
          // Positioned.fill: sem filho e com restrição frouxa, o CustomPaint mediria 0×0.
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                key: ValueKey('$id.svg'),
                painter: RingProgressPainter(progress: progress),
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              key: ValueKey('$id.label'),
              child: AppText(
                HomeFormatters.percent(progress),
                style: AppTextStyles.micro11Bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
