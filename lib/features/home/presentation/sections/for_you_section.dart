import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons.dart';
import '../../../../core/design_system/tokens/app_spacing.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/pill.dart';
import '../../../../core/design_system/widgets/pressable.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';
import '../covers/memorias_postumas_cover.dart';
import '../covers/o_cortico_cover.dart';
import '../covers/quincas_borba_cover.dart';

/// Seção 6 — "Para você" (F08): coluna com gap 14 — cabeçalho (44), chip do motivo (32,6) e o carrossel
/// (218,4) → 327. O retângulo da seção é 20→370 (Key `forYou` no `_fullBleed` da tela), mas o carrossel
/// tem `margin: 4px -20px 0; padding: 0 20px`: ocupa 0→390 e começa 18 abaixo do chip (14 + 4). Por isso a
/// coluna tem a largura toda e o cabeçalho e o chip recuam 20 de cada lado.
class ForYouSection extends ConsumerWidget {
  const ForYouSection({super.key, this.onBookTap, this.onSeeAllTap});

  /// Item tocado (ligado a `/livro/:bookId` na F12).
  final ValueChanged<Book>? onBookTap;

  /// "Ver tudo" (ligado a `/para-voce` na F12).
  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forYou = ref.watch(homeSnapshotProvider.select((s) => s.forYou));
    assert(
      forYou.items.length == 3 &&
          forYou.items[0].cover == CoverArt.memoriasPostumas &&
          forYou.items[1].cover == CoverArt.quincasBorba &&
          forYou.items[2].cover == CoverArt.oCortico,
      'As artes de capa do arquivo nesta seção: Memórias Póstumas, Quincas Borba e O Cortiço.',
    );
    final onBookTap = this.onBookTap;
    // <section aria-label="Para você"> (convenção §5.1 do prompt mestre).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Para você',
      child: Column(
        mainAxisSize: MainAxisSize.min, // altura auto do CSS
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: _Header(onSeeAllTap: onSeeAllTap),
          ),
          const SizedBox(height: 14),
          // align-self: flex-start → o chip abraça o conteúdo, à esquerda.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _ReasonChip(
                label: HomeFormatters.forYouReason(forYou.reasonAuthor),
              ),
            ),
          ),
          // gap 14 + margin-top 4 do carrossel.
          const SizedBox(height: 14 + 4),
          // D-03: rola na horizontal com a física da plataforma; em repouso (offset 0) é o arquivo:
          // padding 20 dos dois lados e o 3º item cortado em 390 (`overflow: hidden`).
          // RepaintBoundary (F12 12.4): rolar a Início não repinta o carrossel e vice-versa. Medido: 0 pixels de
          // diferença no golden (as boundaries nas capas e no gráfico mudam o anti-aliasing de curvas).
          RepaintBoundary(
            child: SingleChildScrollView(
              key: const ValueKey('forYou.carousel'),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              clipBehavior: Clip.hardEdge,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 14,
                children: [
                  for (final (i, book) in forYou.items.indexed)
                    _Item(
                      id: 'forYou.item${i + 1}',
                      book: book,
                      // Só o 1º título tem `nowrap` + `ellipsis` no arquivo ("Memórias Póstu…").
                      ellipsis: i == 0,
                      onTap: onBookTap == null ? null : () => onBookTap(book),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho (44, `space-between`, centralizado): o `<h3>` 109,35 × 28,8 (→ y + 7,6) e o link "Ver tudo"
/// (altura de toque 44, gap 4): texto 14/700 + seta 18 (traço 2).
class _Header extends StatelessWidget {
  const _Header({required this.onSeeAllTap});

  final VoidCallback? onSeeAllTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('forYou.header'),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            container: true,
            header: true,
            headingLevel: 3, // <h3>
            child: AppText(
              'Para você',
              key: const ValueKey('forYou.title'),
              style: AppTextStyles.sectionTitleL,
            ),
          ),
          // <a href>: sem aria-label → o nome do link é o texto "Ver tudo" (a seta é um SVG sem nome acessível;
          // o AppSvg fica fora da árvore).
          Pressable(
            isLink: true,
            onTap: onSeeAllTap,
            child: SizedBox(
              key: const ValueKey('forYou.seeAll'),
              height: 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  AppText('Ver tudo', style: AppTextStyles.label14Bold),
                  const AppSvg(
                    AppIcons.arrowRight,
                    size: 18,
                    key: ValueKey('forYou.seeAll.icon'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip do motivo: padding 7 12 7 10, borda 1,5, fundo `#FFFAF1`, raio 999, gap 6 — brilho sólido 14
/// (`aria-hidden`) + texto 13/600 → 1,5 + 10 + 14 + 6 + 196,28 + 12 + 1,5 = 241,28 × 32,6.
class _ReasonChip extends StatelessWidget {
  const _ReasonChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Pill(
      key: const ValueKey('forYou.reasonChip'),
      padding: const EdgeInsets.fromLTRB(10, 7, 12, 7),
      color: AppColors.surface,
      border: const BorderSide(width: 1.5, color: AppColors.ink),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          const AppSvg(
            AppIcons.sparkleSolid,
            size: 14,
            key: ValueKey('forYou.reasonChip.icon'),
          ),
          AppText(label, style: AppTextStyles.body13Semi),
        ],
      ),
    );
  }
}

/// Item do carrossel (116 × 218,4, `flex-shrink: 0`): coluna com gap 10 — capa 116×174 + bloco de texto
/// (gap 2): título 14/700 (line-height 1,2) e autor 13/500 `#5B544B`. O item inteiro é o `<a>`: sem
/// `semanticsLabel`, o nome do link é o texto do item, como no navegador.
class _Item extends StatelessWidget {
  const _Item({
    required this.id,
    required this.book,
    required this.ellipsis,
    required this.onTap,
  });

  /// Prefixo das Keys: `forYou.item1` … `forYou.item3`.
  final String id;
  final Book book;

  /// `white-space: nowrap; overflow: hidden; text-overflow: ellipsis` no título.
  final bool ellipsis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget cover = switch (book.cover) {
      CoverArt.memoriasPostumas => const MemoriasPostumasCover(),
      CoverArt.quincasBorba => const QuincasBorbaCover(),
      CoverArt.oCortico => const OCorticoCover(),
      _ => throw ArgumentError.value(
        book.cover,
        'cover',
        'sem arte em "Para você"',
      ),
    };
    return Pressable(
      isLink: true, // <a href>
      onTap: onTap,
      child: SizedBox(
        key: ValueKey(id),
        width: 116,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            cover,
            Column(
              key: ValueKey('$id.textBlock'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 2,
              children: [
                // O arquivo abrevia o 1º título ("Memórias Póstumas") e ainda o corta com "…".
                AppText(
                  book.shortTitle ?? book.title,
                  key: ValueKey('$id.title'),
                  style: AppTextStyles.label14Bold,
                  maxLines: ellipsis ? 1 : null,
                  ellipsis: ellipsis,
                ),
                AppText(
                  book.author,
                  key: ValueKey('$id.author'),
                  style: AppTextStyles.body13Muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
