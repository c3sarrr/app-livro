// G15.3 — telas 27 e 27b, a folha do sumário (L27/L27b): véu sobre a página, folha a 10 das bordas com o topo em 112,
// alça, "Sumário" com o título do livro e o número de capítulos, × e as abas Capítulos e Marcadas. Abre sempre na aba
// Capítulos (D-154); os ids da prancha viram `bm.*` na aba Marcadas; trocar de aba e voltar deixa a lista onde estava.
// Abre e fecha em 150 ms subindo e descendo; fecha pelo ×, tocando no véu ou puxando pela alça (como a D-141): subir e
// puxar só movem a folha, sem refazer a lista. No Noite, as cores das ilhas (como a D-143). Sem dados ainda, só a
// moldura e as abas.
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/rendering.dart' show SemanticsRole;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/tap_target.dart';
import '../application/toc_view.dart';
import 'reader_chrome_palette.dart';
import 'reader_overlays.dart' show readerFade;
import 'reader_settings_sheet.dart'
    show
        readerSheetBottom,
        readerSheetDismissDrag,
        readerSheetDismissVelocity,
        readerSheetSide;
import 'toc_bookmarks.dart';
import 'toc_chapters.dart';

/// O topo da folha (L27: 112 — abaixo da barra de status em qualquer celular).
const double tocSheetTop = 112;

/// O véu sobre a página: `#1A1714` a 28 %.
const double tocVeilAlpha = 0.28;

enum TocTab { chapters, bookmarks }

class TocSheet extends StatefulWidget {
  const TocSheet({
    super.key,
    required this.open,
    required this.view,
    required this.palette,
    required this.brand,
    required this.onClose,
    required this.onChapter,
    required this.onBookmark,
    required this.onRibbon,
    this.onClub,
  });

  final bool open;

  /// O que a folha mostra; `null` antes da 1ª leitura (só a moldura e as abas).
  final TocView? view;

  /// As cores das ilhas (Noite — D-154).
  final ReaderChromePalette palette;
  final Color brand;
  final VoidCallback onClose;

  /// Tocar num capítulo ou numa parte (D-151).
  final ValueChanged<TocRow> onChapter;

  /// Tocar num cartão das Marcadas: abre a página (D-151).
  final ValueChanged<TocBookmarkCard> onBookmark;

  /// A fita do cartão: tira ou devolve a marca (D-152).
  final ValueChanged<TocBookmarkCard> onRibbon;

  /// A faixa do clube (até a G21, o aviso de "próxima fase" — D-149).
  final VoidCallback? onClub;

  @override
  State<TocSheet> createState() => _TocSheetState();
}

class _TocSheetState extends State<TocSheet> {
  /// Quanto o dedo puxou a folha para baixo pela alça (só a posição muda: a folha não é refeita).
  final ValueNotifier<double> _drag = ValueNotifier(0);
  TocTab _tab = TocTab.chapters;

  /// Onde a lista de Capítulos estava nesta abertura (a volta da aba Marcadas).
  double? _chaptersAt;

  /// A última vista: a folha desce com ela depois que a tela solta os dados.
  TocView? _last;

  @override
  void initState() {
    super.initState();
    _last = widget.view;
  }

  @override
  void didUpdateWidget(TocSheet old) {
    super.didUpdateWidget(old);
    if (widget.view != null) _last = widget.view;
    if (widget.open && !old.open) {
      _drag.value = 0;
      _tab = TocTab.chapters;
      _chaptersAt = null;
      _last = widget.view;
    }
  }

  @override
  void dispose() {
    _drag.dispose();
    super.dispose();
  }

  void _dragged(DragUpdateDetails d) =>
      _drag.value = math.max(0, _drag.value + d.delta.dy);

  void _released(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy;
    if (v >= readerSheetDismissVelocity ||
        (_drag.value >= readerSheetDismissDrag &&
            v > -readerSheetDismissVelocity)) {
      widget.onClose();
    } else {
      _drag.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.viewPaddingOf(context);
    final pre = _tab == TocTab.chapters ? 'toc' : 'bm';
    // a folha é montada aqui, fora da animação: subir, descer e puxar só a movem
    final sheet = Semantics(
      container: true,
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: 'Sumário',
      child: _Sheet(
        pre: pre,
        tab: _tab,
        view: _last,
        palette: widget.palette,
        brand: widget.brand,
        onTab: (t) => setState(() => _tab = t),
        onClose: widget.onClose,
        onDrag: _dragged,
        onRelease: _released,
        onChapter: widget.onChapter,
        onBookmark: widget.onBookmark,
        onRibbon: widget.onRibbon,
        onClub: widget.onClub,
        chaptersAt: _chaptersAt,
        onChaptersAt: (o) => _chaptersAt = o,
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: widget.open ? 1 : 0),
      duration: readerFade,
      child: sheet,
      builder: (context, a, child) {
        if (a == 0) return const SizedBox.shrink();
        return IgnorePointer(
          // fechando: os toques já vão para os controles que voltam
          ignoring: !widget.open,
          child: ExcludeSemantics(
            excluding: !widget.open,
            child: BlockSemantics(
              blocking: widget.open,
              child: Stack(
                children: [
                  // o véu: o toque fecha; a página não vira nem seleciona por baixo
                  Positioned.fill(
                    child: GestureDetector(
                      key: ValueKey('$pre.fade'),
                      behavior: HitTestBehavior.opaque,
                      excludeFromSemantics: true,
                      onTap: widget.onClose,
                      child: ColoredBox(
                        color: AppColors.ink.withValues(
                          alpha: tocVeilAlpha * a,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomSingleChildLayout(
                      delegate: _SheetPlace(
                        shown: a,
                        drag: _drag,
                        bottom: readerSheetBottom(pad),
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A folha entre o topo (112) e a base (como a da G14), subindo com [shown] e descendo com o [drag] (que reposiciona
/// sem refazer nada).
final class _SheetPlace extends SingleChildLayoutDelegate {
  _SheetPlace({required this.shown, required this.drag, required this.bottom})
    : super(relayout: drag);

  final double shown, bottom;
  final ValueListenable<double> drag;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints c) {
    final w = math.max(0.0, c.maxWidth - 2 * readerSheetSide);
    final h = math.max(0.0, c.maxHeight - tocSheetTop - bottom);
    return BoxConstraints.tightFor(width: w, height: h);
  }

  @override
  Offset getPositionForChild(Size size, Size child) {
    // fechada: toda abaixo da tela, com a sombra
    final away = size.height + AppShadows.drop4.dy;
    return Offset(
      readerSheetSide,
      tocSheetTop + (away - tocSheetTop) * (1 - shown) + drag.value,
    );
  }

  @override
  bool shouldRelayout(_SheetPlace old) =>
      old.shown != shown || old.drag != drag || old.bottom != bottom;
}

/// A folha (`toc.sheet` / `bm.sheet`): alça e cabeçalho (por onde se puxa para fechar), abas e a aba escolhida.
class _Sheet extends StatelessWidget {
  const _Sheet({
    required this.pre,
    required this.tab,
    required this.view,
    required this.palette,
    required this.brand,
    required this.onTab,
    required this.onClose,
    required this.onDrag,
    required this.onRelease,
    required this.onChapter,
    required this.onBookmark,
    required this.onRibbon,
    required this.onClub,
    required this.chaptersAt,
    required this.onChaptersAt,
  });

  final String pre;
  final TocTab tab;
  final TocView? view;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<TocTab> onTab;
  final VoidCallback onClose;
  final GestureDragUpdateCallback onDrag;
  final GestureDragEndCallback onRelease;
  final ValueChanged<TocRow> onChapter;
  final ValueChanged<TocBookmarkCard> onBookmark;
  final ValueChanged<TocBookmarkCard> onRibbon;
  final VoidCallback? onClub;
  final double? chaptersAt;
  final ValueChanged<double> onChaptersAt;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final v = view;
    return NeoBox(
      key: ValueKey('$pre.sheet'),
      color: p.island,
      border: line,
      radius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomLeft: Radius.circular(44),
        bottomRight: Radius.circular(44),
      ),
      shadow: AppShadows.drop4,
      shadowColor: p.shadow,
      padding: const EdgeInsets.only(top: 10),
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // a alça e o cabeçalho: puxar para baixo fecha
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onVerticalDragUpdate: onDrag,
              onVerticalDragEnd: onRelease,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      key: ValueKey('$pre.sheet.grabber'),
                      width: 40,
                      height: 5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: p.dash,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Header(
                    pre: pre,
                    subtitle: v?.subtitle ?? '',
                    palette: p,
                    onClose: onClose,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: _Tabs(
              pre: pre,
              tab: tab,
              chapters: v?.chapters,
              bookmarks: v?.bookmarks ?? 0,
              palette: p,
              brand: brand,
              onTab: onTab,
            ),
          ),
          Expanded(
            child: v == null
                ? const SizedBox.shrink()
                : tab == TocTab.chapters
                ? TocChapters(
                    view: v,
                    palette: p,
                    onChapter: onChapter,
                    onClub: onClub,
                    offset: chaptersAt,
                    onOffset: onChaptersAt,
                  )
                : TocBookmarks(
                    view: v,
                    palette: p,
                    onOpen: onBookmark,
                    onRibbon: onRibbon,
                  ),
          ),
        ],
      ),
    );
  }
}

/// "Sumário" (cabeçalho), "Dom Casmurro · 148 capítulos" e o × (`*.sheet.header`).
class _Header extends StatelessWidget {
  const _Header({
    required this.pre,
    required this.subtitle,
    required this.palette,
    required this.onClose,
  });

  final String pre;
  final String subtitle;
  final ReaderChromePalette palette;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Padding(
      key: ValueKey('$pre.sheet.header'),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              // a caixa dos textos tem a largura do maior (o subtítulo), como o `<span>` da prancha
              child: IntrinsicWidth(
                child: Column(
                  key: ValueKey('$pre.sheet.header.texts'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      container: true,
                      header: true,
                      child: AppText(
                        'Sumário',
                        key: ValueKey('$pre.sheet.title'),
                        style: AppTextStyles.readerTocTitle.copyWith(
                          color: p.title,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      subtitle,
                      key: ValueKey('$pre.sheet.subtitle'),
                      style: AppTextStyles.readerTocSubtitle.copyWith(
                        color: p.night ? p.muted : AppColors.inkMuted,
                      ),
                      maxLines: 1,
                      ellipsis: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          TapTarget(
            child: CircleIconButton(
              key: ValueKey('$pre.sheet.close'),
              size: 44,
              color: p.well,
              border: BorderSide(width: AppStrokes.regular, color: p.border),
              icon: AppSvg(
                AppIconsLeitor.closeRound,
                key: ValueKey('$pre.sheet.close.icon'),
                size: 18,
                color: p.night ? p.title : null,
              ),
              semanticsLabel: 'Fechar',
              onTap: onClose,
            ),
          ),
        ],
      ),
    );
  }
}

/// As abas (`*.sheet.tabs`, tablist): "Capítulos 148" e "▮ Marcadas 3"; a escolhida na `brand`.
class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.pre,
    required this.tab,
    required this.chapters,
    required this.bookmarks,
    required this.palette,
    required this.brand,
    required this.onTab,
  });

  final String pre;
  final TocTab tab;
  final int? chapters;
  final int bookmarks;
  final ReaderChromePalette palette;
  final Color brand;
  final ValueChanged<TocTab> onTab;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final onChapters = tab == TocTab.chapters;
    TextStyle text(bool on) =>
        (on ? AppTextStyles.readerTocTabOn : AppTextStyles.readerTocTab)
            .copyWith(color: on ? AppColors.ink : p.title);
    TextStyle count(bool on) => AppTextStyles.readerTocTabCount.copyWith(
      color: on
          ? AppColors.captionOnBrand
          : (p.night ? p.caption : AppColors.inkSoft),
    );
    return Semantics(
      container: true,
      role: SemanticsRole.tabBar,
      explicitChildNodes: true,
      child: NeoBox(
        key: ValueKey('$pre.sheet.tabs'),
        height: 46,
        color: p.well,
        border: BorderSide(width: AppStrokes.regular, color: p.border),
        radius: BorderRadius.circular(999),
        padding: const EdgeInsets.all(3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Tab(
                id: '$pre.sheet.tabs.chapters',
                on: onChapters,
                label: chapters == null ? 'Capítulos' : 'Capítulos $chapters',
                palette: p,
                brand: brand,
                onTap: () => onTab(TocTab.chapters),
                child: AppText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: chapters == null ? 'Capítulos' : 'Capítulos ',
                        style: text(onChapters),
                      ),
                      if (chapters != null)
                        TextSpan(text: '$chapters', style: count(onChapters)),
                    ],
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 3),
            Expanded(
              child: _Tab(
                id: '$pre.sheet.tabs.bookmarks',
                on: !onChapters,
                label: 'Marcadas $bookmarks',
                palette: p,
                brand: brand,
                onTap: () => onTab(TocTab.bookmarks),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppSvg(
                      AppIconsLeitor.ribbonCoral,
                      key: ValueKey('$pre.sheet.tabs.bookmarks.icon'),
                      size: 11,
                      height: 13,
                    ),
                    const SizedBox(width: 6),
                    AppText('Marcadas', style: text(!onChapters), maxLines: 1),
                    const SizedBox(width: 6),
                    AppText(
                      '$bookmarks',
                      key: ValueKey('$pre.sheet.tabs.bookmarks.count'),
                      style: count(!onChapters),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma aba (tab): a escolhida na `brand` com borda; a outra sem fundo (a borda transparente mantém o tamanho).
class _Tab extends StatelessWidget {
  const _Tab({
    required this.id,
    required this.on,
    required this.label,
    required this.palette,
    required this.brand,
    required this.onTap,
    required this.child,
  });

  final String id;
  final bool on;
  final String label;
  final ReaderChromePalette palette;
  final Color brand;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => TapTarget(
    role: SemanticsRole.tab,
    child: Semantics(
      container: true,
      role: SemanticsRole.tab,
      selected: on,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onTap,
        child: NeoBox(
          key: ValueKey(id),
          color: on ? brand : null,
          border: BorderSide(
            width: AppStrokes.regular,
            color: on ? palette.border : const Color(0x00000000),
          ),
          radius: BorderRadius.circular(999),
          child: Center(child: child),
        ),
      ),
    ),
  );
}
