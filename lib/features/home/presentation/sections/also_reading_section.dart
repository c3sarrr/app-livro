import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/painters/ring_progress_painter.dart';
import '../../../../core/design_system/text/app_text.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_icons_inicio.dart';
import '../../../../core/design_system/tokens/app_radii.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/design_system/widgets/app_svg.dart';
import '../../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../../core/design_system/widgets/count_badge.dart';
import '../../../../core/design_system/widgets/neo_box.dart';
import '../../../../core/design_system/widgets/pill.dart';
import '../../../../core/design_system/widgets/pressable.dart';
import '../../application/formatters.dart';
import '../../application/home_providers.dart';
import '../../domain/models.dart';
import '../covers/book_cover.dart';
import '../covers/bras_cubas_hat_cover.dart';
import '../covers/mrs_dalloway_cover.dart';
import '../covers/pride_prejudice_cover.dart';

/// Seção 4 — "Também lendo" (F06; prancha 01, L01a3): coluna com gap 30 (grande porque as capas sobem 22 px para
/// dentro dele) entre o cabeçalho (título + contador, gap 8, centralizados) e a grade de 2 colunas iguais com gap 12
/// (cards de 169). O livro de papel ganha a pílula "Papel · …" (D-252/D-253): 22 + 30 + 153,81 = 205,81 na 01 (o app
/// mede 205,80: a prancha arredonda as alturas a 2 casas); sem livro de papel, 175,6 como na v1. Nada recorta a grade
/// nem os cards.
class AlsoReadingSection extends ConsumerWidget {
  const AlsoReadingSection({super.key, this.onBookTap, this.onStartReadingTap});

  /// Card (ou a capa do livro de papel sem página) tocado (ligado a `/livro/:bookId` na F12).
  final ValueChanged<Book>? onBookTap;

  /// O "play" do livro de papel sem página (D-253): a Início passa o "sem ação" até o cronômetro da T04 (D-243 b).
  final ValueChanged<Book>? onStartReadingTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(homeSnapshotProvider.select((s) => s.alsoReading));
    assert(
      items.every((i) => i.book.cover is PhotoCover) ||
          _arts(items.take(2)) ==
              (CoverArt.mrsDalloway, CoverArt.pridePrejudice) ||
          _arts(items.take(2)) == (CoverArt.brasCubas, CoverArt.pridePrejudice),
      'As artes de capa do arquivo nesta seção: Mrs. Dalloway (v1) ou Brás Cubas (01) no card 1 e Orgulho e '
      'Preconceito no card 2.',
    );
    final onBookTap = this.onBookTap;
    final onStartReadingTap = this.onStartReadingTap;
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
          // `display: grid` estica os itens à altura da linha: um card com a pílula "Papel" e outro sem ficam iguais.
          IntrinsicHeight(
            child: Row(
              key: const ValueKey('alsoReading.grid'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                // Até 2 cartões (o contador mostra todos — D-85); com 1, o cartão fica na metade, como no arquivo.
                for (final (i, item) in items.take(2).indexed)
                  Expanded(
                    child: _BookCard(
                      id: 'alsoReading.card${i + 1}',
                      item: item,
                      onTap: onBookTap == null
                          ? null
                          : () => onBookTap(item.book),
                      onStartReading: onStartReadingTap == null
                          ? null
                          : () => onStartReadingTap(item.book),
                    ),
                  ),
                if (items.length == 1) const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static (CoverArt?, CoverArt?) _arts(Iterable<AlsoReadingItem> items) {
    CoverArt? art(AlsoReadingItem? i) => switch (i?.book.cover) {
      DesignedCover(:final art) => art,
      _ => null,
    };
    return (art(items.elementAtOrNull(0)), art(items.elementAtOrNull(1)));
  }
}

/// Card de 169 (= 1,5 + 59 + 12 + texto + 14 + 1,5; o texto é 35,6 sem a pílula e 65,81 com ela): fundo `#FFFAF1`,
/// borda 1,5, raio 22, padding 0/14/14 (sem padding no topo), sem sombra e sem recorte — a capa passa por cima da
/// borda. O e-book e o papel com página são um `<a>` inteiro (sem `semanticsLabel`: o nome é o texto do card, como no
/// navegador) com o anel; o papel sem página (D-253) é um `<div>`: a capa é o link (o título inteiro como nome) e o
/// "play" é um botão.
class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.id,
    required this.item,
    required this.onTap,
    required this.onStartReading,
  });

  /// Prefixo das Keys: `alsoReading.card1` / `alsoReading.card2`.
  final String id;
  final AlsoReadingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onStartReading;

  @override
  Widget build(BuildContext context) {
    final paper = item.format == BookFormat.physical;
    final play = paper && item.paperPage == null;
    final cover = _CoverSlot(id: '$id.cover', book: item.book);
    final card = NeoBox(
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
                if (play)
                  // <a aria-label="Memórias Póstumas de Brás Cubas">: a capa leva à página do livro.
                  Pressable(
                    isLink: true,
                    semanticsLabel: item.book.title,
                    onTap: onTap,
                    child: cover,
                  )
                else
                  cover,
                // margin-top 12 → o anel (ou o "play") ocupa 58 e, alinhado embaixo, começa 13 abaixo do topo.
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: play
                      ? CircleIconButton(
                          key: ValueKey('$id.play'),
                          size: 46,
                          color: AppColors.ink,
                          border: const BorderSide(
                            width: 1.5,
                            color: AppColors.ink,
                          ),
                          icon: AppSvg(
                            AppIconsInicio.play,
                            size: 18,
                            key: ValueKey('$id.play.icon'),
                          ),
                          onTap: onStartReading,
                          semanticsLabel: HomeFormatters.startReadingAria(
                            item.book,
                          ),
                        )
                      : _Ring(id: '$id.ring', progress: item.progress),
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
              // white-space: nowrap + text-overflow: ellipsis ("Orgulho e Precon…"); o título curto quando há
              // ("Brás Cubas").
              AppText(
                HomeFormatters.bookTitleShort(item.book),
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
              if (paper)
                Padding(
                  padding: const EdgeInsets.only(top: 6), // margin-top: 6
                  child: Align(
                    alignment: Alignment.centerLeft, // align-self: flex-start
                    child: _PaperMeta(id: '$id.meta', item: item),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
    return play
        ? card
        : Pressable(
            isLink: true, // <a href>
            onTap: onTap,
            child: card,
          );
  }
}

/// "Papel · 3h 40min" / "Papel · pág. 344" (D-252/D-253): fundo `#F7F0E3`, borda 1,2 `#E2D7C4`, raio 999, padding
/// 3/8/3/6, o livro de papel 12 e o texto Figtree 11,5/700 com gap 4, centralizados (22,21 de altura).
class _PaperMeta extends StatelessWidget {
  const _PaperMeta({required this.id, required this.item});

  final String id;
  final AlsoReadingItem item;

  @override
  Widget build(BuildContext context) {
    return Pill(
      key: ValueKey(id),
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      color: AppColors.paper,
      border: const BorderSide(width: 1.2, color: AppColors.markerRowBorder),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          AppSvg(AppIconsInicio.bookPaper, size: 12, key: ValueKey('$id.icon')),
          AppText(
            HomeFormatters.paperMeta(
              page: item.paperPage,
              readTime: item.readTime,
            ),
            style: AppTextStyles.paperMeta,
          ),
        ],
      ),
    );
  }
}

/// Capa 54×81 com `margin-top: −22`: ocupa 54×59 na linha e vaza 22 px para cima (o `OverflowBox` mantém o
/// tamanho de layout do CSS). `transform: rotate` em torno do centro, sem afetar o layout; a sombra 2/2
/// gira junto com a arte.
class _CoverSlot extends StatelessWidget {
  const _CoverSlot({required this.id, required this.book});

  /// `alsoReading.card1.cover` / `alsoReading.card2.cover`.
  final String id;
  final Book book;

  @override
  Widget build(BuildContext context) {
    final (cover, degrees) = switch (book.cover) {
      DesignedCover(art: CoverArt.mrsDalloway) => (
        const MrsDallowayCover(),
        -4.0,
      ),
      DesignedCover(art: CoverArt.brasCubas) => (
        const BrasCubasHatCover(),
        -4.0,
      ),
      DesignedCover(art: CoverArt.pridePrejudice) => (
        const PridePrejudiceCover(),
        3.0,
      ),
      // Livro real (D-79): a foto na moldura do arquivo, com a inclinação do cartão (1º −4°, 2º 3°).
      final PhotoCover c => (
        PhotoBookCover(book: book, cover: c, slot: CoverSlot.alsoReading),
        id.endsWith('card1.cover') ? -4.0 : 3.0,
      ),
      final other => throw ArgumentError.value(
        other,
        'cover',
        'sem arte em "Também lendo"',
      ),
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
