// G12.3 — ilha de cima dos controles (`r20.topIsland`, L20a): "Fechar o livro" (círculo 44), título e autor numa
// linha cada (com "…"), "Buscar no livro" e a fita do marcador (D-124: desmarcada = só o contorno), com o estado
// para o leitor de tela. Cores da tela 20 nos papéis claros e da 26b no Noite (`ReaderChromeScope`).
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/circle_icon_button.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import 'reader_chrome_scope.dart';

class TopIsland extends StatelessWidget {
  const TopIsland({
    super.key,
    required this.title,
    required this.author,
    required this.marked,
    required this.onClose,
    required this.onSearch,
    required this.onBookmark,
  });

  final String title, author;

  /// A página de referência mostrada tem marcador vivo.
  final bool marked;
  final VoidCallback onClose, onSearch, onBookmark;

  static String ribbon({required bool marked, required bool night}) =>
      switch ((marked, night)) {
        (true, false) => AppIconsLeitor.ribbonMarked,
        (true, true) => AppIconsLeitor.ribbonMarkedNight,
        (false, false) => AppIconsLeitor.ribbonEmpty,
        (false, true) => AppIconsLeitor.ribbonEmptyNight,
      };

  @override
  Widget build(BuildContext context) {
    final s = ReaderChromeScope.of(context);
    final p = s.palette;
    final night = p.night;
    final side = BorderSide(width: AppStrokes.regular, color: p.border);
    return NeoBox(
      key: const ValueKey('r20.topIsland'),
      height: 62,
      color: p.island,
      border: side,
      radius: BorderRadius.circular(31),
      shadow: AppShadows.hard3,
      shadowColor: p.shadow,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: 10,
        children: [
          CircleIconButton(
            key: const ValueKey('r20.topIsland.close'),
            size: 44,
            color: p.well,
            border: side,
            icon: AppSvg(
              night ? AppIconsLeitor.arrowLeftNight : AppIconsLeitor.arrowLeft,
              key: const ValueKey('r20.topIsland.close.icon'),
              size: 20,
              opacity: s.a,
            ),
            semanticsLabel: 'Fechar o livro',
            onTap: onClose,
          ),
          Expanded(
            child: Column(
              key: const ValueKey('r20.topIsland.titleBlock'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  key: const ValueKey('r20.topIsland.title'),
                  style: AppTextStyles.readerIslandTitle.copyWith(
                    color: p.title,
                  ),
                  maxLines: 1,
                  ellipsis: true,
                ),
                const SizedBox(height: 1),
                AppText(
                  author,
                  key: const ValueKey('r20.topIsland.author'),
                  style: AppTextStyles.readerIslandAuthor.copyWith(
                    color: p.muted,
                  ),
                  maxLines: 1,
                  ellipsis: true,
                ),
              ],
            ),
          ),
          Pressable(
            key: const ValueKey('r20.topIsland.search'),
            semanticsLabel: 'Buscar no livro',
            onTap: onSearch,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: AppSvg(
                  night ? AppIconsLeitor.searchNight : AppIconsLeitor.search,
                  key: const ValueKey('r20.topIsland.search.icon'),
                  size: 21,
                  opacity: s.a,
                ),
              ),
            ),
          ),
          Pressable(
            key: const ValueKey('r20.topIsland.bookmark'),
            semanticsLabel: 'Página marcada',
            toggled: marked,
            onTap: onBookmark,
            child: SizedBox.square(
              dimension: 44,
              child: Center(
                child: AppSvg(
                  ribbon(marked: marked, night: night),
                  key: const ValueKey('r20.topIsland.bookmark.icon'),
                  size: 22,
                  height: 24,
                  opacity: s.a,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
