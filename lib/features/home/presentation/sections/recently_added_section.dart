import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_strokes.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../../../core/design_system/widgets/pill.dart';
import '../../../../core/design_system/widgets/pressable.dart';
import '../../application/css_flex.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';
import '../covers/book_cover.dart';
import '../covers/frankenstein_mini_cover.dart';
import '../covers/o_alienista_mini_cover.dart';
import '../covers/senhora_mini_cover.dart';

/// Seção 8 — "Recém-chegados" (F10): coluna com gap 10 — cabeçalho (44) e a lista (280) → 334. A lista é uma
/// caixa `#FFFAF1` de raio 24, sem borda nem sombra, com padding 4/8/4/14 (assimétrico) e as linhas em coluna.
/// Cada linha tem a altura da mini-capa (66) + padding 12 em cima e embaixo + o divisor de 1 px das duas
/// primeiras (91, 91 e 90): capa 44, texto flexível, selo e o botão "mais opções" 44, com gap 14.
class RecentlyAddedSection extends ConsumerWidget {
  const RecentlyAddedSection({
    super.key,
    this.onBookTap,
    this.onMoreTap,
    this.onLibraryTap,
  });

  /// Texto do livro tocado (ligado a `/livro/:bookId` na F12).
  final ValueChanged<Book>? onBookTap;

  /// Botão "Mais opções para …" (menu do livro, F12).
  final ValueChanged<Book>? onMoreTap;

  /// Link "Biblioteca" (ligado a `/biblioteca` na F12).
  final VoidCallback? onLibraryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(homeSnapshotProvider.select((s) => s.recent));
    assert(
      recent.every((r) => r.book.cover is PhotoCover) ||
          (recent.length == 3 &&
              recent[0].book.cover ==
                  const DesignedCover(CoverArt.frankenstein) &&
              recent[1].book.cover ==
                  const DesignedCover(CoverArt.oAlienista) &&
              recent[2].book.cover == const DesignedCover(CoverArt.senhora)),
      'As artes de capa do arquivo nesta seção: Frankenstein, O Alienista e Senhora.',
    );
    final onBookTap = this.onBookTap;
    final onMoreTap = this.onMoreTap;
    // <section aria-label="Adicionados recentemente"> (convenção §5.1 do prompt mestre).
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Adicionados recentemente',
      child: Column(
        key: const ValueKey('recent'),
        mainAxisSize: MainAxisSize.min, // altura auto do CSS
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          _Header(onLibraryTap: onLibraryTap),
          NeoBox(
            key: const ValueKey('recent.list'),
            color: AppColors.surface,
            radius: BorderRadius.circular(AppRadii.list),
            padding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, item) in recent.indexed)
                  _Row(
                    index: i,
                    item: item,
                    // O divisor é `border-bottom` das linhas 0 e 1; a última não tem.
                    divider: i < recent.length - 1,
                    onTap: onBookTap == null
                        ? null
                        : () => onBookTap(item.book),
                    onMore: onMoreTap == null
                        ? null
                        : () => onMoreTap(item.book),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho (44, `space-between`, centralizado): o `<h3>` 195,47 × 28,8 (→ y + 7,6) e o link "Biblioteca"
/// (altura de toque 44, gap 4): texto 14/700 + seta 18 (traço 2). Igual ao de "Para você".
class _Header extends StatelessWidget {
  const _Header({required this.onLibraryTap});

  final VoidCallback? onLibraryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('recent.header'),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            container: true,
            header: true,
            headingLevel: 3, // <h3>
            child: AppText(
              'Recém-chegados',
              key: const ValueKey('recent.title'),
              style: AppTextStyles.sectionTitleL,
            ),
          ),
          // <a href>: sem aria-label → o nome do link é o texto "Biblioteca" (a seta é um SVG sem nome acessível;
          // o AppSvg fica fora da árvore).
          Pressable(
            isLink: true,
            onTap: onLibraryTap,
            child: SizedBox(
              key: const ValueKey('recent.libraryLink'),
              height: 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  AppText('Biblioteca', style: AppTextStyles.label14Bold),
                  const AppSvg(
                    AppIcons.arrowRight,
                    size: 18,
                    key: ValueKey('recent.libraryLink.icon'),
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

/// Linha: `align-items: center`, gap 14, padding 12 0 e divisor opcional. O texto (`flex-grow: 1`, `min-width: 0`)
/// e o selo (`flex-shrink: 1`) NÃO usam `Expanded`/`Flexible`: o CSS encolhe os dois em proporção à base interna
/// de cada um, e `resolveTextAndTag` implementa esse algoritmo (§9.7 do CSS Flexbox) sobre as larguras
/// intrínsecas medidas com os mesmos estilos do `AppText`.
class _Row extends StatelessWidget {
  const _Row({
    required this.index,
    required this.item,
    required this.divider,
    required this.onTap,
    required this.onMore,
  });

  /// 0–2: `recent.row0` … `recent.row2`.
  final int index;
  final RecentItem item;
  final bool divider;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  static const double _cover = 44, _more = 44, _gap = 14;

  @override
  Widget build(BuildContext context) {
    final id = 'recent.row$index';
    final book = item.book;
    final subtitle = HomeFormatters.recentSubtitle(item);
    final real = book.cover is PhotoCover;
    final (tagLabel, tagStyle, tagColor) = switch (item.status) {
      RecentStatus.wantToRead => (
        HomeFormatters.recentStatusLabel(item.status),
        AppTextStyles.tagLavender,
        AppColors.tagLavenderBg,
      ),
      RecentStatus.isNew => (
        HomeFormatters.recentStatusLabel(item.status),
        AppTextStyles.tagSand,
        AppColors.tagSandBg,
      ),
      RecentStatus.read => (
        HomeFormatters.recentStatusLabel(item.status),
        AppTextStyles.tagRead,
        AppColors.tagReadBg,
      ),
    };
    final Widget cover = switch (book.cover) {
      DesignedCover(art: CoverArt.frankenstein) => FrankensteinMiniCover(
        id: '$id.cover',
      ),
      DesignedCover(art: CoverArt.oAlienista) => OAlienistaMiniCover(
        id: '$id.cover',
      ),
      DesignedCover(art: CoverArt.senhora) => SenhoraMiniCover(id: '$id.cover'),
      // Livro real (D-79): a foto na moldura da miniatura (44×66).
      final PhotoCover c => PhotoBookCover(
        key: ValueKey<String>('$id.cover'),
        book: book,
        cover: c,
        slot: CoverSlot.recent,
      ),
      final other => throw ArgumentError.value(
        other,
        'cover',
        'sem mini-capa em "Recém-chegados"',
      ),
    };
    return LayoutBuilder(
      builder: (context, c) {
        final w = resolveTextAndTag(
          // 328 − 44 − 44 − 3 × 14 = 198
          available: c.maxWidth - _cover - _more - 3 * _gap,
          textMaxContent: math.max(
            measure(book.title, AppTextStyles.title15),
            measure(subtitle, AppTextStyles.body13Muted),
          ),
          tagTextMaxContent: measure(tagLabel, tagStyle),
          // "Lido" tem `white-space: nowrap` na prancha 01 (o mínimo é o texto inteiro); os outros quebram entre as
          // palavras. Com a palavra única de hoje as duas medidas coincidem: a regra segue o CSS da prancha.
          tagTextMinContent: item.status == RecentStatus.read
              ? measure(tagLabel, tagStyle)
              : longestWord(tagLabel, tagStyle),
        );
        // `Container` SOMA a borda ao tamanho (o `DecoratedBox` não soma): 66 + 24 + 1 = 91; a última, 90.
        return Container(
          key: ValueKey<String>(id),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: divider
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: AppStrokes.divider,
                      color: AppColors.divider,
                    ),
                  ),
                )
              : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: _gap,
            children: [
              cover,
              // O `<a>` inteiro (título + subtítulo): sem `semanticsLabel`, o nome do link é o texto do bloco.
              SizedBox(
                width: w.text,
                child: Pressable(
                  isLink: true,
                  onTap: onTap,
                  child: Column(
                    key: ValueKey<String>('$id.textBlock'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 3,
                    children: [
                      AppText(
                        book.title,
                        key: ValueKey<String>('$id.title'),
                        style: AppTextStyles.title15,
                        // Livro real: até 2 linhas (os do arquivo cabem).
                        maxLines: real ? 2 : null,
                        ellipsis: real,
                      ),
                      AppText(
                        subtitle,
                        key: ValueKey<String>('$id.subtitle'),
                        style: AppTextStyles.body13Muted,
                        maxLines: real ? 2 : null,
                        ellipsis: real,
                      ),
                    ],
                  ),
                ),
              ),
              // Selo: o texto quebra dentro desta largura ("Quero" / "ler" na linha 1 → selo 68,17 × 38,8).
              SizedBox(
                width: w.tag,
                child: Pill(
                  key: ValueKey<String>('$id.tag'),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  color: tagColor,
                  child: AppText(tagLabel, style: tagStyle),
                ),
              ),
              // Botão "mais opções": 44×44, transparente, sem borda; o ícone 20 (três pontos r 1,8).
              CircleIconButton(
                key: ValueKey<String>('$id.more'),
                size: _more,
                icon: AppSvg(
                  AppIcons.moreHorizontal,
                  size: 20,
                  key: ValueKey<String>('$id.more.icon'),
                ),
                onTap: onMore,
                semanticsLabel: HomeFormatters.moreOptionsAria(book),
              ),
            ],
          ),
        );
      },
    );
  }
}
