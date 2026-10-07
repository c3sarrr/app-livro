// G15.4 — a aba Marcadas da folha do sumário (tela 27b, L27b): as páginas marcadas na ordem do livro, cada uma num
// cartão com "pág. N", "cap. I · Do título", "você está aqui" na página de agora (com a sombra), o excerto em até 3
// linhas (D-49) e "marcada em 2 set"/"marcada hoje"; a fita no canto tira e devolve a marca (D-152: tirada, fica só o
// contorno até a folha fechar); o toque no cartão abre a página (D-151), e o leitor de tela lê o cartão inteiro
// (D-158); a dica no fim (sozinha, sem marcas). A lista rola por dentro. No Noite, as cores das ilhas (D-154).
import 'package:flutter/widgets.dart';

import '../../../core/design_system/painters/dashed_stadium_painter.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../application/toc_view.dart';
import 'reader_chrome_palette.dart';

/// A dica no fim da aba Marcadas.
const String tocBookmarksHint =
    'Toque na fita no alto do leitor para marcar ou desmarcar.';

class TocBookmarks extends StatelessWidget {
  const TocBookmarks({
    super.key,
    required this.view,
    required this.palette,
    required this.onOpen,
    required this.onRibbon,
  });

  final TocView view;
  final ReaderChromePalette palette;
  final ValueChanged<TocBookmarkCard> onOpen;
  final ValueChanged<TocBookmarkCard> onRibbon;

  @override
  Widget build(BuildContext context) {
    final cards = view.cards;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Páginas marcadas',
      child: SizedBox(
        key: const ValueKey('bm.sheet.bookmarks'),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cards.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    key: const ValueKey('bm.sheet.bookmarks.list'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _Card(
                          n: i + 1,
                          card: cards[i],
                          palette: palette,
                          onOpen: onOpen,
                          onRibbon: onRibbon,
                        ),
                      ],
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 18, 6, 0),
                child: _Hint(palette: palette),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um cartão (`bm.sheet.bookmarks.itemN`): o link com o cabeçalho, o excerto e a data; a fita de 44 no canto.
class _Card extends StatelessWidget {
  const _Card({
    required this.n,
    required this.card,
    required this.palette,
    required this.onOpen,
    required this.onRibbon,
  });

  final int n;
  final TocBookmarkCard card;
  final ReaderChromePalette palette;
  final ValueChanged<TocBookmarkCard> onOpen;
  final ValueChanged<TocBookmarkCard> onRibbon;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final id = 'bm.sheet.bookmarks.item$n';
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final c = card;
    final link = Column(
      key: ValueKey('$id.link'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: ValueKey('$id.head'),
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NeoBox(
                key: ValueKey('$id.head.page'),
                height: 26,
                color: p.well,
                border: line,
                radius: BorderRadius.circular(999),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  widthFactor: 1,
                  child: AppText(
                    'pág. ${c.page}',
                    key: ValueKey('$id.head.page.text'),
                    style: AppTextStyles.readerBmPage.copyWith(color: p.title),
                    maxLines: 1,
                  ),
                ),
              ),
              if (c.chapter != null)
                AppText(
                  c.chapter!,
                  key: ValueKey('$id.head.chapter'),
                  style: AppTextStyles.readerBmChapter.copyWith(
                    color: p.night ? p.label : AppColors.labelReader,
                  ),
                  maxLines: 1,
                  ellipsis: true,
                ),
              if (c.here)
                NeoBox(
                  key: ValueKey('$id.head.here'),
                  height: 22,
                  color: AppColors.flame,
                  border: BorderSide(width: 1.3, color: p.border),
                  radius: BorderRadius.circular(999),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Center(
                    widthFactor: 1,
                    child: AppText(
                      'você está aqui',
                      key: ValueKey('$id.head.here.text'),
                      style: AppTextStyles.readerBmHere,
                      maxLines: 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (c.excerpt case final e?) ...[
          const SizedBox(height: 9),
          AppText(
            e,
            key: ValueKey('$id.excerpt'),
            style: AppTextStyles.readerBmExcerpt.copyWith(
              color: p.night ? p.muted : AppColors.inkWarm,
            ),
            maxLines: 3,
            ellipsis: true,
          ),
        ],
        const SizedBox(height: 7),
        AppText(
          c.date,
          key: ValueKey('$id.date'),
          style: AppTextStyles.readerBmDate.copyWith(
            color: p.night ? p.caption : AppColors.inkSoft,
          ),
          maxLines: 1,
        ),
      ],
    );
    return KeyedSubtree(
      key: ValueKey(id),
      child: Stack(
        children: [
          NeoBox(
            key: ValueKey('$id.row'),
            color: p.island,
            border: line,
            radius: BorderRadius.circular(18),
            shadow: c.here ? AppShadows.hard2 : null,
            shadowColor: p.shadow,
            padding: const EdgeInsets.fromLTRB(14, 12, 52, 14),
            child: c.target == null
                ? link
                : Pressable(
                    onTap: () => onOpen(c),
                    semanticsLabel: c.spoken,
                    hint: 'Abrir na página ${c.page}',
                    child: link,
                  ),
          ),
          // a fita: 6 da direita e do alto, dentro da borda
          Positioned(
            right: 6 + AppStrokes.regular,
            top: 6 + AppStrokes.regular,
            child: Pressable(
              onTap: () => onRibbon(c),
              toggled: c.marked,
              semanticsLabel: c.marked
                  ? 'Tirar a marca da página ${c.page}'
                  : 'Marcar a página ${c.page}',
              child: SizedBox(
                key: ValueKey('$id.ribbon'),
                width: 44,
                height: 44,
                child: Center(
                  child: AppSvg(
                    c.marked
                        ? AppIconsLeitor.ribbonCoral
                        : (p.night
                              ? AppIconsLeitor.ribbonEmptyNight
                              : AppIconsLeitor.ribbonEmpty),
                    key: ValueKey('$id.ribbon.icon'),
                    size: 20,
                    height: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dica no fim (`bm.sheet.hint`): a fita num círculo tracejado e o texto.
class _Hint extends StatelessWidget {
  const _Hint({required this.palette});

  final ReaderChromePalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Row(
      key: const ValueKey('bm.sheet.hint'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          key: const ValueKey('bm.sheet.hint.iconWrap'),
          width: 30,
          height: 30,
          child: CustomPaint(
            painter: DashedStadiumPainter(color: p.border),
            child: const Center(
              child: AppSvg(
                AppIconsLeitor.ribbonHint,
                key: ValueKey('bm.sheet.hint.icon'),
                size: 11,
                height: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppText(
            tocBookmarksHint,
            key: const ValueKey('bm.sheet.hint.text'),
            style: AppTextStyles.readerBmHint.copyWith(
              color: p.night ? p.label : AppColors.labelReader,
            ),
          ),
        ),
      ],
    );
  }
}
