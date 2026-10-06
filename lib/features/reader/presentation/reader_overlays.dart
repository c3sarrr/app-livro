// G11.3/G12.3 — as pílulas por cima da página:
// - "← Voltar à pág. N" (D-108, D-119): no estilo do app (fundo da ilha, borda 1,5, sombra dura 2/2,
//   Figtree 12,5/800), centralizada na altura do rodapé, entre "pág." e "%";
// - "Chega numa próxima fase" (D-118): a mesma pílula, sem a seta, 12 acima da ilha de baixo, por 2 s.
// No Noite, com as cores da ilha do Noite (D-124). O "Fechar o livro" provisório da G11 (D-106) saiu: a ilha de
// cima tem o de verdade (D-117).
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../domain/reader_settings.dart';
import 'reader_chrome_palette.dart';
import 'reader_chrome_scope.dart';

/// Abrir e fechar os controles (D-124).
const Duration readerFade = Duration(milliseconds: 150);

/// Quanto o aviso "Chega numa próxima fase" fica na tela (D-118).
const Duration readerToastLife = Duration(seconds: 2);

/// O texto do aviso dos botões das próximas fases (D-118).
const String readerSoonText = 'Chega numa próxima fase';

class BackToPagePill extends StatelessWidget {
  const BackToPagePill({
    super.key,
    required this.refPage,
    required this.onTap,
    this.palette,
  });

  final int refPage;
  final VoidCallback onTap;

  /// As cores das ilhas do tema (`null` = as dos papéis claros).
  final ReaderChromePalette? palette;

  @override
  Widget build(BuildContext context) {
    final p = palette ?? ReaderChromePalette.of(ReaderPaper.creme);
    return Pressable(
      semanticsLabel: 'Voltar à pág. $refPage',
      onTap: onTap,
      child: _PillBox(
        key: const ValueKey('leitor.voltarDoLink'),
        palette: p,
        padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
        children: [
          AppSvg(
            p.night ? AppIconsLeitor.arrowLeftNight : AppIconsLeitor.arrowLeft,
            size: 16,
          ),
          AppText(
            'Voltar à pág. $refPage',
            style: AppTextStyles.readerPill.copyWith(color: p.title),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

/// "Chega numa próxima fase" (D-118). Com o leitor de tela, a tela anuncia o aviso quando ele aparece.
class ReaderToastPill extends StatelessWidget {
  const ReaderToastPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final s = ReaderChromeScope.of(context);
    return Semantics(
      container: true,
      child: _PillBox(
        key: const ValueKey('leitor.aviso'),
        palette: s.palette,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          AppText(
            text,
            style: AppTextStyles.readerPill.copyWith(color: s.palette.title),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _PillBox extends StatelessWidget {
  const _PillBox({
    super.key,
    required this.palette,
    required this.padding,
    required this.children,
  });

  final ReaderChromePalette palette;
  final EdgeInsets padding;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => NeoBox(
    color: palette.island,
    border: BorderSide(width: AppStrokes.regular, color: palette.border),
    radius: BorderRadius.circular(999),
    shadow: AppShadows.hard2,
    shadowColor: palette.shadow,
    padding: padding,
    child: Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: children),
  );
}
