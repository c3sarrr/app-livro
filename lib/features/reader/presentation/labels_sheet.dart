// G17 (D-177) — a folha "Rótulos", aberta pelo "Editar rótulos" do painel do marca-texto (no padrão da folha da nota:
// D-23, extrapolada com os tokens das ilhas): o cartão a 14 das bordas e 14 acima do teclado, sobre o véu, que segura
// os toques; "RÓTULOS", as 4 cores com a amostra e o campo (até 24, contando como o banco; a dica é o nome da cor) e
// Cancelar/Salvar. Salvar devolve os 4 textos sem os espaços das pontas (vazio = sem rótulo).
import 'package:flutter/material.dart'
    show InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/widgets.dart';

import '../../../core/design_system/color/color_names.dart';
import '../../../core/design_system/text/app_text.dart';
import '../../../core/design_system/tokens/app_shadows.dart';
import '../../../core/design_system/tokens/app_strokes.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/design_system/widgets/neo_box.dart';
import '../../../core/design_system/widgets/pressable.dart';
import '../annotations/ink/ink_stroke.dart' show argbOfHex;
import '../application/highlight_labels_store.dart'
    show highlightLabelMaxLength;
import 'note_sheet.dart' show NoteLengthLimit, noteSheetMargin;
import 'reader_chrome_palette.dart';

/// As chaves das 4 cores (os ids do arquivo).
const Map<String, String> _ids = {
  '#FED170': 'yellow',
  '#FFC1C6': 'pink',
  '#ABCF82': 'green',
  '#B6ACE4': 'lavender',
};

class LabelsSheet extends StatefulWidget {
  const LabelsSheet({
    super.key,
    required this.labels,
    required this.palette,
    required this.brand,
    required this.onCancel,
    required this.onSave,
  });

  /// Os rótulos de agora, pela cor.
  final Map<String, String> labels;
  final ReaderChromePalette palette;
  final Color brand;
  final VoidCallback onCancel;

  /// Os 4 textos, pela cor (vazio = sem rótulo).
  final ValueChanged<Map<String, String>> onSave;

  @override
  State<LabelsSheet> createState() => _LabelsSheetState();
}

class _LabelsSheetState extends State<LabelsSheet> {
  late final Map<String, TextEditingController> _fields = {
    for (final c in markerColors)
      c: TextEditingController(
        text: widget.labels[c] ?? widget.labels[c.toLowerCase()] ?? '',
      ),
  };

  @override
  void dispose() {
    for (final f in _fields.values) {
      f.dispose();
    }
    super.dispose();
  }

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
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: () {},
            child: ColoredBox(
              key: const ValueKey('ann.labels.veil'),
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
            label: 'Rótulos das cores',
            child: NeoBox(
              key: const ValueKey('ann.labels'),
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
                    'RÓTULOS',
                    key: const ValueKey('ann.labels.title'),
                    style: AppTextStyles.readerToolbarLabel.copyWith(
                      color: p.label,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 12),
                  for (final c in markerColors) ...[
                    _row(c, line),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    spacing: 10,
                    children: [
                      button(
                        'ann.labels.cancel',
                        'Cancelar',
                        p.island,
                        null,
                        widget.onCancel,
                      ),
                      button(
                        'ann.labels.save',
                        'Salvar',
                        widget.brand,
                        AppShadows.hard2,
                        () => widget.onSave({
                          for (final MapEntry(key: c, value: f)
                              in _fields.entries)
                            c: f.text.trim(),
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String color, BorderSide line) {
    final p = widget.palette;
    final id = _ids[color]!;
    final name = markerColorName(color)!;
    return Row(
      key: ValueKey('ann.labels.$id'),
      spacing: 10,
      children: [
        SizedBox.square(
          key: ValueKey('ann.labels.$id.swatch'),
          dimension: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(argbOfHex(color)),
              shape: BoxShape.circle,
              border: Border.all(width: AppStrokes.regular, color: p.border),
            ),
          ),
        ),
        Expanded(
          child: NeoBox(
            color: p.well,
            border: line,
            radius: BorderRadius.circular(14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Semantics(
              label: 'Rótulo do $name',
              child: Material(
                type: MaterialType.transparency,
                child: TextField(
                  key: ValueKey('ann.labels.$id.field'),
                  controller: _fields[color],
                  maxLines: 1,
                  inputFormatters: const [
                    NoteLengthLimit(highlightLabelMaxLength),
                  ],
                  style: AppTextStyles.readerNoteField.copyWith(color: p.title),
                  cursorColor: p.title,
                  decoration: InputDecoration.collapsed(
                    hintText: name,
                    hintStyle: AppTextStyles.readerNoteField.copyWith(
                      color: p.muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
