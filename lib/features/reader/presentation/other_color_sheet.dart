// G17 (D-178, R27) — a folha "Outra cor" da tela 21 (no padrão da folha da nota: D-23, extrapolada com os tokens das
// ilhas): o cartão a 14 das bordas e 14 acima do teclado, sobre o véu, que segura os toques; "OUTRA COR", o seletor
// de cor da tela 23 (D-38: roda, brilho e código) começando na cor dada (a última de grifo — D-130 — ou a do grifo
// tocado — D-132) e Cancelar/Grifar. Grifar devolve a cor escolhida; quem chama grifa pela D-32 (D-173) ou troca a
// cor do grifo.
import 'package:flutter/widgets.dart';

import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import 'color_picker.dart';
import 'note_sheet.dart' show noteSheetMargin;
import 'reader_chrome_palette.dart';
import 'reader_chrome_scope.dart';

class OtherColorSheet extends StatefulWidget {
  const OtherColorSheet({
    super.key,
    required this.initial,
    required this.palette,
    required this.brand,
    required this.onCancel,
    required this.onApply,
  });

  /// A cor de começo (`#RRGGBB`).
  final String initial;
  final ReaderChromePalette palette;
  final Color brand;
  final VoidCallback onCancel;

  /// "Grifar": a cor escolhida.
  final ValueChanged<String> onApply;

  @override
  State<OtherColorSheet> createState() => _OtherColorSheetState();
}

class _OtherColorSheetState extends State<OtherColorSheet> {
  late String _hex = widget.initial.toUpperCase();

  void _set(String hex) => setState(() => _hex = hex.toUpperCase());

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final line = BorderSide(width: AppStrokes.regular, color: p.border);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    Widget button(
      String key,
      String label,
      Color fill,
      Offset? shadow,
      VoidCallback onTap,
    ) => Expanded(
      child: Pressable(
        key: ValueKey(key),
        semanticsLabel: label,
        onTap: onTap,
        child: NeoBox(
          height: 44,
          color: fill,
          border: line,
          radius: BorderRadius.circular(999),
          shadow: shadow,
          shadowColor: p.shadow,
          child: Center(
            child: AppText(
              label,
              style: AppTextStyles.readerNoteButton.copyWith(color: p.title),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
    return ReaderChromeScope(
      palette: p,
      brand: widget.brand,
      a: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: () {},
              child: ColoredBox(
                key: const ValueKey('leitor.outraCor.veu'),
                color: p.veil,
              ),
            ),
          ),
          Positioned(
            left: noteSheetMargin,
            right: noteSheetMargin,
            bottom: keyboard + noteSheetMargin,
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              scopesRoute: true,
              namesRoute: true,
              label: 'Outra cor',
              child: NeoBox(
                key: const ValueKey('leitor.outraCor'),
                color: p.island,
                border: line,
                radius: BorderRadius.circular(28),
                shadow: AppShadows.hard3,
                shadowColor: p.shadow,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      'OUTRA COR',
                      key: const ValueKey('leitor.outraCor.titulo'),
                      style: AppTextStyles.readerToolbarLabel.copyWith(
                        color: p.label,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    ColorPicker(
                      color: _hex,
                      keyPrefix: 'leitor.outraCor.picker',
                      onChanged: _set,
                      onChangeEnd: _set,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      spacing: 10,
                      children: [
                        button(
                          'leitor.outraCor.cancelar',
                          'Cancelar',
                          p.island,
                          null,
                          widget.onCancel,
                        ),
                        button(
                          'leitor.outraCor.grifar',
                          'Grifar',
                          widget.brand,
                          AppShadows.hard2,
                          () => widget.onApply(_hex),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
