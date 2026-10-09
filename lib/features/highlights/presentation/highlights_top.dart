// G19.3 — o topo da tela 25 (L25a): "Voltar ao livro" (círculo de 48 com sombra 2/2) e "Exportar" (pílula de 48),
// o título "Grifos e notas" (Bricolage 34 + Instrument Serif itálico 42) com a estrela decorativa, o subtítulo
// "‹título› · na ordem do livro" e a busca (pílula de 48 com a lupa e o campo; com texto, o "×" de 28 — D-203).
import 'package:flutter/material.dart'
    show InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/services.dart' show TextInputAction;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_colors.dart';
import '../../../core/design_system/tokens/app_icons_leitor.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/app_svg.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';

const BorderSide _line = BorderSide(
  width: AppStrokes.regular,
  color: AppColors.ink,
);

/// O texto do campo da busca (e o rótulo dele para o leitor de tela).
const String searchHint = 'Buscar nos grifos e notas';

class HighlightsTopBar extends StatelessWidget {
  const HighlightsTopBar({
    super.key,
    required this.onBack,
    required this.onExport,
  });

  final VoidCallback onBack;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('hl.topBar'),
    height: 48,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Pressable(
          semanticsLabel: 'Voltar ao livro',
          onTap: onBack,
          child: NeoBox(
            key: const ValueKey('hl.topBar.back'),
            width: 48,
            height: 48,
            color: AppColors.surface,
            border: _line,
            radius: BorderRadius.circular(24),
            shadow: const Offset(2, 2),
            child: const Center(
              child: AppSvg(
                AppIconsLeitor.arrowLeft,
                key: ValueKey('hl.topBar.back.icon'),
                size: 20,
              ),
            ),
          ),
        ),
        Pressable(
          semanticsLabel: 'Exportar grifos e notas',
          onTap: onExport,
          child: NeoBox(
            key: const ValueKey('hl.topBar.export'),
            height: 48,
            color: AppColors.surface,
            border: _line,
            radius: BorderRadius.circular(999),
            shadow: const Offset(2, 2),
            padding: const EdgeInsets.fromLTRB(13, 0, 16, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 7,
              children: [
                const AppSvg(
                  AppIconsLeitor.share,
                  key: ValueKey('hl.topBar.export.icon'),
                  size: 18,
                ),
                AppText('Exportar', style: AppTextStyles.hlExport, maxLines: 1),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// O título com a estrela (em 318,128 da prancha: 302,6 do título) e o subtítulo.
class HighlightsHeading extends StatelessWidget {
  const HighlightsHeading({super.key, required this.title});

  /// O título curto do livro ("Dom Casmurro").
  final String title;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Stack(
        clipBehavior: Clip.none,
        fit: StackFit.passthrough,
        children: [
          Semantics(
            header: true,
            child: AppText.rich(
              key: const ValueKey('hl.title'),
              TextSpan(
                children: [
                  TextSpan(text: 'Grifos ', style: AppTextStyles.hlTitle),
                  TextSpan(text: 'e notas', style: AppTextStyles.hlTitleSerif),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 302,
            top: 6,
            child: ExcludeSemantics(
              child: AppSvg(
                AppIconsLeitor.starDeco,
                key: ValueKey('hl.sparkle'),
                size: 22,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      AppText.rich(
        key: const ValueKey('hl.subtitle'),
        TextSpan(
          style: AppTextStyles.hlSubtitle,
          children: [
            TextSpan(text: title, style: AppTextStyles.hlSubtitleStrong),
            const TextSpan(text: ' · na ordem do livro'),
          ],
        ),
      ),
    ],
  );
}

/// A busca: a pílula de 48 com a lupa 20 e o campo (Figtree 15/600); com texto, o "×" de 28 (D-203). A ação do
/// teclado é "Buscar", que fecha o teclado.
class HighlightsSearch extends StatefulWidget {
  const HighlightsSearch({
    super.key,
    required this.query,
    required this.onQuery,
  });

  final String query;
  final ValueChanged<String> onQuery;

  @override
  State<HighlightsSearch> createState() => _HighlightsSearchState();
}

class _HighlightsSearchState extends State<HighlightsSearch> {
  late final TextEditingController _field = TextEditingController(
    text: widget.query,
  );
  final FocusNode _focus = FocusNode(debugLabel: 'hl.search');

  @override
  void didUpdateWidget(HighlightsSearch old) {
    super.didUpdateWidget(old);
    // "Limpar filtros" (D-198) apaga a busca por fora
    if (widget.query != _field.text) _field.text = widget.query;
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _clear() {
    _field.clear();
    widget.onQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final typed = _field.text.isNotEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: _focus.requestFocus,
      child: NeoBox(
        key: const ValueKey('hl.search'),
        height: 48,
        color: AppColors.surface,
        border: _line,
        radius: BorderRadius.circular(999),
        padding: EdgeInsets.fromLTRB(16, 0, typed ? 8.5 : 16, 0),
        child: Row(
          spacing: 10,
          children: [
            const AppSvg(
              AppIconsLeitor.searchGray,
              key: ValueKey('hl.search.icon'),
              size: 20,
            ),
            Expanded(
              child: SizedBox(
                key: const ValueKey('hl.search.input'),
                height: 45,
                child: Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: TextField(
                      key: const ValueKey('hl.search.field'),
                      controller: _field,
                      focusNode: _focus,
                      autocorrect: false,
                      enableSuggestions: false,
                      maxLines: 1,
                      textInputAction: TextInputAction.search,
                      onChanged: (q) {
                        widget.onQuery(q);
                        setState(() {});
                      },
                      style: AppTextStyles.hlSearch,
                      cursorColor: AppColors.ink,
                      decoration: InputDecoration.collapsed(
                        hintText: searchHint,
                        hintStyle: AppTextStyles.hlSearchPlaceholder,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (typed)
              Pressable(
                semanticsLabel: 'Limpar busca',
                onTap: _clear,
                child: NeoBox(
                  key: const ValueKey('hl.search.clear'),
                  width: 28,
                  height: 28,
                  color: AppColors.paper,
                  border: _line,
                  radius: BorderRadius.circular(14),
                  child: const Center(
                    child: AppSvg(AppIconsLeitor.closeRound, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
